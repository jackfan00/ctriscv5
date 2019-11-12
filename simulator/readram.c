#include "globalsig.h"
#include "regfile.h"
#include "opcode_define.h"
#include "memory.h"

void readram()
{
    load_misaligned_exxeption =0;

    int loaddata;
    /**< misaligned */
    int readram_addr;
    int readram_opmode;
    if (load_misaligned_exxeption_ffout){
        readram_addr = readram2ex_memaddr_ffout;
        readram_opmode =  readram2ex_mem_op_ffout;
    }
    else{
        readram_addr = ex2readram_addr_ffout;     /**< IN hardware, this mem readaddr should be inside ram, need combine with mem writeaddr */
        readram_opmode = ex2readram_opmode_ffout;
    }

    int byteaddr = readram_addr & 0x03;
    int memrdata = dataram[(unsigned int)(readram_addr>>2)];
    switch(readram_opmode)
    {
        case LOAD_LB:
        case LOAD_LBU:
            switch(byteaddr)
                {
                case 0:
                    loaddata = memrdata&0xff;
                    if (loaddata > 0x80 && readram_opmode==LOAD_LB){
                        loaddata = loaddata -256;
                    }
                    break;
                case 1:
                    loaddata = (memrdata>>8)&0xff;
                    if (loaddata > 0x80 && readram_opmode==LOAD_LB){
                        loaddata = loaddata -256;
                    }
                    break;
                case 2:
                    loaddata = (memrdata>>16)&0xff;
                    if (loaddata > 0x80 && readram_opmode==LOAD_LB){
                        loaddata = loaddata -256;
                    }
                    break;
                case 3:
                    loaddata = (memrdata>>24)&0xff;
                    if (loaddata > 0x80 && readram_opmode==LOAD_LB){
                        loaddata = loaddata -256;
                    }
                    break;
                }
            break;
        case LOAD_LH:
        case LOAD_LHU:
            switch(byteaddr)
                {
                case 0:
                    loaddata = memrdata&0xffff;
                    if (loaddata > 0x8000 && readram_opmode==LOAD_LH){
                        loaddata = loaddata -0x10000;
                    }
                    break;
                case 1:
                    loaddata = (memrdata>>8)&0xffff;
                    if (loaddata > 0x8000 && readram_opmode==LOAD_LH){
                        loaddata = loaddata -0x10000;
                    }
                    break;
                case 2:
                    loaddata = (memrdata>>16)&0xffff;
                    if (loaddata > 0x8000 && readram_opmode==LOAD_LH){
                        loaddata = loaddata -0x10000;
                    }
                    break;
                case 3:   /**< misaligned load, need 2 clock cycle */
                    readram_mis_tmprdat = (memrdata>>24)&0xff;
                    readram_mis_hytes =1;
                    readram2ex_memaddr = ex2readram_addr_ffout +1;
                    readram2ex_mem_op = LOAD_LBU;
                    load_misaligned_exxeption =1;
                    break;
                }
            break;
        case LOAD_LW:  /**< misaligned */
            switch(byteaddr)
                {
                case 0:
                    loaddata = memrdata;
                    break;
                case 1:
                    readram_mis_tmprdat = (memrdata>>8)&0xffffff;
                    readram_mis_hytes =1;
                    readram2ex_memaddr = ex2readram_addr_ffout +3;
                    readram2ex_mem_op = LOAD_LBU;
                    load_misaligned_exxeption =1;
                    break;
                case 2:
                    readram_mis_tmprdat = (memrdata>>16)&0xffff;
                    readram_mis_hytes =2;
                    readram2ex_memaddr = ex2readram_addr_ffout +2;
                    readram2ex_mem_op = LOAD_LHU;
                    load_misaligned_exxeption =1;
                    break;
                case 3:
                    readram_mis_tmprdat = (memrdata>>24)&0xff;
                    readram_mis_hytes =3;
                    readram2ex_memaddr = ex2readram_addr_ffout +1;
                    readram2ex_mem_op = LOAD_LHBU;
                    load_misaligned_exxeption =1;
                    break;

                }

            break;
            case LOAD_LHBU:  /**< only for solve LOAD_SW case3 misaligned */
                loaddata = (memrdata)&0xffffff;
                break;

    }




    int prev_readram_opmode = ex2readram_opmode_ffout;  /**< previous mem_op */
    if (ex2readram_mem_en_ffout){
        if (load_misaligned_exxeption_ffout){   /**< misaligned case */
            switch(readram_mis_hytes_ffout)
            {
            case 1:
                if (prev_readram_opmode == LOAD_LH){
                    readram_rdata = (loaddata<<8) + readram_mis_tmprdat_ffout;
                    readram_rdata = readram_rdata > (1<<15) ? readram_rdata - (1<<16) : readram_rdata;
                }
                else if (prev_readram_opmode==LOAD_LHU){
                    readram_rdata = (loaddata&0xff)<<8 + readram_mis_tmprdat_ffout;
                }
                else if (prev_readram_opmode==LOAD_LW){
                    readram_rdata = (unsigned int)((loaddata&0xff)<<24) + readram_mis_tmprdat_ffout;
                }
                break;
            case 2:  /**< prev mem_op is LOAD_LW */
                readram_rdata = (unsigned int)((loaddata&0xffff)<<16) + readram_mis_tmprdat_ffout;

                break;
            case 3:  /**< prev mem_op is LOAD_LW */
                readram_rdata = (unsigned int)((loaddata&0xffffff)<<8) + readram_mis_tmprdat_ffout;

                break;

            }
        }
        else{   /**< not misaligned case */
            readram_rdata = loaddata;
        }

    }


    readram_stall = load_misaligned_exxeption;

}
