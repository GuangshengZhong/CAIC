`include "src/dp_components/alu.v"
`include "src/dp_components/op_selector.v"
module EX_MODULE(
    input [3:0] alu_type,
    input alu_src1, alu_src2,
    input [31:0] pc,
    input [31:0] rs1_data, rs2_data, imm,
    //input [2:0] branch_type,
    input [31:0] reg_write_data_mem, reg_write_data_wb,
    input [1:0] rs1_fwd_ex, rs2_fwd_ex,
    //input branch, jal, jalr,
    output [31:0] alu_result,
    output [31:0] rs2_data_ex_new,
    //output [4:0] rs1_ex, rs2_ex,
    //output [31:0] new_pc,
    //output reg [31:0] mem_addr,//???
    output pc_src
);
    wire [31:0] op1, op2;
    wire [31:0] rs1_data_new, rs2_data_new;
    wire [31:0] alu_result_wire;
    wire zero,less_than;
    OpSelector EX_OP_SELECTOR(
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .reg_write_data_wb(reg_write_data_wb),
        .reg_write_data_mem(reg_write_data_mem),
        .fwd_ex1(rs1_fwd_ex),
        .fwd_ex2(rs2_fwd_ex),
        .pc(pc),
        .imm(imm),
        .op1(op1),
        .op2(op2),
        .rs1_data_new(rs1_data_new),
        .rs2_data_new(rs2_data_new)
        );
    ALU EX_ALU(
        .alu_in1(op1),
        .alu_in2(op2),
        .alu_type(alu_type),
        .alu_result(alu_result),
        .zero(zero),
        .less_than(less_than)
    );
    assign alu_result_wire = alu_result;
    assign rs2_data_ex_new = rs2_data_new;
endmodule