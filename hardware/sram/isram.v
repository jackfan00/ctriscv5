module isram #(parameter AW=16, DW=64, BW=8)
(clk, csn0,csn1, wen, ben, addr, din, dout);

input clk, csn0,csn1, wen;
input [BW-1:0] ben;
input [AW-1:0] addr;
input [DW-1:0] din;
output [DW-1:0] dout;

//
wire [(DW>>1)-1:0] dout0, dout1;
dsram #(AW-1, (BW>>1)) dsram_u0(
.clk   (clk          ),
.csn   (csn0         ),
.wen   (wen          ),
.addr  (addr         ), 
.ben   (ben[(BW>>1)-1:0]     ),
.din   (din          ), 
.dout  (dout0         )
);

dsram #(AW-1, (BW>>1)) dsram_u1(
.clk   (clk          ),
.csn   (csn1         ),
.wen   (wen          ),
.addr  (addr         ), 
.ben   (ben[BW-1:(BW>>1)]     ),
.din   (din          ), 
.dout  (dout1         )
);

assign dout = {dout1, dout0};

/////////////
///////////reg [DW-1:0] mem[(1<<AW)-1:0];
///////////always @(posedge clk)
///////////begin
///////////  if (~csn & ~wen)
///////////    mem[addr] <= din;
///////////end
///////////
///////////reg [AW-1:0] a_latch;
///////////always @(posedge clk)
///////////begin
///////////  if (~csn)
///////////    a_latch <= addr;
///////////end
///////////
///////////assign dout = mem[a_latch];

endmodule
