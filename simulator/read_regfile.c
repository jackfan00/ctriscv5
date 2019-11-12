#include "regfile.h"
#include "globalsig.h"
int read_regfile(int addr)
{
    /**< priority is important, otherwise function error in case (repeat r15 = r15 - r1) */
    int rdata;
    if (ex2mem_wr_regindex == addr && ex2mem_wr_reg ){  /**< ex/de data dependence , 1st priority*/
        rdata = ex2mem_wr_wdata;
    }
    else if (ex2mem_wr_regindex_ffout == addr && mem2wb_wr_reg){  /**< mem/de data dependence, 2nd priority */
        rdata = mem2wb_wr_wdata;
    }
    else if (mem2wb_wr_regindex_ffout == addr && mem2wb_wr_reg_ffout){  /**< wb/de data dependence, 3rd priority */
        rdata = mem2wb_wr_wdata_ffout;
    }
    else{
        rdata = regfile_x[addr];
    }
}
