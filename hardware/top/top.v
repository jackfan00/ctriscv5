module top(
clk, cpurst,  ext_int, boot_addr,
peri_w, peri_r, peri_addr, peri_wdat, peri_rdat, peri_ack
);
input clk, cpurst, ext_int;
input [31:0] boot_addr;
//
output peri_w, peri_r;
output [31:0] peri_addr, peri_wdat;
input [31:0] peri_rdat;
input peri_ack;

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
wire [31:0] clint_rdat;
wire clint_cs_ff;
wire periw_stall, perir_stall;
wire peri_cs;
reg peri_cs_ff;
reg [31:0] peri_rdat_ff;

wire [31:0] lr_sram_rdata;
core core_u(
.clk                        (clk), 
.cpurst                     (cpurst),
.boot_addr                  (boot_addr),
.periw_stall                (periw_stall                ), 
.perir_stall                (perir_stall                ),
.clint_timer_int            (clint_timer_int    ), 
.clint_soft_int             (clint_soft_int     ),
.ext_int                    (ext_int            ),
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
                       clint_cs_ff ? clint_rdat :
                       peri_cs_ff  ? peri_rdat_ff :
                        dsram_rdata ;
                        
//

clint clint_u(
.clk          (clk          ), 
.cpurst       (cpurst       ),
.lr_sram_we   (lr_sram_we   ), 
.lr_sram_cs   (lr_sram_cs   ),
.lr_sram_addr (lr_sram_addr ), 
.lr_sram_wdata(lr_sram_wdata),
//           (//           )
.timer_int    (clint_timer_int    ), 
.soft_int     (clint_soft_int     ),
.clint_rdat   (clint_rdat   ),
.clint_cs_ff  (clint_cs_ff  )
);

//
assign peri_cs = lr_sram_cs & (lr_sram_addr[31:24]==`PERIP_BASE);
assign peri_w = peri_cs & lr_sram_we;
assign peri_r = peri_cs & !lr_sram_we;
assign peri_addr = {8'b0,lr_sram_addr[23:0]};
assign peri_wdat = lr_sram_wdata;

//
assign periw_stall = peri_cs & lr_sram_we  & !peri_ack;
assign perir_stall = peri_cs & !lr_sram_we & !peri_ack;

always @(posedge clk)
begin
  if (cpurst)
    peri_cs_ff <= 1'b0;
  else
    peri_cs_ff <= peri_cs & !lr_sram_we & peri_ack;  
end

always @(posedge clk)
begin
  if (peri_cs & !lr_sram_we & peri_ack)
    peri_rdat_ff <= peri_rdat;  
end

endmodule
