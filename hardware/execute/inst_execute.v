//#include "globalsig.h"
//#include "opcode_define.h"
//#include <math.h>

module inst_execute(
de2ex_wr_mem_ffout,
de2ex_mem_op_ffout,
de2ex_wr_memwdata_ffout,
de2ex_mem_en_ffout,
de2ex_load_ffout, de2ex_store_ffout,
de2ex_rd_csrreg_ffout,
de2ex_wr_csrreg_ffout,
de2ex_MD_OP_ffout,
de2ex_rd_oprand1_ffout,
de2ex_rd_oprand2_ffout,
de2ex_aluop_ffout,
de2ex_aluop_sub_ffout,
de2ex_wr_reg_ffout,
de2ex_wr_regindex_ffout,
de2ex_inst_valid_ffout,
de2ex_csrop_ffout,
de2ex_rd_is_x1_ffout,
de2ex_rd_is_xn_ffout,
mem2ex_mem_op,
store_misaligned_exxeption,
mem2ex_memadr,
ex2mem_store_ffout,
ex2mem_mem_en_ffout,
de2ex_csr_index_ffout,
de2ex_exp_ffout,
de2ex_mstatus_mie_ffout ,
de2ex_mstatus_pmie_ffout,
de2ex_mtval_ffout       ,
de2ex_mtvec_ffout       ,
de2ex_mepc_ffout        ,
de2ex_causecode_ffout   ,
de2ex_rv16_ffout   ,
ex2mem_mulvalid,
mul2mem_wr_wdata,
div2mem_divvalid,
div2mem_wr_wdata,


// output port
ex2mem_wr_reg,
ex2mem_wr_regindex,
ex2mem_wr_wdata,
ex2mem_memaddr,
ex2mem_wr_mem,
ex2mem_wr_memwdata,
ex2mem_mem_op,
ex2mem_mem_en,
ex2readram_mem_en,
ex2readram_addr,
ex2readram_opmode,
ex2mem_load, ex2mem_store,
exe_store_load_conflict,
ex2mem_rd_is_x1, ex2mem_rd_is_xn,
ex2mem_wr_csrreg   ,
ex2mem_wr_csrindex ,
ex2mem_wr_csrwdata ,
ex2mem_exp,
ex2mem_mstatus_mie  ,
ex2mem_mstatus_pmie ,
ex2mem_mtval        ,
ex2mem_mtvec        ,
ex2mem_mepc         ,
ex2mem_causecode    ,
ex2mem_rv16    

);

input de2ex_wr_mem_ffout ;
input [2:0] de2ex_mem_op_ffout ;
input [31:0] de2ex_wr_memwdata_ffout ;
input de2ex_mem_en_ffout ;
input de2ex_load_ffout, de2ex_store_ffout ;
input de2ex_rd_csrreg_ffout ;
input de2ex_wr_csrreg_ffout ;
input de2ex_MD_OP_ffout ;
input [31:0] de2ex_rd_oprand1_ffout ;
input [31:0] de2ex_rd_oprand2_ffout ;
input [2:0] de2ex_aluop_ffout ;
input [6:0] de2ex_aluop_sub_ffout ;
input de2ex_wr_reg_ffout ;
input [4:0] de2ex_wr_regindex_ffout ;
input de2ex_inst_valid_ffout ;
input [2:0] de2ex_csrop_ffout;
input de2ex_rd_is_x1_ffout;
input de2ex_rd_is_xn_ffout;
//from mem back-to exe
input [2:0] mem2ex_mem_op;
input store_misaligned_exxeption ;
input [31:0] mem2ex_memadr;
input ex2mem_store_ffout;
input ex2mem_mem_en_ffout;
input [11:0] de2ex_csr_index_ffout;
input de2ex_exp_ffout;
input de2ex_mstatus_mie_ffout ;    
input de2ex_mstatus_pmie_ffout;   
input [31:0] de2ex_mtval_ffout       ;          
input [31:0] de2ex_mtvec_ffout       ;          
input [31:0] de2ex_mepc_ffout        ;           
input [4:0] de2ex_causecode_ffout   ;      
input de2ex_rv16_ffout   ;      
input ex2mem_mulvalid;
input [31:0] mul2mem_wr_wdata;
input div2mem_divvalid;
input [31:0] div2mem_wr_wdata;


