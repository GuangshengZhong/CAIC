`include "src/defines.v"
`include "src/templates/pipe_dff.v"
module EX_MEM(
    input clk,
    input [31:0] pc_plus4_ex,
    input [31:0] imm_ex, rs2_data_ex, alu_result_ex,
    input mem_read_ex, mem_write_ex, reg_write_ex, // 3rd =reg_write_enable 
    input [1:0] reg_src_ex,
    input [2:0] instr_funct3_ex, //To Complete
    input [4:0] rd_ex,
    input stall_mem, bubble_mem,
    //To NextReg and MEM_Module
    output mem_read_mem, mem_write_mem, reg_write_mem,
    output [31:0] pc_plus4_mem,
    output [31:0] imm_mem, rs2_data_mem, alu_result_mem,
    output [1:0] reg_src_mem,
    output [2:0] instr_funct3_mem,
    output [4:0] rd_mem, //[4:0]??
    // To Memory
    output mem_write, 
    output [2:0] write_type,
    output [31:0] write_data, mem_addr
)
    PipeDff EX_MEM_alu_result(.clk(clk),.bubble(bubble_mem),.stall(stall_mem),.default_val(`ZERO_WORD),.data_in(alu_result_ex),.data_out(alu_result_mem));
    PipeDff EX_MEM_pc_plus4(.clk(clk),.bubble(bubble_mem),.stall(stall_mem),.default_val(`ZERO_WORD),.data_in(pc_plus4_ex),.data_out(pc_plus4_mem));
    PipeDff EX_MEM_imm(.clk(clk),.bubble(bubble_mem),.stall(stall_mem),.default_val(`ZERO_WORD),.data_in(imm_ex),.data_out(imm_mem));
    PipeDff EX_MEM_rs2_data(.clk(clk),.bubble(bubble_mem),.stall(stall_mem),.default_val(`ZERO_WORD),.data_in(rs2_data_ex),.data_out(rs2_data_mem));

    PipeDff EX_MEM_mem_write(.clk(clk),.bubble(bubble_mem),.stall(stall_mem),.default_val(1'b0),.data_in(mem_write_ex),.data_out(mem_write_mem));
    PipeDff EX_MEM_reg_write(.clk(clk),.bubble(bubble_mem),.stall(stall_mem),.default_val(1'b0),.data_in(reg_write_ex),.data_out(reg_write_mem));
    PipeDff EX_MEM_mem_read(.clk(clk),.bubble(bubble_mem),.stall(stall_mem),.default_val(1'b0),.data_in(mem_read_ex),.data_out(mem_read_mem));

    PipeDff EX_MEM_instr_funct3(.clk(clk),.bubble(bubble_mem),.stall(stall_mem),.default_val(`SB),.data_in(instr_funct3_ex),.data_out(instr_funct3_mem));
    PipeDff EX_MEM_rd(.clk(clk),.bubble(bubble_mem),.stall(stall_mem),.default_val(`ZERO_REG),.data_in(rd_ex),.data_out(rd_mem));
    PipeDff EX_MEM_reg_src(.clk(clk),.bubble(bubble_mem),.stall(stall_mem),.default_val(`FROM_ALU),.data_in(reg_src_ex),.data_out(reg_src_mem));

endmodule