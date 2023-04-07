//opcode
`define INST_TYPE_R 7'b0110011
`define INST_TYPE_I 7'b0010011
`define INST_TYPE_L 7'b0000011
`define INST_TYPE_S 7'b0100011
`define INST_TYPE_B 7'b1100011
`define INST_LUI    7'b0110111
`define INST_AUIPC  7'b0010111
`define INST_JAL    7'b1101111
`define INST_JALR   7'b1100111

//alu_op_type
`define ALU_OP_B    2'b01
`define ALU_OP_IR   2'b10

//alu_type
`define ADD   4'b0000
`define SLL   4'b0001
`define SLT   4'b0010
`define SLTU  4'b0011
`define XOR   4'b0100
`define SRL   4'b0101
`define OR    4'b0110
`define AND   4'b0111
`define SUB   4'b1000
`define SRA   4'b1101

`define SB 3'b000
`define SH 3'b001
`define SW 3'b010

`define READ_TYPE 1'b0
`define WRITE_TYPE 1'b1

// funct3 for arithmetic operations
`define SR_FUNCT3  3'b101
`define SLL_FUNCT3 3'b001