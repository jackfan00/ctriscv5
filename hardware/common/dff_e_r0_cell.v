module dff_e_r0_cell #(parameter DW=1)
( rstz, clk, en, d, q );
input rstz, clk, en;
input [DW-1:0] d;
output [DW-1:0] q;

reg [DW-1:0] q;
always @(posedge clk or negedge rstz)
  begin
    if (~rstz)
      q <= {DW{1'b0}};
    else if (en)
      q <= d;
  end
endmodule
