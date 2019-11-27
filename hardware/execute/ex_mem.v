module ex_mem(
clk, cpurst,
memacc_stall,
mult_stall, div_stall, //mem_stall, readram_stall, 
exe_store_load_conflict, //interrupt,
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
ex2mem_rd_is_x1,
ex2mem_rd_is_xn,
ex2mem_exp,
ex2mem_pc,
ex2mem_wr_csrreg   ,
ex2mem_wr_csrindex ,
ex2mem_wr_csrwdata ,
mem2wb_exp_ffout,
ex2mem_mret,
ex2mem_e_ecfm,
ex2mem_e_bk,
ex2mem_mstatus_pmie,
ex2mem_mstatus_mie ,
ex2mem_mtvec       ,
ex2mem_mepc        ,
ex2mem_causecode  ,
ex2mem_mtval,
ex2mem_rv16,
//
ex2mem_wr_reg_ffout,
ex2mem_wr_regindex_ffout,
ex2mem_wr_wdata_ffout,
ex2mem_memaddr_ffout,
ex2mem_wr_mem_ffout,
ex2mem_wr_memwdata_ffout,
ex2mem_mem_op_ffout,
ex2mem_mem_en_ffout,
ex2readram_mem_en_ffout,
ex2readram_addr_ffout,
ex2readram_opmode_ffout,
ex2mem_load_ffout, ex2mem_store_ffout,
ex2mem_rd_is_x1_ffout,
ex2mem_rd_is_xn_ffout,
ex2mem_exp_ffout,
ex2mem_pc_ffout ,
ex2mem_wr_csrreg_ffout   ,
ex2mem_wr_csrindex_ffout ,
ex2mem_wr_csrwdata_ffout ,
ex2mem_mret_ffout,
ex2mem_e_ecfm_ffout,
ex2mem_e_bk_ffout,
ex2mem_mstatus_pmie_ffout,
ex2mem_mstatus_mie_ffout ,
ex2mem_mtvec_ffout       ,
ex2mem_mepc_ffout        ,
ex2mem_causecode_ffout  ,
ex2mem_mtval_ffout ,
ex2mem_rv16_ffout



);

input clk, cpurst;
input memacc_stall;
input mult_stall, div_stall; //, mem_stall, readram_stall, 
input exe_store_load_conflict; //, interrupt;
input ex2mem_wr_reg;
input [4:0] ex2mem_wr_regindex;
input [31:0] ex2mem_wr_wdata;
input [31:0] ex2mem_memaddr;
input ex2mem_wr_mem;
input [31:0] ex2mem_wr_memwdata;
input [2:0] ex2mem_mem_op;
input ex2mem_mem_en;
input ex2readram_mem_en;
input [31:0] ex2readram_addr;
input [2:0] ex2readram_opmode;
input ex2mem_load, ex2mem_store;
input ex2mem_rd_is_x1, ex2mem_rd_is_xn;
input ex2mem_exp;
input [31:0] ex2mem_pc;
input ex2mem_wr_csrreg   ;
input [11:0] ex2mem_wr_csrindex ;
input [31:0] ex2mem_wr_csrwdata ;
input mem2wb_exp_ffout;
input ex2mem_mret;
input ex2mem_e_ecfm;
input ex2mem_e_bk;
input ex2mem_mstatus_pmie ;
input ex2mem_mstatus_mie  ;
input [31:0] ex2mem_mtvec        ;
input [31:0] ex2mem_mepc         ;
input [4:0] ex2mem_causecode    ;
input [31:0] ex2mem_mtval        ;
input ex2mem_rv16         ;


output ex2mem_wr_reg_ffout;
output [4:0] ex2mem_wr_regindex_ffout;
output [31:0] ex2mem_wr_wdata_ffout;
output [31:0] ex2mem_memaddr_ffout;
output ex2mem_wr_mem_ffout;
output [31:0] ex2mem_wr_memwdata_ffout;
output [2:0] ex2mem_mem_op_ffout;
output ex2mem_mem_en_ffout;
output ex2readram_mem_en_ffout;
output [31:0] ex2readram_addr_ffout;
output [2:0] ex2readram_opmode_ffout;
output ex2mem_load_ffout, ex2mem_store_ffout;
output ex2mem_rd_is_x1_ffout, ex2mem_rd_is_xn_ffout;
output ex2mem_exp_ffout;
output [31:0] ex2mem_pc_ffout;
output ex2mem_wr_csrreg_ffout   ;
output [11:0] ex2mem_wr_csrindex_ffout ;
output [31:0] ex2mem_wr_csrwdata_ffout ;
output ex2mem_mret_ffout;
output ex2mem_e_ecfm_ffout;
output ex2mem_e_bk_ffout;
output ex2mem_mstatus_pmie_ffout ;
output ex2mem_mstatus_mie_ffout  ;
output [31:0] ex2mem_mtvec_ffout        ;
output [31:0] ex2mem_mepc_ffout         ;
output [4:0] ex2mem_causecode_ffout    ;
output [31:0] ex2mem_mtval_ffout        ;
output ex2mem_rv16_ffout         ;


