module test_top;

reg clk, cpurst;
initial begin
  $fsdbDumpfile("riscv_wind.fsdb");
  $fsdbDumpvars;
  //
  $readmemh("romcode.hex", top_u.isram_u.mem);
  top_u.dsram_u.mem0[0] = 8'h01;
  top_u.dsram_u.mem1[0] = 8'h23;
  top_u.dsram_u.mem2[0] = 8'h45;
  top_u.dsram_u.mem3[0] = 8'h67;

  top_u.dsram_u.mem0[1] = 8'h89;
  top_u.dsram_u.mem1[1] = 8'hab;
  top_u.dsram_u.mem2[1] = 8'hcd;
  top_u.dsram_u.mem3[1] = 8'hef;
  
  //
  cpurst=1'b1;
  clk=1'b0;
#100;
  cpurst=1'b0;
#10000;
  $finish;
end

always #10 clk = ~clk;

wire interrupt = 1'b0;

top top_u(
.clk      (clk      ), 
.cpurst   (cpurst   ), 
.interrupt(interrupt),
.boot_addr(32'b0)
);
endmodule
