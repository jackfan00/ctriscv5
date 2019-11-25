//
module divrem(
clk, cpurst,
divider, dividend,
diven_p,
div0, ovflow,
//
divout_valid, diven,
rem, quo, 

);

input clk, cpurst;
input [31:0] divider, dividend;
input diven_p;
input div0, ovflow;
//output
output divout_valid, diven;
output [31:0] rem, quo;

//
reg [4:0] inik;
always @*
begin
  if (divider[31] | div0 | ovflow)  //div0 
    inik = 5'd31;
  else if (divider[30])
    inik = 5'd30;
  else if (divider[29])
    inik = 5'd29;
  else if (divider[28])
    inik = 5'd28;
  else if (divider[27])
    inik = 5'd27;
  else if (divider[26])
    inik = 5'd26;
  else if (divider[25])
    inik = 5'd25;
  else if (divider[24])
    inik = 5'd24;
  else if (divider[23])
    inik = 5'd23;
  else if (divider[22])
    inik = 5'd22;
  else if (divider[21])
    inik = 5'd21;
  else if (divider[20])
    inik = 5'd20;
  else if (divider[19])
    inik = 5'd19;  
  else if (divider[18])
    inik = 5'd18;  
  else if (divider[17])
    inik = 5'd17;  
  else if (divider[16])
    inik = 5'd16;  
  else if (divider[15])
    inik = 5'd15;  
  else if (divider[14])
    inik = 5'd14;  
  else if (divider[13])
    inik = 5'd13;  
  else if (divider[12])
    inik = 5'd12;  
  else if (divider[11])
    inik = 5'd11;  
  else if (divider[10])
    inik = 5'd10;
  else if (divider[9])
    inik = 5'd9;  
  else if (divider[8])
    inik = 5'd8;  
  else if (divider[7])
    inik = 5'd7;  
  else if (divider[6])
    inik = 5'd6;  
  else if (divider[5])
    inik = 5'd5;  
  else if (divider[4])
    inik = 5'd4;  
  else if (divider[3])
    inik = 5'd3;  
  else if (divider[2])
    inik = 5'd2;  
  else if (divider[1])
    inik = 5'd1;  
  else //if (divider[0])
    inik = 5'd0;    
end
//
wire div_end;
reg diven;
always @(posedge clk)
begin
  if (cpurst)
    diven <= 0;
  else if (div_end)
    diven <= 1'b0;  
  else if (diven_p)
    diven <= 1'b1;  
end

reg [4:0] cnt;
always @(posedge clk)
begin
  if (cpurst)
    cnt <= 0;
  else if (diven_p)
    cnt <= inik;
  else if (diven)
    cnt <= cnt+1'b1;  
end
assign div_end = (cnt == 5'd31) & diven;
//
reg [31:0] minued;
reg [32:0] q;

wire qbit = (minued >= divider[31:0]);
wire [31:0] newminued = minued - divider[31:0];
wire [31:0] nxt_minued = qbit ? {newminued,dividend[5'd31-cnt-1'b1]} : {minued,dividend[5'd31-cnt-1'b1]};
wire [32:0] nxt_q = {q[31:0],qbit};  //shift in right

wire [31:0] nxtrem = div_end ? (qbit ? newminued : minued) : 32'b0;

//wire [31:0] iniminued = dividend[31:(5'd31-inik)];
reg [31:0] iniminued;
always @*
begin
  if (divider[31])
    iniminued = dividend[31:0];
  else if (divider[30])
    iniminued = {1'b0,dividend[31:1]};
  else if (divider[29])
    iniminued = {2'b0,dividend[31:2]};
  else if (divider[28])
    iniminued = {3'b0,dividend[31:3]};
  else if (divider[27])
    iniminued = {4'b0,dividend[31:4]};
  else if (divider[26])
    iniminued = {5'b0,dividend[31:5]};
  else if (divider[25])
    iniminued = {6'b0,dividend[31:6]};
  else if (divider[24])
    iniminued = {7'b0,dividend[31:7]};
  else if (divider[23])
    iniminued = {8'b0,dividend[31:8]};
  else if (divider[22])
    iniminued = {9'b0,dividend[31:9]};
  else if (divider[21])
    iniminued = {10'b0,dividend[31:10]};
  else if (divider[20])
    iniminued = {11'b0,dividend[31:11]};
  else if (divider[19])
    iniminued = {12'b0,dividend[31:12]};  
  else if (divider[18])
    iniminued = {13'b0,dividend[31:13]};  
  else if (divider[17])
    iniminued = {14'b0,dividend[31:14]};  
  else if (divider[16])
    iniminued = {15'b0,dividend[31:15]};  
  else if (divider[15])
    iniminued = {16'b0,dividend[31:16]};  
  else if (divider[14])
    iniminued = {17'b0,dividend[31:17]};  
  else if (divider[13])
    iniminued = {18'b0,dividend[31:18]};  
  else if (divider[12])
    iniminued = {19'b0,dividend[31:19]};  
  else if (divider[11])
    iniminued = {20'b0,dividend[31:20]};  
  else if (divider[10])
    iniminued = {21'b0,dividend[31:21]};
  else if (divider[9])
    iniminued = {22'b0,dividend[31:22]};  
  else if (divider[8])
    iniminued = {23'b0,dividend[31:23]};  
  else if (divider[7])
    iniminued = {24'b0,dividend[31:24]};  
  else if (divider[6])
    iniminued = {25'b0,dividend[31:25]};  
  else if (divider[5])
    iniminued = {26'b0,dividend[31:26]};  
  else if (divider[4])
    iniminued = {27'b0,dividend[31:27]};  
  else if (divider[3])
    iniminued = {28'b0,dividend[31:28]};  
  else if (divider[2])
    iniminued = {29'b0,dividend[31:29]};  
  else if (divider[1])
    iniminued = {30'b0,dividend[31:30]};  
  else if (divider[0])
    iniminued = {31'b0,dividend[31:31]};    
  else
    iniminued = 32'b0;
end

always @(posedge clk)
  begin
    if (cpurst | !diven)
      begin
        minued <= iniminued;
        q      <= 0;
      end
    else
      begin
        minued <= nxt_minued;
        q      <= nxt_q;
      end      
  end
//
reg [31:0] rem, quo;
always @(posedge clk)
  begin
    if (cpurst)
      begin
        rem <= 0;
        quo <= 0;
      end
    else if (div_end)
      begin
        rem <= nxtrem;
        quo <= nxt_q;
      end      
  end
reg divout_valid;
always @(posedge clk)
  begin
    if (cpurst)
      begin
        divout_valid <= 0;
      end
    else 
      begin
        divout_valid <= div_end;
      end      
  end

endmodule