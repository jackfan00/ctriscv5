module ft_de(
clk, cpurst, fet_flush,
de_stall, exe_store_load_conflict, readram_stall, mem_stall, mult_stall,
fetch_pc, rv32_instr_todec,
fet_is_x1, fet_is_xn, predict_bxxtaken, fe2de_rv16,
mem2wb_exp_ffout, interrupt, branch_predict_err,
cross_bd_ff,
de_store_load_conflict,

fe2de_pc_ffout, fe2de_instr_ffout, 
fet_is_x1_ffout, fet_is_xn_ffout,
fe2de_predict_bxxtaken_ffout,
fe2de_rv16_ffout, 
fet_stall
);
input clk, cpurst, fet_flush, de_stall, exe_store_load_conflict, readram_stall, mem_stall, mult_stall;
input [31:0] fetch_pc, rv32_instr_todec;
input fet_is_x1, fet_is_xn, predict_bxxtaken, fe2de_rv16;
input mem2wb_exp_ffout;
input interrupt;
input branch_predict_err;
input cross_bd_ff;
input de_store_load_conflict;

output [31:0] fe2de_pc_ffout, fe2de_instr_ffout;
output fet_is_x1_ffout, fet_is_xn_ffout;
output fe2de_predict_bxxtaken_ffout;
output fe2de_rv16_ffout;
output fet_stall;

assign fet_stall = de_store_load_conflict | de_stall | exe_store_load_conflict | readram_stall | mem_stall | mult_stall;
///dff_e_cell #(32) u0 ( .clk(clk), .en(~stall), .d(fetch_pc),         .q(dec_pc) );
///dff_e_cell #(32) u1 ( .clk(clk), .en(~stall), .d(rv32_instr_todec), .q(dec_instr) );
///dff_e_cell #(1) u2  ( .clk(clk), .en(~stall), .d(predict_bxxtaken), .q(fe2de_predict_bxxtaken_ffout) );
///dff_e_cell #(1) u3  ( .clk(clk), .en(~stall), .d(fe2de_rv16), .q(fe2de_rv16_ffout) );

//
reg [31:0] fe2de_instr_ffout;
reg fet_is_x1_ffout, fet_is_xn_ffout;
reg fe2de_predict_bxxtaken_ffout, fe2de_rv16_ffout;
always @(posedge clk)
begin
   if (cpurst || fet_flush || branch_predict_err ||
           (mem2wb_exp_ffout || interrupt) )   /**< insert dummy NOP command to flush pipeline */
     begin       
//       fe2de_instr_ffout <=  0;
       fet_is_x1_ffout <= 0;
       fet_is_xn_ffout <= 0;
       fe2de_predict_bxxtaken_ffout <= 0;
       fe2de_rv16_ffout <= 0;
     end
   else if (~de_store_load_conflict) //if (~fet_stall)
     begin
//       fe2de_instr_ffout <=  rv32_instr_todec;
       fet_is_x1_ffout <= fet_is_x1;
       fet_is_xn_ffout <= fet_is_xn;
       fe2de_predict_bxxtaken_ffout <= predict_bxxtaken;
       fe2de_rv16_ffout <= fe2de_rv16;
     end
end

always @(posedge clk)
begin
   if (cpurst || fet_flush || branch_predict_err || cross_bd_ff ||
           (mem2wb_exp_ffout || interrupt) )   /**< insert dummy NOP command to flush pipeline */
     begin       
       fe2de_instr_ffout <=  0;
     end
   else if (~de_store_load_conflict)
     begin
       fe2de_instr_ffout <=  rv32_instr_todec;
     end
end

reg [31:0] fe2de_pc_ffout;
always @(posedge clk)
begin
   if (cpurst)
     fe2de_pc_ffout = 0;
   else if (~de_store_load_conflict)
     fe2de_pc_ffout = fetch_pc;
end     

endmodule
