//#include "globalsig.h"
//#include "memory.h"
//#include "opcode_define.h"

module inst_memacc(
clk, cpurst,
ex2mem_wr_reg_ffout,
ex2mem_wr_regindex_ffout,
ex2mem_wr_wdata_ffout,
ex2mem_memaddr_ffout,
ex2mem_wr_mem_ffout,
ex2mem_wr_memwdata_ffout,
ex2mem_mem_op_ffout,
ex2mem_mem_en,
ex2mem_mem_en_ffout,
ex2mem_load_ffout,
ex2mem_load,
ex2mem_store_ffout,
ex2mem_rd_is_x1_ffout,
ex2mem_rd_is_xn_ffout,
readram_addr,
readram_rdata,
mul2mem_LO_ffout, mul2mem_HI_ffout,
mul2mem_prod_complete_ffout,
multprod_LO_ffout,
multprod_HI_ffout,
load_misaligned_exxeption,
ex2mem_exp_ffout,
ex2mem_int_ffout,
div2mem_divvalid_ffout,
div2mem_wr_wdata_ffout,

//output port
mem2ex_mem_op,
mem2ex_memadr,
mem2wb_wr_regindex,
mem2wb_wr_wdata,
mem2wb_wr_reg,
mem2wb_memaddr,
mem2wb_mem_byteen,
mem2wb_mem_en,
mem2wb_wr_mem,
mem2wb_mem_wdata,
mem2wb_rd_is_x1,
mem2wb_rd_is_xn,
store_stall,
dsram_addr,
dsram_cs,
dsram_we,
dsram_ben,
dsram_wdata,
mem2wb_exp,
mem2wb_int,
store_misaligned_exxeption
);
input clk, cpurst;
input ex2mem_wr_reg_ffout;
input [4:0] ex2mem_wr_regindex_ffout;
input [31:0] ex2mem_wr_wdata_ffout;
input [31:0] ex2mem_memaddr_ffout;
input ex2mem_wr_mem_ffout;
input [31:0] ex2mem_wr_memwdata_ffout;
input [2:0] ex2mem_mem_op_ffout;
input ex2mem_mem_en, ex2mem_mem_en_ffout;
input ex2mem_load_ffout, ex2mem_load, ex2mem_store_ffout;
input ex2mem_rd_is_x1_ffout;
input ex2mem_rd_is_xn_ffout;
input [31:0] readram_addr;
input [31:0] readram_rdata;
input mul2mem_LO_ffout, mul2mem_HI_ffout;
input mul2mem_prod_complete_ffout;
input [31:0] multprod_LO_ffout;
input [31:0] multprod_HI_ffout;
input load_misaligned_exxeption;
input ex2mem_exp_ffout;
input ex2mem_int_ffout;
input div2mem_divvalid_ffout;
input [31:0] div2mem_wr_wdata_ffout;


output [2:0] mem2ex_mem_op;
output [31:0] mem2ex_memadr;
output [4:0] mem2wb_wr_regindex;
output [31:0] mem2wb_wr_wdata;
output mem2wb_wr_reg;
output [31:0] mem2wb_memaddr;  //to sram write addr
output [3:0] mem2wb_mem_byteen;  //to sram byte enable
output mem2wb_mem_en;   // to sram cs for write, sram cs for read is ex2mem_mem_en
output mem2wb_wr_mem;  // to sram write enable
output [31:0] mem2wb_mem_wdata;
output mem2wb_rd_is_x1;
output mem2wb_rd_is_xn;
output store_stall;
output [31:0] dsram_addr;
output dsram_cs;
output dsram_we;
output [3:0] dsram_ben;
output [31:0] dsram_wdata;
output mem2wb_exp;
output mem2wb_int;
output store_misaligned_exxeption;

assign mem2wb_rd_is_x1 = ex2mem_rd_is_x1_ffout;
assign mem2wb_rd_is_xn = ex2mem_rd_is_xn_ffout;

    //mem2wb_pc = ex2mem_pc_ffout;

