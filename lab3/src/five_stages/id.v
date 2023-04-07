`include "src/dp_components/regfile.v"
`include "src/dp_components/imm_gen.v"
`include "src/cp_components/control_unit.v"
`include "src/cp_components/alu_control.v"
module ID_MODULE(
    input [31:0] instr,
    input [31:0] reg_write_data,
    input clk,
    output [1:0] reg_src, 
    output alu_src1, alu_src2,
    output mem_read, mem_write, 
    output [31:0] rs1_data, rs2_data, imm,
    output [3:0] alu_type, 
    output [2:0] branch_type, load_type, store_type,
    output branch, jal, jalr
);
    wire [4:0] R_Addr1, R_Addr2, W_Addr;
    wire [31:0] R_Data1_p, R_Data2_p;
    wire reg_write_enable;
    
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
        //.inst(instr_out),
        //.write_data(reg_write_data),
        .reg_write_enable(reg_write_enable),
        .store_type(store_type),
        .reg_src(reg_src),
        .branch_type(branch_type),
        .load_type(load_type)
    );
    ALUControl ID_ALU_Control(
        .instr(instr),
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .R_Data1(R_Data1_p),
        .R_Data2(R_Data2_p),
        .imm(imm),
        //.pc(pc),
        .alu_type(alu_type)
    );
    RegFile ID_RegFile(
        .read_addr1(R_Addr1),
        .read_addr2(R_Addr2),
        .reg_write_addr(W_Addr),
        .reg_write_data(reg_write_data),
        .clk(clk),
        .read_data1(rs1_data),
        .read_data2(rs2_data),
        .reg_write_enable(reg_write_enable)
    );
    assign R_Data1_p = rs1_data;
    assign R_Data2_p = rs2_data;
endmodule