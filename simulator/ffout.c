#include "globalsig.h"
#include "regfile.h"
#include "memory.h"

void ffout()
{
    if (g_resetz==0)
    {
        for (int i=0;i<32;i++){
            regfile_x[i]=0;
        }

    fe_pc_ffout =BOOTADDR;

    fe2de_pc_ffout = 0;
    fe2de_ir_ffout = 0;

    de2ex_pc_ffout = 0;
    ex2mem_pc_ffout = 0;
    mem2wb_pc_ffout = 0;
    wb2regfile_pc_ffout = 0;

    de2ex_aluop_ffout = 0;
    de2ex_aluop_sub_ffout = 0;
    de2ex_rd_oprand1_ffout = 0;
    de2ex_rd_oprand2_ffout = 0;
    de2ex_wr_reg_ffout = 0;
    de2ex_wr_regindex_ffout = 0;
    de2ex_inst_valid_ffout = 0;

    ex2mem_wr_reg_ffout = 0;
    ex2mem_wr_regindex_ffout = 0;
    ex2mem_wr_wdata_ffout = 0;

    mem2wb_wr_reg_ffout =  0;
    mem2wb_wr_regindex_ffout = 0;
    mem2wb_wr_wdata_ffout = 0;

    de2ex_mem_op_ffout = 0;
    de2ex_wr_mem_ffout = 0;
    de2ex_mem_en_ffout = 0;
    de2ex_wr_memwdata_ffout = 0;
    ex2mem_memaddr_ffout = 0;
    ex2mem_wr_mem_ffout = 0;
    ex2mem_wr_memwdata_ffout = 0;
    ex2mem_mem_op_ffout = 0;
    ex2mem_mem_en_ffout = 0;
    ex2mem_load_ffout = 0;
    ex2readram_mem_en_ffout = 0;
    ex2readram_addr_ffout = 0;
    ex2readram_opmode_ffout = 0;
    mul2mem_prod_complete_ffout =0;
    mul2mem_LO_ffout =0;

    de2ex_load_ffout = 0;

    mem_misaligned_exxeption_ffout =0;
    load_misaligned_exxeption_ffout =0;
    readram_mis_tmprdat_ffout =0;
    readram_mis_hytes_ffout =0;
    readram2ex_mem_op_ffout =0;
    readram2ex_memaddr_ffout =0;
    mem2ex_memadr_ffout =0;
    mem2ex_mem_op_ffout =0;
    mem2ex_wr_memwdata_ffout =0;

    mult_cycle_counter=1;

    }
    else
    {

    if (de_stall==0 && mem_stall==0 && readram_stall==0 && mult_stall==0)
    {
    fe_pc_ffout = fe_pc;
    fe2de_pc_ffout = fe2de_pc;
    fe2de_ir_ffout = fe2de_ir;
    }


    if (mem_stall==0 && readram_stall==0 && mult_stall==0)
    {
        if (de_stall==1){    /**< insert dummy NOP command to flush pipeline */
    de2ex_pc_ffout = de2ex_pc;
    de2ex_aluop_ffout = 0;
    de2ex_aluop_sub_ffout = 0;
    de2ex_rd_oprand1_ffout = 0;
    de2ex_rd_oprand2_ffout = 0;
    de2ex_wr_reg_ffout = 0;
    de2ex_wr_regindex_ffout = 0;
    de2ex_inst_valid_ffout = 1;
    de2ex_mem_op_ffout = 0;
    de2ex_wr_mem_ffout = 0;
    de2ex_mem_en_ffout = 0;
    de2ex_wr_memwdata_ffout = 0;
    de2ex_load_ffout = 0;
    de2ex_MD_OP_ffout =0;

        }
        else{
    de2ex_pc_ffout = de2ex_pc;
    de2ex_aluop_ffout = de2ex_aluop;
    de2ex_aluop_sub_ffout = de2ex_aluop_sub;
    de2ex_rd_oprand1_ffout = de2ex_rd_oprand1;
    de2ex_rd_oprand2_ffout = de2ex_rd_oprand2;
    de2ex_wr_reg_ffout = de2ex_wr_reg;
    de2ex_wr_regindex_ffout = de2ex_wr_regindex;
    de2ex_inst_valid_ffout = de2ex_inst_valid;
    de2ex_mem_op_ffout = de2ex_mem_op;
    de2ex_wr_mem_ffout = de2ex_wr_mem;
    de2ex_mem_en_ffout = de2ex_mem_en;
    de2ex_wr_memwdata_ffout = de2ex_wr_memwdata;
    de2ex_load_ffout = de2ex_load;
    de2ex_MD_OP_ffout = de2ex_MD_OP;

        }
    }

    if (mem_stall==0 && readram_stall==0)
    {
        if (mult_stall==1){
    ex2mem_pc_ffout = ex2mem_pc;
    ex2mem_wr_reg_ffout = 0;
    ex2mem_wr_regindex_ffout = 0;
    ex2mem_wr_wdata_ffout = 0;
    ex2mem_memaddr_ffout = 0;
    ex2mem_wr_mem_ffout = 0;
    ex2mem_wr_memwdata_ffout = 0;
    ex2mem_mem_op_ffout = 0;
    ex2mem_mem_en_ffout = 0;
    ex2mem_load_ffout = 0;
    ex2readram_mem_en_ffout = 0;
    ex2readram_addr_ffout = 0;
    ex2readram_opmode_ffout = 0;

    mul2mem_prod_complete_ffout = 0;
    mul2mem_LO_ffout = 0;

        }
        else{
    ex2mem_pc_ffout = ex2mem_pc;
    ex2mem_wr_reg_ffout = ex2mem_wr_reg;
    ex2mem_wr_regindex_ffout = ex2mem_wr_regindex;
    ex2mem_wr_wdata_ffout = ex2mem_wr_wdata;
    ex2mem_memaddr_ffout = ex2mem_memaddr;
    ex2mem_wr_mem_ffout = ex2mem_wr_mem;
    ex2mem_wr_memwdata_ffout = ex2mem_wr_memwdata;
    ex2mem_mem_op_ffout = ex2mem_mem_op;
    ex2mem_mem_en_ffout = ex2mem_mem_en;
    ex2mem_load_ffout = ex2mem_load;
    ex2readram_mem_en_ffout = ex2readram_mem_en;
    ex2readram_addr_ffout = ex2readram_addr;
    ex2readram_opmode_ffout = ex2readram_opmode;

    mul2mem_prod_complete_ffout = mul2mem_prod_complete;
    mul2mem_LO_ffout = mul2mem_LO;
        }
    }



    if (mem_stall==1 || readram_stall==1){   /**< insert dummy NOP command to flush pipeline */

    mem2wb_pc_ffout = mem2wb_pc;
    mem2wb_wr_reg_ffout =  0;
    mem2wb_wr_regindex_ffout = 0;
    mem2wb_wr_wdata_ffout = 0;


    }
    else{
    mem2wb_pc_ffout = mem2wb_pc;
    mem2wb_wr_reg_ffout =  mem2wb_wr_reg;
    mem2wb_wr_regindex_ffout = mem2wb_wr_regindex;
    mem2wb_wr_wdata_ffout = mem2wb_wr_wdata;

    }

    if (mul2mem_prod_complete){
        mult_cycle_counter =1;
        mult_LO_ffout = mult_LO;
        mult_HI_ffout = mult_HI;
    }
    else{
        mult_cycle_counter ++;

    }

    mem_misaligned_exxeption_ffout = mem_misaligned_exxeption;
    load_misaligned_exxeption_ffout = load_misaligned_exxeption;
    readram_mis_tmprdat_ffout = readram_mis_tmprdat;
    readram_mis_hytes_ffout = readram_mis_hytes;
    readram2ex_mem_op_ffout = readram2ex_mem_op;
    readram2ex_memaddr_ffout = readram2ex_memaddr;
    mem2ex_memadr_ffout = mem2ex_memadr;
    mem2ex_mem_op_ffout = mem2ex_mem_op;
    mem2ex_wr_memwdata_ffout = mem2ex_wr_memwdata;


    wb2regfile_pc_ffout = wb2regfile_pc;  /**< monitor purpose */

    }


    /**< write dataram  */
    if (mem2wb_mem_en && mem2wb_wr_mem){
        dataram[mem2wb_memaddr>>2] = mem2wb_mem_wdata;
        printf("write dataram addr=%x, wdata=%x\n", mem2wb_memaddr>>2, mem2wb_mem_wdata);
    }

    /**< regfile */
    if (wb2regfile_wr_reg && wb2regfile_wr_regindex) /**< dont write r0 */
        regfile_x[wb2regfile_wr_regindex] = wb2regfile_wr_wdata;


    // is the smae
    regfile_pc = wb2regfile_pc_ffout;
}
