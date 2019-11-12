module de_ex(
clk, cpurst,
de_stall, exe_store_load_conflict, mem_stall, readram_stall, mult_stall, mem2wb_exp_ffout, interrupt, 
de2ex_pc,
de2ex_wr_mem,
de2ex_mem_op,
de2ex_wr_memwdata,
de2ex_mem_en,
de2ex_load,
de2ex_store,
de2ex_rd_csrreg,
de2ex_wr_csrreg,
de2ex_MD_OP,
de2ex_rd_oprand1,
de2ex_rd_oprand2,
de2ex_aluop,
de2ex_aluop_sub,
de2ex_wr_reg,
de2ex_wr_regindex,
de2ex_inst_valid,
de2ex_csrop,
de2ex_rd_is_x1,
de2ex_rd_is_xn,
de2ex_exp,
de2ex_mret,
de2ex_csr_index,
de2ex_rs1addr, de2ex_rs2addr,

de2ex_pc_ffout,
de2ex_wr_mem_ffout,
de2ex_mem_op_ffout,
de2ex_wr_memwdata_ffout,
de2ex_mem_en_ffout,
de2ex_load_ffout,
de2ex_store_ffout,
de2ex_rd_csrreg_ffout,
de2ex_wr_csrreg_ffout,
de2ex_MD_OP_ffout,
de2ex_rd_oprand1_ffout,
de2ex_rd_oprand2_ffout,
de2ex_aluop_ffout,
de2ex_aluop_sub_ffout,
de2ex_wr_reg_ffout,
de2ex_wr_regindex_ffout,
de2ex_inst_valid_ffout,
de2ex_csrop_ffout,
de2ex_rd_is_x1_ffout,
de2ex_rd_is_xn_ffout,
de2ex_exp_ffout,
de2ex_mret_ffout,
de2ex_csr_index_ffout,
de2ex_rs1addr_ffout, de2ex_rs2addr_ffout

);

input clk, cpurst;
input de_stall, exe_store_load_conflict, mem_stall, readram_stall, mult_stall, mem2wb_exp_ffout, interrupt;
input [31:0] de2ex_pc;
input de2ex_wr_mem ;
input [2:0] de2ex_mem_op ;
input [31:0] de2ex_wr_memwdata ;
input de2ex_mem_en ;
input de2ex_load, de2ex_store ;
input de2ex_rd_csrreg ;
input de2ex_wr_csrreg ;
input de2ex_MD_OP ;
input [31:0] de2ex_rd_oprand1 ;
input [31:0] de2ex_rd_oprand2 ;
input [2:0] de2ex_aluop ;
input [6:0] de2ex_aluop_sub ;
input de2ex_wr_reg ;
input [4:0] de2ex_wr_regindex ;
input de2ex_inst_valid ;
input [2:0] de2ex_csrop;
input de2ex_rd_is_x1;
input de2ex_rd_is_xn;
input de2ex_exp;
input de2ex_mret;
input [11:0] de2ex_csr_index;
input [4:0] de2ex_rs1addr, de2ex_rs2addr;

output [31:0] de2ex_pc_ffout;
output de2ex_wr_mem_ffout ;
output [2:0] de2ex_mem_op_ffout ;
output [31:0] de2ex_wr_memwdata_ffout ;
output de2ex_mem_en_ffout ;
output de2ex_load_ffout, de2ex_store_ffout ;
output de2ex_rd_csrreg_ffout ;
output de2ex_wr_csrreg_ffout ;
output de2ex_MD_OP_ffout ;
output [31:0] de2ex_rd_oprand1_ffout ;
output [31:0] de2ex_rd_oprand2_ffout ;
output [2:0] de2ex_aluop_ffout ;
output [6:0] de2ex_aluop_sub_ffout ;
output de2ex_wr_reg_ffout ;
output [4:0] de2ex_wr_regindex_ffout ;
output de2ex_inst_valid_ffout ;
output [2:0] de2ex_csrop_ffout;
output de2ex_rd_is_x1_ffout;
output de2ex_rd_is_xn_ffout;
output de2ex_exp_ffout;
output de2ex_mret_ffout;
output [11:0] de2ex_csr_index_ffout;
output [4:0] de2ex_rs1addr_ffout, de2ex_rs2addr_ffout;

