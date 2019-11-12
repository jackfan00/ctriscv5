module decode(

clk, cpurst,
de_stall, mem_stall, readram_stall, mult_stall,
fe2de_pc_ffout, fe2de_ir_ffout, rs1v, rs2v,
de2fe_branch, de2fe_branch_target,
de2ex_pc_ffout,
de2ex_wr_mem_ffout,
de2ex_mem_op_ffout,
de2ex_wr_memwdata_ffout,
de2ex_mem_en_ffout,
de2ex_load_ffout,
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
rs1_addr, rs2_addr

);
input clk, cpurst;
input de_stall, mem_stall, readram_stall, mult_stall;
input [31:0] fe2de_pc_ffout, fe2de_ir_ffout, rs1v, rs2v;

output de2fe_branch;
output [31:0] de2fe_branch_target;
output [31:0] de2ex_pc_ffout;
output de2ex_wr_mem_ffout ;
output de2ex_mem_op_ffout ;
output [31:0] de2ex_wr_memwdata_ffout ;
output de2ex_mem_en_ffout ;
output de2ex_load_ffout ;
output de2ex_rd_csrreg_ffout ;
output de2ex_wr_csrreg_ffout ;
output de2ex_MD_OP_ffout ;
output [31:0] de2ex_rd_oprand1_ffout ;
output [31:0] de2ex_rd_oprand2_ffout ;
output [2:0] de2ex_aluop_ffout ;
output [2:0] de2ex_aluop_sub_ffout ;
output de2ex_wr_reg_ffout ;
output [4:0] de2ex_wr_regindex_ffout ;
output de2ex_inst_valid_ffout ;
output [2:0] de2ex_csrop_ffout;
output [4:0] rs1_addr, rs2_addr;


wire [31:0] de2ex_pc;
wire de2ex_wr_mem ;
wire de2ex_mem_op ;
wire [31:0] de2ex_wr_memwdata ;
wire de2ex_mem_en ;
wire de2ex_load ;
wire de2ex_rd_csrreg ;
wire de2ex_wr_csrreg ;
wire de2ex_MD_OP ;
wire [31:0] de2ex_rd_oprand1 ;
wire [31:0] de2ex_rd_oprand2 ;
wire [2:0] de2ex_aluop ;
wire [2:0] de2ex_aluop_sub ;
wire de2ex_wr_reg ;
wire [4:0] de2ex_wr_regindex ;
wire de2ex_inst_valid ;
wire [2:0] de2ex_csrop;

inst_decode inst_decode_u(
.fe2de_pc_ffout(fe2de_pc_ffout),
.fe2de_ir_ffout(fe2de_ir_ffout),
.rs1v(rs1v), 
.rs2v(rs2v),
.de2ex_load_ffout(de2ex_load_ffout),
.de2ex_wr_regindex_ffout(de2ex_wr_regindex_ffout),
// output port
.de2fe_branch(de2fe_branch),
.de2fe_branch_target(de2fe_branch_target),
.de2ex_wr_mem(de2ex_wr_mem),
.de2ex_mem_op(de2ex_mem_op),
.de2ex_wr_memwdata(de2ex_wr_memwdata),
.de2ex_mem_en(de2ex_mem_en),
.de2ex_load(de2ex_load),
.de2ex_rd_csrreg(de2ex_rd_csrreg),
.de2ex_wr_csrreg(de2ex_wr_csrreg),
.de2ex_MD_OP(de2ex_MD_OP),
.de2ex_rd_oprand1(de2ex_rd_oprand1),
.de2ex_rd_oprand2(de2ex_rd_oprand2),
.de2ex_aluop(de2ex_aluop),
.de2ex_aluop_sub(de2ex_aluop_sub),
.de2ex_wr_reg(de2ex_wr_reg),
.de2ex_wr_regindex(de2ex_wr_regindex),
.de2ex_inst_valid(de2ex_inst_valid),
.de2ex_csrop(de2ex_csrop),
.de2ex_pc(de2ex_pc),
.de_stall(de_stall),
.rs1_addr(rs1_addr), 
.rs2_addr(rs2_addr)
);


de_ex de_ex_u(
.clk(clk), 
.cpurst(cpurst),
.de_stall(de_stall), 
.mem_stall(mem_stall), 
.readram_stall(readram_stall), 
.mult_stall(mult_stall),
.de2ex_pc(de2ex_pc),
.de2ex_wr_mem(de2ex_wr_mem),
.de2ex_mem_op(de2ex_mem_op),
.de2ex_wr_memwdata(de2ex_wr_memwdata),
.de2ex_mem_en(de2ex_mem_en),
.de2ex_load(de2ex_load),
.de2ex_rd_csrreg(de2ex_rd_csrreg),
.de2ex_wr_csrreg(de2ex_wr_csrreg),
.de2ex_MD_OP(de2ex_MD_OP),
.de2ex_rd_oprand1(de2ex_rd_oprand1),
.de2ex_rd_oprand2(de2ex_rd_oprand2),
.de2ex_aluop(de2ex_aluop),
.de2ex_aluop_sub(de2ex_aluop_sub),
.de2ex_wr_reg(de2ex_wr_reg),
.de2ex_wr_regindex(de2ex_wr_regindex),
.de2ex_inst_valid(de2ex_inst_valid),
.de2ex_csrop(de2ex_csrop),

// output port
.de2ex_pc_ffout(de2ex_pc_ffout),
.de2ex_wr_mem_ffout(de2ex_wr_mem_ffout),
.de2ex_mem_op_ffout(de2ex_mem_op_ffout),
.de2ex_wr_memwdata_ffout(de2ex_wr_memwdata_ffout),
.de2ex_mem_en_ffout(de2ex_mem_en_ffout),
.de2ex_load_ffout(de2ex_load_ffout),
.de2ex_rd_csrreg_ffout(de2ex_rd_csrreg_ffout),
.de2ex_wr_csrreg_ffout(de2ex_wr_csrreg_ffout),
.de2ex_MD_OP_ffout(de2ex_MD_OP_ffout),
.de2ex_rd_oprand1_ffout(de2ex_rd_oprand1_ffout),
.de2ex_rd_oprand2_ffout(de2ex_rd_oprand2_ffout),
.de2ex_aluop_ffout(de2ex_aluop_ffout),
.de2ex_aluop_sub_ffout(de2ex_aluop_sub_ffout),
.de2ex_wr_reg_ffout(de2ex_wr_reg_ffout),
.de2ex_wr_regindex_ffout(de2ex_wr_regindex_ffout),
.de2ex_inst_valid_ffout(de2ex_inst_valid_ffout),
.de2ex_csrop_ffout(de2ex_csrop_ffout)

);

endmodule
