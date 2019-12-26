module test_top;
`define ITCM top_u.isram_u
`define DTCM top_u.dsram_u
`define ITCM_SIZE 65536

`ifdef COMPLIANCE_TEST
`define PC_WRITE_TOHOST       32'h80000040    //compilance rv32i test
`define HAS_REFERENCEOUT
`elsif COMPLIANCEIMC_TEST
`define PC_WRITE_TOHOST       32'h80000036    //compilance rv32imc test
`define HAS_REFERENCEOUT
`else
`define PC_WRITE_TOHOST       32'h80000086  //e200 test
`endif

wire [31:0] fe2de_pc_ffout = top_u.core_u.fe2de_pc_ffout;
reg main_return_event;
reg [7:0] halt_count;

reg[8*300:1] testcase, referenceout;
reg [31:0] signature_startaddr, signature;
initial begin
  $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");  
  if($value$plusargs("TESTCASE=%s",testcase))begin
    $display("TESTCASE=%s",testcase);
  end  

`ifdef HAS_REFERENCEOUT
  if($value$plusargs("REFERENCEOUT=%s",referenceout))begin
    $display("REFERENCEOUT=%s",referenceout);
  end
  //  
  signature_startaddr = 32'h80002000;
  if($value$plusargs("SIGNATURE=%h",signature))begin
    //$display("SIGNATURE=%x",signature);
    if (signature!=0)
       signature_startaddr = signature;
  end  
  $display("SIGNATURE=%x",signature_startaddr);
`endif
end
integer i;
reg [7:0] itcm_mem [0:`ITCM_SIZE-1];
reg [31:0] signature_mem [0:255];
initial begin
  $readmemh({testcase, ".verilog"}, itcm_mem);
  for (i=0;i<`ITCM_SIZE;i=i+8) begin
      `ITCM.dsram_u0.mem0[i/8][7:0  ] = itcm_mem[i+0];
      `ITCM.dsram_u0.mem1[i/8][7:0  ] = itcm_mem[i+1];
      `ITCM.dsram_u0.mem2[i/8][7:0  ] = itcm_mem[i+2];
      `ITCM.dsram_u0.mem3[i/8][7:0  ] = itcm_mem[i+3];
      `ITCM.dsram_u1.mem0[i/8][7:0  ] = itcm_mem[i+4];
      `ITCM.dsram_u1.mem1[i/8][7:0  ] = itcm_mem[i+5];
      `ITCM.dsram_u1.mem2[i/8][7:0  ] = itcm_mem[i+6];
      `ITCM.dsram_u1.mem3[i/8][7:0  ] = itcm_mem[i+7];
  end
///  for (i=0;i<`ITCM_SIZE;i=i+4) begin
///      `DTCM.mem0[i/4][7:0  ] = itcm_mem[i+0];
///      `DTCM.mem1[i/4][7:0  ] = itcm_mem[i+1];
///      `DTCM.mem2[i/4][7:0  ] = itcm_mem[i+2];
///      `DTCM.mem3[i/4][7:0  ] = itcm_mem[i+3];
///  end
  $display("ITCM 0x00: %h", `ITCM.dsram_u0.mem0[0][7:0  ]);
  $display("ITCM 0x01: %h", `ITCM.dsram_u0.mem1[0][7:0  ]);
  $display("ITCM 0x02: %h", `ITCM.dsram_u0.mem2[0][7:0  ]);
  $display("ITCM 0x03: %h", `ITCM.dsram_u0.mem3[0][7:0  ]);
  $display("ITCM 0x04: %h", `ITCM.dsram_u1.mem0[0][7:0  ]);
  $display("ITCM 0x05: %h", `ITCM.dsram_u1.mem1[0][7:0  ]);
  $display("ITCM 0x06: %h", `ITCM.dsram_u1.mem2[0][7:0  ]);
  $display("ITCM 0x07: %h", `ITCM.dsram_u1.mem3[0][7:0  ]);
//  $display("ITCM 0x16: %h", `ITCM.mem[8'h16]);
//  $display("ITCM 0x20: %h", `ITCM.mem[8'h20]);

`ifdef HAS_REFERENCEOUT
  $readmemh({referenceout, ".reference_output"}, signature_mem);
`endif
end
//
reg clk, cpurst;
initial begin
//  $fsdbDumpfile("riscv_wind.fsdb");
//  $fsdbDumpvars;
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
  
