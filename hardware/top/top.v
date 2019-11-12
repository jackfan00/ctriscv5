module top(
clk, cpurst,  interrupt, boot_addr
);
input clk, cpurst, interrupt;
input [31:0] boot_addr;

wire [63:0] instr_fromsram;
wire [31:0] dsram_rdata;
wire [31:3] isram_adr;
wire [31:0] dsram_addr ;
wire  dsram_cs   ;
wire  dsram_we   ;
wire [3:0] dsram_ben  ;
wire [31:0] dsram_wdata;


core core_u(
.clk                        (clk), 
.cpurst                     (cpurst),
.boot_addr                  (boot_addr),
.interrupt                  (interrupt),
.instr_fromsram             (instr_fromsram),
.dsram_rdata                (dsram_rdata               ),
// output port
.isram_cs                   (isram_cs),
.isram_adr                  (isram_adr),
.dsram_addr                 (dsram_addr                 ),
.dsram_cs                   (dsram_cs                   ),
.dsram_we                   (dsram_we                   ),
.dsram_ben                  (dsram_ben                  ),
.dsram_wdata                (dsram_wdata                )
);

isram #(16, 64) isram_u(
.clk(clk), 
.csn(~isram_cs), 
.wen(1'b1), 
.addr(isram_adr[18:3]), 
.din(64'b0), 
.dout(instr_fromsram)
);

dsram #(16, 4) dsram_u(
.clk(clk), 
.csn(~dsram_cs), 
.wen(~dsram_we), 
.addr(dsram_addr[17:2]), 
.ben (dsram_ben),
.din(dsram_wdata[31:0]), 
.dout(dsram_rdata[31:0])
);

endmodule
