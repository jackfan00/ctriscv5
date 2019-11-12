`ifndef OPCODE_DEFINE_H_INCLUDED
`define OPCODE_DEFINE_H_INCLUDED

`define MCCODE_NOP      7'h13

`define OPCODE_ZERO     7'h00
`define OPCODE_IMM      7'b0010011
`define OPCODE_OP       7'b0110011
`define OPCODE_OP32     7'b0111011
`define OPCODE_LOAD     7'b0000011
`define OPCODE_STORE    7'b0100011
`define OPCODE_LUI      7'b0110111
`define OPCODE_AUIPC    7'b0010111
`define OPCODE_JAL      7'b1101111
`define OPCODE_JALR     7'b1100111
`define OPCODE_BRANCH   7'b1100011
`define OPCODE_MISCMEM  7'b0001111
`define OPCODE_SYSTEM   7'b1110011

`define BRANCH_BEQ         3'h0
`define BRANCH_BNE         3'h1
`define BRANCH_BLT         3'h4
`define BRANCH_BGE         3'h5
`define BRANCH_BLTU        3'h6
`define BRANCH_BGEU        3'h7

`define ALU_ADDI         3'h0
`define ALU_SLLI         3'h1
`define ALU_SLTI         3'h2
`define ALU_SLTIU        3'h3
`define ALU_XORI         3'h4
`define ALU_SRLI         3'h5
`define ALU_SRAI         3'h5
`define ALU_ORI          3'h6
`define ALU_ANDI         3'h7

`define ALU_ADD         3'h0
`define ALU_SUB         3'h0
`define ALU_SLL         3'h1
`define ALU_SLT         3'h2
`define ALU_SLTU        3'h3
`define ALU_XOR         3'h4
`define ALU_SRL         3'h5
`define ALU_SRA         3'h5
`define ALU_OR          3'h6
`define ALU_AND         3'h7

`define ALU_MUL           3'h0
`define ALU_MULH          3'h1
`define ALU_MULHSU        3'h2
`define ALU_MULHU         3'h3
`define ALU_DIV           3'h4
`define ALU_DIVU          3'h5
`define ALU_REM           3'h6
`define ALU_REMU          3'h7

`define STORE_SB         3'h0
`define STORE_SH         3'h1
`define STORE_SW         3'h2
`define STORE_SHB        3'h3  /**< user define command, not standard ISA, only for misaligned */

`define LOAD_LB         3'h0
`define LOAD_LH         3'h1
`define LOAD_LW         3'h2
`define LOAD_LHBU       3'h3  /**< user define command, not standard ISA, only for misaligned */
`define LOAD_LBU        3'h4
`define LOAD_LHU        3'h5

`define SYSTEM_ECALL    3'h0
`define SYSTEM_EBREAK   3'h0
`define SYSTEM_CSRRW    3'h1
`define SYSTEM_CSRRS    3'h2
`define SYSTEM_CSRRC    3'h3
`define SYSTEM_CSRRWI   3'h5
`define SYSTEM_CSRRSI   3'h6
`define SYSTEM_CSRRCI   3'h7

`define CSR_WR          3'h1
`define CSR_SET         3'h2
`define CSR_CLR         3'h3

`endif // OPCODE_DEFINE_H_INCLUDED
