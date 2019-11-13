module test_top;
`define ITCM top_u.isram_u
`define ITCM_SIZE 16384
reg[8*300:1] testcase;
initial begin
  $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");  
  if($value$plusargs("TESTCASE=%s",testcase))begin
    $display("TESTCASE=%s",testcase);
  end  
end
integer i;
reg [7:0] itcm_mem [0:`ITCM_SIZE-1];
initial begin
  $readmemh({testcase, ".verilog"}, itcm_mem);
  for (i=0;i<`ITCM_SIZE;i=i+8) begin
      `ITCM.mem[i/8][7:0  ] = itcm_mem[i+0];
      `ITCM.mem[i/8][15:8 ] = itcm_mem[i+1];
      `ITCM.mem[i/8][23:16] = itcm_mem[i+2];
      `ITCM.mem[i/8][31:24] = itcm_mem[i+3];
      `ITCM.mem[i/8][39:32] = itcm_mem[i+4];
      `ITCM.mem[i/8][47:40] = itcm_mem[i+5];
      `ITCM.mem[i/8][55:48] = itcm_mem[i+6];
      `ITCM.mem[i/8][63:56] = itcm_mem[i+7];
  end
  //
  $display("ITCM 0x00: %h", `ITCM.mem[0][7:0  ]);
  $display("ITCM 0x01: %h", `ITCM.mem[0][15:8 ]);
  $display("ITCM 0x02: %h", `ITCM.mem[0][23:16]);
  $display("ITCM 0x03: %h", `ITCM.mem[0][31:24]);
  $display("ITCM 0x04: %h", `ITCM.mem[0][39:32]);
  $display("ITCM 0x05: %h", `ITCM.mem[0][47:40]);
  $display("ITCM 0x06: %h", `ITCM.mem[0][55:48]);
  $display("ITCM 0x07: %h", `ITCM.mem[0][63:56]);
//  $display("ITCM 0x16: %h", `ITCM.mem[8'h16]);
//  $display("ITCM 0x20: %h", `ITCM.mem[8'h20]);
end
//
reg clk, cpurst;
initial begin
  $fsdbDumpfile("riscv_wind.fsdb");
  $fsdbDumpvars;
  //
/////  $readmemh("romcode.hex", top_u.isram_u.mem);
/////  top_u.dsram_u.mem0[0] = 8'h01;
/////  top_u.dsram_u.mem1[0] = 8'h23;
/////  top_u.dsram_u.mem2[0] = 8'h45;
/////  top_u.dsram_u.mem3[0] = 8'h67;
/////
/////  top_u.dsram_u.mem0[1] = 8'h89;
/////  top_u.dsram_u.mem1[1] = 8'hab;
/////  top_u.dsram_u.mem2[1] = 8'hcd;
/////  top_u.dsram_u.mem3[1] = 8'hef;
  
  //
  cpurst=1'b1;
  clk=1'b0;
#100;
  cpurst=1'b0;
#1000000;
  $finish;
end

always #10 clk = ~clk;

wire interrupt = 1'b0;

top top_u(
.clk      (clk      ), 
.cpurst   (cpurst   ), 
.interrupt(interrupt),
.boot_addr(32'h0000_0000)
);
endmodule
