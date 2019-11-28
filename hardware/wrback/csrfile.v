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
fe2de_rv16, fetch_pc,
mip_msip, mip_mtip, mip_meip,
//wb2csrfile_exp         ,
wb2csrfile_int         ,
//wb2csrfile_mret        ,
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
ex2mem_mtval, mem2wb_mtval, wb2csrfile_mtval,
ex2mem_causecode, mem2wb_causecode, wb2csrfile_causecode,
ex2mem_mtvec, mem2wb_mtvec, wb2csrfile_mtvec,
ex2mem_mepc, mem2wb_mepc, wb2csrfile_mepc,
ex2mem_mstatus_mie, mem2wb_mstatus_mie, wb2csrfile_mstatus_mie,
ex2mem_mstatus_pmie, mem2wb_mstatus_pmie, wb2csrfile_mstatus_pmie,
wb2csrfile_rv16,
ex2mem_mret, mem2wb_mret, wb2csrfile_mret,
ex2mem_exp, mem2wb_exp, wb2csrfile_exp,
//        
mstatus                ,
mie                    ,
mtvec                  ,
mepc                   ,
mcause                 ,
mtval                  ,
mip                    ,
csr_rdat               ,
g_int                  ,
causecode_int

);

input clk, cpurst      ;
input fe2de_rv16;
input [31:0] fetch_pc;
input mip_msip, mip_mtip, mip_meip;
//input wb2csrfile_exp   ;
input wb2csrfile_int   ;
//input wb2csrfile_mret  ;
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
input [31:0] ex2mem_mtval, mem2wb_mtval, wb2csrfile_mtval;
input [4:0] ex2mem_causecode, mem2wb_causecode, wb2csrfile_causecode;
input [31:0] ex2mem_mtvec, mem2wb_mtvec, wb2csrfile_mtvec;
input [31:0] ex2mem_mepc, mem2wb_mepc, wb2csrfile_mepc;
input ex2mem_mstatus_mie, mem2wb_mstatus_mie, wb2csrfile_mstatus_mie;
input ex2mem_mstatus_pmie, mem2wb_mstatus_pmie, wb2csrfile_mstatus_pmie;
input wb2csrfile_rv16;
input ex2mem_mret, mem2wb_mret, wb2csrfile_mret;
input ex2mem_exp, mem2wb_exp, wb2csrfile_exp;

output [31:0] mstatus ; 
output [31:0] mie     ;
output [31:0] mtvec   ;
output [31:0] mepc    ;
output [31:0] mcause  ;
output [31:0] mtval   ;
output [31:0] mip     ;
output [31:0] csr_rdat;
output g_int;
output [4:0] causecode_int;

reg mie_meie, mie_mtie, mie_msie;
reg mstatus_mie, mstatus_pmie;

//individual int enable
wire int_indi = (mip_mtip & mie_mtie) | (mip_msip & mie_msie) | (mip_meip & mie_meie);
//global int enable
assign g_int = int_indi & mstatus_mie;


