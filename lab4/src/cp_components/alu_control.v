`include "src/defines.v"

module ALUControl (
    input [31:0] instr,
    input [31:0] R_Data1, R_Data2,
    input [31:0] imm,
    //input [31:0] pc,
    output reg alu_src1, alu_src2,
    //output reg [31:0] alu_op1, alu_op2,
    output reg [3:0] alu_type
);
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    always@(*) begin
    opcode = instr[6:0];
    funct3 = instr[14:12];
    funct7 = instr[31:25];
        case (opcode)
        `INST_TYPE_R: begin
            funct7 = instr[31:25];
            alu_src1 = 1'b0;
            alu_src2 = 1'b0;
            // alu_op1 = R_Data1;
            // alu_op2 = R_Data2;
            case (funct3)
            3'b000: alu_type = (funct7 == 7'b0 ) ? `ADD : `SUB;
            3'b001: alu_type = `SLL;
            3'b010: alu_type = `SLT;
            3'b011: alu_type = `SLTU;
            3'b100: alu_type = `XOR;
            3'b101: alu_type = (funct7 == 7'b0 ) ? `SRL : `SRA;
            3'b110: alu_type = `OR;
            3'b111: alu_type = `AND;
            default: alu_type = 4'b0;
            endcase
        end
        `INST_TYPE_I: begin
            alu_src1 = 1'b0;
            alu_src2 = 1'b1;
            // alu_op1 = R_Data1;
            // alu_op2 = imm;
            case (funct3)
            3'b000: alu_type = `ADD;//ADDI
            3'b010: alu_type = `SLT;//SLTI
            3'b011: alu_type = `SLTU;//SLTIU
            3'b100: alu_type = `XOR;//XORI
            3'b110: alu_type = `OR;//ORI
            3'b111: alu_type = `AND;//ANDI
            //////
            3'b001: alu_type = `SLL; //SLLI
            3'b101: alu_type = (funct7 == 7'b0 ) ? `SRL : `SRA;//SRLI:SRAI
            default: alu_type = 4'b0;
            endcase
        end
        `INST_TYPE_L: begin
            alu_src1 = 1'b0;
            alu_src2 = 1'b1;
            // alu_op1 = R_Data1;
            // alu_op2 = imm;
            alu_type = `ADD;
        end
        `INST_TYPE_S: begin
            alu_src1 = 1'b0;
            alu_src2 = 1'b1;
            // alu_op1 = R_Data1;
            // alu_op2 = imm;
            alu_type = `ADD;
        end
        `INST_TYPE_B: begin
            alu_src1 = 1'b0;
            alu_src2 = 1'b0;
            // alu_op1 = R_Data1;
            // alu_op2 = R_Data2;
            case(funct3)
            3'b000: alu_type = `SUB;//BEQ
            3'b001: alu_type = `SUB;//BNE
            3'b100: alu_type = `SLT;//BLT
            3'b101: alu_type = `SLT;//BGE
            3'b110: alu_type = `SLTU;//BLTU
            3'b111: alu_type = `SLTU;//BGEU
            endcase
            alu_type = `ADD;
        end
        `INST_LUI:begin
            alu_src1 = 1'b0;
            alu_src2 = 1'b1;
            // alu_op1 = R_Data1;
            // alu_op2 = imm;
            alu_type = `ADD;
        end
        `INST_AUIPC:begin
            alu_src1 = 1'b1;
            alu_src2 = 1'b1;
            // alu_op1 = pc;
            // alu_op2 = imm;
            alu_type = `ADD;
        end
        `INST_JAL:begin
            alu_src1 = 1'b1;
            alu_src2 = 1'b1;
            alu_type = `ADD;
            // alu_op1 = R_Data1;
            // alu_op1 = pc;
            // alu_op2 = imm;
        end
        `INST_JALR:begin
            alu_src1 = 1'b0;
            alu_src2 = 1'b1;
            alu_type = `ADD;
            // alu_op1 = R_Data1;
            // alu_op2 = imm;
        end
        endcase
    end

endmodule