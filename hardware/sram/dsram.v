module dsram #(parameter AW=16, BW=4)
(clk, csn, wen, ben, addr, din, dout);

input clk, csn, wen;
input [BW-1:0] ben;
input [AW-1:0] addr;
input [BW*8-1:0] din;
output [BW*8-1:0] dout;

//
reg [7:0] mem0[(1<<AW)-1:0];
reg [7:0] mem1[(1<<AW)-1:0];
reg [7:0] mem2[(1<<AW)-1:0];
reg [7:0] mem3[(1<<AW)-1:0];
//
///integer i;
///initial begin
///  for (i=0;i<(1<<AW);i=i+1)
///    begin
///      mem0[i] = 8'b0;
///      mem1[i] = 8'b0;
///      mem2[i] = 8'b0;
///      mem3[i] = 8'b0;
///    end
///end
//
always @(posedge clk)
begin
  if (~csn & ~wen)
    begin
      if (ben[0])
        mem0[addr] <= din[7:0];
      if (ben[1])
        mem1[addr] <= din[15:8];
      if (ben[2])
        mem2[addr] <= din[23:16];
      if (ben[3])
        mem3[addr] <= din[31:24];
    end
end

reg [AW-1:0] a_latch;
always @(posedge clk)
begin
  if (~csn)
    a_latch <= addr;
end

assign dout = {mem3[a_latch],mem2[a_latch],mem1[a_latch],mem0[a_latch]};
endmodule
