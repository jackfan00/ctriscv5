module fetch ( clk, cpurst, 
de_stall, exe_stall, memacc_stall,
btb_pc, btb_instr, btb_valid,
boot_addr,
r_x1, rs3v,
dec_is_x1, exe_is_x1, mem_is_x1, wb_is_x1,
dec_is_xn, exe_is_xn, mem_is_xn, wb_is_xn,
dec_regfile_wen, exe_regfile_wen, mem_regfile_wen, wb_regfile_wen,
instr_fromsram, 
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
lr_isram_cs, lr_isram_cs_ff,

isram_cs, isram_adr, rv32_instr_todec, fetch_pc,
fet_is_x1, fet_is_xn,
fetch_rs3n,
predict_bxxtaken,
fe2de_rv16,
fet_flush,
cross_bd_ff,
jalr_dep,
rv16_instr_todec,
fet_stall

);
input clk,cpurst;
input de_stall, exe_stall, memacc_stall;
input [31:0] btb_pc, btb_instr;
input btb_valid;
input [31:0] boot_addr;
input [31:0] r_x1, rs3v;
input dec_is_x1, exe_is_x1, mem_is_x1, wb_is_x1;
input dec_is_xn, exe_is_xn, mem_is_xn, wb_is_xn;
input dec_regfile_wen, exe_regfile_wen, mem_regfile_wen, wb_regfile_wen;
input [63:0] instr_fromsram;
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
input lr_isram_cs, lr_isram_cs_ff;

output isram_cs;
output [31:3] isram_adr;
output [31:0] rv32_instr_todec;
output [31:0] fetch_pc;
output fet_is_x1, fet_is_xn;
output [4:0] fetch_rs3n;
output predict_bxxtaken;
output fe2de_rv16;
output fet_flush;
output cross_bd_ff;
output jalr_dep;
output [15:0] rv16_instr_todec;
output fet_stall;

wire lr_isram_cs_endp;
wire isrv16;
assign fe2de_rv16 = isrv16;

genpc genpc_u(
.clk(clk), 
.cpurst(cpurst), 
.de_stall(de_stall), 
.exe_stall(exe_stall), 
.memacc_stall(memacc_stall),
.btb_pc(btb_pc),
.btb_valid(btb_valid),
.boot_addr(boot_addr),
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
.fetch_misalign(fetch_misalign), 
.rv32_instr(rv32_instr_todec), 
.isrv16(isrv16), 
.branch_predict_err(branch_predict_err),
.de2fe_branch_target(de2fe_branch_target),
.wb2csrfile_int_ffout(wb2csrfile_int_ffout),
.wb2csrfile_exp_ffout(wb2csrfile_exp_ffout),
.mtvec               (mtvec               ),
.mepc                (mepc                ),
.mcause              (mcause              ),
.de2ex_wr_csrreg         (de2ex_wr_csrreg         ), 
.ex2mem_wr_csrreg        (ex2mem_wr_csrreg        ), 
.mem2wb_wr_csrreg        (mem2wb_wr_csrreg        ), 
.mem2wb_wr_csrreg_ffout  (mem2wb_wr_csrreg_ffout  ),
.de2ex_wr_csrindex       (de2ex_wr_csrindex       ), 
.ex2mem_wr_csrindex      (ex2mem_wr_csrindex      ), 
.ex2mem_wr_csrindex_ffout(ex2mem_wr_csrindex_ffout), 
.mem2wb_wr_csrindex_ffout(mem2wb_wr_csrindex_ffout),
.de2ex_wr_csrwdata       (de2ex_wr_csrwdata       ), 
.ex2mem_wr_csrwdata      (ex2mem_wr_csrwdata      ), 
.mem2wb_wr_csrwdata      (mem2wb_wr_csrwdata      ), 
.mem2wb_wr_csrwdata_ffout(mem2wb_wr_csrwdata_ffout),
.lr_isram_cs             (lr_isram_cs             ),
.lr_isram_cs_endp        (lr_isram_cs_endp        ),

// output port
.isram_adr(isram_adr), 
.pc(fetch_pc), 
.fet_is_x1(fet_is_x1),
.fet_is_xn(fet_is_xn),
.isram_cs(isram_cs), 
.jb_ff(jb_ff),
.jalr_dep(jalr_dep), 
.isram_cs_ff(sram_cs_ff),
.fetch_rs3n(fetch_rs3n),
.predict_bxxtaken(predict_bxxtaken),
.fet_flush(fet_flush),
//.holdpc(holdpc),
.cross_bd_ff(cross_bd_ff),
.fet_stall(fet_stall)

);

// exclude load-store isram
////reg lr_isram_cs_ff;
////always @(posedge clk)
////  begin
////    if (cpurst)
////      lr_isram_cs_ff <= 1'b0;
////    else 
////      lr_isram_cs_ff <= lr_isram_cs;;
////  end
wire lr_isram_cs_stp = lr_isram_cs & (!lr_isram_cs_ff);
assign lr_isram_cs_endp = (!lr_isram_cs) & lr_isram_cs_ff;
reg [63:0] instr_hold;
always @(posedge clk)
  begin
    if (lr_isram_cs_stp)
       instr_hold <= instr_fromsram;
  end
wire [63:0] valid_instr_fromsram = lr_isram_cs_ff ? instr_hold : instr_fromsram;

genrv32 genrv32_u( 
.clk(clk), 
.jalr_dep(jalr_dep), 
.jb_ff(jb_ff), 
.sram_cs_ff(sram_cs_ff), 
.pc(fetch_pc), 
.instr(valid_instr_fromsram), //instr_fromsram), 
.fet_stall(fet_stall),
.btb_pc(btb_pc), 
.btb_instr(btb_instr),
.btb_valid(btb_valid),
.lr_isram_cs(lr_isram_cs),

// output port
.rv32_instr(rv32_instr_todec), 
.isrv16(isrv16),
.fetch_misalign(fetch_misalign),
.rv16_instr_todec(rv16_instr_todec)
);

endmodule
