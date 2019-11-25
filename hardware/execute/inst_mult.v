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
//mul2mem_wr_wdata,
mult_stall,
div_stall,
div2mem_wr_wdata_ffout,
div2mem_divvalid_ffout,
ex2mem_mulvalid,
mul2mem_wr_wdata,
div2mem_divvalid,
div2mem_wr_wdata


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
//output [31:0] mul2mem_wr_wdata;
output mult_stall;
output div_stall;
output [31:0] div2mem_wr_wdata_ffout;
output div2mem_divvalid_ffout;
output ex2mem_mulvalid;
output [31:0] mul2mem_wr_wdata;
output div2mem_divvalid;
output [31:0] div2mem_wr_wdata;

reg [31:0] ex2mul_opr1,ex2mul_opr2, ex2div_dividend, ex2div_divider;
reg mul2mem_LO, mul2mem_HI, mult_enable, mult_sign;
reg ex2div_signed, ex2div_diven_p;
always @*
begin
    //if (de2ex_inst_valid_ffout && de2ex_MD_OP_ffout){
        ex2mul_opr1 =0;
        ex2mul_opr2 =0;
        mul2mem_LO =0;
        mul2mem_HI =0;
        mult_enable =0;
        ex2div_dividend =0;
        ex2div_divider =0;
        ex2div_signed = 0;
        ex2div_diven_p = 0;
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
        `ALU_DIV,
        `ALU_REM:
            begin              
              ex2div_dividend = de2ex_rd_oprand1_ffout ;
              ex2div_divider =  de2ex_rd_oprand2_ffout ;
              ex2div_signed = 1'b1;
              ex2div_diven_p = 1'b1;
            end
        `ALU_DIVU,
        `ALU_REMU:
            begin              
              ex2div_dividend = de2ex_rd_oprand1_ffout ;
              ex2div_divider =  de2ex_rd_oprand2_ffout ;
              ex2div_signed = 1'b0;
              ex2div_diven_p = 1'b1;
            end
        endcase
end  
    
reg [63:0] mult_prod_t, mult_prod;  
always @*
begin
  mult_prod_t = ex2mul_opr1 * ex2mul_opr2;
  mult_prod = mult_sign ? ~mult_prod_t + 1'b1 : mult_prod_t;    
end
  
wire de2ex_mult_fuse_p, de2ex_mult_fuse;
reg [1:0] mult_cycle_counter;
parameter MULT_INSTCLK_CYCLES =1;
reg mul2mem_prod_complete_ffout, mul2mem_HI_ffout, mul2mem_LO_ffout, de2ex_mult_fuse_p_ffout;

assign ex2mem_mulvalid = (de2ex_inst_valid_ffout && de2ex_MD_OP_ffout && mult_enable && mult_cycle_counter==MULT_INSTCLK_CYCLES) || de2ex_mult_fuse_p_ffout;

always @(posedge clk)
begin
  if (cpurst)
    begin
      mul2mem_prod_complete_ffout <= 0;
      mul2mem_HI_ffout <= 0;
      mul2mem_LO_ffout <= 0;
      de2ex_mult_fuse_p_ffout <= 0;
    end  
  else
    begin
      mul2mem_prod_complete_ffout <= ex2mem_mulvalid; //(de2ex_inst_valid_ffout && de2ex_MD_OP_ffout && mult_enable && mult_cycle_counter==MULT_INSTCLK_CYCLES) || de2ex_mult_fuse_p_ffout;  
      mul2mem_HI_ffout <= mul2mem_HI;
      mul2mem_LO_ffout <= mul2mem_LO;
      de2ex_mult_fuse_p_ffout <= de2ex_mult_fuse_p;
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
  else if ( de2ex_inst_valid_ffout && de2ex_MD_OP_ffout && mult_enable && mult_cycle_counter==MULT_INSTCLK_CYCLES && (!de2ex_mult_fuse_p_ffout) )
    begin
      multprod_LO_ffout <= mult_prod[31:0];
      multprod_HI_ffout <= mult_prod[63:32];
    end
end

assign mul2mem_wr_wdata = mul2mem_HI ? mult_prod[63:32] : mult_prod[31:0];


