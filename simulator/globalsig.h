#ifndef GLOBALSIG_H_INCLUDED
#define GLOBALSIG_H_INCLUDED

int g_resetz;
int BOOTADDR;

int fe_pc;
int fe_pc_ffout;
int de2ex_pc;
int de2ex_pc_ffout;
int ex2mem_pc;
int ex2mem_pc_ffout;
int mem2wb_pc;
int mem2wb_pc_ffout;
int wb2regfile_pc;
int wb2regfile_pc_ffout;
int fe2de_pc;
int fe2de_pc_ffout;
int fe2de_ir;
int fe2de_ir_ffout;
int de2ex_aluop;
int de2ex_aluop_ffout;
int de2ex_aluop_sub;
int de2ex_aluop_sub_ffout;
int de2ex_rd_oprand1;
int de2ex_rd_oprand1_ffout;
int de2ex_rd_oprand2;
int de2ex_rd_oprand2_ffout;
int de2ex_wr_reg;
int de2ex_wr_reg_ffout;
int de2ex_wr_regindex;
int de2ex_wr_regindex_ffout;
int de2ex_inst_valid;
int de2ex_inst_valid_ffout;
int ex2mem_wr_reg;
int ex2mem_wr_reg_ffout;
int ex2mem_wr_regindex;
int ex2mem_wr_regindex_ffout;
int ex2mem_wr_wdata;
int ex2mem_wr_wdata_ffout;
int mem2wb_wr_reg;
int mem2wb_wr_reg_ffout;
int mem2wb_wr_regindex;
int mem2wb_wr_regindex_ffout;
int mem2wb_wr_wdata;
int mem2wb_wr_wdata_ffout;
int wb2regfile_wr_reg;
int wb2regfile_wr_regindex;
int wb2regfile_wr_wdata;
int de2ex_mem_op;
int de2ex_mem_op_ffout;
int de2ex_wr_mem;
int de2ex_wr_mem_ffout;
int de2ex_mem_en;
int de2ex_mem_en_ffout;
int de2ex_wr_memwdata;
int de2ex_wr_memwdata_ffout;
int de2ex_load;
int de2ex_load_ffout;
int de2ex_MD_OP;
int de2ex_MD_OP_ffout;

int ex2mem_memaddr;
int ex2mem_memaddr_ffout;
int ex2mem_wr_mem;
int ex2mem_wr_mem_ffout;
int ex2mem_wr_memwdata;
int ex2mem_wr_memwdata_ffout;
int ex2mem_mem_op;
int ex2mem_mem_op_ffout;
int ex2mem_mem_en;
int ex2mem_mem_en_ffout;
int ex2mem_load;
int ex2mem_load_ffout;
int ex2readram_mem_en;
int ex2readram_mem_en_ffout;
int ex2readram_addr;
int ex2readram_addr_ffout;
int ex2readram_opmode;
int ex2readram_opmode_ffout;

int mem2wb_memaddr;
int mem2wb_memaddr_ffout;
int mem2wb_mem_en;
int mem2wb_mem_en_ffout;
int mem2wb_mem_op;
int mem2wb_mem_op_ffout;
int mem2wb_wr_mem;
int mem2wb_mem_wdata;




int de2fe_branch;
int de2fe_branch_target;

int mem2ex_memadr;
int mem2ex_memadr_ffout;
int mem2ex_mem_op;
int mem2ex_mem_op_ffout;
int mem2ex_wr_memwdata;
int mem2ex_wr_memwdata_ffout;
int mem_stall;
int de_stall;
int readram_stall;
int fe_misaligned_exxeption;
int mem_misaligned_exxeption;
int mem_misaligned_exxeption_ffout;
int load_misaligned_exxeption;
int load_misaligned_exxeption_ffout;

int readram_mis_tmprdat;
int readram_mis_tmprdat_ffout;
int readram_mis_hytes;
int readram_mis_hytes_ffout;
int readram2ex_memaddr;
int readram2ex_memaddr_ffout;
int readram2ex_mem_op;
int readram2ex_mem_op_ffout;
int readram_rdata;

int mult_cycle_counter;
int mul2mem_prod_complete;
int mul2mem_prod_complete_ffout;
int mult_LO;
int mult_LO_ffout;
int mult_HI;
int mult_HI_ffout;
int mult_stall;
int mul2mem_LO;
int mul2mem_LO_ffout;


int de2ex_rd_csrreg;
int de2ex_wr_csrreg;
int de2ex_csrop;

#endif // GLOBALSIG_H_INCLUDED
