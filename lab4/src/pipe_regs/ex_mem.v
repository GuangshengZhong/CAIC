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

endmodule