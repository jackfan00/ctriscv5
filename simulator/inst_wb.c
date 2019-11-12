#include "globalsig.h"
#include "regfile.h"
#include "opcode_define.h"
#include "memory.h"

void inst_wb()
{
    wb2regfile_pc = mem2wb_pc_ffout;
    wb2regfile_wr_regindex = mem2wb_wr_regindex_ffout ;
    wb2regfile_wr_reg = mem2wb_wr_reg_ffout ;
    wb2regfile_wr_wdata = mem2wb_wr_wdata_ffout ;


}
