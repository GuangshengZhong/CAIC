`include "src/dp_components/regfile.v"
`include "src/dp_components/imm_gen.v"
`include "src/cp_components/control_unit.v"
`include "src/cp_components/alu_control.v"
`include "src/dp_components/pc_ex.v"
`include "src/dp_components/id_control.v"
module ID_MODULE(
    input [31:0] instr,
    //input [31:0] reg_write_data,//用_wb _mem代替？
    input [31:0] pc, pc_plus4,//for pc_ex
    input clk,
    input reg_write_in,
    input [31:0] reg_write_data_mem,//new
    input [31:0] reg_write_data_wb,//new
    input [1:0] rs1_fwd_id,rs2_fwd_id,
    input [4:0] rd_wb,//从wb传过来的
    output pc_src,
    output [1:0] reg_src, 
    output alu_src1, alu_src2,
    output mem_read, mem_write, reg_write_out,
    output [31:0] rs1_data, rs2_data, imm,
    output [31:0] new_pc,
    output [2:0] branch_type, load_type, store_type, instr_funct3,
    output [3:0] alu_type, 
    output [4:0] rd, rs1, rs2,
    output branch, jal, jalr
);
    wire [2:0] funct3_inn;
    wire [4:0] R_Addr1, R_Addr2, W_Addr;
    //wire [31:0] R_Data1_p, R_Data2_p;
    wire [31:0] rs1_data_old, rs2_data_old;
    wire [31:0] rs1_data_new, rs2_data_new;
    wire branch_inn, jal_inn, jalr_inn;
    wire zero, less_than;
    assign rd = W_Addr;
    assign rs1 = R_Addr1;
    assign rs2 = R_Addr2;
    ImmGen ID_Imm_Gen(
        .instr(instr),
        .imm(imm)
    );

    wire reg_write_enable;
    assign reg_write_enable = reg_write_in || rs1_fwd_id || rs2_fwd_id;//???

    ControlUnit ID_Control_Unit(
        .instr(instr), 
        .rs1_read_addr(R_Addr1),
        .rs2_read_addr(R_Addr2),
        .reg_write_addr(W_Addr),
        .branch(branch_inn),
        .jal(jal_inn),
        .jalr(jalr_inn),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .instr_funct3(funct3_inn),
        //.write_data(reg_write_data),
        .reg_write_enable(reg_write_out),
        .store_type(store_type),
        .reg_src(reg_src),
        .branch_type(branch_type),
        .load_type(load_type)
    );

    ALUControl ID_ALU_Control(
        .instr(instr),
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .R_Data1(rs1_data_new),
        .R_Data2(rs2_data_new),
        .imm(imm),
        //.pc(pc),
        .alu_type(alu_type)
    );

    wire [31:0] reg_write_data_chosen;
    wire [4:0] reg_write_addr;
    assign reg_write_data_chosen = (rs1_fwd_id||rs2_fwd_id) ? reg_write_data_mem : reg_write_data_wb;
    assign reg_write_addr = rs1_fwd_id ? R_Addr1 : (rs2_fwd_id ? R_Addr2 : rd_wb);

    RegFile ID_RegFile(
        .read_addr1(R_Addr1),
        .read_addr2(R_Addr2),
        .reg_write_addr(reg_write_addr),
        .reg_write_data(reg_write_data_chosen),//not sure
        .clk(clk),
        .read_data1(rs1_data_old),
        .read_data2(rs2_data_old),
        .reg_write_enable(reg_write_enable)
    );

    ID_Control ID_ID_Control(
        .branch(branch_inn),
        .rs1_data(rs1_data_old), .rs2_data(rs2_data_old),
        .reg_write_data_mem(reg_write_data_mem),
        .rs1_fwd_id(rs1_fwd_id), .rs2_fwd_id(rs2_fwd_id),
        .funct3(funct3_inn),
        .rs1_data_update(rs1_data_new), .rs2_data_update(rs2_data_new),
        .alu_type(alu_type),
        .zero(zero), .less_than(less_than)
    );

    PC_EX ID_PC_EX(
        .branch(branch_inn),.jal(jal_inn),.jalr(jalr_inn),
        .branch_type(branch_type),
        .pc(pc),.pc_plus4(pc_plus4),
        .rs1_data(rs1_data_new),
        //.rs2_data(rs2_data),
        .imm(imm),
        .zero(zero),.less_than(less_than),
        //.alu_result(alu_result_wire),
        .pc_src(pc_src),
        .new_pc(new_pc)
    );

    assign rs1_data = rs1_data_new;
    assign rs2_data = rs2_data_new;
    assign branch = branch_inn;
    assign jal = jal_inn;
    assign jalr = jalr_inn;
    assign instr_funct3 = funct3_inn;
endmodule