// fuse 2 inst : MULH[s][u] rdh, rs1, rs2, MUL rdl, rs1, rs2
assign de2ex_mult_fuse = //(de2ex_rd_oprand1_ffout==de2ex_rd_oprand1) && (de2ex_rd_oprand2_ffout==de2ex_rd_oprand2) && 
                   de2ex_MD_OP_ffout && de2ex_MD_OP &&
                   (de2ex_rs1addr_ffout==de2ex_rs1addr) && (de2ex_rs2addr_ffout==de2ex_rs2addr) && 
                   (de2ex_rs1addr_ffout!=de2ex_wr_regindex_ffout) && (de2ex_rs2addr_ffout!=de2ex_wr_regindex_ffout) &&
                   (de2ex_aluop==`ALU_MUL) && ((de2ex_aluop_ffout==`ALU_MULH) || (de2ex_aluop_ffout==`ALU_MULHU) || (de2ex_aluop_ffout==`ALU_MULHSU));   
assign de2ex_mult_fuse_p = de2ex_mult_fuse & (!mult_stall);

assign mult_stall = de2ex_inst_valid_ffout && de2ex_MD_OP_ffout && mult_enable && (mult_cycle_counter<MULT_INSTCLK_CYCLES) && (!de2ex_mult_fuse_p_ffout);

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

//
wire de2ex_div_fuse;
wire diven_p = ex2div_diven_p & !de2ex_div_fuse ; //use previous result in fuse case

wire [31:0] rem, quo;
divrem_top divrem_top_u(
.clk          (clk             ), 
.cpurst       (cpurst          ),
.divider      (ex2div_divider  ), 
.dividend     (ex2div_dividend ),
.diven_p      (diven_p         ),
.divsigned    (ex2div_signed   ),
//
.rem          (rem             ), 
.quo          (quo             ), 
.diven        (diven           ),
.divout_valid (divout_valid    )

);

assign de2ex_div_fuse = //(de2ex_rd_oprand1_ffout==de2ex_rd_oprand1) && (de2ex_rd_oprand2_ffout==de2ex_rd_oprand2) && 
                   de2ex_MD_OP_ffout && de2ex_MD_OP &&
                   (de2ex_rs1addr_ffout==de2ex_rs1addr) && (de2ex_rs2addr_ffout==de2ex_rs2addr) && 
                   (de2ex_rs1addr_ffout!=de2ex_wr_regindex_ffout) && (de2ex_rs2addr_ffout!=de2ex_wr_regindex_ffout) &&
                   (de2ex_aluop==`ALU_REM) && ((de2ex_aluop_ffout==`ALU_DIV) || (de2ex_aluop_ffout==`ALU_REMU) || (de2ex_aluop_ffout==`ALU_DIVU));   

wire de2ex_div_fuse_p = de2ex_div_fuse & (!div_stall);
reg de2ex_div_fuse_p_ffout;
reg div2mem_divvalid_ffout;
reg [31:0] div2mem_wr_wdata_ffout;
wire div2mem_divvalid;
wire [31:0] div2mem_wr_wdata;
always @(posedge clk)
begin
  if (cpurst)
    begin
      de2ex_div_fuse_p_ffout <= 0;
      div2mem_divvalid_ffout <= 0;
      div2mem_wr_wdata_ffout <= 0;
    end  
  else
    begin
      de2ex_div_fuse_p_ffout <= de2ex_div_fuse_p;
      div2mem_divvalid_ffout <= div2mem_divvalid;
      div2mem_wr_wdata_ffout <= div2mem_wr_wdata;
    end  
end

wire div_enable = diven | diven_p;
assign div_stall = de2ex_inst_valid_ffout && de2ex_MD_OP_ffout && div_enable &&  (!de2ex_div_fuse_p_ffout);

assign div2mem_divvalid = divout_valid | de2ex_div_fuse_p_ffout;
wire divop = (de2ex_aluop_ffout == `ALU_DIV) | (de2ex_aluop_ffout == `ALU_DIVU);
assign div2mem_wr_wdata = divop ? quo : rem;

endmodule