reg ex2mem_wr_reg_ffout;
reg [4:0] ex2mem_wr_regindex_ffout;
reg [31:0] ex2mem_wr_wdata_ffout;
reg [31:0] ex2mem_memaddr_ffout;
reg ex2mem_wr_mem_ffout;
reg [31:0] ex2mem_wr_memwdata_ffout;
reg [2:0] ex2mem_mem_op_ffout;
reg ex2mem_mem_en_ffout;
reg ex2readram_mem_en_ffout;
reg [31:0] ex2readram_addr_ffout;
reg [2:0] ex2readram_opmode_ffout;
reg ex2mem_load_ffout, ex2mem_store_ffout;
reg ex2mem_rd_is_x1_ffout, ex2mem_rd_is_xn_ffout;
reg ex2mem_exp_ffout;
reg ex2mem_wr_csrreg_ffout   ;
reg [11:0] ex2mem_wr_csrindex_ffout ;
reg [31:0] ex2mem_wr_csrwdata_ffout ;
reg ex2mem_mret_ffout;
reg ex2mem_e_ecfm_ffout;
reg ex2mem_e_bk_ffout;
reg ex2mem_mstatus_pmie_ffout ;
reg ex2mem_mstatus_mie_ffout  ;
reg [31:0] ex2mem_mtvec_ffout        ;
reg [31:0] ex2mem_mepc_ffout         ;
reg [4:0] ex2mem_causecode_ffout    ;
reg [31:0] ex2mem_mtval_ffout        ;
reg ex2mem_rv16_ffout         ;

wire stall = memacc_stall;
always @(posedge clk)
begin
   if (   cpurst ||
         (mult_stall & (!stall)) ||
         (div_stall  & (!stall)) ||
         (exe_store_load_conflict & (!stall))
      )   
        
      //    (mult_stall || div_stall || (exe_store_load_conflict & mem_stall==0) ) )//|| 
           /**< insert dummy NOP command to flush pipeline */
     begin
       //ex2mem_pc_ffout = ex2mem_pc;
       ex2mem_wr_reg_ffout <= 0;
       ex2mem_wr_regindex_ffout <= 0;
       ex2mem_wr_wdata_ffout <= 0;
       ex2mem_memaddr_ffout <= 0;
       ex2mem_wr_mem_ffout <= 0;
       ex2mem_wr_memwdata_ffout <= 0;
       ex2mem_mem_op_ffout <= 0;
       ex2mem_mem_en_ffout <= 0;
       ex2mem_load_ffout <= 0;
       ex2mem_store_ffout <= 0 ;
       ex2readram_mem_en_ffout <= 0;
       ex2readram_addr_ffout <= 0;
       ex2readram_opmode_ffout <= 0;
       ex2mem_rd_is_x1_ffout <=0;
       ex2mem_rd_is_xn_ffout <=0;
       ex2mem_exp_ffout <= 0;
       ex2mem_wr_csrreg_ffout <= 0;
       ex2mem_wr_csrindex_ffout <= 0;
       ex2mem_wr_csrwdata_ffout <= 0;
       ex2mem_mret_ffout <= 0;
       ex2mem_e_ecfm_ffout <= 0;
       ex2mem_e_bk_ffout   <= 0;
       ex2mem_mstatus_pmie_ffout <= 0;
       ex2mem_mstatus_mie_ffout  <= 0;
       ex2mem_mtvec_ffout        <= 0;
       ex2mem_mepc_ffout         <= 0;
       ex2mem_causecode_ffout    <= 0;
       ex2mem_mtval_ffout        <= 0;
       ex2mem_rv16_ffout         <= 0;
     end
//   else  if ( mem_stall==0 && readram_stall==0 )
   else  if ( stall==0 )
     begin
       //ex2mem_pc_ffout = ex2mem_pc;
       ex2mem_wr_reg_ffout <= ex2mem_wr_reg;
       ex2mem_wr_regindex_ffout <= ex2mem_wr_regindex;
       ex2mem_wr_wdata_ffout <= ex2mem_wr_wdata;
       ex2mem_memaddr_ffout <= ex2mem_memaddr;
       ex2mem_wr_mem_ffout <= ex2mem_wr_mem;
       ex2mem_wr_memwdata_ffout <= ex2mem_wr_memwdata;
       ex2mem_mem_op_ffout <= ex2mem_mem_op;
       ex2mem_mem_en_ffout <= ex2mem_mem_en;
       ex2mem_load_ffout <= ex2mem_load;
       ex2mem_store_ffout <= ex2mem_store;
       ex2readram_mem_en_ffout <= ex2readram_mem_en;
       ex2readram_addr_ffout <= ex2readram_addr;
       ex2readram_opmode_ffout <= ex2readram_opmode;
       ex2mem_rd_is_x1_ffout <= ex2mem_rd_is_x1;
       ex2mem_rd_is_xn_ffout <= ex2mem_rd_is_xn;
       ex2mem_exp_ffout <= ex2mem_exp;
       ex2mem_wr_csrreg_ffout <= ex2mem_wr_csrreg;
       ex2mem_wr_csrindex_ffout <= ex2mem_wr_csrindex;
       ex2mem_wr_csrwdata_ffout <= ex2mem_wr_csrwdata;
       ex2mem_mret_ffout <= ex2mem_mret;
       ex2mem_e_ecfm_ffout <= ex2mem_e_ecfm;
       ex2mem_e_bk_ffout   <= ex2mem_e_bk;
       ex2mem_mstatus_pmie_ffout <= ex2mem_mstatus_pmie;
       ex2mem_mstatus_mie_ffout  <= ex2mem_mstatus_mie;
       ex2mem_mtvec_ffout        <= ex2mem_mtvec;
       ex2mem_mepc_ffout         <= ex2mem_mepc;
       ex2mem_causecode_ffout    <= ex2mem_causecode;
       ex2mem_mtval_ffout        <= ex2mem_mtval;
       ex2mem_rv16_ffout         <= ex2mem_rv16;
     end
end

reg [31:0] ex2mem_pc_ffout;
always @(posedge clk)
begin
   if (cpurst)
     ex2mem_pc_ffout <= 0;
   else if (~stall)
     ex2mem_pc_ffout <= ex2mem_pc;
end     

endmodule
