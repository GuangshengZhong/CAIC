`include "src/defines.v"
module ID_EX(
    input clk,
    input [31:0] pc_id, pc_plus4_id, 
    input [31:0] imm_id, rs1_data_id, rs2_data_id,
    input branch_id, jal_id, jalr_id, 
    input mem_read_id, mem_write_id, reg_write_id, // 3rd =reg_write_enable 
    input [1:0] reg_src_id,
    input alu_src1_id, alu_src2_id,
    input [2:0] instr_funct3_id, //To Complete
    input [3:0] alu_type_id,
    input [4:0] rd_id, rs1_id, rs2_id,
    input stall_ex, bubble_ex,
    output mem_read_ex, mem_write_ex, reg_write_ex,
    output alu_src1_ex, alu_src2_ex,
    output [31:0] pc_plus4_ex, pc_ex,
    output [31:0] imm_ex, rs1_data_ex, rs2_data_ex,
    output [1:0] reg_src_ex,
    output [2:0] instr_funct3_ex,
    output [3:0] alu_type_ex, 
    output [4:0] rd_ex, rs1_ex, rs2_ex//[4:0]??
);
    PipeDff ID_EX_pc(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(`ZERO_WORD),.data_in(pc_id),.data_out(pc_ex));
    PipeDff ID_EX_pc_plus4(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(`ZERO_WORD),.data_in(pc_plus4_id),.data_out(pc_plus4_ex));
    PipeDff ID_EX_imm(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(`ZERO_WORD),.data_in(imm_id),.data_out(imm_ex));
    PipeDff ID_EX_rs1_data(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(`ZERO_WORD),.data_in(rs1_data_id),.data_out(rs1_data_ex));
    PipeDff ID_EX_rs2_data(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(`ZERO_WORD),.data_in(rs2_data_id),.data_out(rs2_data_ex));

    PipeDff #(5) ID_EX_rd(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(`ZERO_REG),.data_in(rd_id),.data_out(rd_ex));
    PipeDff #(5) ID_EX_rs1(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(`ZERO_REG),.data_in(rs1_id),.data_out(rs1_ex));
    PipeDff #(5) ID_EX_rs2(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(`ZERO_REG),.data_in(rs2_id),.data_out(rs2_ex));

    PipeDff #(4) ID_EX_alu_type(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(`ADD),.data_in(alu_type_id),.data_out(alu_type_ex));
    PipeDff #(3) ID_EX_instr_funct3(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(`SB),.data_in(instr_funct3_id),.data_out(instr_funct3_ex));
    PipeDff #(2) ID_EX_reg_src(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(`FROM_ALU),.data_in(reg_src_id),.data_out(reg_src_ex));

    PipeDff #(1) ID_EX_mem_write(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(1'b0),.data_in(mem_write_id),.data_out(mem_write_ex));
    PipeDff #(1) ID_EX_reg_write(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(1'b0),.data_in(reg_write_id),.data_out(reg_write_ex));
    PipeDff #(1) ID_EX_jalr(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(1'b0),.data_in(jalr_id),.data_out(jalr_ex));
    PipeDff #(1) ID_EX_alu_src1(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(1'b0),.data_in(alu_src1_id),.data_out(alu_src1_ex));
    PipeDff #(1) ID_EX_branch(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(1'b0),.data_in(branch_id),.data_out(branch_ex));
    PipeDff #(1) ID_EX_mem_read(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(1'b0),.data_in(mem_read_id),.data_out(mem_read_ex));
    PipeDff #(1) ID_EX_alu_src2(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(1'b0),.data_in(alu_src2_id),.data_out(alu_src2_ex));
    PipeDff #(1) ID_EX_jal(.clk(clk),.bubble(bubble_ex),.stall(stall_ex),.default_val(1'b0),.data_in(jal_id),.data_out(jal_ex));


endmodule