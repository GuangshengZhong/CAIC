`include "src/dp_components/alu.v"
`include "src/dp_components/pc_ex.v"
`include "src/dp_components/op_selector.v"
module EX_MODULE(
    input [3:0] alu_type,
    input alu_src1, alu_src2,
    input [31:0] rs1_data, rs2_data, imm,
    input [2:0] branch_type,
    input [31:0] pc,
    input branch, jal, jalr,
    output [31:0] alu_result,
    output [31:0] new_pc,
    //output reg [31:0] mem_addr,//???
    output pc_src
);
    wire [31:0] op1, op2;
    wire [31:0] alu_result_wire;
    wire zero,less_than;
    OpSelector EX_OP_SELECTOR(
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .pc(pc),
        .imm(imm),
        .op1(op1),
        .op2(op2)
        );
    ALU EX_ALU(
        .alu_in1(op1),
        .alu_in2(op2),
        .alu_type(alu_type),
        .alu_result(alu_result),
        .zero(zero),
        .less_than(less_than)
    );
    PC_EX EX_PC_EX(
        .branch(branch),.jal(jal),.jalr(jalr),
        .branch_type(branch_type),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .zero(zero),.less_than(less_than),
        .alu_result(alu_result_wire),
        .pc_src(pc_src),
        .new_pc(new_pc)
    );
    assign alu_result_wire = alu_result;
endmodule