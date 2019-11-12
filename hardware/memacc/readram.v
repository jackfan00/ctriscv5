//#include "globalsig.h"
//#include "regfile.h"
//#include "opcode_define.h"
//#include "memory.h"

module readram(
clk, cpurst,
ex2readram_opmode_ffout,
ex2readram_addr,
ex2readram_addr_ffout,
memrdata,
ex2readram_mem_en_ffout,  ex2mem_load_ffout, 
//
readram_addr,
load_misaligned_exxeption,
readram_rdata,
readram_stall
);
input clk, cpurst;
input [2:0] ex2readram_opmode_ffout;
input [31:0] ex2readram_addr, ex2readram_addr_ffout;
input [31:0] memrdata;
input ex2readram_mem_en_ffout,  ex2mem_load_ffout; 


output [31:0] readram_addr;  // to sram read addr
output load_misaligned_exxeption;
output [31:0] readram_rdata;
output readram_stall;

reg [31:0] readram2ex_memaddr;

    //if (load_misaligned_exxeption_ffout){
    //    readram_addr = readram2ex_memaddr_ffout;
    //    readram_opmode =  readram2ex_mem_op_ffout;
    //}
    //else{
    //    readram_addr = ex2readram_addr_ffout;     /**< IN hardware, this mem readaddr should be inside ram, need combine with mem writeaddr */
    //    readram_opmode = ex2readram_opmode_ffout;
    //}

    reg load_misaligned_exxeption_ffout;
    reg [2:0] readram2ex_mem_op_ffout;
    reg [1:0] readram_addr_ffout;
    wire [2:0] readram_opmode = load_misaligned_exxeption_ffout ? readram2ex_mem_op_ffout : ex2readram_opmode_ffout;

    //int byteaddr = readram_addr & 0x03;
    //assign readram_addr = load_misaligned_exxeption_ffout ? readram2ex_memaddr_ffout[1:0] : ex2readram_addr_ffout[1:0];

    // hardware sram macro read addr
    assign readram_addr = load_misaligned_exxeption ? readram2ex_memaddr[31:0] : ex2readram_addr[31:0];
    wire [1:0] byteaddr = readram_addr_ffout[1:0];

    // in hardware, use sram macro, readram_addr should be ex2readram_addr which latch by sramclk (means ex2readram_addr_ffout)
    //int memrdata = dataram[(unsigned int)(readram_addr>>2)];

reg [31:0] loaddata;
reg [23:0] readram_mis_tmprdat, readram_mis_tmprdat_ffout;
reg [1:0] readram_mis_hytes, readram_mis_hytes_ffout;
reg [2:0] readram2ex_mem_op;
reg load_misaligned_exxeption_t;


