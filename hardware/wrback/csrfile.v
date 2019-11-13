// mstatus
// mie
// mtvec
// mepc
// mcause
// mtval
// mip
// mcycle
// mcycleh
// minstret
// minstreth

module csrfile(
clk, cpurst,
wb2csrfile_exp         ,
wb2csrfile_int         ,
wb2csrfile_mret        ,
wb2csrfile_wr_reg      ,
wb2csrfile_wr_regindex , ex2mem_wr_csrreg, mem2wb_wr_csrreg, mem2wb_wr_csrreg_ffout,
csr_r_index   , ex2mem_wr_csrindex, ex2mem_wr_csrindex_ffout, mem2wb_wr_csrindex_ffout,
wb2csrfile_wr_wdata    , ex2mem_wr_csrwdata, mem2wb_wr_csrwdata, mem2wb_wr_csrwdata_ffout,
wb2csrfile_i_ms        ,
wb2csrfile_i_mt        ,
wb2csrfile_i_me        ,
wb2csrfile_e_iam       ,
wb2csrfile_e_ii        ,
wb2csrfile_e_bk        ,
wb2csrfile_e_lam       ,
wb2csrfile_e_ecfm      ,
mem2wb_instr_ffout     ,
mem2wb_pc_ffout        ,
ex2mem_pc_ffout        ,
                         
mstatus                ,
mie                    ,
mtvec                  ,
mepc                   ,
mcause                 ,
mtval                  ,
mip                    ,
csr_rdat

);

input clk, cpurst      ;
input wb2csrfile_exp   ;
input wb2csrfile_int   ;
input wb2csrfile_mret  ;
input wb2csrfile_wr_reg, ex2mem_wr_csrreg, mem2wb_wr_csrreg, mem2wb_wr_csrreg_ffout;
input [11:0] wb2csrfile_wr_regindex;
input [11:0] csr_r_index, ex2mem_wr_csrindex, ex2mem_wr_csrindex_ffout, mem2wb_wr_csrindex_ffout;
input [31:0] wb2csrfile_wr_wdata, ex2mem_wr_csrwdata, mem2wb_wr_csrwdata, mem2wb_wr_csrwdata_ffout ;
input wb2csrfile_i_ms  ;
input wb2csrfile_i_mt  ;
input wb2csrfile_i_me  ;
input wb2csrfile_e_iam ;
input wb2csrfile_e_ii  ;
input wb2csrfile_e_bk  ;
input wb2csrfile_e_lam ;
input wb2csrfile_e_ecfm;
input [31:0] mem2wb_instr_ffout;
input [31:0] mem2wb_pc_ffout   ;
input [31:0] ex2mem_pc_ffout   ;

output [31:0] mstatus ; 
output [31:0] mie     ;
output [31:0] mtvec   ;
output [31:0] mepc    ;
output [31:0] mcause  ;
output [31:0] mtval   ;
output [31:0] mip     ;
output [31:0] csr_rdat;

