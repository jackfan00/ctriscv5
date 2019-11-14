module genrv32( clk, jalr_dep, jb_ff, sram_cs_ff, pc, instr, fet_stall,

rv32_instr, isrv16,
fetch_misalign
);

input clk, jalr_dep;
input jb_ff, sram_cs_ff;
input [31:0] pc;
input [63:0] instr;
input fet_stall;

output [31:0] rv32_instr;
output isrv16;
output fetch_misalign;

reg [15:0] pre_instr_h;
reg fetch_misalign_ff;
wire [31:0] eff_instr = pc[2:1]==2'b00 ? instr[31:0]  :
                   pc[2:1]==2'b01 ? instr[47:16] :
                   pc[2:1]==2'b10 ? instr[63:32] :
                   {instr[15:0],pre_instr_h[15:0]} ;   //fetch cross boundry
//                   fetch_misalign_ff && (pc[2:1]==2'b11) ? {instr[15:0],pre_instr_h[15:0]} : 
//                   {instr[63:48],instr[63:48]};

assign isrv16 = eff_instr[1:0]!=2'b11;

always @(posedge clk)
begin
//  if (sram_cs_ff & (!fet_stall) )
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