always @*
  begin
    loaddata =0;
    readram_mis_tmprdat =0;
    readram_mis_hytes =0;
    readram2ex_memaddr =0;
    readram2ex_mem_op =0;
    load_misaligned_exxeption_t =0;

    case(readram_opmode)
    
        `LOAD_LB,
        `LOAD_LBU:
            case(byteaddr)
                
                0:
                    loaddata = readram_opmode==`LOAD_LB ? {{24{memrdata[7]}},memrdata[7:0]} : {24'b0, memrdata[7:0]};
                    //if (loaddata[7]  && readram_opmode==LOAD_LB){
                    //    loaddata = loaddata -256;
                    //}
                1:
                    loaddata = readram_opmode==`LOAD_LB ? {{24{memrdata[15]}},memrdata[15:8]} : {24'b0, memrdata[15:8]};
                    //if (loaddata > 0x80 && readram_opmode==LOAD_LB){
                    //    loaddata = loaddata -256;
                    //}
                2:
                    loaddata = readram_opmode==`LOAD_LB ? {{24{memrdata[23]}},memrdata[23:16]} : {24'b0, memrdata[23:16]};
                    //if (loaddata > 0x80 && readram_opmode==LOAD_LB){
                    //    loaddata = loaddata -256;
                    //}
                3:
                    loaddata = readram_opmode==`LOAD_LB ? {{24{memrdata[31]}},memrdata[31:24]} : {24'b0, memrdata[31:24]};
                    //if (loaddata > 0x80 && readram_opmode==LOAD_LB){
                    //    loaddata = loaddata -256;
                    //}
                endcase
        `LOAD_LH,
        `LOAD_LHU:
            case(byteaddr)
                
                0:
                    loaddata = readram_opmode==`LOAD_LH ? {{16{memrdata[15]}},memrdata[15:0]} : {16'b0, memrdata[15:0]};
                    //if (loaddata > 0x8000 && readram_opmode==LOAD_LH){
                    //    loaddata = loaddata -0x10000;
                    //}
                1:
                    loaddata = readram_opmode==`LOAD_LH ? {{16{memrdata[23]}},memrdata[23:8]} : {16'b0, memrdata[23:8]};
                    //if (loaddata > 0x8000 && readram_opmode==LOAD_LH){
                    //    loaddata = loaddata -0x10000;
                    //}
                2:
                    loaddata = readram_opmode==`LOAD_LH ? {{16{memrdata[31]}},memrdata[31:16]} : {16'b0, memrdata[31:16]};
                    //if (loaddata > 0x8000 && readram_opmode==LOAD_LH){
                    //    loaddata = loaddata -0x10000;
                    //}
                3:   /**< misaligned load, need 2 clock cycle */
                  begin
                    readram_mis_tmprdat = {16'b0,memrdata[31:24]};
                    readram_mis_hytes =1;
                    readram2ex_memaddr = ex2readram_addr_ffout +1;
                    readram2ex_mem_op = `LOAD_LBU;
                    load_misaligned_exxeption_t =1;
                  end
                endcase
        `LOAD_LW:  /**< misaligned */
            case(byteaddr)
                
                0:
                    loaddata = memrdata;
                1:
                  begin
                    readram_mis_tmprdat = memrdata[31:8];
                    readram_mis_hytes =1;
                    readram2ex_memaddr = ex2readram_addr_ffout +3;
                    readram2ex_mem_op = `LOAD_LBU;
                    load_misaligned_exxeption_t =1;
                  end
                2:
                  begin
                    readram_mis_tmprdat = {8'b0,memrdata[31:16]};
                    readram_mis_hytes =2;
                    readram2ex_memaddr = ex2readram_addr_ffout +2;
                    readram2ex_mem_op = `LOAD_LHU;
                    load_misaligned_exxeption_t =1;
                  end
                3:
                  begin
                    readram_mis_tmprdat = {16'b0,memrdata[31:24]};
                    readram_mis_hytes =3;
                    readram2ex_memaddr = ex2readram_addr_ffout +1;
                    readram2ex_mem_op = `LOAD_LHBU;
                    load_misaligned_exxeption_t =1;
                  end

                endcase

         `LOAD_LHBU:  /**< only for solve LOAD_LW case3 misaligned */
                loaddata = {8'b0,memrdata[23:0]};
     endcase
end




    wire [2:0] prev_readram_opmode = ex2readram_opmode_ffout ;  /**< previous mem_op */

reg [31:0] readram_rdata;
always @*
 begin
    //if (ex2readram_mem_en_ffout){
        if (load_misaligned_exxeption_ffout) begin   /**< misaligned case */
            case(readram_mis_hytes_ffout)
            
            1:
                //if (prev_readram_opmode == LOAD_LH){
                //    readram_rdata = (loaddata<<8) + readram_mis_tmprdat_ffout;
                //    readram_rdata = readram_rdata > (1<<15) ? readram_rdata - (1<<16) : readram_rdata;
                //}
                //else if (prev_readram_opmode==LOAD_LHU){
                //    readram_rdata = (loaddata&0xff)<<8 + readram_mis_tmprdat_ffout;
                //}
                //else if (prev_readram_opmode==LOAD_LW){
                //    readram_rdata = (unsigned int)((loaddata&0xff)<<24) + readram_mis_tmprdat_ffout;
                //}
                readram_rdata = prev_readram_opmode == `LOAD_LH ? {{16{loaddata[7]}},loaddata[7:0],readram_mis_tmprdat_ffout[7:0]} :
                             prev_readram_opmode==`LOAD_LHU ? {16'b0,loaddata[7:0],readram_mis_tmprdat_ffout[7:0]} :
                                     {loaddata[7:0],readram_mis_tmprdat_ffout[23:0]};  //prev_readram_opmode==LOAD_LW
            2:  /**< prev mem_op is LOAD_LW */
                //readram_rdata = (unsigned int)((loaddata&0xffff)<<16) + readram_mis_tmprdat_ffout;
                readram_rdata = {loaddata[15:0], readram_mis_tmprdat_ffout[15:0]};

            3:  /**< prev mem_op is LOAD_LW */
                //readram_rdata = (unsigned int)((loaddata&0xffffff)<<8) + readram_mis_tmprdat_ffout;
                readram_rdata = {loaddata[23:0], readram_mis_tmprdat_ffout[7:0]};


            endcase
        end
        else   /**< not misaligned case */
            readram_rdata = loaddata;
        

    //}
 end


assign    load_misaligned_exxeption = load_misaligned_exxeption_t & ex2readram_mem_en_ffout &  ex2mem_load_ffout;

assign    readram_stall =load_misaligned_exxeption;

always @(posedge clk)
begin
  if (cpurst)
    begin
      load_misaligned_exxeption_ffout <=0;
      readram_mis_tmprdat_ffout <= 0;
      readram_mis_hytes_ffout <= 0;
      readram2ex_mem_op_ffout <= 0;
      readram_addr_ffout <= 0;
    end
  else
    begin
      load_misaligned_exxeption_ffout <= load_misaligned_exxeption;
      readram_mis_tmprdat_ffout <= readram_mis_tmprdat;
      readram_mis_hytes_ffout<= readram_mis_hytes;
      readram2ex_mem_op_ffout <= readram2ex_mem_op;
      readram_addr_ffout <= readram_addr;
    end
end

endmodule
