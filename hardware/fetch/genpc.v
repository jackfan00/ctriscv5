module genpc(clk, cpurst, fet_stall,
boot_addr,
r_x1, rs3v,
dec_is_x1, exe_is_x1, mem_is_x1, wb_is_x1,
dec_is_xn, exe_is_xn, mem_is_xn, wb_is_xn,
dec_regfile_wen, exe_regfile_wen, mem_regfile_wen, wb_regfile_wen,
fetch_misalign, 
rv32_instr, 
isrv16, 
branch_predict_err,
de2fe_branch_target,
wb2csrfile_int_ffout,
wb2csrfile_exp_ffout,
mtvec,
mepc,
mcause,
de2ex_wr_csrreg, ex2mem_wr_csrreg, mem2wb_wr_csrreg, mem2wb_wr_csrreg_ffout,
de2ex_wr_csrindex, ex2mem_wr_csrindex, ex2mem_wr_csrindex_ffout, mem2wb_wr_csrindex_ffout,
de2ex_wr_csrwdata, ex2mem_wr_csrwdata, mem2wb_wr_csrwdata, mem2wb_wr_csrwdata_ffout,

isram_adr, 
pc, 
fet_is_x1, fet_is_xn,
isram_cs, 
jb_ff,
jalr_dep, 
isram_cs_ff,
fetch_rs3n,
predict_bxxtaken,
fet_flush
);

input clk, cpurst;
input fet_stall;
input [31:0] boot_addr;
input [31:0] r_x1, rs3v;
input dec_is_x1, exe_is_x1, mem_is_x1, wb_is_x1;
input dec_is_xn, exe_is_xn, mem_is_xn, wb_is_xn;
input dec_regfile_wen, exe_regfile_wen, mem_regfile_wen, wb_regfile_wen;
input fetch_misalign;
input [31:0] rv32_instr;
input isrv16;
input branch_predict_err;
input [31:0] de2fe_branch_target;
input wb2csrfile_int_ffout;
input wb2csrfile_exp_ffout;
input [31:0] mtvec;
input [31:0] mepc;
input [4:0] mcause;
input de2ex_wr_csrreg, ex2mem_wr_csrreg, mem2wb_wr_csrreg, mem2wb_wr_csrreg_ffout;
input [11:0] de2ex_wr_csrindex, ex2mem_wr_csrindex, ex2mem_wr_csrindex_ffout, mem2wb_wr_csrindex_ffout;
input [31:0] de2ex_wr_csrwdata, ex2mem_wr_csrwdata, mem2wb_wr_csrwdata, mem2wb_wr_csrwdata_ffout;

output [31:3] isram_adr;
output [31:0] pc;
output fet_is_x1, fet_is_xn;
output isram_cs;
output jb_ff;
output jalr_dep;
output isram_cs_ff;
output [4:0] fetch_rs3n;
output predict_bxxtaken;
output fet_flush;

wire [31:0] jaloffset, jalroffset, bxxoffset, jalr_xn;
wire [11:0] if_csr_r_index;
mini_decode mini_decode_u (
   .rv32_instr(rv32_instr), 
   .r_x1(r_x1), 
   .rs3v(rs3v),
   .dec_is_x1(dec_is_x1), 
   .exe_is_x1(exe_is_x1), 
   .mem_is_x1(mem_is_x1), 
   .wb_is_x1(wb_is_x1),
   .dec_is_xn(dec_is_xn), 
   .exe_is_xn(exe_is_xn), 
   .mem_is_xn(mem_is_xn), 
   .wb_is_xn(wb_is_xn),
   .dec_regfile_wen(dec_regfile_wen), 
   .exe_regfile_wen(exe_regfile_wen), 
   .mem_regfile_wen(mem_regfile_wen), 
   .wb_regfile_wen(wb_regfile_wen),
 // output port
   .isjal(isjal),  
   .isjalr(isjalr),  
   .isbxx(isbxx),  
   .predict_bxxtaken(predict_bxxtaken),
   .jaloffset(jaloffset),  
   .jalroffset(jalroffset),  
   .bxxoffset(bxxoffset), 
   .fet_is_x1(fet_is_x1), 
   .fet_is_xn(fet_is_xn),
   .jalr_dep(jalr_dep),
   .fetch_rs3n(fetch_rs3n),
   .ismret(ismret),
   .jalr_xn(jalr_xn),
   .if_csr_r_index(if_csr_r_index)
);