assign    mem2wb_wr_regindex = ex2mem_wr_regindex_ffout;

reg [31:0] mem2wb_wr_wdata;
always @*
begin
    if (ex2mem_load_ffout)
        mem2wb_wr_wdata = readram_rdata;
    
    ///////else begin   /**< sel from aluout / multout / divout */
    ///////    if (mul2mem_prod_complete_ffout) begin
    ///////        //if (mul2mem_LO_ffout){
    ///////        //    mem2wb_wr_wdata = multprod_LO_ffout;
    ///////        //}
    ///////        //else{
    ///////        //    mem2wb_wr_wdata = multprod_HI_ffout;
    ///////        //}
    ///////        mem2wb_wr_wdata = mul2mem_LO_ffout ? multprod_LO_ffout : 
    ///////                           mul2mem_HI_ffout ? multprod_HI_ffout : 32'b0;
    ///////                           
    ///////    end
    ///////    else if (div2mem_divvalid_ffout) begin
    ///////        mem2wb_wr_wdata = div2mem_wr_wdata_ffout;
    ///////    end
    ///////end    
        
    else
        mem2wb_wr_wdata = ex2mem_wr_wdata_ffout;
        
end


//    /**< STORE misaligned */
//    if (store_misaligned_exxeption_ffout){
//        mem2wb_memaddr = mem2ex_memadr_ffout;
//        mem2wb_mem_op = mem2ex_mem_op_ffout;
//        mem_wr_memwdata = mem2ex_wr_memwdata_ffout;
//    }
//    else{
//        mem2wb_memaddr = ex2mem_memaddr_ffout;
//        mem2wb_mem_op = ex2mem_mem_op_ffout;
//        mem_wr_memwdata = ex2mem_wr_memwdata_ffout;
//    }

reg store_misaligned_exxeption_ffout;
reg [31:0] mem2ex_memadr_ffout;
reg [2:0] mem2ex_mem_op_ffout;
reg [31:0] mem2ex_wr_memwdata_ffout;

wire [31:0] mem2wb_memaddr = store_misaligned_exxeption_ffout ? mem2ex_memadr_ffout : ex2mem_memaddr_ffout;
wire [2:0] mem2wb_mem_op = store_misaligned_exxeption_ffout ? mem2ex_mem_op_ffout : ex2mem_mem_op_ffout;
wire [31:0] mem_wr_memwdata = store_misaligned_exxeption_ffout ? mem2ex_wr_memwdata_ffout : ex2mem_wr_memwdata_ffout;

//    /**< disable write reg when LOAD misaligned, until next cycle */
//    if (load_misaligned_exxeption && mem2wb_mem_op){
//        mem2wb_wr_reg =0;
//    }
//    else{
//        mem2wb_wr_reg = ex2mem_wr_reg_ffout;
//    }

//assign mem2wb_wr_reg = load_misaligned_exxeption && mem2wb_mem_op ? 0 : ex2mem_wr_reg_ffout;
assign mem2wb_wr_reg = load_misaligned_exxeption  ? 0 : ex2mem_wr_reg_ffout;


    wire mem2wb_mem_en = ex2mem_mem_en_ffout;

    wire mem2wb_wr_mem = ex2mem_wr_mem_ffout;

    wire [1:0] byteaddr = mem2wb_memaddr[1:0] ;
    //unsigned int intaddr = (unsigned int) (mem2wb_memaddr >> 2);
    //
    /**< this is only for software implementation, in hardware should have byte-enable signal to support byte access*/
    //int oldv = dataram[intaddr];