//regfile
output ex2mem_wr_reg;
output [4:0] ex2mem_wr_regindex;
output [31:0] ex2mem_wr_wdata;
//write mem
output [31:0] ex2mem_memaddr;
output ex2mem_wr_mem;
output [31:0] ex2mem_wr_memwdata;
output [2:0] ex2mem_mem_op;
output ex2mem_mem_en;
//read mem
output ex2readram_mem_en;
output [31:0] ex2readram_addr;
output [2:0] ex2readram_opmode;
// load command
output ex2mem_load, ex2mem_store;
output exe_store_load_conflict;
output ex2mem_rd_is_x1, ex2mem_rd_is_xn;
output ex2mem_wr_csrreg   ;
output [11:0] ex2mem_wr_csrindex ;
output [31:0] ex2mem_wr_csrwdata ;
output ex2mem_exp;
output ex2mem_mstatus_mie  ; 
output ex2mem_mstatus_pmie ; 
output [31:0] ex2mem_mtval        ; 
output [31:0] ex2mem_mtvec        ; 
output [31:0] ex2mem_mepc         ; 
output [4:0] ex2mem_causecode    ; 
output ex2mem_rv16    ; 

reg [63:0] alu_out_t64;
reg [31:0] alu_out;
reg [31:0] rop2,topr1,topr2;
reg [4:0] amt;

