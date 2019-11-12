//#include "regfile.h"
//#include "globalsig.h"
module regfile(
clk, cpurst,
ex2mem_wr_regindex, ex2mem_wr_regindex_ffout, mem2wb_wr_regindex_ffout,
rs1_addr, rs2_addr, rs3_addr, wb2regfile_wr_regindex,
ex2mem_wr_reg, mem2wb_wr_reg, mem2wb_wr_reg_ffout, wb2regfile_wr_reg,
ex2mem_wr_wdata, mem2wb_wr_wdata, mem2wb_wr_wdata_ffout, wb2regfile_wr_wdata,
rs1v,rs2v, rs3v, r_x1
);

input clk, cpurst;
input [4:0] ex2mem_wr_regindex, ex2mem_wr_regindex_ffout, mem2wb_wr_regindex_ffout;
input [4:0] rs1_addr, rs2_addr, rs3_addr, wb2regfile_wr_regindex;
input ex2mem_wr_reg, mem2wb_wr_reg, mem2wb_wr_reg_ffout, wb2regfile_wr_reg;
input [31:0] ex2mem_wr_wdata, mem2wb_wr_wdata, mem2wb_wr_wdata_ffout, wb2regfile_wr_wdata;
output [31:0] rs1v,rs2v, rs3v;
output [31:0] r_x1;

reg [31:0] regfile_xx[31:1];


//assign r_x1 = regfile_xx[1];
reg [31:0] r_x1;
always @*
begin
    if (rs3_addr==5'b0)
        r_x1 =0;
    /**< priority is important, otherwise function error in case (repeat r15 = r15 - r1) */
    else if (ex2mem_wr_regindex == rs3_addr && ex2mem_wr_reg )  /**< ex/de data dependence , 1st priority*/
        r_x1 = ex2mem_wr_wdata;
    
    else if (ex2mem_wr_regindex_ffout == rs3_addr && mem2wb_wr_reg)  /**< mem/de data dependence, 2nd priority */
        r_x1 = mem2wb_wr_wdata;
    
    else if (mem2wb_wr_regindex_ffout == rs3_addr && mem2wb_wr_reg_ffout)  /**< wb/de data dependence, 3rd priority */
        r_x1 = mem2wb_wr_wdata_ffout;
    
    else
        r_x1 = regfile_xx[1];
end

integer i;
always @(posedge clk)
begin
  if (cpurst)
     begin
       for (i=1;i<=31;i=i+1)
         regfile_xx[i] <= 0;
     end
  else if (wb2regfile_wr_reg && wb2regfile_wr_regindex!=0)
    regfile_xx[wb2regfile_wr_regindex] <= wb2regfile_wr_wdata;
end


reg [31:0] rs1v;
always @*
begin
    if (rs1_addr==5'b0)
        rs1v =0;
    /**< priority is important, otherwise function error in case (repeat r15 = r15 - r1) */
    else if (ex2mem_wr_regindex == rs1_addr && ex2mem_wr_reg )  /**< ex/de data dependence , 1st priority*/
        rs1v = ex2mem_wr_wdata;
    
    else if (ex2mem_wr_regindex_ffout == rs1_addr && mem2wb_wr_reg)  /**< mem/de data dependence, 2nd priority */
        rs1v = mem2wb_wr_wdata;
    
    else if (mem2wb_wr_regindex_ffout == rs1_addr && mem2wb_wr_reg_ffout)  /**< wb/de data dependence, 3rd priority */
        rs1v = mem2wb_wr_wdata_ffout;
    
    else
        rs1v = regfile_xx[rs1_addr];
end

reg [31:0] rs2v;
always @*
begin
    if (rs2_addr==5'b0)
        rs2v =0;
    /**< priority is important, otherwise function error in case (repeat r15 = r15 - r1) */
    else if (ex2mem_wr_regindex == rs2_addr && ex2mem_wr_reg )  /**< ex/de data dependence , 1st priority*/
        rs2v = ex2mem_wr_wdata;
    
    else if (ex2mem_wr_regindex_ffout == rs2_addr && mem2wb_wr_reg)  /**< mem/de data dependence, 2nd priority */
        rs2v = mem2wb_wr_wdata;
    
    else if (mem2wb_wr_regindex_ffout == rs2_addr && mem2wb_wr_reg_ffout)  /**< wb/de data dependence, 3rd priority */
        rs2v = mem2wb_wr_wdata_ffout;
    
    else
        rs2v = regfile_xx[rs2_addr];
end 

reg [31:0] rs3v;
always @*
begin
    if (rs3_addr==5'b0)
        rs3v =0;
    /**< priority is important, otherwise function error in case (repeat r15 = r15 - r1) */
    else if (ex2mem_wr_regindex == rs3_addr && ex2mem_wr_reg )  /**< ex/de data dependence , 1st priority*/
        rs3v = ex2mem_wr_wdata;
    
    else if (ex2mem_wr_regindex_ffout == rs3_addr && mem2wb_wr_reg)  /**< mem/de data dependence, 2nd priority */
        rs3v = mem2wb_wr_wdata;
    
    else if (mem2wb_wr_regindex_ffout == rs3_addr && mem2wb_wr_reg_ffout)  /**< wb/de data dependence, 3rd priority */
        rs3v = mem2wb_wr_wdata_ffout;
    
    else
        rs3v = regfile_xx[rs3_addr];
end 

endmodule
