module dff_e_cell #(parameter DW=1)
( clk, en, d, q );
input  clk, en;
input [DW-1:0] d;
output [DW-1:0] q;

reg [DW-1:0] q;
always @(posedge clk )
  begin
    if (en)
      q <= d;
  end
endmodule