`ifndef SOFTWARE_TEST  
#1000000;
  $display("TEST_FAIL::TIMEOUT");
  $finish;
`else
  #10000;
  @(main_return_event);  
  $finish;
`endif  
end
//
reg [31:0] fe2de_pc_ffout_d1;
always @(posedge clk)
begin
   fe2de_pc_ffout_d1 <= fe2de_pc_ffout;
end
always @(posedge clk)
begin 
  if(cpurst) begin
      halt_count <= 8'b0;
  end
  else if (fe2de_pc_ffout != fe2de_pc_ffout_d1)
  begin
      halt_count <= 8'b0;
  end
  else if (fe2de_pc_ffout == fe2de_pc_ffout_d1)
  begin
      halt_count <= halt_count + 1'b1;
  end
end
always @(posedge clk)
begin 
  if(cpurst) 
    main_return_event <= 1'b0;
  else if (halt_count==8'd100)
    main_return_event <= 1'b1;
end
//
reg [31:0] valid_ir_cycle;
reg [31:0] cycle_count;
always @(posedge clk)
begin 
  if(cpurst) begin
      cycle_count <= 32'b0;
  end
  else begin
      cycle_count <= cycle_count + 1'b1;
  end
end
wire de2ex_inst_valid = top_u.core_u.de2ex_inst_valid;
wire de2ex_stall      = top_u.core_u.ft_de_u.stall;
always @(posedge clk)
begin 
  if(cpurst) begin
      valid_ir_cycle <= 32'b0;
  end
  else if (de2ex_inst_valid & !de2ex_stall) 
   begin
      valid_ir_cycle <= valid_ir_cycle + 1'b1;
  end
end


reg [31:0] pc_write_to_host_cnt;
always @(posedge clk)
  begin
    if (cpurst)
      pc_write_to_host_cnt <=0;
    else if ((fe2de_pc_ffout == `PC_WRITE_TOHOST) & de2ex_inst_valid)
      pc_write_to_host_cnt <= pc_write_to_host_cnt+1'b1;
  end

