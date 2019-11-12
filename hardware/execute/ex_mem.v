module ex_mem(
clk, cpurst,
mult_stall, mem_stall, readram_stall, exe_store_load_conflict, interrupt,
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
ex2mem_mret_ffout


);

input clk, cpurst;
input mult_stall, mem_stall, readram_stall, exe_store_load_conflict, interrupt;
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

always @(posedge clk)
begin
   if (cpurst ||
          (mult_stall || (exe_store_load_conflict & mem_stall==0) ) || (mem2wb_exp_ffout || interrupt) ) /**< insert dummy NOP command to flush pipeline */
//////////////////          (mult_stall && mem_stall==0 && readram_stall==0 && exe_store_load_conflict==0) || (mem2wb_exp_ffout || interrupt) ) /**< insert dummy NOP command to flush pipeline */
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
     end
/////////////   else  if ( mem_stall==0 && readram_stall==0 && exe_store_load_conflict==0 )
   else  if ( mem_stall==0 && readram_stall==0  )
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
     end
end

reg [31:0] ex2mem_pc_ffout;
always @(posedge clk)
begin
   if (cpurst)
     ex2mem_pc_ffout <= 0;
   else
     ex2mem_pc_ffout <= ex2mem_pc;
end     

endmodule
