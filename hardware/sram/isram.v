module isram #(parameter AW=16, DW=64)
(clk, csn, wen, addr, din, dout);

input clk, csn, wen;
input [AW-1:0] addr;
input [DW-1:0] din;
output [DW-1:0] dout;

//
reg [DW-1:0] mem[(1<<AW)-1:0];
always @(posedge clk)
begin
  if (~csn & ~wen)
    mem[addr] <= din;
end

reg [AW-1:0] a_latch;
always @(posedge clk)
begin
  if (~csn)
    a_latch <= addr;
end

assign dout = mem[a_latch];
endmodule
