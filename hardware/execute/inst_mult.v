//#include "inst_mult.h"
//#include "globalsig.h"
//#include "opcode_define.h"
module inst_mult(
clk, cpurst,
de2ex_inst_valid_ffout,
de2ex_MD_OP_ffout, de2ex_MD_OP,
de2ex_aluop_ffout, de2ex_aluop,
de2ex_rd_oprand1_ffout, de2ex_rd_oprand1,
de2ex_rd_oprand2_ffout, de2ex_rd_oprand2,
de2ex_rs1addr_ffout, de2ex_rs2addr_ffout, de2ex_wr_regindex_ffout,
de2ex_rs1addr, de2ex_rs2addr,
// output port
mul2mem_prod_complete_ffout,
mul2mem_HI_ffout, 
mul2mem_LO_ffout,
multprod_LO_ffout, 
multprod_HI_ffout,
mult_stall
);

input clk, cpurst;
input de2ex_inst_valid_ffout;
input de2ex_MD_OP_ffout, de2ex_MD_OP;
input [2:0] de2ex_aluop_ffout, de2ex_aluop;
input [31:0] de2ex_rd_oprand1_ffout, de2ex_rd_oprand1;
input [31:0] de2ex_rd_oprand2_ffout, de2ex_rd_oprand2;
input [4:0] de2ex_rs1addr_ffout, de2ex_rs2addr_ffout, de2ex_wr_regindex_ffout;
input [4:0] de2ex_rs1addr, de2ex_rs2addr;
// output port
output mul2mem_prod_complete_ffout;
output mul2mem_HI_ffout; 
output mul2mem_LO_ffout;
output [31:0] multprod_LO_ffout; 
output [31:0] multprod_HI_ffout;
output mult_stall;


reg [31:0] ex2mul_opr1,ex2mul_opr2;
reg mul2mem_LO, mul2mem_HI, mult_enable, mult_sign;
always @*
begin
    //if (de2ex_inst_valid_ffout && de2ex_MD_OP_ffout){
        ex2mul_opr1 =0;
        ex2mul_opr2 =0;
        mul2mem_LO =0;
        mul2mem_HI =0;
        mult_enable =0;
        case(de2ex_aluop_ffout)
        
        `ALU_MUL:
            begin
              ex2mul_opr1 = de2ex_rd_oprand1_ffout[31] ? ~de2ex_rd_oprand1_ffout+1'b1 : de2ex_rd_oprand1_ffout;
              ex2mul_opr2 = de2ex_rd_oprand2_ffout[31] ? ~de2ex_rd_oprand2_ffout+1'b1 : de2ex_rd_oprand2_ffout;
              mul2mem_LO =1;
              mult_enable =1;              
              mult_sign = de2ex_rd_oprand1_ffout[31] ^ de2ex_rd_oprand2_ffout[31];
            end
        `ALU_MULH:
            begin
              ex2mul_opr1 = de2ex_rd_oprand1_ffout[31] ? ~de2ex_rd_oprand1_ffout+1'b1 : de2ex_rd_oprand1_ffout;
              ex2mul_opr2 = de2ex_rd_oprand2_ffout[31] ? ~de2ex_rd_oprand2_ffout+1'b1 : de2ex_rd_oprand2_ffout;
              mul2mem_HI =1;
              mult_enable =1;
              mult_sign = de2ex_rd_oprand1_ffout[31] ^ de2ex_rd_oprand2_ffout[31];
            end
        `ALU_MULHSU:  //signed x unsigned
            begin
              ex2mul_opr1 = de2ex_rd_oprand1_ffout[31] ? ~de2ex_rd_oprand1_ffout+1'b1 : de2ex_rd_oprand1_ffout;              
              ex2mul_opr2 = de2ex_rd_oprand2_ffout;              
              mult_sign = de2ex_rd_oprand1_ffout[31];              
              mul2mem_HI =1;
              mult_enable =1;
            end
        `ALU_MULHU:  // unsigned x unsigned
            begin              
              ex2mul_opr1 = de2ex_rd_oprand1_ffout;
              ex2mul_opr2 = de2ex_rd_oprand2_ffout;              
              mul2mem_HI =1;
              mult_enable =1;
              mult_sign = 0;
            end
        //`ALU_DIV:
        //    ex2div_dividend = de2ex_rd_oprand1_ffout ;
        //    ex2div_divisor =  de2ex_rd_oprand2_ffout ;
        //    break;
        endcase
