#include "globalsig.h"
#include "opcode_define.h"
#include "regfile.h"

void inst_decode()
{
    int opcode = fe2de_ir_ffout & 0x7f;
    int func3 = (fe2de_ir_ffout >> 12) & 0x07;
    int func7 = (fe2de_ir_ffout >> 25) & 0x3f;
    int rs1 = (fe2de_ir_ffout >> 15) & 0x1f;
    int zimm = rs1;
    int rs2 = (fe2de_ir_ffout >> 20) & 0x1f;
    int rs1v = read_regfile(rs1);
    int rs2v = read_regfile(rs2);
    int rd = (fe2de_ir_ffout >> 7) & 0x1f;
    int imm = (fe2de_ir_ffout >> 20) & 0xfff;  ///**< signed value */
    int csrindex = imm;
    if (imm > 0x7ff)
    {
        imm = imm - 4096;
    }
    int LUIimm = (fe2de_ir_ffout & 0xfffff000);  ///**< msb[31:12] */
    int JALimm = (((fe2de_ir_ffout>>31)&0x1) << 20 ) +  (((fe2de_ir_ffout>>12)&0xff) << 12 ) + (((fe2de_ir_ffout>>20)&0x1) << 11 ) + (((fe2de_ir_ffout>>21)&0x3ff) << 1 );
    if (JALimm >=(1<<20)){
        JALimm = JALimm - (1<<21);
    }
    int JALRimm = (((fe2de_ir_ffout>>20) + rs1v) >>1) <<1;   /**< set b0=0 */
    int Bimm = (((fe2de_ir_ffout>>31)&0x1) << 12 ) +  (((fe2de_ir_ffout>>7)&0x1) << 11 ) + (((fe2de_ir_ffout>>25)&0x3f) << 5 ) + (((fe2de_ir_ffout>>8)&0xf) << 1 );
    if (Bimm >=(1<<12)){
        Bimm = Bimm - (1<<13);
    }
    int Storeimm = (((fe2de_ir_ffout>>25)&0x7f) << 5 ) +  ((fe2de_ir_ffout>>7)&0x1f)   ;
    if (Storeimm >=(1<<11)){
        Storeimm = Storeimm - (1<<12);
    }
    //
    long rs1u,rs2u;
    rs1u =  ((long) rs1v) & 0x0ffffffff;
    rs2u =  ((long) rs2v) & 0x0ffffffff;
    int de_r_rs1 =0;
    int de_r_rs2 =0;
    //
    de2fe_branch =0;
    de2ex_wr_mem =0;
    de2ex_mem_en =0;
    de2ex_load =0;
    de2ex_rd_csrreg =0;
    de2ex_wr_csrreg =0;
    de2ex_MD_OP = 0;
    //
    switch (opcode)
    {
    case OPCODE_IMM:
        de2ex_rd_oprand1 = rs1v;
        de2ex_rd_oprand2 = imm;
        de2ex_aluop = func3;
        de2ex_aluop_sub = -1;
        de2ex_wr_reg = 1;
        de2ex_wr_regindex = rd;
        if (func3==1 || func3==5)
        {
            de2ex_aluop_sub = func7;
            de2ex_rd_oprand2 = imm & 0x1f;
        }
        else
            de2ex_aluop_sub  = 1;
        de2ex_inst_valid =1;
        de_r_rs1 =1;
        break;
    case OPCODE_OP:
        if (func7==1){
            de2ex_MD_OP =1;
        }
        de2ex_rd_oprand1 = rs1v;
        de2ex_rd_oprand2 = rs2v;
        de2ex_aluop = func3;
        de2ex_aluop_sub = func7;
        de2ex_wr_reg = 1;
        de2ex_wr_regindex = rd;
        de2ex_inst_valid =1;
        de_r_rs1 =1;
        de_r_rs2 =1;
        break;
    case OPCODE_LOAD:
        de2ex_rd_oprand1 =rs1v;
        de2ex_rd_oprand2 =imm;
        de2ex_aluop =0;
        de2ex_aluop_sub =0;
        de2ex_wr_reg =1;
        de2ex_wr_regindex =rd;
        de2ex_inst_valid =1;
        de2ex_mem_en =1;
        de2ex_mem_op = func3;
        de_r_rs1 =1;
        de2ex_load =1;
        break;
    case OPCODE_STORE:
        de2ex_rd_oprand1 =rs1v;
        de2ex_rd_oprand2 =Storeimm;
        de2ex_aluop =0;
        de2ex_aluop_sub =0;
        de2ex_wr_reg =0;
        de2ex_wr_regindex =0;
        de2ex_inst_valid =1;
        de_r_rs1 =1;
        de2ex_mem_en =1;
        de2ex_mem_op = func3;
        de2ex_wr_mem =1;
        de2ex_wr_memwdata = rs2v;
        de_r_rs2 =1;
        break;
    case OPCODE_LUI:
        de2ex_rd_oprand1 = LUIimm;
        de2ex_rd_oprand2 = 0;
        de2ex_aluop = 0;
        de2ex_aluop_sub = 0;
        de2ex_wr_reg = 1;
        de2ex_wr_regindex = rd;
        de2ex_inst_valid =1;
        break;
    case OPCODE_AUIPC:
        de2ex_rd_oprand1 = LUIimm;
        de2ex_rd_oprand2 = fe2de_pc_ffout;
        de2ex_aluop = 0;
        de2ex_aluop_sub = 0;
        de2ex_wr_reg = 1;
        de2ex_wr_regindex = rd;
        de2ex_inst_valid =1;
        break;
    case OPCODE_JAL:
        de2ex_rd_oprand1 = fe2de_pc_ffout;
        de2ex_rd_oprand2 = 4;
        de2ex_aluop = 0;
        de2ex_aluop_sub = 0;
        de2ex_wr_reg = 1;
        de2ex_wr_regindex = rd;
        de2ex_inst_valid =1;
        de2fe_branch =1;
        de2fe_branch_target = fe2de_pc_ffout + JALimm;
        break;
    case OPCODE_JALR:
        de2ex_rd_oprand1 = fe2de_pc_ffout;
        de2ex_rd_oprand2 = 4;
        de2ex_aluop = 0;
        de2ex_aluop_sub = 0;
        de2ex_wr_reg = 1;
        de2ex_wr_regindex = rd;
        de2ex_inst_valid =1;
        de_r_rs1 =1;
        de2fe_branch =1;
        de2fe_branch_target = fe2de_pc_ffout + JALRimm;
        break;
    case OPCODE_BRANCH:
        de2ex_rd_oprand1 = 0;
        de2ex_rd_oprand2 = 0;
        de2ex_aluop = 0;
        de2ex_aluop_sub = 0;
        de2ex_wr_reg = 0;
        de2ex_wr_regindex = 0;
        de2ex_inst_valid =1;
        de_r_rs1 =1;
        de_r_rs2 =1;
        //
        de2fe_branch_target = 0;
        switch(func3)
        {
        case BRANCH_BEQ:
            if (rs1v==rs2v){
                de2fe_branch =1;
                de2fe_branch_target = fe2de_pc_ffout + Bimm;
            }
            break;
        case BRANCH_BNE:
            if (rs1v!=rs2v){
                de2fe_branch =1;
                de2fe_branch_target = fe2de_pc_ffout + Bimm;
            }
            break;
         case BRANCH_BLT:
            if (rs1v<rs2v){
                de2fe_branch =1;
                de2fe_branch_target = fe2de_pc_ffout + Bimm;
            }
            break;
         case BRANCH_BGE:
            if (rs1v>=rs2v){
                de2fe_branch =1;
                de2fe_branch_target = fe2de_pc_ffout + Bimm;
            }
            break;
         case BRANCH_BLTU:
            if (rs1u<rs2u){
                de2fe_branch =1;
                de2fe_branch_target = fe2de_pc_ffout + Bimm;
            }
            break;
         case BRANCH_BGEU:
            if (rs1u>=rs2u){
                de2fe_branch =1;
                de2fe_branch_target = fe2de_pc_ffout + Bimm;
            }
            break;
         default:
            ;
       }

        break;
    case OPCODE_SYSTEM:
        de2ex_aluop =0;
        de2ex_aluop_sub =0;
        de2ex_wr_reg =0;
        de2ex_wr_regindex =rd;
        de2ex_inst_valid =1;
        //
        switch(func3)
        {
        //case SYSTEM_ECALL:
        case SYSTEM_EBREAK:
            break;
        case SYSTEM_CSRRW:
            de2ex_csrop = CSR_WR;
            de2ex_rd_oprand1 =rs1v;
            de2ex_wr_csrreg =1;
            if (rd!=0){
                de2ex_rd_oprand2 = csrindex;
                de2ex_rd_csrreg =1;
            }
            break;
        case SYSTEM_CSRRS:
            de2ex_csrop = CSR_SET;
            de2ex_rd_oprand1 =rs1v;
            if (rs1!=0){
                de2ex_wr_csrreg =1;
            }

            if (rd!=0){
                de2ex_rd_oprand2 = csrindex;
                de2ex_rd_csrreg =1;
            }
            break;
        case SYSTEM_CSRRC:
            de2ex_csrop = CSR_CLR;
            de2ex_rd_oprand1 =rs1v;
            if (rs1!=0){
                de2ex_wr_csrreg =1;
            }
            if (rd!=0){
                de2ex_rd_oprand2 = csrindex;
                de2ex_rd_csrreg =1;
            }
            break;
        case SYSTEM_CSRRWI:
            de2ex_csrop = CSR_WR;
            de2ex_rd_oprand1 =zimm;
            de2ex_wr_csrreg =1;
            if (rd!=0){
                de2ex_rd_oprand2 = csrindex;
                de2ex_rd_csrreg =1;
            }
            break;
        case SYSTEM_CSRRSI:
            de2ex_csrop = CSR_SET;
            de2ex_rd_oprand1 =zimm;
            if (zimm!=0){
                de2ex_wr_csrreg =1;
            }

            if (rd!=0){
                de2ex_rd_oprand2 = csrindex;
                de2ex_rd_csrreg =1;
            }
            break;
        case SYSTEM_CSRRCI:
            de2ex_csrop = CSR_CLR;
            de2ex_rd_oprand1 =zimm;
            if (zimm!=0){
                de2ex_wr_csrreg =1;
            }
            if (rd!=0){
                de2ex_rd_oprand2 = csrindex;
                de2ex_rd_csrreg =1;
            }
            break;
        }
        break;

    case OPCODE_MISCMEM:
        if (func3==1){
            //FENCE.I
        }
        else{
            //FENCE
        }
        /**< FENCE is no effect at single core */
        de2ex_rd_oprand1 =0;
        de2ex_rd_oprand2 =0;
        de2ex_aluop =0;
        de2ex_aluop_sub =0;
        de2ex_wr_reg =0;
        de2ex_wr_regindex =0;
        de2ex_inst_valid =1;
        break;

    case OPCODE_ZERO:
        de2ex_rd_oprand1 =0;
        de2ex_rd_oprand2 =0;
        de2ex_aluop =-1;
        de2ex_aluop_sub =-1;
        de2ex_wr_reg =0;
        de2ex_wr_regindex =0;
        de2ex_inst_valid =0;
        break;
    default:
        ;
    }

    de2ex_pc = fe2de_pc_ffout;

    /**< load data dependence, need stall 1 clock */
    de_stall=0;
    if (de2ex_load_ffout){
        if ((de2ex_wr_regindex_ffout==rs1) && de_r_rs1){
            de_stall =1;
        }
        else if ((de2ex_wr_regindex_ffout==rs2) && de_r_rs2){
            de_stall =1;
        }

    }

}
