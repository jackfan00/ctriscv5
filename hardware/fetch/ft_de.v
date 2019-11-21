module ft_de(
clk, cpurst, fet_flush,
de_stall, exe_store_load_conflict, readram_stall, mem_stall, mult_stall,
fetch_pc, rv32_instr_todec,
fet_is_x1, fet_is_xn, predict_bxxtaken, fe2de_rv16,
mem2wb_exp_ffout, interrupt, branch_predict_err,
cross_bd_ff,
de_store_load_conflict,
de2fe_branch, de2ex_inst_valid,
rv16_instr_todec,

fe2de_pc_ffout, fe2de_instr_ffout, 
fet_is_x1_ffout, fet_is_xn_ffout,
fe2de_predict_bxxtaken_ffout,
fe2de_rv16_ffout, 
fet_stall,
btb_pc, btb_instr, btb_valid
);
input clk, cpurst, fet_flush, de_stall, exe_store_load_conflict, readram_stall, mem_stall, mult_stall;
input [31:0] fetch_pc, rv32_instr_todec;
input fet_is_x1, fet_is_xn, predict_bxxtaken, fe2de_rv16;
input mem2wb_exp_ffout;
input interrupt;
input branch_predict_err;
input cross_bd_ff;
input de_store_load_conflict;
input de2fe_branch, de2ex_inst_valid;
input [15:0] rv16_instr_todec;

output [31:0] fe2de_pc_ffout, fe2de_instr_ffout;
output fet_is_x1_ffout, fet_is_xn_ffout;
output fe2de_predict_bxxtaken_ffout;
output fe2de_rv16_ffout;
output fet_stall;
output [31:0] btb_pc, btb_instr;
output btb_valid;

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
   if (cpurst || fet_flush || branch_predict_err) // ||
           //(mem2wb_exp_ffout || interrupt) )   /**< insert dummy NOP command to flush pipeline */
     begin       
//       fe2de_instr_ffout <=  0;
       fet_is_x1_ffout <= 0;
       fet_is_xn_ffout <= 0;
       fe2de_predict_bxxtaken_ffout <= 0;
       fe2de_rv16_ffout <= 0;
     end
   else if (~de_store_load_conflict && ~de_stall) //if (~fet_stall)
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
   if (cpurst || fet_flush || branch_predict_err || (cross_bd_ff & !de_stall) )//||
           //(mem2wb_exp_ffout || interrupt) )   /**< insert dummy NOP command to flush pipeline */
     begin       
       fe2de_instr_ffout <=  0;
     end
   else if (~de_store_load_conflict && ~de_stall)
     begin
       fe2de_instr_ffout <=  rv32_instr_todec;
     end
end

reg [31:0] fe2de_pc_ffout;
always @(posedge clk)
begin
   if (cpurst)
     fe2de_pc_ffout = 0;
   else if (~de_store_load_conflict && ~de_stall)
     fe2de_pc_ffout = fetch_pc;
end     

//
// BTB, branch target buffer : only 1 item
//
reg [15:0] fe2de_rv16_instr_ffout;
always @(posedge clk)
begin
  fe2de_rv16_instr_ffout <=  rv16_instr_todec;
end

// prevent btb hit reset pc value
reg [3:0] btb_dlycnt;
always @(posedge clk)
  begin
    if (cpurst)
      btb_dlycnt <= 4'b0;
    else if (btb_dlycnt < 4'd10)
      btb_dlycnt <= btb_dlycnt+1'b1;
  end
assign btb_valid = (btb_dlycnt >= 4'd10);

reg btb_en;
always @(posedge clk)
  begin
    if (cpurst)
      btb_en <= 1'b0;
    else if (btb_en & de2ex_inst_valid)
      btb_en <= 1'b0;
    else if (de2fe_branch)
      btb_en <= 1'b1;
  end

reg [31:0] btb_pc, btb_instr;
always @(posedge clk)
  begin
    if (cpurst)
      begin
        btb_pc <= 0;
        btb_instr <= 0;
      end
    else if (btb_en & de2ex_inst_valid)
      begin
        btb_pc <= fe2de_pc_ffout;
        btb_instr <= fe2de_rv16_ffout ? {16'b0,fe2de_rv16_instr_ffout} : fe2de_instr_ffout;
      end
  end
endmodule