reg c1, c2, c3;
always @*
  begin
    alu_out =0;
    if (de2ex_inst_valid_ffout)
    begin

    case(de2ex_aluop_ffout)
    
    //case ALU_ADD:
    //case ALU_SUB:
    `ALU_ADDI:
        begin
          rop2 = (de2ex_aluop_sub_ffout==7'h20) ? ~de2ex_rd_oprand2_ffout + 1'b1 : de2ex_rd_oprand2_ffout;
          alu_out = de2ex_rd_oprand1_ffout + rop2;
        end
    //case ALU_SLL:
    `ALU_SLLI:
        alu_out = de2ex_rd_oprand1_ffout << de2ex_rd_oprand2_ffout[4:0] ;
    //case ALU_SLT:
    `ALU_SLTI:
        begin
          c1 = de2ex_rd_oprand1_ffout[31] & (!de2ex_rd_oprand2_ffout[31]) ;
          c2 = de2ex_rd_oprand1_ffout[30:0] < de2ex_rd_oprand2_ffout[30:0];
          c3 = de2ex_rd_oprand1_ffout[31] ^ de2ex_rd_oprand2_ffout[31];
          alu_out = c1 || (c2 & (!c3));
        end
    //case ALU_SLTU:
    `ALU_SLTIU:
        begin
          alu_out = de2ex_rd_oprand1_ffout < de2ex_rd_oprand2_ffout;
        end
        //alu_out = tounsigned(de2ex_rd_oprand1_ffout) < tounsigned(de2ex_rd_oprand2_ffout);
     //case ALU_XOR:
    `ALU_XORI:
        alu_out = de2ex_rd_oprand1_ffout ^ de2ex_rd_oprand2_ffout;
    //case ALU_SRA
    //case ALU_SRAI
    //case ALU_SRL
    `ALU_SRLI:
        begin
        amt = de2ex_rd_oprand2_ffout[4:0];
        if (de2ex_aluop_sub_ffout==7'h20)
          begin
            alu_out_t64 = {{32{de2ex_rd_oprand1_ffout[31]}},de2ex_rd_oprand1_ffout} >> amt;
            alu_out = alu_out_t64[31:0];
          end
        else
          begin
            alu_out = de2ex_rd_oprand1_ffout >> amt;
          end
        end   

    //case ALU_OR:
    `ALU_ORI:
        alu_out = de2ex_rd_oprand1_ffout | de2ex_rd_oprand2_ffout;
    //case ALU_AND:
    `ALU_ANDI:
        alu_out = de2ex_rd_oprand1_ffout & de2ex_rd_oprand2_ffout;
    endcase

    end
    //
  end



//assign    ex2mem_pc = de2ex_pc_ffout;
assign    ex2mem_wr_reg = de2ex_wr_reg_ffout;
assign    ex2mem_wr_regindex = de2ex_wr_regindex_ffout;

assign    ex2mem_wr_wdata = de2ex_rd_csrreg_ffout & de2ex_wr_reg_ffout ? de2ex_rd_oprand2_ffout : 
                            de2ex_MD_OP_ffout & ex2mem_mulvalid ? mul2mem_wr_wdata :
                            de2ex_MD_OP_ffout & div2mem_divvalid ? div2mem_wr_wdata :
                            alu_out;  //reg wdata

reg [31:0] csr_out;
always @*
begin
  csr_out =0;
  case(de2ex_csrop_ffout)
    `CSR_WR:
       csr_out = de2ex_rd_oprand1_ffout;
    `CSR_SET:
       csr_out = de2ex_rd_oprand1_ffout | de2ex_rd_oprand2_ffout;
    `CSR_CLR:
       csr_out = (~de2ex_rd_oprand1_ffout) & de2ex_rd_oprand2_ffout;
  endcase
end

assign    ex2mem_wr_csrreg   = de2ex_wr_csrreg_ffout;
assign    ex2mem_wr_csrindex = de2ex_csr_index_ffout;
assign    ex2mem_wr_csrwdata = csr_out;

assign    ex2mem_memaddr =  store_misaligned_exxeption ? mem2ex_memadr : alu_out;

//always @*
//begin
//    /**< avoid read dataram[] array core dump, only for software purpose */
//
//    if (de2ex_mem_en_ffout) begin
//        if (store_misaligned_exxeption)
//            ex2mem_memaddr = mem2ex_memadr;
//        
//        else
//            ex2mem_memaddr = alu_out;
//    end
//    else
//        ex2mem_memaddr = 0;
//    
//end

assign   ex2mem_wr_mem = de2ex_wr_mem_ffout;
assign   ex2mem_wr_memwdata = de2ex_wr_memwdata_ffout;
assign   ex2mem_mem_op = store_misaligned_exxeption ? mem2ex_mem_op : de2ex_mem_op_ffout;

//    if (store_misaligned_exxeption){
//        ex2mem_mem_op = mem2ex_mem_op;
//    }
//    else{
//        ex2mem_mem_op = de2ex_mem_op_ffout;
//    }

assign    ex2mem_mem_en = de2ex_mem_en_ffout;

assign    ex2readram_mem_en = de2ex_mem_en_ffout;

assign    ex2mem_load = de2ex_load_ffout;
assign    ex2mem_store = de2ex_store_ffout;

/**< seperate LOAD readram address to speed timing, can use alu_out to reduce cost */
assign    ex2readram_addr = de2ex_rd_oprand1_ffout + de2ex_rd_oprand2_ffout;
 
//    /**< seperate LOAD readram address to speed timing */
//    /**< avoid read dataram[] array core dump, only for software purpose */
//    if (de2ex_mem_en_ffout){
//        ex2readram_addr = de2ex_rd_oprand1_ffout + de2ex_rd_oprand2_ffout;
//    }
//    else{
//        ex2readram_addr =0;
//    }

assign    ex2readram_opmode = de2ex_mem_op_ffout;

// store and load sram conflict, in "store, then load" case
assign exe_store_load_conflict = ex2mem_load & ex2mem_mem_en & ex2mem_store_ffout & ex2mem_mem_en_ffout;

assign ex2mem_rd_is_x1 = de2ex_rd_is_x1_ffout;
assign ex2mem_rd_is_xn = de2ex_rd_is_xn_ffout;

assign ex2mem_exp = de2ex_exp_ffout;

assign ex2mem_mstatus_mie = de2ex_mstatus_mie_ffout;
assign ex2mem_mstatus_pmie = de2ex_mstatus_pmie_ffout;
assign ex2mem_mtval = de2ex_mtval_ffout;
assign ex2mem_mtvec = de2ex_mtvec_ffout;
assign ex2mem_mepc = de2ex_mepc_ffout;
assign ex2mem_causecode = de2ex_causecode_ffout;
assign ex2mem_rv16 = de2ex_rv16_ffout;

endmodule
