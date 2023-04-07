`include "src/cp_components/alu_control.v"
`include "src/cp_components/control_unit.v"
`include "src/dp_components/pc.v"
`include "src/dp_components/regfile.v"
`include "src/dp_components/imm_gen.v"
`include "src/template/adder.v"
`include "src/ram.v"

module TOP (
    input clk, rst,
    input [31:0] write_data,
    output [31:0] rs1_data, rs2_data,
    output [31:0] imm,
    output branch, jal, jalr, 
    output mem_read, mem_write,
    output alu_src1, alu_src2,
    output [3:0] alu_type,
    // output for verification
    output reg_write_enable,
    output [31:0] instr_out,
    output [31:0] alu_op1, alu_op2
);
    wire [31:0] pc, nxpc;
    wire [31:0] pc_incre = 32'h00000004;
    wire [31:0] instr;

    wire reg_write;
    wire[1:0] alu_op_type;

    // for RAM: RAM is only used for reading, so default signals about writing.
    wire write_enable = `READ_TYPE;
    wire [2:0] write_type = 3'b111;
    wire [31:0] data_in = 32'h00000000;

    //IF Module
    PC IF_PC(
        .rst(rst),
        .clk(clk),
        .pc(pc),
        .new_pc(nxpc)
    );
    RAM IF_Instr_Mem(
        .clk(clk),
        .addr(pc),
        .data_out(instr),
        .data_in(data_in),
        .write_type(write_type),
        .write_enable(write_enable)
    );
    Adder IF_ADD(
        .op_num1(pc),
        .op_num2(pc_incre),
        .res(nxpc)
    );
    //ID Module
    wire [4:0] R_Addr1, R_Addr2, W_Addr;
    wire [31:0] R_Data1_p, R_Data2_p;
    ImmGen ID_Imm_Gen(
        .instr(instr),
        .imm(imm)
    );
    ControlUnit ID_Control_Unit(
        .instr(instr), 
        .rs1_read_addr(R_Addr1),
        .rs2_read_addr(R_Addr2),
        .reg_write_addr(W_Addr),
        .branch(branch),
        .jal(jal),
        .jalr(jalr),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .inst(instr_out),
        .write_data(data_in),
        .reg_write_enable(reg_write_enable)
    );//write_data(???)
    ALUControl ID_ALU_Control(
        .instr(instr),
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .R_Data1(R_Data1_p),
        .R_Data2(R_Data2_p),
        .imm(imm),
        .pc(pc),
        .alu_op1(alu_op1),
        .alu_op2(alu_op2),
        .alu_type(alu_type)
    );
    RegFile ID_RegFile(
        .R_Addr1(R_Addr1),
        .R_Addr2(R_Addr2),
        .W_Addr(W_Addr),
        .W_Data(write_data),
        .clk(clk),
        .R_Data1(rs1_data),
        .R_Data2(rs2_data),
        .write_enable(write_enable)
    );
    assign R_Data1_p = rs1_data;
    assign R_Data2_p = rs2_data;
endmodule