//
wire wb2csrfile_intorexp = wb2csrfile_exp | wb2csrfile_int;
//
reg mstatus_mie, mstatus_pmie;
always @(posedge clk)
begin
  if (cpurst)
    begin
      mstatus_mie <= 1'b0;
      mstatus_pmie <= 1'b0;
    end
  else if (wb2csrfile_intorexp)
    begin
      mstatus_mie <= 1'b0;
      mstatus_pmie <= mstatus_mie;
    end
  else if (wb2csrfile_mret)
    begin
      mstatus_mie <= mstatus_pmie;
      mstatus_pmie <= 1'b0;
    end
  else if (wb2csrfile_wr_reg && wb2csrfile_wr_regindex[11:0]==12'h300)
    begin
      mstatus_mie <= wb2csrfile_wr_wdata[3];
      mstatus_pmie <= wb2csrfile_wr_wdata[7];
    end
end
assign mstatus = {19'b0, 2'b11, 3'b0, mstatus_pmie, 3'b0, mstatus_mie, 3'b0};
//
reg mie_meie, mie_mtie, mie_msie;
always @(posedge clk)
begin
  if (cpurst)
    begin
      mie_meie <= 1'b0;
      mie_mtie <= 1'b0;
      mie_msie <= 1'b0;
    end
  else if (wb2csrfile_wr_reg && wb2csrfile_wr_regindex[11:0]==12'h304)
    begin
      mie_meie <= wb2csrfile_wr_wdata[3];
      mie_mtie <= wb2csrfile_wr_wdata[7];
      mie_msie <= wb2csrfile_wr_wdata[11];
    end
end
assign mie = {20'b0, mie_msie, 3'b0, mie_mtie, 3'b0, mie_meie, 3'b0};
//
reg [31:2] mtvec_w;
always @(posedge clk)
begin
  if (cpurst)
    begin
      mtvec_w <= 30'b0;
    end
  else if (wb2csrfile_wr_reg && wb2csrfile_wr_regindex[11:0]==12'h305)
    begin
      mtvec_w <= wb2csrfile_wr_wdata[31:2];
    end
end
assign mtvec = {mtvec_w, 2'b01};   //vectored mode
//
reg [31:0] mepc;
always @(posedge clk)
begin
  if (cpurst)
    begin
      mepc <= 32'b0;
    end
  else if (wb2csrfile_exp)
    begin
      mepc <= mem2wb_pc_ffout[31:0];  //current instr pc
    end    
  else if (wb2csrfile_int)
    begin
      mepc <= ex2mem_pc_ffout[31:0];  // next instr pc
    end    
  else if (wb2csrfile_wr_reg && wb2csrfile_wr_regindex[11:0]==12'h341)
    begin
      mepc <= wb2csrfile_wr_wdata[31:0];
    end
end
//
wire [4:0] causecode_t = wb2csrfile_i_ms   ? 5'd3 : 
                         wb2csrfile_i_mt   ? 5'd7 :
                         wb2csrfile_i_me   ? 5'd11 :
                         wb2csrfile_e_iam  ? 5'd0 :
                         wb2csrfile_e_ii   ? 5'd2 :
                         wb2csrfile_e_bk   ? 5'd3 :
                         wb2csrfile_e_lam  ? 5'd4 :
                         wb2csrfile_e_ecfm ? 5'd11 : 5'd16;                       
reg [4:0] causecode;
reg cause_int;
always @(posedge clk)
begin
  if (cpurst)
    begin
      causecode <= 5'b0;
      cause_int <= 1'b0;
    end
  else if (wb2csrfile_intorexp)
    begin
      causecode <= causecode_t;
      cause_int <= wb2csrfile_int;
    end  
end
assign mcause = {cause_int, 26'b0, causecode[4:0]};
//
reg [31:0] mtval;
always @(posedge clk)
begin
  if (cpurst)
    begin
      mtval <= 32'b0;
    end
  else if (wb2csrfile_exp)
    begin
      mtval <= (wb2csrfile_e_ii | wb2csrfile_e_bk | wb2csrfile_e_ecfm) ? mem2wb_instr_ffout : mem2wb_pc_ffout;
    end
end
//
reg mip_meip, mip_mtip, mip_msip;
always @(posedge clk)
begin
  if (cpurst)
    begin
      mip_meip <= 1'b0;
      mip_mtip <= 1'b0;
      mip_msip <= 1'b0;
    end
  else if (wb2csrfile_wr_reg && wb2csrfile_wr_regindex[11:0]==12'h344)
    begin
      mip_meip <= wb2csrfile_wr_wdata[3];
      mip_mtip <= wb2csrfile_wr_wdata[7];
      mip_msip <= wb2csrfile_wr_wdata[11];
    end
end
assign mip = {20'b0, mip_msip, 3'b0, mip_mtip, 3'b0, mip_meip, 3'b0};
//
reg [31:0] csr_rdat;
always @*
begin
  csr_rdat =0;
  /**< priority is important, otherwise function error in case (repeat r15 = r15 - r1) */
  if (ex2mem_wr_csrindex == csr_r_index && ex2mem_wr_csrreg )  /**< ex/de data dependence , 1st priority*/
      csr_rdat = ex2mem_wr_csrwdata;
  
  else if (ex2mem_wr_csrindex_ffout == csr_r_index && mem2wb_wr_csrreg)  /**< mem/de data dependence, 2nd priority */
      csr_rdat = mem2wb_wr_csrwdata;
  
  else if (mem2wb_wr_csrindex_ffout == csr_r_index && mem2wb_wr_csrreg_ffout)  /**< wb/de data dependence, 3rd priority */
      csr_rdat = mem2wb_wr_csrwdata_ffout;
  else    
    begin
      case(csr_r_index[11:0])
        12'h300:
          csr_rdat = mstatus[31:0];
        12'h304:
          csr_rdat = mie[31:0];
        12'h305:
          csr_rdat = mtvec[31:0];
        12'h341:
          csr_rdat = mepc[31:0];
        12'h342:
          csr_rdat = mcause[31:0];
        12'h343:
          csr_rdat = mtval[31:0];
        12'h344:
          csr_rdat = mip[31:0];
    /**
        12'hb00:
          csr_rdat = mcycle[31:0];
        12'hb80:
          csr_rdat = mcycleh[31:0];
        12'hb02:
          csr_rdat = minstret[31:0];
        12'hb82:
          csr_rdat = minstreth[31:0];      
    */
      endcase
    end
end
endmodule