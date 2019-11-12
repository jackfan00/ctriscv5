#include "globalsig.h"
#include "regfile.h"
#include "memory.h"
#include "opcode_define.h"

void inst_fetch()
{
    /**< next instruction pc */
    if (de2fe_branch){
        fe_pc = de2fe_branch_target;
        fe2de_ir = MCCODE_NOP;   /**< branch following inst is no effect, flushing it */
    }
    else{
        fe_pc = fe_pc_ffout + 4;    /**< regfile_pc equal to  fe_pc_ffout */
        fe2de_ir = rom[(fe_pc_ffout >>2)];
    }
    //
    fe2de_pc = fe_pc_ffout;  /**< regfile_pc equal to  fe_pc_ffout */


    if ((fe_pc_ffout&0x3)!=0){
        fe_misaligned_exxeption =1;
    }



}
