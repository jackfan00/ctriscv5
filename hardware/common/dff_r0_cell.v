module dff_r0_cell #(parameter DW=1)
( rstz, clk, d, q );
input rstz, clk;
input [DW-1:0] d;
output [DW-1:0] q;

reg [DW-1:0] q;
always @(posedge clk or negedge rstz)
  begin
    if (~rstz)
      q <= {DW{1'b0}};
    else
      q <= d;
  end
endmodule
