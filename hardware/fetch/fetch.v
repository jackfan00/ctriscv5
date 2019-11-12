module fetch ( clk, cpurst, fet_stall,
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

isram_cs, isram_adr, rv32_instr_todec, fetch_pc,
fet_is_x1, fet_is_xn,
fetch_rs3n,
predict_bxxtaken,
fe2de_rv16,
fet_flush
);
input clk,cpurst;
input fet_stall;
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

output isram_cs;
output [31:3] isram_adr;
output [31:0] rv32_instr_todec;
output [31:0] fetch_pc;
output fet_is_x1, fet_is_xn;
output [4:0] fetch_rs3n;
output predict_bxxtaken;
output fe2de_rv16;
output fet_flush;

wire isrv16;
assign fe2de_rv16 = isrv16;

genpc genpc_u(
.clk(clk), 
.cpurst(cpurst), 
.fet_stall(fet_stall),
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
.fet_flush(fet_flush)
);

genrv32 genrv32_u( 
.clk(clk), 
.jalr_dep(jalr_dep), 
.jb_ff(jb_ff), 
.sram_cs_ff(sram_cs_ff), 
.pc(fetch_pc), 
.instr(instr_fromsram), 
// output port
.rv32_instr(rv32_instr_todec), 
.isrv16(isrv16),
.fetch_misalign(fetch_misalign)
);

endmodule
