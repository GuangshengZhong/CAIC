`include "src/defines.v"
module MEM_WB(
    input [31:0] pc_plus4_mem,
    input [31:0] imm_mem, alu_result_mem, mem2reg_data,
    input reg_write_mem, // 3rd =reg_write_enable 
    input [1:0] reg_src_mem,
    input [4:0] rd_mem,
    input stall_wb, bubble_wb,
    //To NextReg and MEM_Module
    output [31:0] nxpc_wb
    output [31:0] imm_wb, alu_result_wb, mem_to_reg_data_wb,
    output [1:0] reg_src_wb
)
    
endmodule