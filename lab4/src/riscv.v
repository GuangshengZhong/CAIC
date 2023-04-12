`include "src/defines.v"
`include "src/five_stages/if.v"
`include "src/five_stages/id.v"
`include "src/five_stages/ex.v"
`include "src/five_stages/mem.v"
`include "src/five_stages/wb.v"
`include "src/templates/pipe_dff.v"
`include "src/pipe_regs/if_id.v"
`include "src/pipe_regs/id_ex.v"
`include "src/pipe_regs/ex_mem.v"
`include "src/pipe_regs/mem_wb.v"
`include "src/hazard_unit/forward_unit_id.v"
`include "src/hazard_unit/forward_unit_ex.v"
`include "src/hazard_unit/hazard_detect_unit.v"

module RISCVPipeline (
    input clk, rst,
    input [31:0] instr, mem_read_data,
    output ram_write,
    output [2:0] write_type,
    output [31:0] instr_addr, mem_addr, mem_write_data
);

    //ID
    wire [31:0] instr, instr_id, pc_id, pc_plus4_id, imm_id, rs1_data_id, rs2_data_id ;
    wire branch_id, jal_id, jalr_id, mem_read_id, mem_write_id, reg_write_id, alu_src1_id, alu_src2_id;
    wire [1:0] reg_src_id;
    wire [2:0] instr_funct3_id;
    wire [3:0] alu_type_id;
    wire [4:0] rd_id, rs1_id, rs2_id;
    ID_MODULE id_module(
        .instr(instr),
        .reg_write_data(reg_write_data_mem),
        .pc_id(pc_id),.pc_plus4_id(pc_plus4_id),//还没写完！
    );


    //EX
    wire [3:0] alu_type_ex;
    wire alu_src1_ex, alu_src2_ex;
    wire [31:0] pc_ex, rs1_data_ex, rs2_data_ex, imm_ex;
    wire [4:0] rs1_ex, rs2_ex;
    wire [31:0] reg_write_data_mem, reg_write_data_wb;
    wire [1:0] rs1_fwd_ex, rs2_fwd_ex;
    wire [31:0] alu_result_ex;
    EX_MODULE ex_module(
        .alu_type(alu_type_ex),
        .alu_src1(alu_src1_ex),.alu_src2(alu_src2_ex),
        .pc(pc_ex),
        .rs1_data(rs1_data_ex),.rs2_data(rs2_data_ex),
        .imm(imm_ex),
        .reg_write_data_mem(reg_write_data_mem),
        .reg_write_data_wb(reg_write_data_wb),
        .rs1_fwd_ex(rs1_fwd_ex),.rs2_fwd_ex(rs2_fwd_ex),
        .alu_result(alu_result_ex),
    );
endmodule