//wire wb2csrfile_intorexp = wb2csrfile_exp | wb2csrfile_int_i;
//
always @(posedge clk)
begin
  if (cpurst)
    begin
      mstatus_mie <= 1'b0;
      mstatus_pmie <= 1'b0;
    end
  else if (wb2csrfile_int)  // int happen, turn-off mie
    begin
      mstatus_mie <= 1'b0;
      mstatus_pmie <= wb2csrfile_mstatus_mie;
    end
  else if (wb2csrfile_exp)
    begin
      mstatus_mie <= 1'b0;
      mstatus_pmie <= wb2csrfile_mstatus_mie;
    end
  else if (wb2csrfile_mret)
    begin
      mstatus_mie <= wb2csrfile_mstatus_pmie;
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
reg [31:0] mscratch;
always @(posedge clk)
begin
  if (cpurst)
    begin
      mscratch <= 30'b0;
    end
  else if (wb2csrfile_wr_reg && wb2csrfile_wr_regindex[11:0]==12'h340)
    begin
      mscratch <= wb2csrfile_wr_wdata[31:0];
    end
end

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
      mepc <= wb2csrfile_rv16 ? mem2wb_pc_ffout+ 3'd2 : mem2wb_pc_ffout+ 3'd4; //ex2mem_pc_ffout[31:0];  // next instr pc
    //  mepc <= fe2de_rv16 ? fetch_pc+ 3'd2 : fetch_pc+ 3'd4; //
    end    
  else if (wb2csrfile_wr_reg && wb2csrfile_wr_regindex[11:0]==12'h341)
    begin
      mepc <= wb2csrfile_wr_wdata[31:0];
    end
end
//
wire [4:0] causecode_int = mip_msip & mie_msie   ? 5'd3 : 
                           mip_mtip & mie_mtie   ? 5'd7 :
                           mip_meip & mie_meie   ? 5'd11 :
                           5'd16;        
reg [4:0] causecode;
reg cause_int;
always @(posedge clk)
begin
  if (cpurst)
    begin
      causecode <= 5'b0;
      cause_int <= 1'b0;
    end
/////  else if (g_int)
/////    begin
/////      causecode <= causecode_int;//causecode_t;
/////      cause_int <= 1'b1;
/////    end  
  else if (wb2csrfile_int)
    begin
      causecode <= wb2csrfile_causecode;//causecode_t;
      cause_int <= 1'b0;
    end  
  else if (wb2csrfile_exp)
    begin
      causecode <= wb2csrfile_causecode;//causecode_t;
      cause_int <= 1'b0;
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
     // mtval <= (wb2csrfile_e_ii | wb2csrfile_e_bk | wb2csrfile_e_ecfm) ? mem2wb_instr_ffout : mem2wb_pc_ffout;
      mtval <= wb2csrfile_mtval; //(wb2csrfile_e_ii ) ? mem2wb_instr_ffout : mem2wb_pc_ffout;
    end
end
//
/////reg mip_meip, mip_mtip, mip_msip;
/////always @(posedge clk)
/////begin
/////  if (cpurst)
/////    begin
/////      mip_meip <= 1'b0;
/////      mip_mtip <= 1'b0;
/////      mip_msip <= 1'b0;
/////    end
/////  else if (wb2csrfile_wr_reg && wb2csrfile_wr_regindex[11:0]==12'h344)
/////    begin
/////      mip_meip <= wb2csrfile_wr_wdata[3];
/////      mip_mtip <= wb2csrfile_wr_wdata[7];
/////      mip_msip <= wb2csrfile_wr_wdata[11];
/////    end
/////end
//mip read-only register
assign mip = {20'b0, mip_msip, 3'b0, mip_mtip, 3'b0, mip_meip, 3'b0};
//
reg [31:0] csr_rdat;
reg mstatus_index, mtvec_index, mepc_index, mcause_index, mtval_index;
always @*
begin
  csr_rdat =0;
  mstatus_index= (csr_r_index==12'h300);
  mtvec_index  = (csr_r_index==12'h305);
  mepc_index   = (csr_r_index==12'h341);
  mcause_index = (csr_r_index==12'h342);
  mtval_index  = (csr_r_index==12'h343);
  
  // "read before write conflict" at csrfile
  /**< priority is important, otherwise function error in case (repeat r15 = r15 - r1) */
  //ex2mem 1st priority, then mem2wb, then wb2csrfile/wb2reg
  if (ex2mem_mret & mstatus_index)
    csr_rdat = {19'b0, 2'b11, 3'b0, 1'b0, 3'b0, ex2mem_mstatus_pmie, 3'b0} & {32{mstatus_index}};    
  else if (ex2mem_exp & (mstatus_index|mtvec_index|mepc_index|mtval_index|mcause_index))
    csr_rdat = {19'b0, 2'b11, 3'b0, ex2mem_mstatus_mie, 3'b0, 1'b0, 3'b0} & {32{mstatus_index}} |
               ex2mem_mtvec & {32{mtvec_index}} |
               ex2mem_mepc  & {32{mepc_index}}  |
               ex2mem_mtval  & {32{mtval_index}}  |
               {cause_int, 26'b0, ex2mem_causecode[4:0]} & {32{mcause_index}};
  else if (ex2mem_wr_csrindex == csr_r_index && ex2mem_wr_csrreg )  /**< ex/de data dependence , 1st priority*/
      csr_rdat = ex2mem_wr_csrwdata;
  
  //2nd priority
  else if (mem2wb_exp & (mstatus_index|mtvec_index|mepc_index|mtval_index|mcause_index))
    csr_rdat = {19'b0, 2'b11, 3'b0, mem2wb_mstatus_mie, 3'b0, 1'b0, 3'b0} & {32{mstatus_index}} |
               mem2wb_mtvec & {32{mtvec_index}} |
               mem2wb_mepc  & {32{mepc_index}}  |
               mem2wb_mtval  & {32{mtval_index}}  |
               {cause_int, 26'b0, mem2wb_causecode[4:0]} & {32{mcause_index}};
  else if (mem2wb_mret & mstatus_index)
    csr_rdat = {19'b0, 2'b11, 3'b0, 1'b0, 3'b0, mem2wb_mstatus_pmie, 3'b0} & {32{mstatus_index}};
  else if (ex2mem_wr_csrindex_ffout == csr_r_index && mem2wb_wr_csrreg)  /**< mem/de data dependence, 2nd priority */
      csr_rdat = mem2wb_wr_csrwdata;
  
  //3rd priority
  else if (wb2csrfile_exp & (mstatus_index|mtvec_index|mepc_index|mtval_index|mcause_index))
    csr_rdat = {19'b0, 2'b11, 3'b0, wb2csrfile_mstatus_mie, 3'b0, 1'b0, 3'b0} & {32{mstatus_index}} |
               wb2csrfile_mtvec & {32{mtvec_index}} |
               wb2csrfile_mepc  & {32{mepc_index}}  |
               wb2csrfile_mtval  & {32{mtval_index}}  |
               {cause_int, 26'b0, wb2csrfile_causecode[4:0]} & {32{mcause_index}};
  else if (wb2csrfile_mret & mstatus_index)
    csr_rdat = {19'b0, 2'b11, 3'b0, 1'b0, 3'b0, wb2csrfile_mstatus_pmie, 3'b0} & {32{mstatus_index}};
  else if (mem2wb_wr_csrindex_ffout == csr_r_index && mem2wb_wr_csrreg_ffout)  /**< wb/de data dependence, 3rd priority */
      csr_rdat = mem2wb_wr_csrwdata_ffout;

  else    
    begin
      case(csr_r_index[11:0])
        12'hf11:
          csr_rdat = 32'b0;  //mvendorID,
        12'hf12:
          csr_rdat = 32'b0;  //marchID,
        12'hf13:
          csr_rdat = 32'b0;  //mimpID,
        12'hf14:
          csr_rdat = 32'b0;  //mhartID,

//a value of zero can be returned to
//indicate the misa register has not been implemented, requiring that CPU capabilities be determined
//through a separate non-standard mechanism.  
        12'h301:
          csr_rdat = 32'b0;  //misa,
        12'h300:
          csr_rdat = mstatus[31:0];
        12'h304:
          csr_rdat = mie[31:0];
        12'h305:
          csr_rdat = mtvec[31:0];
        12'h340:
          csr_rdat = mscratch[31:0];
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