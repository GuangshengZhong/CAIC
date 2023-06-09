`include "src/defines.v"

module ControlUnit (
    input [31:0] instr,
    //output alu_src1,alu_src2,
    //output [3:0] alu_type,
    output reg [4:0] rs1_read_addr, rs2_read_addr, reg_write_addr,
    output reg [31:0] inst,
    output reg [31:0] write_data,
    // output reg [31:0] alu_op1, alu_op2,//temp
    // output [2:0] store_type,
    // output [1:0] reg_src,
    // output [2:0] branch_type,
    // output [2:0] load_type
    output reg branch, jal, jalr,
    output reg mem_read, mem_write, reg_write_enable
);
    reg [6:0] opcode;
    reg [2:0] funct3;
    //store_type = 3'b0; load_type = 3'b0; branch_type = 3'b0; reg_src = 2'b0;
    always@(*) begin
    opcode = instr[6:0];
    funct3 = instr[14:12];
    rs1_read_addr = instr[19:15];
    rs2_read_addr = instr[24:20];
    inst = instr;
    case (opcode)
        `INST_TYPE_R:begin//.ADD .SUB .SLL .SLT .SLTU .XOR .SRL .SRA .OR .AND 
            reg_write_addr = instr[11:7];
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;
            reg_write_enable = 1'b1;
        end
        `INST_TYPE_I:begin//.ADDI .SLTI .SLTIU .XORI .ORI .ANDI
            reg_write_addr = instr[11:7];
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;
            reg_write_enable = 1'b1;
        end
        `INST_TYPE_S:begin//SB SH SW
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b1;
            reg_write_enable = 1'b0;
        end
        `INST_TYPE_L:begin//LB LH LW LBU LHU
            mem_read = 1'b1;
            reg_write_addr = instr[11:7];
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b1; mem_write = 1'b0;
            reg_write_enable = 1'b1;
        end
        `INST_TYPE_B:begin//BEQ BNE BLT BGE BLTU BGEU
            branch = 1'b1; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;
            reg_write_enable = 1'b0;
        end
        `INST_LUI:begin//LUI
            reg_write_addr = instr[11:7];
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;reg_write_enable = 1'b1;
        end
        `INST_AUIPC:begin//AUIPC
            reg_write_addr = instr[11:7];
            branch = 1'b0; jal = 1'b0; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;
            reg_write_enable = 1'b1;
        end
        `INST_JAL:begin//JAL
            reg_write_addr = instr[11:7];
            branch = 1'b0; jal = 1'b1; jalr = 1'b0;
            mem_read = 1'b0; mem_write = 1'b0;
            reg_write_enable = 1'b1;
        end
        `INST_JALR:begin//JALR
            reg_write_addr = instr[11:7];
            branch = 1'b0; jal = 1'b0; jalr = 1'b1;
            mem_read = 1'b0; mem_write = 1'b0;//?
            reg_write_enable = 1'b1;
        end
    endcase
    end
endmodule