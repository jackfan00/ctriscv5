module genpc(clk, cpurst,  btb_pc, btb_valid,
de_stall, exe_stall, memacc_stall, fence_stall,
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
all_int,
//wb2csrfile_exp_ffout,
mtvec,
mepc,
mcause,
de2ex_wr_csrreg, ex2mem_wr_csrreg, mem2wb_wr_csrreg, mem2wb_wr_csrreg_ffout,
de2ex_wr_csrindex, ex2mem_wr_csrindex, ex2mem_wr_csrindex_ffout, mem2wb_wr_csrindex_ffout,
de2ex_wr_csrwdata, ex2mem_wr_csrwdata, mem2wb_wr_csrwdata, mem2wb_wr_csrwdata_ffout,
lr_isram_cs, lr_isram_cs_endp,

isram_adr, 
pc, 
fet_is_x1, fet_is_xn,
isram_cs, 
jb_ff,
jalr_dep, 
isram_cs_ff,
fetch_rs3n,
predict_bxxtaken,
fet_flush,
//holdpc, 
cross_bd_ff,
fet_stall
);

input clk, cpurst;
input de_stall, exe_stall, memacc_stall, fence_stall;
input [31:0] btb_pc;
input btb_valid;
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
input all_int;
//input wb2csrfile_exp_ffout;
input [31:0] mtvec;
input [31:0] mepc;
input [4:0] mcause;
input de2ex_wr_csrreg, ex2mem_wr_csrreg, mem2wb_wr_csrreg, mem2wb_wr_csrreg_ffout;
input [11:0] de2ex_wr_csrindex, ex2mem_wr_csrindex, ex2mem_wr_csrindex_ffout, mem2wb_wr_csrindex_ffout;
input [31:0] de2ex_wr_csrwdata, ex2mem_wr_csrwdata, mem2wb_wr_csrwdata, mem2wb_wr_csrwdata_ffout;
input lr_isram_cs, lr_isram_cs_endp;
//
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
//output holdpc;
output cross_bd_ff;
output fet_stall;

reg cross_bd_ff;
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
   .isecallbk(isecallbk),
   .jalr_xn(jalr_xn),
   .if_csr_r_index(if_csr_r_index)
);

//fet_stall : hold pc and flush decode pipe
assign fet_stall = jalr_dep | lr_isram_cs | (cross_bd_ff&(!branch_predict_err));

reg [31:0] nxtpcoffset;
always @*
begin
  //if (cross_bd_ff)  //1st priority
  //  nxtpcoffset =0;
  //else 
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
reg [31:0] bypass_mepc, bypass_mtvec;
//wire [31:0] pcop1 = isjalr ? jalr_xn : pc;
wire [31:0] pcop1 = isjalr & (!cross_bd_ff) ? jalr_xn : pc;
wire [31:0] nxtpc = 

// branch_predict_err is 1st priority
// because fetched addr is wrong, so need to correct it first.
       branch_predict_err ? de2fe_branch_target :   
       fet_stall|de_stall|exe_stall|memacc_stall|fence_stall ? pc :
       //need to modify?????
       all_int ? {mtvec[31:2],2'b0} + {mcause[4:0],2'b0} :
       isecallbk ? {bypass_mtvec[31:2],2'b0} :
       ismret ? bypass_mepc :
//       branch_predict_err ? de2fe_branch_target :   
                            pcop1 + nxtpcoffset ;//       
       //fet_stall | fetch_misalign | jalr_dep ? pc : pcop1 + nxtpcoffset;

//pc jump condition 
wire jc = (all_int | isecallbk | ismret | branch_predict_err | jb) & (!lr_isram_cs);

//assign holdpc = fet_stall | fetch_misalign | jalr_dep;

wire cross_bd;
reg [31:0] pc;
always @(posedge clk )
begin
  if (cpurst)
    pc <= boot_addr; //32'b0;
  else //if (!cross_bd_ff)
    pc <= nxtpc;
end

assign fet_flush = fet_stall; //fetch_misalign | jalr_dep;

//cross 8bytes boundary
//assign isram_adr = cpurst ? boot_addr[31:0] : (nxtpc[2:1]==2'b11 && (!jb)) ? nxtpc[31:3]+1'b1 : nxtpc[31:3];
assign isram_adr = cpurst ? boot_addr[31:0] : 
                   
                   // continuous fetch case, dont need 1 more dummty clock at cross-boundry
                   cross_bd & (!jc) ? pc[31:3]+1'b1 :  
                   //jump address and cross 8-byte boundry, need read 2 cycle
                   cross_bd_ff &(!branch_predict_err) ? pc[31:3]+1'b1 :
                            nxtpc[31:3];
//cross boundry need fetch 2 times
assign cross_bd = (nxtpc[2:1]==2'b11);

// btb predict, 
wire btb_hit_npc = (btb_pc == nxtpc) & btb_valid;
//

always @(posedge clk)
begin
  if (cpurst)
    cross_bd_ff <= 1'b0;
  // dont need 2 cycle if btb hit  
  else if (btb_hit_npc)
    cross_bd_ff <= 1'b0;
  // continuous fetch case, dont need 1 more dummty clock at cross-boundry  
  else if (cross_bd & (!jc))
    cross_bd_ff <= 1'b0;
  else if (cross_bd_ff & (!branch_predict_err))
    cross_bd_ff <= 1'b0;
  else
  //jump address and cross 8-byte boundry
    cross_bd_ff <= cross_bd;
end

reg [31:3] isram_adr_ff;
always @(posedge clk)
begin
  isram_adr_ff <= isram_adr[31:3];
end
assign isram_cs = cpurst ? 1'b1 : ((nxtpc[2:1]==2'b11) && (isram_adr[31:3] == isram_adr_ff[31:3])) ||
                                  (isram_adr[31:3] != isram_adr_ff[31:3]) ||
                                  lr_isram_cs_endp;
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

//
// data dependence mtvec ctrl
wire [11:0] mtvec_index = 12'h305;
always @*
  begin
    if (de2ex_wr_csrindex == mtvec_index && de2ex_wr_csrreg )  /**< ex/de data dependence , 1st priority*/
        bypass_mtvec = de2ex_wr_csrwdata;

    else if (ex2mem_wr_csrindex == mtvec_index && ex2mem_wr_csrreg )  /**< ex/de data dependence , 1st priority*/
        bypass_mtvec = ex2mem_wr_csrwdata;
    
    else if (ex2mem_wr_csrindex_ffout == mtvec_index && mem2wb_wr_csrreg)  /**< mem/de data dependence, 2nd priority */
        bypass_mtvec = mem2wb_wr_csrwdata;
    
    else if (mem2wb_wr_csrindex_ffout == mtvec_index && mem2wb_wr_csrreg_ffout)  /**< wb/de data dependence, 3rd priority */
        bypass_mtvec = mem2wb_wr_csrwdata_ffout;
    else    
        bypass_mtvec = mtvec;
  end
endmodule
