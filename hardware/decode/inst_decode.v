//#include "globalsig.h"
//`include "../define/opcode_define.v"
//#include "regfile.h"

module inst_decode(
de2ex_store_ffout, de2ex_mem_en_ffout,
fe2de_pc_ffout,
fe2de_ir_ffout,
fe2de_predict_bxxtaken_ffout,
fe2de_rv16_ffout,
rs1v, rs2v,
de2ex_load_ffout,
de2ex_wr_regindex_ffout,
csr_rdat,
//
branch_predict_err,
de2fe_branch_target,
de2ex_wr_mem,
de2ex_mem_op,
de2ex_wr_memwdata,
de2ex_mem_en,
de2ex_load, de2ex_store,
de2ex_rd_csrreg,
de2ex_wr_csrreg,
de2ex_MD_OP,
de2ex_rd_oprand1,
de2ex_rd_oprand2,
de2ex_aluop,
de2ex_aluop_sub,
de2ex_wr_reg,
de2ex_wr_regindex,
de2ex_inst_valid,
de2ex_csrop,
de2ex_pc,
de_stall,
rs1_addr, rs2_addr,
de2ex_rd_is_x1, de2ex_rd_is_xn,
de2ex_exp, de2ex_mret,
de2ex_csr_index,
de2ex_wr_csrwdata,
de2ex_e_ecfm, de2ex_e_bk,
de_store_load_conflict
);
input de2ex_store_ffout, de2ex_mem_en_ffout;
input [31:0] fe2de_pc_ffout,fe2de_ir_ffout;
input fe2de_predict_bxxtaken_ffout;
input fe2de_rv16_ffout;
input [31:0] rs1v, rs2v;
input de2ex_load_ffout;
input [4:0] de2ex_wr_regindex_ffout;
input [31:0] csr_rdat;

output branch_predict_err ;
output [31:0] de2fe_branch_target;
output de2ex_wr_mem ;
output [2:0] de2ex_mem_op ;
output [31:0] de2ex_wr_memwdata ;
output de2ex_mem_en ;
output de2ex_load, de2ex_store ;
output de2ex_rd_csrreg ;
output de2ex_wr_csrreg ;
output de2ex_MD_OP ;

output [31:0] de2ex_rd_oprand1 ;
output [31:0] de2ex_rd_oprand2 ;
output [2:0] de2ex_aluop ;
output [6:0] de2ex_aluop_sub ;
output de2ex_wr_reg ;
output [4:0] de2ex_wr_regindex ;
output de2ex_inst_valid ;