wire [31:0] x3 = top_u.core_u.regfile_u.regfile_xx[3];
reg cpass, itcmen, dtcmen;
initial begin
#1000;
itcmen = 1'b0;
dtcmen = 1'b0;
@(pc_write_to_host_cnt == 32'd8);

`ifdef HAS_REFERENCEOUT
// check signature
$display("intercept write_tohost, generate signature file");
/////for (i=signature_startaddr;i>32'h20;i=i+4)
/////  begin
/////    if (`DTCM.mem0[i/4]===8'hxx) 
/////       i = 32'h0; //break;
/////    //$display("%02x%02x%02x%02x",`DTCM.mem3[i/4],`DTCM.mem2[i/4],`DTCM.mem1[i/4],`DTCM.mem0[i/4]);    
/////  end

cpass = 1'b1;  
itcmen = (signature_startaddr[31:24]==8'h80);
dtcmen = (signature_startaddr[31:24]==8'h90);

for (i=0;i<4096;i=i+4)
  begin
    if ((signature_mem[i/4]===32'hxxxxxxxx))// || !cpass)
      i= 6000; //break
    if (dtcmen)
      begin  
        if ( (signature_mem[i/4][7:0  ] !== `DTCM.mem0[(i+signature_startaddr[23:0])/4]) ||
             (signature_mem[i/4][15:8 ] !== `DTCM.mem1[(i+signature_startaddr[23:0])/4]) ||
             (signature_mem[i/4][23:16] !== `DTCM.mem2[(i+signature_startaddr[23:0])/4]) ||
             (signature_mem[i/4][31:24] !== `DTCM.mem3[(i+signature_startaddr[23:0])/4]) )
           cpass = 1'b0;  
        $display("ref:%08x -- simout:%02x%02x%02x%02x",
                signature_mem[i/4],
                `DTCM.mem3[(i+signature_startaddr)/4],`DTCM.mem2[(i+signature_startaddr)/4],
                `DTCM.mem1[(i+signature_startaddr)/4],`DTCM.mem0[(i+signature_startaddr)/4]);    
      end
    if (itcmen)
      begin  
        if ((i%8)==0)
          begin
            if ( (signature_mem[i/4][7:0  ] !== `ITCM.dsram_u0.mem0[(i/8+signature_startaddr[23:0]/8)]) ||
                 (signature_mem[i/4][15:8 ] !== `ITCM.dsram_u0.mem1[(i/8+signature_startaddr[23:0]/8)]) ||
                 (signature_mem[i/4][23:16] !== `ITCM.dsram_u0.mem2[(i/8+signature_startaddr[23:0]/8)]) ||
                 (signature_mem[i/4][31:24] !== `ITCM.dsram_u0.mem3[(i/8+signature_startaddr[23:0]/8)]) )
               cpass = 1'b0;  
            $display("ref:%08x -- simout:%02x%02x%02x%02x",
                    signature_mem[i/4],
                    `ITCM.dsram_u0.mem3[(i/8+signature_startaddr[23:0]/8)],`ITCM.dsram_u0.mem2[(i/8+signature_startaddr[23:0]/8)],
                    `ITCM.dsram_u0.mem1[(i/8+signature_startaddr[23:0]/8)],`ITCM.dsram_u0.mem0[(i/8+signature_startaddr[23:0]/8)]);  
          end        
        else
          begin
            if ( (signature_mem[i/4][7:0  ] !== `ITCM.dsram_u1.mem0[(i/8+signature_startaddr[23:0]/8)]) ||
                 (signature_mem[i/4][15:8 ] !== `ITCM.dsram_u1.mem1[(i/8+signature_startaddr[23:0]/8)]) ||
                 (signature_mem[i/4][23:16] !== `ITCM.dsram_u1.mem2[(i/8+signature_startaddr[23:0]/8)]) ||
                 (signature_mem[i/4][31:24] !== `ITCM.dsram_u1.mem3[(i/8+signature_startaddr[23:0]/8)]) )
               cpass = 1'b0;  
            $display("ref:%08x -- simout:%02x%02x%02x%02x",
                    signature_mem[i/4],
                    `ITCM.dsram_u1.mem3[(i/8+signature_startaddr[23:0]/8)],`ITCM.dsram_u1.mem2[(i/8+signature_startaddr[23:0]/8)],
                    `ITCM.dsram_u1.mem1[(i/8+signature_startaddr[23:0]/8)],`ITCM.dsram_u1.mem0[(i/8+signature_startaddr[23:0]/8)]);  
          end        
      end
  end
`endif
//
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~ Test Result Summary ~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~TESTCASE: %s ~~~~~~~~~~~~~", testcase);
        $display("~~~~~~~~~~~~~~Total cycle_count value: %d ~~~~~~~~~~~~~", cycle_count);
        $display("~~~~~~~~~~The valid Instruction Count: %d ~~~~~~~~~~~~~", valid_ir_cycle);
//        $display("~~~~~The test ending reached at cycle: %d ~~~~~~~~~~~~~", pc_write_to_host_cycle);
        $display("~~~~~~~~~~~~~~~The final x3 Reg value: %d ~~~~~~~~~~~~~", x3);
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
`ifdef HAS_REFERENCEOUT
    if (cpass) begin
`else
    if (x3 == 1) begin
`endif
        $display("~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end
    else begin
        $display("~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end
    #10
     $finish;
end

always #10 clk = ~clk;

wire ext_int = 1'b0;


wire [31:0] regrdat, peri_rdat;
wire peri_ack, regack;
wire [31:0] peri_addr, peri_wdat;
top top_u(
.clk      (clk      ), 
.cpurst   (cpurst   ), 
.ext_int  (ext_int  ),
.boot_addr(32'h8000_0000),
.peri_rdat(peri_rdat), 
.peri_ack (peri_ack ),
//
.peri_w   (peri_w   ), 
.peri_r   (peri_r   ), 
.peri_addr(peri_addr), 
.peri_wdat(peri_wdat)

);

wire regw = peri_w;
wire regr = peri_r;
wire [31:0] regadr = peri_addr;
wire [31:0] regwdata = peri_wdat;
assign peri_rdat = regrdat;
assign peri_ack = regack;

peri peri_u(
.clk   (clk   ), 
.rstz  (!cpurst  ),
.regw  (regw  ), 
.regr  (regr  ),
.adr   (regadr   ), 
.wdata (regwdata ),
//    (//    )
.ack   (regack   ),
.rdat  (regrdat  )

);


endmodule
