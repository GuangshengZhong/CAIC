`include "src/defines.v"

module ControlUnit (
    input [31:0] instr,
    output reg [4:0] rs1_read_addr, rs2_read_addr, reg_write_addr,
    output reg [2:0] instr_funct3,
    //output reg [31:0] write_data,
    output [2:0] store_type,
    output reg [1:0] reg_src,
    output [2:0] branch_type,
    output [2:0] load_type,
    output accelerator_instr,
    output reg branch, jal, jalr,
    output reg mem_read, mem_write, reg_write_enable
);
    reg [6:0] opcode;
    reg [2:0] funct3;
    assign branch_type = funct3;
    assign load_type = funct3;
    assign store_type = funct3;
    assign accelerator_instr = (opcode==`INST_ACC);
    always@(*) begin
    opcode = instr[6:0];
    funct3 = instr[14:12];
    rs1_read_addr = instr[19:15];
    rs2_read_addr = instr[24:20];
    reg_write_addr = instr[11:7];
    instr_funct3 = funct3;
    case (opcode)
        `INST_TYPE_R:begin//ADD SUB SLL SLT SLTU XOR SRL SRA OR AND 
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;
            reg_write_enable = 1'b1;
            reg_src = `FROM_ALU;
        end
        `INST_TYPE_I:begin//ADDI SLTI SLTIU XORI ORI ANDI
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;
            reg_write_enable = 1'b1;
            reg_src = `FROM_ALU;
        end
        `INST_TYPE_S:begin//SB SH SW
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b1;
            reg_write_enable = 1'b0;
            reg_src = `FROM_MEM;
        end
        `INST_TYPE_L:begin//LB LH LW LBU LHU
            mem_read = 1'b1;
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b1; mem_write = 1'b0;
            reg_write_enable = 1'b1;
            reg_src = `FROM_MEM;
        end
        `INST_TYPE_B:begin//BEQ BNE BLT BGE BLTU BGEU
            branch = 1'b1; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;
            reg_write_enable = 1'b0;
            reg_src = `FROM_ALU;
        end
        `INST_LUI:begin//LUI
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;reg_write_enable = 1'b1;
            reg_src = `FROM_ALU;
        end
        `INST_AUIPC:begin//AUIPC
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;
            reg_write_enable = 1'b1;
            reg_src = `FROM_ALU;
        end
        `INST_JAL:begin//JAL
            branch = 1'b0; jal = 1'b1; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;
            reg_write_enable = 1'b1;
            reg_src = `FROM_PC;
        end
        `INST_JALR:begin//JALR
            branch = 1'b0; jal = 1'b0; jalr = 1'b1;
            mem_read = 1'b0; mem_write = 1'b0;//?
            reg_write_enable = 1'b1;
            reg_src = `FROM_PC;
        end
        // ISA extension
        `INST_ACC:begin
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            reg_src = `FROM_MEM;
            reg_write_enable = 1'b0;//??
            mem_read = (funct3 == `SAVE)||(funct3 == `LOAD)||(funct3 == `RESET)||(funct3 == `MOVE);
            mem_write = (funct3 == `LOAD)||(funct3 == `MATMUL)||(funct3 == `RESET)||(funct3 == `MOVE);
            /*
            case(funct3)
                `LOAD:begin
                    mem_read = 1'b1; mem_write = 1'b0;
                    reg_write_enable = 1'b1;
                    reg_src = `FROM_MEM;
                end
                `SAVE:begin
                    mem_read = 1'b0; mem_write = 1'b1;
                    reg_write_enable = 1'b0;
                    reg_src = `FROM_MEM;
                end
                `MATMUL:begin
                    mem_read = 1'b0; mem_write = 1'b0;
                    reg_write_enable = 1'b0;
                    reg_src = `FROM_MEM;
                end
                `RESET:begin
                    mem_read = 1'b0; mem_write = 1'b0;
                    reg_write_enable = 1'b0;
                    reg_src = `FROM_MEM;
                end
                `MOVE:begin
                    mem_read = 1'b0; mem_write = 1'b0;
                    reg_write_enable = 1'b0;
                    reg_src = `FROM_MEM;
                end
                default:begin
                    mem_read = 1'b0; mem_write = 1'b0;
                    reg_write_enable = 1'b0;
                    reg_src = `FROM_MEM;
                end
            endcase
            */
        end
        default:begin
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;
            reg_write_enable = 1'b0;
            reg_src = `FROM_PC;//For 32'b0
        end
    endcase
    end
endmodule