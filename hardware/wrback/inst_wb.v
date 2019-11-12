//#include "globalsig.h"
//#include "regfile.h"
//#include "opcode_define.h"
//#include "memory.h"

module inst_wb(
mem2wb_rd_is_x1_ffout,
mem2wb_rd_is_xn_ffout,
mem2wb_wr_regindex_ffout,
mem2wb_wr_reg_ffout,
mem2wb_wr_wdata_ffout,
mem2wb_wr_csrreg_ffout  ,
mem2wb_wr_csrindex_ffout,
mem2wb_wr_csrwdata_ffout,
mem2wb_exp_ffout, interrupt,

wb2regfile_wr_regindex,
wb2regfile_wr_reg,
wb2regfile_wr_wdata,
wb2regfile_rd_is_x1,
wb2regfile_rd_is_xn,
wb2csrfile_wr_reg     ,
wb2csrfile_wr_regindex,
wb2csrfile_wr_wdata   

);
input mem2wb_rd_is_x1_ffout;
input mem2wb_rd_is_xn_ffout;
input [4:0] mem2wb_wr_regindex_ffout;
input mem2wb_wr_reg_ffout;
input [31:0] mem2wb_wr_wdata_ffout;
input mem2wb_wr_csrreg_ffout  ;
input [11:0] mem2wb_wr_csrindex_ffout;
input [31:0] mem2wb_wr_csrwdata_ffout;
input mem2wb_exp_ffout , interrupt;

output [4:0] wb2regfile_wr_regindex;
output wb2regfile_wr_reg;
output [31:0] wb2regfile_wr_wdata;
output wb2regfile_rd_is_x1;
output wb2regfile_rd_is_xn;
output wb2csrfile_wr_reg      ;
output [11:0] wb2csrfile_wr_regindex; 
output [31:0] wb2csrfile_wr_wdata    ;


wire wb2csrfile_exporint = mem2wb_exp_ffout | interrupt;
//assign    wb2regfile_pc = mem2wb_pc_ffout;
assign    wb2regfile_wr_regindex = mem2wb_wr_regindex_ffout ;
assign    wb2regfile_wr_reg =  wb2csrfile_exporint ? 1'b0 :  mem2wb_wr_reg_ffout ;
assign    wb2regfile_wr_wdata = mem2wb_wr_wdata_ffout ;
assign    wb2regfile_rd_is_x1 = mem2wb_rd_is_x1_ffout;
assign    wb2regfile_rd_is_xn = mem2wb_rd_is_xn_ffout;

//csrfile
assign wb2csrfile_wr_reg      = wb2csrfile_exporint ? 1'b0 : mem2wb_wr_csrreg_ffout  ;
assign wb2csrfile_wr_regindex = mem2wb_wr_csrindex_ffout;
assign wb2csrfile_wr_wdata    = mem2wb_wr_csrwdata_ffout;

endmodule