output [2:0] de2ex_csrop;
output [31:0] de2ex_pc;
output de_stall;
output [4:0] rs1_addr, rs2_addr;
output de2ex_rd_is_x1, de2ex_rd_is_xn;
output de2ex_exp, de2ex_mret;
output [11:0] de2ex_csr_index;
output [31:0] de2ex_wr_csrwdata;
output de2ex_e_ecfm, de2ex_e_bk;
output de_store_load_conflict;
//
    wire [6:0] opcode = fe2de_ir_ffout[6:0] ;
    wire [2:0] func3 = fe2de_ir_ffout[14:12] ;
    wire [6:0] func7 = fe2de_ir_ffout[31:25] ;
    wire [4:0] rs1 = fe2de_ir_ffout[19:15] ;
    assign rs1_addr = rs1;
    wire [31:0] zimm = {27'b0,fe2de_ir_ffout[19:15]};
    wire [4:0] rs2 = fe2de_ir_ffout[24:20] ;
    assign rs2_addr = rs2;
    //wire [31:0] rs1v = read_regfile(rs1);
    //wire [31:0] rs2v = read_regfile(rs2);
    wire [4:0] rd = fe2de_ir_ffout[11:7] ;
    wire [31:0] imm = {{20{fe2de_ir_ffout[31]}},fe2de_ir_ffout[31:20]} ;  ///**< signed value */
    assign de2ex_csr_index = {imm[11:0]};
    
    wire [31:0] LUIimm = {fe2de_ir_ffout[31:12],12'b0}; // & 0xfffff000);  ///**< msb[31:12] */
    wire [31:0] JALimm = {{11{fe2de_ir_ffout[31]}},fe2de_ir_ffout[31],fe2de_ir_ffout[19:12],fe2de_ir_ffout[20],fe2de_ir_ffout[30:21],1'b0};
    wire [31:0] JALRimm = {{20{fe2de_ir_ffout[31]}},fe2de_ir_ffout[31:20]};    /**< set b0=0 */
    wire [31:0] Bimm = {{19{fe2de_ir_ffout[31]}},fe2de_ir_ffout[31],fe2de_ir_ffout[7],fe2de_ir_ffout[30:25],fe2de_ir_ffout[11:8],1'b0};
    wire [31:0] Storeimm = {{20{fe2de_ir_ffout[31]}},fe2de_ir_ffout[31:25],fe2de_ir_ffout[11:7]}   ;
    //
    // unsigned rs1v
    wire [31:0] rs1u =   rs1v;
    wire [31:0] rs2u =   rs2v;
//
reg de_r_rs1 ;
reg de_r_rs2 ;
    //
reg de_op_branch;    
reg de2fe_branch ;
reg [31:0] de2fe_branch_offset;
reg de2ex_wr_mem ;
reg [2:0] de2ex_mem_op ;
reg [31:0] de2ex_wr_memwdata ;
reg de2ex_mem_en ;
reg de2ex_load, de2ex_store ;
reg de2ex_rd_csrreg ;
reg de2ex_wr_csrreg ;
reg de2ex_MD_OP ;

reg [31:0] de2ex_rd_oprand1 ;
reg [31:0] de2ex_rd_oprand2 ;
reg [2:0] de2ex_aluop ;
reg [6:0] de2ex_aluop_sub ;
reg de2ex_wr_reg ;
reg [4:0] de2ex_wr_regindex ;
reg de2ex_inst_valid ;
reg de2ex_e_ecfm, de2ex_e_bk;
reg [2:0] de2ex_csrop;
reg de2ex_exp, de2ex_mret;
    //
always @*
begin
    de2ex_e_ecfm =0;
    de2ex_e_bk =0;
    de_r_rs1 =0;
    de_r_rs2 =0;
//
    de_op_branch =0;
    de2fe_branch =0;
    de2fe_branch_offset =0;
    de2ex_wr_mem =0;
    de2ex_mem_en =0;
    de2ex_mem_op =0;
    de2ex_wr_memwdata =0;
    de2ex_load =0;
    de2ex_store =0;
    de2ex_rd_csrreg =0;
    de2ex_wr_csrreg =0;
    de2ex_MD_OP = 0;

    de2ex_rd_oprand1 =0;
    de2ex_rd_oprand2 =0;
    de2ex_aluop =0;
    de2ex_aluop_sub =0;
    de2ex_wr_reg =0;
    de2ex_wr_regindex =0;
    de2ex_inst_valid =0;

    de2ex_csrop =0;
    de2ex_exp =0;
    de2ex_mret =0;

    case (opcode)
    `OPCODE_IMM:
        begin
        de2ex_rd_oprand1 = rs1v;
        de2ex_rd_oprand2 = imm;
        de2ex_aluop = func3;
        //de2ex_aluop_sub = -1;
        de2ex_wr_reg = 1;
        de2ex_wr_regindex = rd;
        if (func3==1 || func3==5)
        begin
            de2ex_aluop_sub = func7;
            de2ex_rd_oprand2 = imm ;
        end
        else
            de2ex_aluop_sub  = 1;
        de2ex_inst_valid =1;
        de_r_rs1 =1;
        end
    `OPCODE_OP:
        begin
        if (func7==1)
        begin
            de2ex_MD_OP =1;
        end
        de2ex_rd_oprand1 = rs1v;
        de2ex_rd_oprand2 = rs2v;
        de2ex_aluop = func3;
        de2ex_aluop_sub = func7;
        de2ex_wr_reg = 1;
        de2ex_wr_regindex = rd;
        de2ex_inst_valid =1;
        de_r_rs1 =1;
        de_r_rs2 =1;
        end
    `OPCODE_LOAD:
        begin
        de2ex_rd_oprand1 =rs1v;
        de2ex_rd_oprand2 =imm;
        de2ex_wr_reg =1;
        de2ex_wr_regindex =rd;
        de2ex_inst_valid =1;
        de2ex_mem_en =1;
        de2ex_mem_op = func3;
        de_r_rs1 =1;
        de2ex_load =1;
        end
    `OPCODE_STORE:
        begin
        de2ex_rd_oprand1 =rs1v;
        de2ex_rd_oprand2 =Storeimm;
        de2ex_inst_valid =1;
        de_r_rs1 =1;
        de2ex_mem_en =1;
        de2ex_mem_op = func3;
        de2ex_wr_mem =1;
        de2ex_wr_memwdata = rs2v;
        de_r_rs2 =1;
        de2ex_store =1;
        end
    `OPCODE_LUI:
        begin
        de2ex_rd_oprand1 = LUIimm;
        de2ex_wr_reg = 1;
        de2ex_wr_regindex = rd;
        de2ex_inst_valid =1;
        end
    `OPCODE_AUIPC:
        begin
        de2ex_rd_oprand1 = LUIimm;
        de2ex_rd_oprand2 = fe2de_pc_ffout;
        de2ex_wr_reg = 1;
        de2ex_wr_regindex = rd;
        de2ex_inst_valid =1;
        end
    `OPCODE_JAL:
        begin
        de2ex_rd_oprand1 = fe2de_pc_ffout;
        de2ex_rd_oprand2 = fe2de_rv16_ffout ? 2 : 4;
        de2ex_wr_reg = 1;
        de2ex_wr_regindex = rd;
        de2ex_inst_valid =1;
        //de2fe_branch =1;
        //de2fe_branch_target = fe2de_pc_ffout + JALimm;  // extra adder
        //de2fe_branch_offset =  JALimm;  
        end
    `OPCODE_JALR:
        begin
        de2ex_rd_oprand1 = fe2de_pc_ffout;
        de2ex_rd_oprand2 = fe2de_rv16_ffout ? 2 : 4;
        de2ex_wr_reg = 1;
        de2ex_wr_regindex = rd;
        de2ex_inst_valid =1;
        de_r_rs1 =1;
        //de2fe_branch =1;
        //de2fe_branch_target = fe2de_pc_ffout + JALRimm;  // extra adder
        //de2fe_branch_offset =  JALRimm;  
        end
    `OPCODE_BRANCH:
        begin
        de2ex_inst_valid =1;
        de_r_rs1 =1;
        de_r_rs2 =1;
        de2fe_branch_offset = fe2de_rv16_ffout ? 2 : 4;
        de_op_branch =1;
        //
        case(func3)
        
        `BRANCH_BEQ:
            if (rs1v==rs2v)
            begin
                de2fe_branch =1;
                de2fe_branch_offset =  Bimm;
            end
        `BRANCH_BNE:
            if (rs1v!=rs2v)
            begin
                de2fe_branch =1;
                de2fe_branch_offset =  Bimm;
            end
        `BRANCH_BLT:
            //if (rs1v<rs2v)
            if ( (rs1v[31]&(!rs2v[31])) | 
                 (rs1v[30:0]<rs2v[30:0] && rs1v[31]==1'b0 && rs2v[31]==1'b0) |
                 (rs1v[30:0]<rs2v[30:0] && rs1v[31]==1'b1 && rs2v[31]==1'b1)                  
               )
            begin
                de2fe_branch =1;
                de2fe_branch_offset =  Bimm;
            end
        `BRANCH_BGE:
            if ( (!rs1v[31]&rs2v[31]) | 
                 (rs1v[30:0]>=rs2v[30:0] && rs1v[31]==1'b0 && rs2v[31]==1'b0) |
                 (rs1v[30:0]>=rs2v[30:0] && rs1v[31]==1'b1 && rs2v[31]==1'b1)                  
               )
            begin
                de2fe_branch =1;
                de2fe_branch_offset =  Bimm;
            end
        `BRANCH_BLTU:
            if (rs1u<rs2u)
            begin
                de2fe_branch =1;
                de2fe_branch_offset =  Bimm;
            end
        `BRANCH_BGEU:
            if (rs1u>=rs2u)
            begin
                de2fe_branch =1;
                de2fe_branch_offset =  Bimm;
            end
         endcase
         end
       

    `OPCODE_SYSTEM:
        begin
        de2ex_wr_regindex =rd;
        de2ex_inst_valid =1;
        //
        //mcause
        de2ex_e_ecfm = (fe2de_ir_ffout[31:7]==25'b0);
        de2ex_e_bk = (fe2de_ir_ffout[31:7]==25'b1);
        //
        case(func3)
        
        //`SYSTEM_ECALL, `SYSTEM_MRET
        `SYSTEM_EBREAK:
            begin
            de2ex_exp =1;
            if (func7==7'h18)
              begin
                de2ex_mret =1;
                de2ex_exp =0;
              end  
            end  
        `SYSTEM_CSRRW:
            begin
            de2ex_csrop = `CSR_WR;
            de2ex_rd_oprand1 =rs1v;
            de2ex_wr_csrreg =1;
            
            if (rd!=0)
            begin
                de2ex_rd_oprand2 = csr_rdat; //csrindex;
                de2ex_rd_csrreg =1;
                de2ex_wr_reg =1;
            end
            end
        `SYSTEM_CSRRS:
            begin
            
            de2ex_csrop = `CSR_SET;
            de2ex_rd_oprand1 =rs1v;
            if (rs1!=0)
            begin
                de2ex_wr_csrreg =1;
            end

            if (rd!=0)
            begin
                de2ex_rd_oprand2 = csr_rdat; //csrindex;
                de2ex_rd_csrreg =1;
                de2ex_wr_reg =1;
            end
            end
        `SYSTEM_CSRRC:
            begin
            
            de2ex_csrop = `CSR_CLR;
            de2ex_rd_oprand1 =rs1v;
            if (rs1!=0)
            begin
                de2ex_wr_csrreg =1;
            end
            if (rd!=0)
            begin
                de2ex_rd_oprand2 = csr_rdat; //csrindex;
                de2ex_rd_csrreg =1;
                de2ex_wr_reg =1;
            end
            end
        `SYSTEM_CSRRWI:
            begin
            
            de2ex_csrop = `CSR_WR;
            de2ex_rd_oprand1 =zimm;
            de2ex_wr_csrreg =1;
            if (rd!=0)
            begin
                de2ex_rd_oprand2 = csr_rdat; //csrindex;
                de2ex_rd_csrreg =1;
                de2ex_wr_reg =1;
            end
            end
        `SYSTEM_CSRRSI:
            begin
            
            de2ex_csrop = `CSR_SET;
            de2ex_rd_oprand1 =zimm;
            if (zimm!=0)
            begin
                de2ex_wr_csrreg =1;
            end

            if (rd!=0)
            begin
                de2ex_rd_oprand2 = csr_rdat; //csrindex;
                de2ex_rd_csrreg =1;
                de2ex_wr_reg =1;
            end
            end
        `SYSTEM_CSRRCI:
            begin
            
            de2ex_csrop = `CSR_CLR;
            de2ex_rd_oprand1 =zimm;
            if (zimm!=0)
            begin
                de2ex_wr_csrreg =1;
            end
            if (rd!=0)
            begin
                de2ex_rd_oprand2 = csr_rdat; //csrindex;
                de2ex_rd_csrreg =1;
                de2ex_wr_reg =1;
            end
            end
        endcase
        end

    `OPCODE_MISCMEM:
        //if (func3==1){
        //    //FENCE.I
        //}
        //else{
        //    //FENCE
        //}
        /**< FENCE is no effect at single core */
        de2ex_inst_valid =1;

    //OPCODE_ZERO:
    //    de2ex_rd_oprand1 =0;
    //    de2ex_rd_oprand2 =0;
    //    de2ex_aluop =-1;
    //    de2ex_aluop_sub =-1;
    //    de2ex_wr_reg =0;
    //    de2ex_wr_regindex =0;
    //    de2ex_inst_valid =0;
        
    endcase
end

assign branch_predict_err = (de2fe_branch ^ fe2de_predict_bxxtaken_ffout) & de_op_branch;
assign de2fe_branch_target = fe2de_pc_ffout + de2fe_branch_offset;

assign    de2ex_pc = fe2de_pc_ffout;

reg de_stall;
always @*
begin
    /**< load data dependence, need stall 1 clock */
    de_stall=0;
    if (de2ex_load_ffout)
    begin
        if ((de2ex_wr_regindex_ffout==rs1) && de_r_rs1)
        begin
            de_stall =1;
        end
        else if ((de2ex_wr_regindex_ffout==rs2) && de_r_rs2)
        begin
            de_stall =1;
        end
    end
    //else if (branch_predict_err)
    //  de_stall =1;
end

assign de2ex_rd_is_x1 = (de2ex_wr_regindex==5'h1);
assign de2ex_rd_is_xn = (de2ex_wr_regindex!=5'h0) & (!de2ex_rd_is_x1);
//
reg [31:0] de2ex_wr_csrwdata;
always @*
begin
  de2ex_wr_csrwdata =0;
  case(de2ex_csrop)
    `CSR_WR:
       de2ex_wr_csrwdata = de2ex_rd_oprand1;
    `CSR_SET:
       de2ex_wr_csrwdata = de2ex_rd_oprand1 | de2ex_rd_oprand2;
    `CSR_CLR:
       de2ex_wr_csrwdata = (~de2ex_rd_oprand1) & de2ex_rd_oprand2;
  endcase
end
//
assign de_store_load_conflict = de2ex_load & de2ex_mem_en & de2ex_store_ffout & de2ex_mem_en_ffout;

endmodule
