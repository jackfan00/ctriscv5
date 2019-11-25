//
module tb_divrem();

reg clk, cpurst, diven_p;

initial begin
  $fsdbDumpfile("divrem.fsdb");
  $fsdbDumpvars;
//
clk=1'b0;
diven_p=1'b0;
cpurst=1'b1;
#1000;
cpurst=1'b0;
#1000;
@(posedge clk);
#1;
diven_p=1'b1;
@(posedge clk);
#1;
diven_p=1'b0;
#100000;
$finish;
end

always #10 clk = ~clk;

divrem_top divrem_top_u(
.clk      (clk     ), 
.cpurst   (cpurst  ),
.divider  (32'hffffffff), 
.dividend (32'h80000000),
.diven_p  (diven_p ),
.divsigned(1'b1)
);
endmodule