reg store_misaligned_exxeption;
reg [31:0] mem2wb_mem_wdata;
reg [3:0] mem2wb_mem_byteen;
reg [31:0] mem2ex_memadr;
reg [2:0] mem2ex_mem_op;
reg [31:0] mem2ex_wr_memwdata;
always @*
  begin
    store_misaligned_exxeption =0;
    mem2wb_mem_wdata = mem_wr_memwdata;
    mem2wb_mem_byteen = 4'b0;
    mem2ex_memadr =0;
    mem2ex_mem_op =0;
    mem2ex_wr_memwdata =0;
    //if (ex2mem_mem_en_ffout && ex2mem_wr_mem_ffout)  /**< write memory, STORE */
    //  begin
            case(mem2wb_mem_op)
            
            `STORE_SB:  /**< no misaligned issue */
                case(byteaddr)
                
                0:
                    //mem2wb_mem_wdata = (unsigned int)(oldv&0xffffff00 )+ (mem_wr_memwdata&0xff);
                    mem2wb_mem_byteen = 4'b0001;
                1:
                  begin
                    //mem2wb_mem_wdata = (unsigned int)(oldv&0xffff0000 )+ (oldv&0xff )+ ((mem_wr_memwdata&0xff)<<8);
                    mem2wb_mem_wdata = {16'b0,mem_wr_memwdata[7:0],8'b0};
                    mem2wb_mem_byteen = 4'b0010;
                  end
                2:
                  begin
                    //mem2wb_mem_wdata = (unsigned int)(oldv&0xff000000 )+ (oldv&0xffff )+ ((mem_wr_memwdata&0xff)<<16);
                    mem2wb_mem_wdata = {8'b0,mem_wr_memwdata[7:0],16'b0};
                    mem2wb_mem_byteen = 4'b0100;
                  end
                3:
                  begin
                    //mem2wb_mem_wdata = (oldv&0x00ffffff )+ (unsigned int)((mem_wr_memwdata&0xff)<<24);
                    mem2wb_mem_wdata = {mem_wr_memwdata[7:0],24'b0};
                    mem2wb_mem_byteen = 4'b1000;
                  end
                endcase
            `STORE_SH:
                case(byteaddr)
                
                0:
                    //mem2wb_mem_wdata = (oldv&0xffff0000 )+ (mem_wr_memwdata&0xffff);
                    mem2wb_mem_byteen = 4'b0011;
                1:
                  begin
                    //mem2wb_mem_wdata = (oldv&0xff000000 )+ (oldv&0xff )+ ((mem_wr_memwdata&0xffff)<<8);
                    mem2wb_mem_wdata = {8'b0,mem_wr_memwdata[15:0],8'b0};
                    mem2wb_mem_byteen = 4'b0110;
                  end
                2:
                  begin
                    //mem2wb_mem_wdata = (oldv&0x0000ffff )+ + ((mem_wr_memwdata&0xffff)<<16);
                    mem2wb_mem_wdata = {mem_wr_memwdata[15:0],16'b0};
                    mem2wb_mem_byteen = 4'b1100;
                  end
                3:  /**< misaligned store , need 2 cycle to store mem */
                  begin
                    //mem2wb_mem_wdata = (oldv&0x00ffffff )+ (unsigned int)((mem_wr_memwdata&0xff)<<24);
                    mem2wb_mem_wdata = {mem_wr_memwdata[7:0],24'b0};
                    mem2wb_mem_byteen = 4'b1000;
                    mem2ex_memadr = ex2mem_memaddr_ffout+1;
                    mem2ex_mem_op = `STORE_SB;
                    //mem2ex_wr_memwdata = ((mem_wr_memwdata>>8)&0xff);
                    mem2ex_wr_memwdata = {24'b0,mem_wr_memwdata[15:8]};
                    store_misaligned_exxeption =1;
                  end
                endcase
            `STORE_SW:
                case(byteaddr)
                
                0:
                    //mem2wb_mem_wdata = mem_wr_memwdata;
                    mem2wb_mem_byteen = 4'b1111;
                1:
                  begin
                    //mem2wb_mem_wdata = (oldv&0xff)+ (unsigned int)((mem_wr_memwdata&0xffffff)<<8);
                    mem2wb_mem_wdata = {mem_wr_memwdata[23:0],8'b0};
                    mem2wb_mem_byteen = 4'b1110;
                    mem2ex_memadr = ex2mem_memaddr_ffout+3;
                    mem2ex_mem_op = `STORE_SB;
                    //mem2ex_wr_memwdata = (mem_wr_memwdata>>24)&0xff;
                    mem2ex_wr_memwdata = {24'b0,mem_wr_memwdata[31:24]};
                    store_misaligned_exxeption =1;
                  end
                2:
                  begin
                    //mem2wb_mem_wdata = (oldv&0xffff )+ (unsigned int)(((mem_wr_memwdata)&0xffff)<<16);
                    mem2wb_mem_wdata = {mem_wr_memwdata[15:0],16'b0};
                    mem2wb_mem_byteen = 4'b1100;
                    mem2ex_memadr = ex2mem_memaddr_ffout+2;
                    mem2ex_mem_op = `STORE_SH;
                    //mem2ex_wr_memwdata = (mem_wr_memwdata>>16)&0xffff;
                    mem2ex_wr_memwdata = {16'b0,mem_wr_memwdata[31:16]};
                    store_misaligned_exxeption =1;
                  end
                3:
                  begin
                    //mem2wb_mem_wdata = (oldv&0x00ffffff )+ (unsigned int)((mem_wr_memwdata&0xff) <<24);
                    mem2wb_mem_wdata = {mem_wr_memwdata[7:0],24'b0};
                    mem2wb_mem_byteen = 4'b1000;
                    mem2ex_memadr = ex2mem_memaddr_ffout+1;
                    mem2ex_mem_op = `STORE_SHB;
                    //mem2ex_wr_memwdata = (mem_wr_memwdata>>8)&0xffffff;
                    mem2ex_wr_memwdata = {8'b0,mem_wr_memwdata[31:8]};
                    store_misaligned_exxeption =1;
                  end
                endcase

            `STORE_SHB:  /**< only for solve STORE_SW case3 misaligned */
                begin
                    //mem2wb_mem_wdata = (unsigned int)(oldv&0xff000000)+ (mem_wr_memwdata&0x00ffffff);
                    mem2wb_mem_wdata = {8'b0,mem_wr_memwdata[23:0]};
                    mem2wb_mem_byteen = 4'b0111;
                end

            endcase
     // end  

    end

assign    store_stall = store_misaligned_exxeption & mem2wb_mem_en & mem2wb_wr_mem & ex2mem_store_ffout;

assign mem2wb_exp = ex2mem_exp_ffout;// | store_stall | load_misaligned_exxeption;

assign mem2wb_int = ex2mem_int_ffout;

// data ram signal
assign dsram_addr = mem2wb_wr_mem ? mem2wb_memaddr : readram_addr;
assign dsram_cs = (mem2wb_mem_en&ex2mem_store_ffout) | (ex2mem_mem_en&ex2mem_load);
assign dsram_we = mem2wb_wr_mem;
assign dsram_wdata = mem2wb_mem_wdata;
assign dsram_ben = mem2wb_mem_byteen;

//
always @(posedge clk)
begin
  if (cpurst)
    begin
      store_misaligned_exxeption_ffout <=0;
      mem2ex_memadr_ffout <= 0;
      mem2ex_mem_op_ffout <= 0;
      mem2ex_wr_memwdata_ffout <= 0;
    end
  else
    begin
      store_misaligned_exxeption_ffout <= store_stall;  //store_misaligned_exxeption;
      mem2ex_memadr_ffout <= mem2ex_memadr;
      mem2ex_mem_op_ffout <= mem2ex_mem_op;
      mem2ex_wr_memwdata_ffout <= mem2ex_wr_memwdata;
    end
end

//

endmodule
