#ifndef OPCODE_DEFINE_H_INCLUDED
#define OPCODE_DEFINE_H_INCLUDED

#define MCCODE_NOP      0x00000013

#define OPCODE_ZERO     0b0000000
#define OPCODE_IMM      0b0010011
#define OPCODE_OP       0b0110011
#define OPCODE_OP32     0b0111011
#define OPCODE_LOAD     0b0000011
#define OPCODE_STORE    0b0100011
#define OPCODE_LUI      0b0110111
#define OPCODE_AUIPC    0b0010111
#define OPCODE_JAL      0b1101111
#define OPCODE_JALR     0b1100111
#define OPCODE_BRANCH   0b1100011
#define OPCODE_MISCMEM  0b0001111
#define OPCODE_SYSTEM   0b1110011

#define BRANCH_BEQ         0x00
#define BRANCH_BNE         0x01
#define BRANCH_BLT         0x04
#define BRANCH_BGE         0x05
#define BRANCH_BLTU        0x06
#define BRANCH_BGEU        0x07

#define ALU_ADDI         0x00
#define ALU_SLLI         0x01
#define ALU_SLTI         0x02
#define ALU_SLTIU        0x03
#define ALU_XORI         0x04
#define ALU_SRLI         0x05
#define ALU_SRAI         0x05
#define ALU_ORI          0x06
#define ALU_ANDI         0x07

#define ALU_ADD         0x00
#define ALU_SUB         0x00
#define ALU_SLL          0x01
#define ALU_SLT          0x02
#define ALU_SLTU          0x03
#define ALU_XOR          0x04
#define ALU_SRL          0x05
#define ALU_SRA          0x05
#define ALU_OR          0x06
#define ALU_AND          0x07

#define ALU_MUL           0x00
#define ALU_MULH          0x01
#define ALU_MULHSU        0x02
#define ALU_MULHU         0x03
#define ALU_DIV           0x04
#define ALU_DIVU          0x05
#define ALU_REM           0x06
#define ALU_REMU          0x07

#define STORE_SB         0x00
#define STORE_SH         0x01
#define STORE_SW         0x02
#define STORE_SHB        0x03  /**< user define command, not standard ISA, only for misaligned */

#define LOAD_LB         0x00
#define LOAD_LH         0x01
#define LOAD_LW         0x02
#define LOAD_LHBU       0x03  /**< user define command, not standard ISA, only for misaligned */
#define LOAD_LBU         0x04
#define LOAD_LHU         0x05

#define SYSTEM_ECALL    0x00
#define SYSTEM_EBREAK   0x00
#define SYSTEM_CSRRW    0x01
#define SYSTEM_CSRRS    0x02
#define SYSTEM_CSRRC    0x03
#define SYSTEM_CSRRWI   0x05
#define SYSTEM_CSRRSI   0x06
#define SYSTEM_CSRRCI   0x07

#define CSR_WR          0x01
#define CSR_SET         0x02
#define CSR_CLR         0x03

#endif // OPCODE_DEFINE_H_INCLUDED
