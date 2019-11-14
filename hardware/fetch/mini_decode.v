//`include "../define/opcode_define.v"

module mini_decode(rv32_instr, r_x1, rs3v, 
dec_is_x1, exe_is_x1, mem_is_x1, wb_is_x1,
dec_is_xn, exe_is_xn, mem_is_xn, wb_is_xn,
dec_regfile_wen, exe_regfile_wen, mem_regfile_wen, wb_regfile_wen,
isjal, isjalr, isbxx, predict_bxxtaken,
jaloffset, jalroffset, bxxoffset, 
fet_is_x1, fet_is_xn,
jalr_dep,
fetch_rs3n, ismret,
jalr_xn,
if_csr_r_index
);

input [31:0] rv32_instr, r_x1, rs3v;
input dec_is_x1, exe_is_x1, mem_is_x1, wb_is_x1;
input dec_is_xn, exe_is_xn, mem_is_xn, wb_is_xn;
input dec_regfile_wen, exe_regfile_wen, mem_regfile_wen, wb_regfile_wen;
output isjal;
output isjalr;
output isbxx;
output predict_bxxtaken;
output [31:0] jaloffset,jalroffset,bxxoffset;
output fet_is_x1, fet_is_xn;
output jalr_dep;
output [4:0] fetch_rs3n;
output ismret;
output [31:0] jalr_xn;
output [11:0] if_csr_r_index;

wire [6:0] opcode = rv32_instr[6:0];
wire [20:1] jal_imm = {rv32_instr[31],rv32_instr[19:12],rv32_instr[20],rv32_instr[30:21]};
wire [11:0] jalr_imm = rv32_instr[31:20];
assign if_csr_r_index = rv32_instr[31:20];
wire [12:1] bxx_imm = {rv32_instr[31],rv32_instr[7],rv32_instr[30:25],rv32_instr[11:8]};
assign isjal = (opcode == `OPCODE_JAL); 
assign isjalr = (opcode == `OPCODE_JALR); 
assign isbxx = (opcode == `OPCODE_BRANCH); 
//assign ismret = (opcode == `OPCODE_SYSTEM) && (rv32_instr[31:25]==7'h18); 
assign ismret = (rv32_instr[31:0] == 32'h30200073); 
assign predict_bxxtaken = rv32_instr[31];
assign jaloffset = {{11{jal_imm[20]}},jal_imm[20:1],1'b0};
assign bxxoffset = {{19{bxx_imm[12]}},bxx_imm[12:1],1'b0};

// consider RAW dependence, regfile resource conflict
assign fetch_rs3n = rv32_instr[19:15];

//x0, x1 is speed path
wire fet_is_x0 = (fetch_rs3n == 32'b0) ;
assign fet_is_x1 = (fetch_rs3n == 32'b1) ;
assign fet_is_xn = ~(fet_is_x0 | fet_is_x1);
//
wire decode_w_x1 = (dec_is_x1) & dec_regfile_wen;
wire exe_w_x1 =    (exe_is_x1) & exe_regfile_wen;
wire mem_w_x1 =    (mem_is_x1) & mem_regfile_wen;
wire wb_w_x1 =     (wb_is_x1) & wb_regfile_wen;
wire jalr_x1_dep = (decode_w_x1 ) & (isjalr & fet_is_x1); //jalr r1 dependence
//wire jalr_x1_dep = (decode_w_x1 | exe_w_x1 | mem_w_x1) & (isjalr & fet_is_x1); //jalr r1 dependence
//xn
wire decode_w_xn = (dec_is_xn) & dec_regfile_wen;
wire exe_w_xn =    (exe_is_xn) & exe_regfile_wen;
wire mem_w_xn =    (mem_is_xn) & mem_regfile_wen;
wire wb_w_xn =     (wb_is_xn) & wb_regfile_wen;
wire jalr_xn_dep = (decode_w_xn ) & (isjalr & fet_is_xn) ; //jalr rn dependence
//wire jalr_xn_dep = (decode_w_xn | exe_w_xn | mem_w_xn) & (isjalr & fet_is_xn) ; //jalr rn dependence

assign jalr_dep = jalr_x1_dep | jalr_xn_dep;
assign jalr_xn = ({32{fet_is_x1}} & r_x1) | ({32{fet_is_xn}} & rs3v);
                   
assign jalroffset = {{20{jalr_imm[11]}},jalr_imm[11:0]};
//assign jalroffset = {{20{jalr_imm[11]}},jalr_imm[11:0]}+jalr_xn[31:0];
endmodule
