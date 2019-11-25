//
module divrem_top(
clk, cpurst,
divider, dividend,
diven_p,
divsigned,
//
divout_valid, diven,
rem, quo, 
);

input clk, cpurst;
input [31:0] divider, dividend;
input diven_p;
input divsigned;
//
output divout_valid, diven;
output [31:0] rem, quo;


wire div0 = (divider==32'b0);
wire ovflow = (divider==32'hffffffff) & (dividend==32'h80000000) & divsigned;
//

wire [31:0] divider_undivsigned  = divsigned & divider[31]  ? {1'b0,~divider[30:0]}+1'b1  : divider[31:0];
wire [31:0] dividend_undivsigned = divsigned & dividend[31] ? {1'b0,~dividend[30:0]}+1'b1 : dividend[31:0];

//
wire [31:0] rem_undivsigned, quo_undivsigned;
divrem divrem_u(
.clk          (clk              ), 
.cpurst       (cpurst           ),
.divider      (divider_undivsigned ), 
.dividend     (dividend_undivsigned),
.diven_p      (diven_p          ),
.div0         (div0             ), 
.ovflow       (ovflow           ),
//            (//      )
.rem          (rem_undivsigned     ), 
.quo          (quo_undivsigned     ), 
.diven        (diven            ),
.divout_valid (divout_valid     )
);

wire s1 = divsigned & divider[31];
wire s2 = divsigned & dividend[31];

wire result_signed = s1 ^ s2;

wire [31:0] rems = result_signed ? ~rem_undivsigned[30:0]+1'b1 : rem_undivsigned[31:0];
wire [31:0] quos = result_signed ? ~quo_undivsigned[30:0]+1'b1 : quo_undivsigned[31:0];

assign rem = div0 ? dividend : 
             ovflow ? 0 : rems;
assign quo = div0   ? 32'hffffffff : 
             ovflow ? 32'h80000000 : quos;
             
endmodule