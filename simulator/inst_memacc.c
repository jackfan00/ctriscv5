#include "globalsig.h"
#include "memory.h"
#include "opcode_define.h"

void inst_memacc()
{
    mem_misaligned_exxeption =0;
    mem2wb_pc = ex2mem_pc_ffout;

    mem2wb_wr_regindex = ex2mem_wr_regindex_ffout;

    if (ex2mem_load_ffout){
        mem2wb_wr_wdata = readram_rdata;
    }
    else{   /**< sel from aluout / multout / divout */
        if (mul2mem_prod_complete_ffout){
            if (mul2mem_LO_ffout){
                mem2wb_wr_wdata = mult_LO_ffout;
            }
            else{
                mem2wb_wr_wdata = mult_HI_ffout;
            }

        }
        else{
            mem2wb_wr_wdata = ex2mem_wr_wdata_ffout;
        }

    }



    int mem_wr_memwdata;
    /**< STORE misaligned */
    if (mem_misaligned_exxeption_ffout){
        mem2wb_memaddr = mem2ex_memadr_ffout;
        mem2wb_mem_op = mem2ex_mem_op_ffout;
        mem_wr_memwdata = mem2ex_wr_memwdata_ffout;
    }
    else{
        mem2wb_memaddr = ex2mem_memaddr_ffout;
        mem2wb_mem_op = ex2mem_mem_op_ffout;
        mem_wr_memwdata = ex2mem_wr_memwdata_ffout;
    }

    /**< disable write reg when LOAD misaligned, until next cycle */
    if (load_misaligned_exxeption && mem2wb_mem_op){
        mem2wb_wr_reg =0;
    }
    else{
        mem2wb_wr_reg = ex2mem_wr_reg_ffout;
    }


    mem2wb_mem_en = ex2mem_mem_en_ffout;

    mem2wb_wr_mem = ex2mem_wr_mem_ffout;

    int byteaddr = mem2wb_memaddr & 0x03;
    unsigned int intaddr = (unsigned int) (mem2wb_memaddr >> 2);
    //
    /**< this is only for software implementation, in hardware should have byte-enable signal to support byte access*/
    int oldv = dataram[intaddr];


    if (ex2mem_mem_en_ffout){
        if (ex2mem_wr_mem_ffout){ /**< write memory, STORE */
            switch(mem2wb_mem_op)
            {
            case STORE_SB:  /**< no misaligned issue */
                switch(byteaddr)
                {
                case 0:
                    mem2wb_mem_wdata = (unsigned int)(oldv&0xffffff00 )+ (mem_wr_memwdata&0xff);
                    break;
                case 1:
                    mem2wb_mem_wdata = (unsigned int)(oldv&0xffff0000 )+ (oldv&0xff )+ ((mem_wr_memwdata&0xff)<<8);
                    break;
                case 2:
                    mem2wb_mem_wdata = (unsigned int)(oldv&0xff000000 )+ (oldv&0xffff )+ ((mem_wr_memwdata&0xff)<<16);
                    break;
                case 3:
                    mem2wb_mem_wdata = (oldv&0x00ffffff )+ (unsigned int)((mem_wr_memwdata&0xff)<<24);
                    break;
                }
                break;
            case STORE_SH:
                switch(byteaddr)
                {
                case 0:
                    mem2wb_mem_wdata = (oldv&0xffff0000 )+ (mem_wr_memwdata&0xffff);
                    break;
                case 1:
                    mem2wb_mem_wdata = (oldv&0xff000000 )+ (oldv&0xff )+ ((mem_wr_memwdata&0xffff)<<8);
                    break;
                case 2:
                    mem2wb_mem_wdata = (oldv&0x0000ffff )+ + ((mem_wr_memwdata&0xffff)<<16);
                    break;
                case 3:  /**< misaligned store , need 2 cycle to store mem */
                    mem2wb_mem_wdata = (oldv&0x00ffffff )+ (unsigned int)((mem_wr_memwdata&0xff)<<24);
                    mem2ex_memadr = ex2mem_memaddr_ffout+1;
                    mem2ex_mem_op = STORE_SB;
                    mem2ex_wr_memwdata = ((mem_wr_memwdata>>8)&0xff);
                    mem_misaligned_exxeption =1;
                    break;
                }
                break;
            case STORE_SW:
                switch(byteaddr)
                {
                case 0:
                    mem2wb_mem_wdata = mem_wr_memwdata;
                    break;
                case 1:
                    mem2wb_mem_wdata = (oldv&0xff)+ (unsigned int)((mem_wr_memwdata&0xffffff)<<8);
                    mem2ex_memadr = ex2mem_memaddr_ffout+3;
                    mem2ex_mem_op = STORE_SB;
                    mem2ex_wr_memwdata = (mem_wr_memwdata>>24)&0xff;
                    mem_misaligned_exxeption =1;
                    break;
                case 2:
                    mem2wb_mem_wdata = (oldv&0xffff )+ (unsigned int)(((mem_wr_memwdata)&0xffff)<<16);
                    mem2ex_memadr = ex2mem_memaddr_ffout+2;
                    mem2ex_mem_op = STORE_SH;
                    mem2ex_wr_memwdata = (mem_wr_memwdata>>16)&0xffff;
                    mem_misaligned_exxeption =1;
                    break;
                case 3:
                    mem2wb_mem_wdata = (oldv&0x00ffffff )+ (unsigned int)((mem_wr_memwdata&0xff) <<24);
                    mem2ex_memadr = ex2mem_memaddr_ffout+1;
                    mem2ex_mem_op = STORE_SHB;
                    mem2ex_wr_memwdata = (mem_wr_memwdata>>8)&0xffffff;
                    mem_misaligned_exxeption =1;
                    break;
                }

                break;
            case STORE_SHB:  /**< only for solve STORE_SW case3 misaligned */
                mem2wb_mem_wdata = (unsigned int)(oldv&0xff000000)+ (mem_wr_memwdata&0x00ffffff);
                break;


            }
        }

    }

    mem_stall = mem_misaligned_exxeption;
}
