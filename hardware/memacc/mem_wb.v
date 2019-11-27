module mem_wb(
clk, cpurst,
memacc_stall,
//mem_stall, readram_stall, exe_store_load_conflict,  interrupt,
mem2wb_rd_is_x1,
mem2wb_rd_is_xn,
mem2wb_wr_reg,
mem2wb_wr_regindex,
mem2wb_wr_wdata,
mem2wb_pc,
mem2wb_exp,
mem2wb_wr_csrreg   ,
mem2wb_wr_csrindex ,
mem2wb_wr_csrwdata ,
mem2wb_mret,
mem2wb_e_ecfm,
mem2wb_e_bk,
mem2wb_mstatus_pmie,
mem2wb_mstatus_mie ,
mem2wb_mtvec       ,
mem2wb_mepc        ,
mem2wb_causecode  ,
mem2wb_mtval,
mem2wb_rv16,

mem2wb_wr_reg_ffout,
mem2wb_wr_regindex_ffout,
mem2wb_wr_wdata_ffout,
mem2wb_rd_is_x1_ffout,
mem2wb_rd_is_xn_ffout,
mem2wb_pc_ffout,
mem2wb_exp_ffout,
mem2wb_wr_csrreg_ffout   ,
mem2wb_wr_csrindex_ffout ,
mem2wb_wr_csrwdata_ffout ,
mem2wb_mret_ffout,
mem2wb_e_ecfm_ffout,
mem2wb_e_bk_ffout,
mem2wb_mstatus_pmie_ffout,
mem2wb_mstatus_mie_ffout ,
mem2wb_mtvec_ffout       ,
mem2wb_mepc_ffout        ,
mem2wb_causecode_ffout  ,
mem2wb_mtval_ffout ,
mem2wb_rv16_ffout

);

input clk, cpurst;
input memacc_stall;
//input mem_stall, readram_stall, exe_store_load_conflict, interrupt;
input mem2wb_rd_is_x1;
input mem2wb_rd_is_xn;
input mem2wb_wr_reg;
input [4:0] mem2wb_wr_regindex;
input [31:0] mem2wb_wr_wdata;
input [31:0] mem2wb_pc;
input mem2wb_exp;
input mem2wb_wr_csrreg   ;
input [11:0] mem2wb_wr_csrindex ;
input [31:0] mem2wb_wr_csrwdata ;
input mem2wb_mret;
input mem2wb_e_ecfm;
input mem2wb_e_bk;
input mem2wb_mstatus_pmie;
input mem2wb_mstatus_mie; 
input [31:0] mem2wb_mtvec;       
input [31:0] mem2wb_mepc;        
input [4:0] mem2wb_causecode;   
input [31:0] mem2wb_mtval;       
input mem2wb_rv16;        

output mem2wb_wr_reg_ffout;
output [4:0] mem2wb_wr_regindex_ffout;
output [31:0] mem2wb_wr_wdata_ffout;
output mem2wb_rd_is_x1_ffout;
output mem2wb_rd_is_xn_ffout;
output [31:0] mem2wb_pc_ffout;
output mem2wb_exp_ffout;
output mem2wb_wr_csrreg_ffout   ;
output [11:0] mem2wb_wr_csrindex_ffout ;
output [31:0] mem2wb_wr_csrwdata_ffout ;
output mem2wb_mret_ffout;
output mem2wb_e_ecfm_ffout;
output mem2wb_e_bk_ffout;
output mem2wb_mstatus_pmie_ffout ; 
output mem2wb_mstatus_mie_ffout  ; 
output [31:0] mem2wb_mtvec_ffout        ; 
output [31:0] mem2wb_mepc_ffout         ; 
output [4:0] mem2wb_causecode_ffout    ; 
output [31:0] mem2wb_mtval_ffout        ; 
output mem2wb_rv16_ffout         ; 

