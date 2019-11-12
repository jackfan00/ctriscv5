module dff_cell #(parameter DW=1)
( clk, d, q );
input clk;
input [DW-1:0] d;
output [DW-1:0] q;

reg [DW-1:0] q;
always @(posedge clk)
  begin
      q <= d;
  end
endmodule
