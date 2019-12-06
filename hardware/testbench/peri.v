//
// model periphal r/w
//
module peri(
clk, rstz,
regw, regr,
adr, wdata,
ack,
rdat

);

input clk, rstz;
input regw, regr;
input [31:0] adr, wdata;
output ack;
output [31:0] rdat;

//
// model delay 2clk
reg [3:0] regw_d, regr_d;
always @(posedge clk or negedge rstz)
begin
  if (!rstz)
    begin
      regw_d <=0;
      regr_d <=0;
    end  
  else
    begin
      regw_d <={regw_d[2:0],regw};
      regr_d <={regr_d[2:0],regr};
    end  
end

assign ack = (regw_d[2]&(!regw_d[3])) | (regr_d[2]&(!regr_d[3]));


assign  rdat = ack & regr ? 32'h12345678 : 32'hffffffff;

reg [31:0] mdat;
always @(posedge clk or negedge rstz)
begin
  if (!rstz)
    mdat <= 32'hffffffff;
  else if (ack & regw)
    mdat <= wdata;
end  

endmodule