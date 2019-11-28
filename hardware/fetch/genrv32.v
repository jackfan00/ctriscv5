module genrv32( clk, jalr_dep, 
cross_bd_ff,
jb_ff, sram_cs_ff, pc, instr, 
fet_stall, de_stall, exe_stall, memacc_stall, fence_stall,
btb_pc, btb_instr,
btb_valid,
lr_isram_cs,

rv32_instr, isrv16,
fetch_misalign,
rv16_instr_todec
);

input clk, jalr_dep;
input cross_bd_ff;
input jb_ff, sram_cs_ff;
input [31:0] pc;
input [63:0] instr;
input fet_stall, de_stall, exe_stall, memacc_stall, fence_stall;
input [31:0] btb_pc, btb_instr;
input btb_valid;
input lr_isram_cs;

output [31:0] rv32_instr;
output isrv16;
output fetch_misalign;
output [15:0] rv16_instr_todec;

// btb predict
wire btb_hit = (btb_pc == pc) & btb_valid;
//

reg [15:0] pre_instr_h;
reg fetch_misalign_ff;
wire [31:0] eff_instr = btb_hit ? btb_instr :
                   pc[2:1]==2'b00 ? instr[31:0]  :
                   pc[2:1]==2'b01 ? instr[47:16] :
                   pc[2:1]==2'b10 ? instr[63:32] :
                   {instr[15:0],pre_instr_h[15:0]} ;   //fetch cross boundry
//                   fetch_misalign_ff && (pc[2:1]==2'b11) ? {instr[15:0],pre_instr_h[15:0]} : 
//                   {instr[63:48],instr[63:48]};

assign rv16_instr_todec = eff_instr[15:0];

assign isrv16 = eff_instr[1:0]!=2'b11;

wire stall_pc = fet_stall|de_stall|exe_stall|memacc_stall|fence_stall;

always @(posedge clk)
begin
//  if (sram_cs_ff & (!fet_stall) )
//  if (!fet_stall && !lr_isram_cs)
//when load-store case, isram addr is not fetch code addr, so dont update
//when stall pc , dont update 
// but in cross_bd_ff cycle(which mean jump-to cross 8-byte boundary), need to update
//
  if (cross_bd_ff)
    pre_instr_h <= instr[63:48];
  else if (!stall_pc && !lr_isram_cs)  
    pre_instr_h <= instr[63:48];
end

//assign fetch_misalign = jb_ff & (~isrv16) & (pc[2:1]==2'b11);
assign fetch_misalign = 0; //jb_ff &  (pc[2:1]==2'b11);

always @(posedge clk)
begin
  fetch_misalign_ff <= fetch_misalign;
end


wire [31:0] conv_inst32;
rv16torv32 rv16torv32_u ( .rv16(eff_instr[15:0]), .rv32(conv_inst32));

//feedback-loop issue
//assign rv32_instr = (~fetch_misalign) & (~jalr_dep) ? (isrv16 ? conv_inst32 : eff_instr) :
//                     32'h13; // NOP flushing

assign rv32_instr =  isrv16 ? conv_inst32 : eff_instr ;
                     
endmodule