reg mem2wb_wr_reg_ffout;
reg [4:0] mem2wb_wr_regindex_ffout;
reg [31:0] mem2wb_wr_wdata_ffout;
reg mem2wb_rd_is_x1_ffout;
reg mem2wb_rd_is_xn_ffout;
reg mem2wb_wr_csrreg_ffout   ;
reg [11:0] mem2wb_wr_csrindex_ffout ;
reg [31:0] mem2wb_wr_csrwdata_ffout ;
reg mem2wb_exp_ffout;
reg mem2wb_mret_ffout;
reg mem2wb_e_ecfm_ffout;
reg mem2wb_e_bk_ffout;
reg mem2wb_mstatus_pmie_ffout ; 
reg mem2wb_mstatus_mie_ffout  ; 
reg [31:0] mem2wb_mtvec_ffout        ; 
reg [31:0] mem2wb_mepc_ffout         ; 
reg [4:0] mem2wb_causecode_ffout    ; 
reg [31:0] mem2wb_mtval_ffout        ; 
reg mem2wb_rv16_ffout         ; 


// there is no stall case : write back cannot be stall
always @(posedge clk)
begin
   if (cpurst ||
       memacc_stall
      )
    // (mem_stall==1 || readram_stall==1 || exe_store_load_conflict==1) ) //|| (mem2wb_exp_ffout || interrupt) )   /**< insert dummy NOP command to flush pipeline */
     begin

       //mem2wb_pc_ffout = mem2wb_pc;
       
       mem2wb_wr_reg_ffout <=  0;
       mem2wb_wr_regindex_ffout <= 0;
       mem2wb_wr_wdata_ffout <= 0;
       mem2wb_rd_is_x1_ffout <= 0;
       mem2wb_rd_is_xn_ffout <= 0;
       mem2wb_exp_ffout <= 0;
       mem2wb_wr_csrreg_ffout <= 0;
       mem2wb_wr_csrindex_ffout <= 0;
       mem2wb_wr_csrwdata_ffout <= 0;
       mem2wb_mret_ffout <= 0;
       mem2wb_e_ecfm_ffout <= 0;
       mem2wb_e_bk_ffout   <= 0;
       mem2wb_mstatus_pmie_ffout <= 0;
       mem2wb_mstatus_mie_ffout  <= 0;
       mem2wb_mtvec_ffout        <= 0;
       mem2wb_mepc_ffout         <= 0;
       mem2wb_causecode_ffout    <= 0;
       mem2wb_mtval_ffout        <= 0;
       mem2wb_rv16_ffout         <= 0;
     end
   else
     begin
       //mem2wb_pc_ffout = mem2wb_pc;
       mem2wb_wr_reg_ffout <=  mem2wb_wr_reg;
       mem2wb_wr_regindex_ffout <= mem2wb_wr_regindex;
       mem2wb_wr_wdata_ffout <= mem2wb_wr_wdata;
       mem2wb_rd_is_x1_ffout <= mem2wb_rd_is_x1;
       mem2wb_rd_is_xn_ffout <= mem2wb_rd_is_xn;
       mem2wb_exp_ffout <= mem2wb_exp;
       mem2wb_wr_csrreg_ffout <= mem2wb_wr_csrreg;
       mem2wb_wr_csrindex_ffout <= mem2wb_wr_csrindex;
       mem2wb_wr_csrwdata_ffout <= mem2wb_wr_csrwdata;
       mem2wb_mret_ffout <= mem2wb_mret;
       mem2wb_e_ecfm_ffout <= mem2wb_e_ecfm;
       mem2wb_e_bk_ffout   <= mem2wb_e_bk;
       mem2wb_mstatus_pmie_ffout <= mem2wb_mstatus_pmie;
       mem2wb_mstatus_mie_ffout  <= mem2wb_mstatus_mie;
       mem2wb_mtvec_ffout        <= mem2wb_mtvec;
       mem2wb_mepc_ffout         <= mem2wb_mepc;
       mem2wb_causecode_ffout    <= mem2wb_causecode;
       mem2wb_mtval_ffout        <= mem2wb_mtval;
       mem2wb_rv16_ffout         <= mem2wb_rv16;
     end
end

reg [31:0] mem2wb_pc_ffout;
always @(posedge clk)
begin
   if (cpurst)
     mem2wb_pc_ffout <= 0;
   else
     mem2wb_pc_ffout <= mem2wb_pc;  
end     
endmodule