end  
    
reg [63:0] mult_prod_t, mult_prod;  
always @*
begin
  mult_prod_t = ex2mul_opr1 * ex2mul_opr2;
  mult_prod = mult_sign ? ~mult_prod_t + 1'b1 : mult_prod_t;    
end
  
wire mult_fuse_p, mult_fuse;
reg [1:0] mult_cycle_counter;
parameter MULT_INSTCLK_CYCLES =1;
reg mul2mem_prod_complete_ffout, mul2mem_HI_ffout, mul2mem_LO_ffout, mult_fuse_p_ffout;
always @(posedge clk)
begin
  if (cpurst)
    begin
      mul2mem_prod_complete_ffout <= 0;
      mul2mem_HI_ffout <= 0;
      mul2mem_LO_ffout <= 0;
      mult_fuse_p_ffout <= 0;
    end  
  else
    begin
      mul2mem_prod_complete_ffout <= (de2ex_inst_valid_ffout && de2ex_MD_OP_ffout && mult_enable && mult_cycle_counter==MULT_INSTCLK_CYCLES) || mult_fuse_p_ffout;  
      mul2mem_HI_ffout <= mul2mem_HI;
      mul2mem_LO_ffout <= mul2mem_LO;
      mult_fuse_p_ffout <= mult_fuse_p;
    end  
end

reg [31:0] multprod_LO_ffout, multprod_HI_ffout;
always @(posedge clk)
begin
  if (cpurst)
    begin
      multprod_LO_ffout <= 0;
      multprod_HI_ffout <= 0;      
    end
  else if ( de2ex_inst_valid_ffout && de2ex_MD_OP_ffout && mult_enable && mult_cycle_counter==MULT_INSTCLK_CYCLES && (!mult_fuse_p_ffout) )
    begin
      multprod_LO_ffout <= mult_prod[31:0];
      multprod_HI_ffout <= mult_prod[63:32];
    end
end


// fuse 2 inst : MULH[s][u] rdh, rs1, rs2, MUL rdl, rs1, rs2
assign mult_fuse = //(de2ex_rd_oprand1_ffout==de2ex_rd_oprand1) && (de2ex_rd_oprand2_ffout==de2ex_rd_oprand2) && 
                   de2ex_MD_OP_ffout && de2ex_MD_OP &&
                   (de2ex_rs1addr_ffout==de2ex_rs1addr) && (de2ex_rs2addr_ffout==de2ex_rs2addr) && 
                   (de2ex_rs1addr_ffout!=de2ex_wr_regindex_ffout) && (de2ex_rs2addr_ffout!=de2ex_wr_regindex_ffout) &&
                   (de2ex_aluop==`ALU_MUL) && ((de2ex_aluop_ffout==`ALU_MULH) || (de2ex_aluop_ffout==`ALU_MULHU) || (de2ex_aluop_ffout==`ALU_MULHSU));   
assign mult_fuse_p = mult_fuse & (!mult_stall);

assign mult_stall = de2ex_inst_valid_ffout && de2ex_MD_OP_ffout && mult_enable && (mult_cycle_counter<MULT_INSTCLK_CYCLES) && (!mult_fuse_p_ffout);

always @(posedge clk)
begin
  if (cpurst || (!mult_stall))
    begin
      mult_cycle_counter <= 0;
    end
  else if ( mult_stall )
    begin
      mult_cycle_counter <= mult_cycle_counter+1'b1;
    end
end

endmodule