//reg [31:0] de2ex_pc_ffout;
reg de2ex_wr_mem_ffout ;
reg [2:0] de2ex_mem_op_ffout ;
reg [31:0] de2ex_wr_memwdata_ffout ;
reg de2ex_mem_en_ffout ;
reg de2ex_load_ffout, de2ex_store_ffout ;
reg de2ex_rd_csrreg_ffout ;
reg de2ex_wr_csrreg_ffout ;
reg de2ex_MD_OP_ffout ;
reg [31:0] de2ex_rd_oprand1_ffout ;
reg [31:0] de2ex_rd_oprand2_ffout ;
reg [2:0] de2ex_aluop_ffout ;
reg [6:0] de2ex_aluop_sub_ffout ;
reg de2ex_wr_reg_ffout ;
reg [4:0] de2ex_wr_regindex_ffout ;
reg de2ex_inst_valid_ffout ;
reg [2:0] de2ex_csrop_ffout;
reg de2ex_rd_is_x1_ffout;
reg de2ex_rd_is_xn_ffout;
reg de2ex_exp_ffout;
reg de2ex_mret_ffout;
reg [11:0] de2ex_csr_index_ffout;
reg [4:0] de2ex_rs1addr_ffout, de2ex_rs2addr_ffout;

always @(posedge clk)
begin
    if (cpurst || 
          (de_stall==1 && exe_store_load_conflict==0 && mem_stall==0 && readram_stall==0 && mult_stall==0) || (mem2wb_exp_ffout || interrupt)) /**< insert dummy NOP command to flush pipeline */
      begin
          //de2ex_pc_ffout <= de2ex_pc;
          de2ex_aluop_ffout <= 0;
          de2ex_aluop_sub_ffout <= 0;
          de2ex_rd_oprand1_ffout <= 0;
          de2ex_rd_oprand2_ffout <= 0;
          de2ex_wr_reg_ffout <= 0;
          de2ex_wr_regindex_ffout <= 0;
          de2ex_inst_valid_ffout <= 1;
          de2ex_mem_op_ffout <= 0;
          de2ex_wr_mem_ffout <= 0;
          de2ex_mem_en_ffout <= 0;
          de2ex_wr_memwdata_ffout <= 0;
          de2ex_load_ffout <= 0;
          de2ex_store_ffout <= 0;
          de2ex_MD_OP_ffout <=0;
          de2ex_rd_csrreg_ffout <=0;
          de2ex_wr_csrreg_ffout <= 0;
          de2ex_csrop_ffout <= 0;
          de2ex_rd_is_x1_ffout <= 0;
          de2ex_rd_is_xn_ffout <= 0;
          de2ex_exp_ffout <= 0;
          de2ex_mret_ffout <= 0;
          de2ex_csr_index_ffout <= 0;
          de2ex_rs1addr_ffout <= 0;
          de2ex_rs2addr_ffout <= 0;
      end
    else if (exe_store_load_conflict==0 && mem_stall==0 && readram_stall==0 && mult_stall==0)
      begin
          //de2ex_pc_ffout <= de2ex_pc;
          de2ex_aluop_ffout <= de2ex_aluop;
          de2ex_aluop_sub_ffout <= de2ex_aluop_sub;
          de2ex_rd_oprand1_ffout <= de2ex_rd_oprand1;
          de2ex_rd_oprand2_ffout <= de2ex_rd_oprand2;
          de2ex_wr_reg_ffout <= de2ex_wr_reg;
          de2ex_wr_regindex_ffout <= de2ex_wr_regindex;
          de2ex_inst_valid_ffout <= de2ex_inst_valid;
          de2ex_mem_op_ffout <= de2ex_mem_op;
          de2ex_wr_mem_ffout <= de2ex_wr_mem;
          de2ex_mem_en_ffout <= de2ex_mem_en;
          de2ex_wr_memwdata_ffout <= de2ex_wr_memwdata;
          de2ex_load_ffout <= de2ex_load;
          de2ex_store_ffout <= de2ex_store;
          de2ex_MD_OP_ffout <= de2ex_MD_OP;
          de2ex_rd_csrreg_ffout <= de2ex_rd_csrreg;
          de2ex_wr_csrreg_ffout <= de2ex_wr_csrreg;
          de2ex_csrop_ffout <= de2ex_csrop;
          de2ex_rd_is_x1_ffout <= de2ex_rd_is_x1;
          de2ex_rd_is_xn_ffout <= de2ex_rd_is_xn;
          de2ex_exp_ffout <= de2ex_exp;
          de2ex_mret_ffout <= de2ex_mret;
          de2ex_csr_index_ffout <= de2ex_csr_index;
          de2ex_rs1addr_ffout <= de2ex_rs1addr;
          de2ex_rs2addr_ffout <= de2ex_rs2addr;

      end
end    

reg [31:0] de2ex_pc_ffout;
always @(posedge clk)
begin
   if (cpurst)
     de2ex_pc_ffout = 0;
   else
     de2ex_pc_ffout <= de2ex_pc;
end     
endmodule
