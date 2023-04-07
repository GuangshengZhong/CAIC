`include "src/five_stages/if.v"
`include "src/five_stages/id.v"
`include "src/five_stages/ex.v"
`include "src/five_stages/mem.v"
`include "src/five_stages/wb.v"

module RISCVSingleSycle (
    input clk, rst,
    input [31:0] instr, mem_read_data,
    output ram_write,
    output [2:0] write_type,
    output [31:0] instr_addr, mem_addr, mem_write_data
);
    wire pc_src, alu_src1, alu_src2, debug;
    wire mem_read;
    wire branch, jal, jalr;
    wire [1:0] reg_src;
    wire [2:0] branch_type, load_type, store_type;
    wire [3:0] alu_type;
    wire [31:0] new_pc, pc, pc_plus4, instr;
    wire [31:0] rs1_data, rs2_data, imm;
    wire [31:0] reg_write_data;
    wire [31:0] alu_result;
    wire [31:0] mem2reg_data;
    assign mem_addr = alu_result;
    assign mem_write_data = rs2_data;
    assign instr_addr = pc;
    IF_MODULE RISCV_SC_IF(
        .rst(rst),
        .clk(clk),
        .pc_src(pc_src),
        .new_pc(new_pc),
        //.instr(instr),
        .pc_plus4(pc_plus4),
        .pc(pc)
    );
    ID_MODULE RISCV_SC_ID(
        .instr(instr),
        .reg_write_data(reg_write_data),
        .clk(clk),
        .reg_src(reg_src),
        .alu_src1(alu_src1),.alu_src2(alu_src2),
        .mem_read(mem_read),.mem_write(ram_write),
        .rs1_data(rs1_data),.rs2_data(rs2_data),
        .imm(imm),
        .alu_type(alu_type),.branch_type(branch_type),
        .load_type(load_type),.store_type(write_type),
        .branch(branch),.jal(jal),.jalr(jalr)
    );
    EX_MODULE RISCV_SC_EX(
        .alu_src1(alu_src1),.alu_src2(alu_src2),
        .alu_type(alu_type),.branch_type(branch_type),
        .rs1_data(rs1_data),.rs2_data(rs2_data),
        .imm(imm),
        .pc(pc),.new_pc(new_pc),.pc_src(pc_src),
        .branch(branch),.jal(jal),.jalr(jalr),
        .alu_result(alu_result)
    );
    MEM_MODULE RISCV_SC_MEM(
        .mem_read(mem_read),.load_type(load_type),
        .mem_read_data(mem_read_data),
        .mem2reg_data(mem2reg_data)
    );
    // MEM RISCV_SC_MEMORY(
    //     .clk(clk),.debug(debug),
    //     .write_enable(write_enable),
    //     .write_type(store_type),
    //     .addr(alu_result),
    //     .data_in(rs2_data),
    //     .data_out(mem_read_data)
    // );
    WB_MODULE RISCV_SC_WB(
        .reg_src(reg_src),
        .imm(imm),
        .alu_result(alu_result),
        .pc_plus4(pc_plus4),
        .mem2reg_data(mem2reg_data),
        .reg_write_data(reg_write_data)
    );
endmodule