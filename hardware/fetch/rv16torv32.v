module rv16torv32(rv16, rv32);

input [15:0] rv16;
output [31:0] rv32;

wire [2:0] c0_rdprime = rv16[4:2];
wire [2:0] c0_rs2prime = rv16[4:2];
wire [2:0] c0_rs1prime = rv16[9:7];
wire [6:2] c0_uimm = {rv16[5],rv16[12:10],rv16[6]};
wire [9:2] c0_nzuimm = {rv16[10:7],rv16[12:11],rv16[5],rv16[6]};

wire CADDI4SPN = (rv16[1:0]==2'b0) && (rv16[15:13]==3'b0) && (rv16[12:5]!=8'b0);
wire CLW = (rv16[1:0]==2'b0) && (rv16[15:13]==3'b010);
wire CSW = (rv16[1:0]==2'b0) && (rv16[15:13]==3'b110);

wire [31:0] c0_instr = ({32{CADDI4SPN}} & {2'b0,c0_nzuimm,2'b0,5'h2,3'b0,2'b01,c0_rdprime,7'h13}) |  // addi rd', x2, nzuimm[9:2]
                  ({32{CLW}} & {5'b0,c0_uimm,2'b0,2'b01,c0_rs1prime,3'b010,2'b01,c0_rdprime,7'h03}) |  //lw rd', offset[6:2](rs1')
                  ({32{CSW}} & {5'b0,c0_uimm[6:5],2'b01,c0_rs2prime,2'b01,c0_rs1prime,3'b010,c0_uimm[4:2],2'b0,7'h23}) ;  // sw, rs2', offset[6:2](rs1')

wire [2:0] c1_rs2prime = rv16[4:2];
wire [2:0] c1_rs1prime = rv16[9:7];
wire [2:0] c1_rdprime = rv16[9:7];
wire [4:0] c1_rs1 = rv16[11:7];
wire [4:0] c1_rd = rv16[11:7];
wire [5:0] c1_nzimm = {rv16[12],rv16[6:2]};
wire [11:1] c1_jalimm = {rv16[12],rv16[8],rv16[10:9],rv16[6],rv16[7],rv16[2],rv16[11],rv16[5:3]};
wire [5:0] c1_imm = {rv16[12],rv16[6:2]};
wire [9:4] c1_addi16sp_nzimm = {rv16[12],rv16[3:2],rv16[4],rv16[2],rv16[6]};
wire [17:12] c1_lui_nzuimm = {rv16[12],rv16[6:2]};
wire [5:0] c1_shamt = {rv16[12],rv16[6:2]};
wire [8:1] c1_bxx_offset = {rv16[12],rv16[6:5],rv16[2],rv16[11:10],rv16[4:3]};

wire CNOP = (rv16[15:0]==16'h1);
wire CADDI = (rv16[1:0]==2'b1) && (rv16[15:13]==3'h0) && (c1_nzimm[5:0]!=6'b0) && (c1_rd!=5'b0);
wire CJAL = (rv16[1:0]==2'b1) && (rv16[15:13]==3'b001) ;
wire CLI = (rv16[1:0]==2'b1) && (rv16[15:13]==3'b010) && (c1_rd!=5'b0);
wire CADDI16SP = (rv16[1:0]==2'b1) && (rv16[15:13]==3'b011) && (c1_addi16sp_nzimm[9:4]!=6'b0) && (c1_rd==5'h2) ;
wire CLUI = (rv16[1:0]==2'b1) && (rv16[15:13]==3'b011) && (c1_lui_nzuimm[17:12]!=6'b0) && (c1_rd!=5'h2) && (c1_rd!=5'h0) ;
wire CSRLI = (rv16[1:0]==2'b1) && (rv16[15:13]==3'b100) && (c1_shamt[5:0]!=6'b0) && (rv16[11:10]==2'b00)  ;
wire CSRAI = (rv16[1:0]==2'b1) && (rv16[15:13]==3'b100) && (c1_shamt[5:0]!=6'b0) && (rv16[11:10]==2'b01)  ;
wire CANDI = (rv16[1:0]==2'b1) && (rv16[15:13]==3'b100) && (rv16[11:10]==2'b10)  ;
wire CSUB = (rv16[1:0]==2'b1) && (rv16[15:13]==3'b100) && (rv16[12:10]==3'b011) && (rv16[6:5]==2'b00)  ;
wire CXOR = (rv16[1:0]==2'b1) && (rv16[15:13]==3'b100) && (rv16[12:10]==3'b011) && (rv16[6:5]==2'b01)  ;
wire COR =  (rv16[1:0]==2'b1) && (rv16[15:13]==3'b100) && (rv16[12:10]==3'b011) && (rv16[6:5]==2'b10)  ;
wire CAND = (rv16[1:0]==2'b1) && (rv16[15:13]==3'b100) && (rv16[12:10]==3'b011) && (rv16[6:5]==2'b11)  ;
wire CJ =    (rv16[1:0]==2'b1) && (rv16[15:13]==3'b101) ;
wire CBEQZ = (rv16[1:0]==2'b1) && (rv16[15:13]==3'b110) ;
wire CBNEZ = (rv16[1:0]==2'b1) && (rv16[15:13]==3'b111) ;

wire [31:0] c1_instr = ({32{CNOP}} & 32'h13) |
                  ({32{CADDI}} & {{6{c1_nzimm[5]}},c1_nzimm[5:0],c1_rs1,3'b0,c1_rd,7'h13}) |  // addi rd, rd, nzimm[5:0]
                  ({32{CJAL}} & {c1_jalimm[11],c1_jalimm[10:1],c1_jalimm[11],8'b0,5'h1,7'h6f}) |  //JAL x1, offset[11:1]
                  ({32{CLI}} & {{6{c1_imm[5]}},c1_imm[5:0],5'h0,3'b0,c1_rd,7'h13}) |   //addi rd, x0, imm[5:0]
                  ({32{CADDI16SP}} & {2'b0,c1_addi16sp_nzimm[9:4],4'b0,5'h2,3'b0,5'h2,7'h13}) |  //addi x2, x2, nzimm[9:4]
                  ({32{CLUI}} & {14'b0,c1_lui_nzuimm[17:12],c1_rd,7'h37}) |  //lui rd,  nzuimm[17:12]
                  ({32{CSRLI}} & {7'h00,c1_shamt[5:0],2'b1,c1_rdprime,3'b101,2'b1,c1_rdprime,7'h13}) |  //srli rd', rd',  shamt[5:0]
                  ({32{CSRAI}} & {7'h20,c1_shamt[5:0],2'b1,c1_rdprime,3'b101,2'b1,c1_rdprime,7'h13}) |  //srai rd', rd',  shamt[5:0]
                  ({32{CANDI}} & {{6{c1_imm[5]}},c1_imm[5:0],2'b1,c1_rdprime,3'b111,2'b1,c1_rdprime,7'h13}) |  //andi rd', rd',  imm[5:0]
                  ({32{CSUB}} & {7'h20,2'b1,c1_rs2prime,2'b1,c1_rdprime,3'b0,2'b1,c1_rdprime,7'h33}) |  //sub rd', rd', rs2' 
                  ({32{CXOR}} & {7'h00,2'b1,c1_rs2prime,2'b1,c1_rdprime,3'b100,2'b1,c1_rdprime,7'h33}) |  //xor rd', rd', rs2' 
                  ({32{COR}} & {7'h00,2'b1,c1_rs2prime,2'b1,c1_rdprime,3'b110,2'b1,c1_rdprime,7'h33}) |  //or rd', rd', rs2' 
                  ({32{CAND}} & {7'h00,2'b1,c1_rs2prime,2'b1,c1_rdprime,3'b111,2'b1,c1_rdprime,7'h33}) |  //and rd', rd', rs2' 
                  ({32{CJ}} & {c1_jalimm[11],c1_jalimm[10:1],c1_jalimm[11],8'b0,5'h0,7'h6f}) |  //JAL x0, offset[11:1]
                  ({32{CBEQZ}} & {{3{c1_bxx_offset[8]}},c1_bxx_offset[8:5],5'b0,2'b1,c1_rs1prime,3'b0,c1_bxx_offset[4:1],c1_bxx_offset[8],7'h63}) |  //beq rs1', x0, offset[8:1] 
                  ({32{CBNEZ}} & {{3{c1_bxx_offset[8]}},c1_bxx_offset[8:5],5'b0,2'b1,c1_rs1prime,3'b001,c1_bxx_offset[4:1],c1_bxx_offset[8],7'h63}) ;  //bne rs1', x0, offset[8:1] 


wire [5:0] c2_shamt = {rv16[12],rv16[6:2]};
wire [7:2] c2_lw_offset = {rv16[3:2],rv16[12],rv16[6:4]};
wire [4:0] c2_rs1 = rv16[11:7];
wire [4:0] c2_rd = rv16[11:7];
wire [4:0] c2_rs2 = rv16[6:2];
wire [7:2] c2_sw_offset = {rv16[8:7],rv16[12:9]};


wire CSLLI = (rv16[1:0]==2'b10) && (rv16[15:13]==3'b000) && (c2_shamt[5:0]!=6'b0) && (c2_rd!=5'b0)  ;
wire CLWSP = (rv16[1:0]==2'b10) && (rv16[15:13]==3'b010) && (c2_rd!=5'b0)  ;
wire CJR = (rv16[1:0]==2'b10) && (rv16[15:13]==3'b100) && (c2_shamt[5:0]==6'b0) && (c2_rd!=5'h0)  ;
wire CMV = (rv16[1:0]==2'b10) && (rv16[15:13]==3'b100) && (rv16[12]==1'b0) && (c2_rd!=5'h0) && (c2_rs2!=5'h0)  ;
wire CBREAK = (rv16[15:0]==16'h9002)  ;
wire CJALR = (rv16[1:0]==2'b10) && (rv16[15:13]==3'b100) && (c2_shamt[5:0]==6'h20) && (c2_rs1!=5'h0)  ;
wire CADD = (rv16[1:0]==2'b10) && (rv16[15:13]==3'b100) && (rv16[12]==1'b1) && (c2_rs1!=5'h0) && (c2_rs2!=5'h0)  ;
wire CSWSP = (rv16[1:0]==2'b10) && (rv16[15:13]==3'b110)   ;


wire [31:0] c2_instr = ({32{CSLLI}} & {7'h00,c2_shamt[5:0],c2_rd,3'b001,c1_rd,7'h13} ) |  //slli rd, rd, shamt[5:0]
                       ({32{CLWSP}} & {4'b0,c2_lw_offset[7:2],2'b0,5'h2,3'b010,c2_rd,7'h03}) |  //lw rd, offset[7:2](x2)
                       ({32{CJR}} & {12'b0,c2_rs1,3'b0,5'h0,7'h67}) |  //JALR x0, rs1, 0
                       ({32{CMV}} & {7'h00,c2_rs2,5'h0,3'b0,c2_rd,7'h33}) |  //add rd, x0, rs2 
                       ({32{CBREAK}} & {12'b0,20'h73}) |  // ebreak
                       ({32{CJALR}} & {12'b0,c2_rs1,3'b0,5'h1,7'h67}) |  //JALR x1, rs1, 0
                       ({32{CADD}} & {7'h00,c2_rs2,c2_rd,3'b0,c2_rd,7'h33}) |  //add rd, rd, rs2 
                       ({32{CSWSP}} & {4'b0,c2_sw_offset[7:5],c2_rs2,5'h2,3'b010,c2_sw_offset[4:2],2'b0,7'h23}) ;  // sw, rs2, offset[7:2](x2)

assign rv32 = c0_instr | c1_instr | c2_instr;

endmodule
