`include "src/defines.v"

module ImmGen (
    input [31:0] instr,
    output reg [31:0] imm
);
    reg [11:0] imm12;
    reg [20:0] imm20;
    reg [31:0] immtemp;
    reg [2:0] funct3;
    reg [6:0] opcode;
    always@(*) begin
    funct3 = instr[14:12];
    opcode = instr[6:0];
    immtemp = 32'b0;
    case (opcode)
        `INST_TYPE_R: imm = 32'b0;
        `INST_TYPE_I: begin
            if(funct3 != 3'b000 && funct3!= 3'b101)begin
                immtemp[31:20] = instr[31:20];
                imm = $signed(immtemp)>>>20;
            end
            else begin
                immtemp[31:27] = instr[24:20];
                imm = $signed(immtemp)>>>27;
            end //SLLI SRLI SRAI
        end
        `INST_TYPE_S:begin//SB SH SW
            immtemp[31:25] = instr[31:25];
            immtemp[24:20] = instr[11:7];
            imm = $signed(immtemp)>>>20;
        end
        `INST_TYPE_L:begin//LB LH LW LBU LHU
            immtemp[31:20] = instr[31:20];
            imm = $signed(immtemp)>>>20;
        end
        `INST_TYPE_B:begin//BEQ BNE BLT BGE BLTU BGEU
            imm12[11] = instr[31];
            imm12[9:4] = instr[30:25];
            imm12[10] = instr[7];
            imm12[3:0] = instr[11:8];
            immtemp[31:20] = imm12;
            imm = $signed(immtemp)>>>19;
        end
        `INST_LUI:begin//LUI
            immtemp[31:12] = instr[31:12];
            imm = immtemp;
        end
        `INST_AUIPC:begin//AUIPC
            immtemp[31:12] = instr[31:12];
            imm = immtemp;
        end
        `INST_JAL:begin//JAL
            imm20[19] = instr[31];
            imm20[18:11] = instr[19:12];
            imm20[10] = instr[20];
            imm20[9:0] = instr[30:21];
            immtemp[31:12] = imm20;
            imm = $signed(immtemp)>>>11;
        end
        `INST_JALR:begin//JALR
            immtemp[31:20] = instr[31:20];
            imm = $signed(immtemp)>>>20;
        end
        default: imm = 32'b0;
    endcase
    end

endmodule