reg [31:0] nxtpcoffset;
always @*
begin
  if (isjal)
    nxtpcoffset = jaloffset;
  else if (isjalr)
    nxtpcoffset = jalroffset;
  else if (isbxx && predict_bxxtaken)
    nxtpcoffset = bxxoffset;
  else 
    nxtpcoffset = isrv16 ?  2 :  4;
end

wire jb = isjal | isjalr | (isbxx && predict_bxxtaken) | branch_predict_err;
reg jb_ff;
always @(posedge clk )
begin
  if (cpurst)
    jb_ff <= 1'b0;
  else
    jb_ff <= jb;
end

//32 bits adder
reg [31:0] bypass_mepc;
wire [31:0] pcop1 = isjalr ? jalr_xn : pc;
wire [31:0] nxtpc = 
       wb2csrfile_int_ffout ? {mtvec[31:2],2'b0} + {mcause[4:0],2'b0} :
       wb2csrfile_exp_ffout ? {mtvec[31:2],2'b0} :
       //ismret ? mepc :
       ismret ? bypass_mepc :
       branch_predict_err ? de2fe_branch_target :
       
       fet_stall | fetch_misalign | jalr_dep ? pc : pcop1 + nxtpcoffset;

reg [31:0] pc;
always @(posedge clk )
begin
  if (cpurst)
    pc <= 32'b0;
  else
    pc <= nxtpc;
end

assign fet_flush = fetch_misalign | jalr_dep;

//cross 8bytes boundary
assign isram_adr = cpurst ? boot_addr[31:0] : (nxtpc[2:1]==2'b11 && (!jb)) ? nxtpc[31:3]+1'b1 : nxtpc[31:3];
reg [31:3] isram_adr_ff;
always @(posedge clk)
begin
  isram_adr_ff <= isram_adr[31:3];
end
assign isram_cs = cpurst ? 1'b1 : ((nxtpc[2:1]==2'b11) && (isram_adr[31:3] == isram_adr_ff[31:3])) ||
                (isram_adr[31:3] != isram_adr_ff[31:3]);
reg isram_cs_ff;
always @(posedge clk )
begin
  if (cpurst)
    isram_cs_ff <= 1'b0;
  else
    isram_cs_ff <= isram_cs;
end

//
// data dependence mepc ctrl
wire [11:0] mepc_index = 12'h341;
always @*
  begin
    if (de2ex_wr_csrindex == mepc_index && de2ex_wr_csrreg )  /**< ex/de data dependence , 1st priority*/
        bypass_mepc = de2ex_wr_csrwdata;

    else if (ex2mem_wr_csrindex == mepc_index && ex2mem_wr_csrreg )  /**< ex/de data dependence , 1st priority*/
        bypass_mepc = ex2mem_wr_csrwdata;
    
    else if (ex2mem_wr_csrindex_ffout == mepc_index && mem2wb_wr_csrreg)  /**< mem/de data dependence, 2nd priority */
        bypass_mepc = mem2wb_wr_csrwdata;
    
    else if (mem2wb_wr_csrindex_ffout == mepc_index && mem2wb_wr_csrreg_ffout)  /**< wb/de data dependence, 3rd priority */
        bypass_mepc = mem2wb_wr_csrwdata_ffout;
    else    
        bypass_mepc = mepc;
  end
endmodule
