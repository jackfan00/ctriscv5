#include "globalsig.h"
#include "opcode_define.h"
#include <math.h>

unsigned int tounsigned(int i)
{
    long ui;
    long intmax = 1 << 32;
    if (i<0){
        ui = intmax + (long)i;
    }
    else
        ui = (long)i;

    return((unsigned int)ui);
}
void inst_execute()
{
    int alu_out=0;
    if (de2ex_inst_valid_ffout){


    switch(de2ex_aluop_ffout)
    {
    //case ALU_ADD:
    //case ALU_SUB:
    case ALU_ADDI:
        if (de2ex_aluop_sub_ffout==0x20)
            alu_out = de2ex_rd_oprand1_ffout - de2ex_rd_oprand2_ffout;
        else
            alu_out = de2ex_rd_oprand1_ffout + de2ex_rd_oprand2_ffout;
        break;
    //case ALU_SLL:
    case ALU_SLLI:
        alu_out = de2ex_rd_oprand1_ffout << (de2ex_rd_oprand2_ffout & 0x1f);
        break;
    //case ALU_SLT:
    case ALU_SLTI:
        alu_out = de2ex_rd_oprand1_ffout < de2ex_rd_oprand2_ffout;
        break;
    //case ALU_SLTU:
    case ALU_SLTIU:
        alu_out = tounsigned(de2ex_rd_oprand1_ffout) < tounsigned(de2ex_rd_oprand2_ffout);
        break;
     //case ALU_XOR:
    case ALU_XORI:
        alu_out = de2ex_rd_oprand1_ffout ^ de2ex_rd_oprand2_ffout;
        break;
    //case ALU_SRA
    //case ALU_SRAI
    //case ALU_SRL
    case ALU_SRLI:
        if (de2ex_aluop_sub_ffout==0x20)
        {
            int amt = (de2ex_rd_oprand2_ffout&0x1f);
            //int singed = de2ex_rd_oprand2_ffout >> 31;
            //int tmp = (singed << amt) -1;
            //int tmp2 = tmp << (32-amt);
            //alu_out = (de2ex_rd_oprand1_ffout >> amt) | tmp2 ;
            alu_out = (de2ex_rd_oprand1_ffout >> amt);
        }
        else
        {
            int amt = (de2ex_rd_oprand2_ffout&0x1f);
            int tmp = (1<<amt)-1;
            int tmp2 = tmp << (32-amt);
            int tmp3 = (de2ex_rd_oprand1_ffout >> amt);
            int tmp4 = (~tmp2);
            alu_out = tmp3 & tmp4;
        }

        break;
    //case ALU_OR:
    case ALU_ORI:
        alu_out = de2ex_rd_oprand1_ffout | de2ex_rd_oprand2_ffout;
        break;
    //case ALU_AND:
    case ALU_ANDI:
        alu_out = de2ex_rd_oprand1_ffout & de2ex_rd_oprand2_ffout;
        break;
    default:
        alu_out =0;
    }

    }
    //



    ex2mem_pc = de2ex_pc_ffout;
    ex2mem_wr_reg = de2ex_wr_reg_ffout;
    ex2mem_wr_regindex = de2ex_wr_regindex_ffout;
    ex2mem_wr_wdata = alu_out;

    /**< avoid read dataram[] array core dump, only for software purpose */
    if (de2ex_mem_en_ffout){
        if (mem_misaligned_exxeption){
            ex2mem_memaddr = mem2ex_memadr;
        }
        else{
            ex2mem_memaddr = alu_out;
        }

    }
    else{
        ex2mem_memaddr = 0;
    }

    ex2mem_wr_mem = de2ex_wr_mem_ffout;
    ex2mem_wr_memwdata = de2ex_wr_memwdata_ffout;
    if (mem_misaligned_exxeption){
        ex2mem_mem_op = mem2ex_mem_op;
    }
    else{
        ex2mem_mem_op = de2ex_mem_op_ffout;
    }

    ex2mem_mem_en = de2ex_mem_en_ffout;

    ex2readram_mem_en = de2ex_mem_en_ffout;

    ex2mem_load = de2ex_load_ffout;

    /**< seperate LOAD readram address to speed timing */
    /**< avoid read dataram[] array core dump, only for software purpose */
    if (de2ex_mem_en_ffout){
        ex2readram_addr = de2ex_rd_oprand1_ffout + de2ex_rd_oprand2_ffout;
    }
    else{
        ex2readram_addr =0;
    }

    ex2readram_opmode = de2ex_mem_op_ffout;

}
