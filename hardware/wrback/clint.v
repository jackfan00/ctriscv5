//
// timer/software interrupt
module clint(
clk, cpurst,
lr_sram_we, lr_sram_cs,
lr_sram_addr, lr_sram_wdata,
//
timer_int, soft_int,
clint_rdat,
clint_cs_ff
);

input clk, cpurst;
input lr_sram_we, lr_sram_cs;
input [31:0] lr_sram_addr, lr_sram_wdata;
//
output timer_int, soft_int;
output [31:0] clint_rdat;
output clint_cs_ff;

//
wire [31:0] clint_rdat_i;
wire [63:0] mtimecmp;
//
reg [63:0] mtime;
always @(posedge clk)
begin
  if (cpurst)
    mtime <= 64'b0;
  else
    mtime <= mtime+1'b1;
end
//
reg timer_int;
always @(posedge clk)
begin
  if (cpurst)
    timer_int <= 1'b0;
  else
    timer_int <= (mtime >= mtimecmp);
end

//
wire clint_cs = lr_sram_cs & (lr_sram_addr[31:24]==`CLINT_BASE);

wire msip_cs = clint_cs & (lr_sram_addr[23:0]== 24'h0);
wire msip_we = msip_cs & lr_sram_we;
wire mtimecmp_lo_cs = clint_cs & (lr_sram_addr[23:0]== 24'h4000);
wire mtimecmp_lo_we = mtimecmp_lo_cs & lr_sram_we;
wire mtimecmp_hi_cs = clint_cs & (lr_sram_addr[23:0]== 24'h4004);
wire mtimecmp_hi_we = mtimecmp_hi_cs & lr_sram_we;

wire mtime_lo_cs = clint_cs & (lr_sram_addr[23:0]== 24'hbff8);
wire mtime_hi_cs = clint_cs & (lr_sram_addr[23:0]== 24'hbffc);

//
reg [31:0] msip;
always @(posedge clk)
begin
  if (cpurst)
    msip <= 32'b0;
  else if (msip_we)
    msip <= lr_sram_wdata;
end

assign soft_int = msip[0];
//
reg [31:0] mtimecmp_lo;
always @(posedge clk)
begin
  if (cpurst)
    mtimecmp_lo <= 32'hffff_ffff;
  else if (mtimecmp_lo_we)
    mtimecmp_lo <= lr_sram_wdata;
end
//
reg [31:0] mtimecmp_hi;
always @(posedge clk)
begin
  if (cpurst)
    mtimecmp_hi <= 32'hffff_ffff;
  else if (mtimecmp_hi_we)
    mtimecmp_hi <= lr_sram_wdata;
end
assign mtimecmp = {mtimecmp_hi, mtimecmp_lo};

//
assign clint_rdat_i = ({32{msip_cs}} & msip) |
                    ({32{mtimecmp_lo_cs}} & mtimecmp_lo) |
                    ({32{mtimecmp_hi_cs}} & mtimecmp_hi) |
                    ({32{mtime_lo_cs}} & mtime[31:0] ) |
                    ({32{mtime_hi_cs}} & mtime[62:32]) ;

reg [31:0] clint_rdat;
reg clint_cs_ff;
always @(posedge clk)
begin
  clint_rdat <= clint_rdat_i;
  clint_cs_ff <= clint_cs;
end                    
endmodule