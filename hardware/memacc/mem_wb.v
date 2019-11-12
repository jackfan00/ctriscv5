module mem_wb(
clk, cpurst,
mem_stall, readram_stall, exe_store_load_conflict,  interrupt,
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
mem2wb_mret_ffout

);

input clk, cpurst;
input mem_stall, readram_stall, exe_store_load_conflict, interrupt;
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

always @(posedge clk)
begin
   if (cpurst ||
     (mem_stall==1 || readram_stall==1 || exe_store_load_conflict==1) || (mem2wb_exp_ffout || interrupt) )   /**< insert dummy NOP command to flush pipeline */
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
     end
end

reg [31:0] mem2wb_pc_ffout;
always @(posedge clk)
begin
   if (cpurst)
     mem2wb_pc_ffout = 0;
   else
     mem2wb_pc_ffout = mem2wb_pc;  
end     
endmodule
