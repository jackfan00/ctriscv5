#include "inst_mult.h"
#include "globalsig.h"
#include "opcode_define.h"
void inst_mult()
{
    long long ex2mul_opr1,ex2mul_opr2;
    int mult_enable=0;
    if (de2ex_inst_valid_ffout && de2ex_MD_OP_ffout){
        switch(de2ex_aluop_ffout)
        {
        case ALU_MUL:
            ex2mul_opr1 = de2ex_rd_oprand1_ffout;
            ex2mul_opr2 = de2ex_rd_oprand2_ffout;
            mul2mem_LO =1;
            mult_enable =1;
            break;
        case ALU_MULH:
            ex2mul_opr1 = de2ex_rd_oprand1_ffout;
            ex2mul_opr2 = de2ex_rd_oprand2_ffout;
            mul2mem_LO =0;
            mult_enable =1;
            break;
        case ALU_MULHSU:
            ex2mul_opr1 = de2ex_rd_oprand1_ffout;
            if (de2ex_rd_oprand2_ffout<0){
                ex2mul_opr2 = (1<<32) + de2ex_rd_oprand2_ffout;
            }
            else{
                ex2mul_opr2 = de2ex_rd_oprand2_ffout;
            }

            mul2mem_LO =0;
            mult_enable =1;
            break;
        case ALU_MULHU:
            if (de2ex_rd_oprand1_ffout<0){
                ex2mul_opr1 = (1<<32) + de2ex_rd_oprand1_ffout;
            }
            else{
                ex2mul_opr1 = de2ex_rd_oprand1_ffout;
            }
            if (de2ex_rd_oprand2_ffout<0){
                ex2mul_opr2 = (1<<32) + de2ex_rd_oprand2_ffout;
            }
            else{
                ex2mul_opr2 = de2ex_rd_oprand2_ffout;
            }
            mul2mem_LO =0;
            mult_enable =1;
           break;
        //case ALU_DIV:
        //    ex2div_dividend = de2ex_rd_oprand1_ffout ;
        //    ex2div_divisor =  de2ex_rd_oprand2_ffout ;
        //    break;
        }
    }

    long long mult_prod=0;
    if (de2ex_inst_valid_ffout && de2ex_MD_OP_ffout && mult_enable){
        if (mult_cycle_counter==MULT_INSTCLK_CYCLES){
            mult_prod = ex2mul_opr1 * ex2mul_opr2;

            mul2mem_prod_complete =1;
            mult_LO = mult_prod & 0xffffffff;
            mult_HI = (mult_prod>>32) & 0xffffffff;
            mult_stall =0;
        }
        else{
            mult_prod =0;   /**< just simulate hardware pipeline intermediate result, for debug purpose */

            mul2mem_prod_complete =0;
            mult_LO =0;
            mult_HI =0;
            mult_stall=1;
        }

    }
    else{
        mult_stall =0;
        mul2mem_prod_complete =0;
    }



}
