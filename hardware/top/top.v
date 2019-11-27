module top(
clk, cpurst,  interrupt, boot_addr
);
input clk, cpurst, interrupt;
input [31:0] boot_addr;
//
//input ext_ram_cs, ext_ram_we;
//input [31:0] ext_ram_addr;
//input [31:0] ext_ram_din;

wire [63:0] instr_fromsram;
wire [31:0] dsram_rdata;
wire [31:3] if_sram_adr;
wire [31:0] lr_sram_addr ;
wire  dsram_cs   ;
wire  dsram_we   ;
wire [3:0] lr_sram_ben  ;
wire [31:0] lr_sram_wdata;
wire lr_isram_cs;
reg lr_isram_cs_ff;

wire [31:0] lr_sram_rdata;
core core_u(
.clk                        (clk), 
.cpurst                     (cpurst),
.boot_addr                  (boot_addr),
.interrupt                  (interrupt),
.instr_fromsram             (instr_fromsram),
.dsram_rdata                (lr_sram_rdata               ),
.lr_isram_cs                (lr_isram_cs                 ),
.lr_isram_cs_ff             (lr_isram_cs_ff              ),
// output port
.isram_cs                   (if_sram_cs                   ),
.isram_adr                  (if_sram_adr                  ),
.dsram_addr                 (lr_sram_addr                 ),
.dsram_cs                   (lr_sram_cs                   ),
.dsram_we                   (lr_sram_we                   ),
.dsram_ben                  (lr_sram_ben                  ),
.dsram_wdata                (lr_sram_wdata                )
);

//
wire lr_dsram_cs = lr_sram_cs & (lr_sram_addr[31:24] == `DTCM_BASE );
wire lr_dsram_we = lr_dsram_cs & lr_sram_we;
//
assign lr_isram_cs = lr_sram_cs & (lr_sram_addr[31:24] == `ITCM_BASE );
wire lr_isram_we = lr_isram_cs & lr_sram_we;
//
//
wire [31:0] isram_adr = lr_isram_cs ? lr_sram_addr : {if_sram_adr,3'b0};
wire isram_cs0 = lr_isram_cs ? lr_sram_cs & (!lr_sram_addr[2]) : if_sram_cs;
wire isram_cs1 = lr_isram_cs ? lr_sram_cs &   lr_sram_addr[2]  : if_sram_cs;
wire isram_we = lr_isram_cs ? lr_sram_we : 1'b0;
wire [7:0] isram_ben = lr_isram_cs ? (lr_sram_addr[2] ? {lr_sram_ben,4'b0} : {4'b0,lr_sram_ben}) : 8'hff;
wire [31:0] isram_din = lr_isram_cs ? lr_sram_wdata : 32'h0;
//
isram #(16, 64, 8) isram_u(
.clk(clk), 
.csn0(~isram_cs0), 
.csn1(~isram_cs1), 
.wen(~isram_we), 
.addr(isram_adr[18:3]), 
.ben(isram_ben),
.din({isram_din,isram_din}), 
.dout(instr_fromsram)
);

//
assign dsram_cs = lr_dsram_cs ? lr_sram_cs : 1'b0;
assign dsram_we = lr_dsram_cs ? lr_sram_we : 1'b0;
wire [31:0] dsram_addr = lr_dsram_cs ? lr_sram_addr : 32'b0;
wire [31:0] dsram_wdata = lr_dsram_cs ? lr_sram_wdata : 32'b0;
wire [3:0] dsram_ben = lr_dsram_cs ? lr_sram_ben : 4'b0;

//
dsram #(16, 4) dsram_u(
.clk(clk), 
.csn(~dsram_cs), 
.wen(~dsram_we), 
.addr(dsram_addr[17:2]), 
.ben (dsram_ben),
.din(dsram_wdata[31:0]), 
.dout(dsram_rdata[31:0])
);

//
always @(posedge clk)
begin
  if (cpurst)
    lr_isram_cs_ff <= 1'b0;
  else
    lr_isram_cs_ff <= lr_isram_cs;  
end
reg selh;
always @(posedge clk)
begin
  selh <= isram_adr[2];
end
wire [31:0] rdat = selh ? instr_fromsram[63:32] : instr_fromsram[31:0];

assign lr_sram_rdata = lr_isram_cs_ff ? rdat : 
                        dsram_rdata ;
endmodule
