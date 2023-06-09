`include "src/defines.v"
module MEM_WB(
    input clk,
    input [31:0] pc_plus4_mem,
    input [31:0] imm_mem, alu_result_mem, mem2reg_data_mem,
    input reg_write_mem, // 3rd =reg_write_enable 
    input [1:0] reg_src_mem,
    input [4:0] rd_mem,//?output?
    input stall_wb, bubble_wb,
    //To NextReg and MEM_Module
    output reg_write_wb,
    output [31:0] nxpc_wb, pc_plus4_wb,
    output [31:0] imm_wb, alu_result_wb, mem2reg_data_wb,
    output [4:0] rd_wb,
    output [1:0] reg_src_wb
);
    PipeDff #(2) MEM_WB_reg_src(.clk(clk),.bubble(bubble_wb),.stall(stall_wb),.default_val(`FROM_ALU),.data_in(reg_src_mem),.data_out(reg_src_wb));

    PipeDff MEM_WB_mem2reg_data(.clk(clk),.bubble(bubble_wb),.stall(stall_wb),.default_val(`ZERO_WORD),.data_in(mem2reg_data_mem),.data_out(mem2reg_data_wb));//???要传么
    PipeDff MEM_WB_alu_result(.clk(clk),.bubble(bubble_wb),.stall(stall_wb),.default_val(`ZERO_WORD),.data_in(alu_result_mem),.data_out(alu_result_wb));
    PipeDff MEM_WB_imm(.clk(clk),.bubble(bubble_wb),.stall(stall_wb),.default_val(`ZERO_WORD),.data_in(imm_mem),.data_out(imm_wb));
    PipeDff MEM_WB_pc_plus4(.clk(clk),.bubble(bubble_wb),.stall(stall_wb),.default_val(`ZERO_WORD),.data_in(pc_plus4_mem),.data_out(pc_plus4_wb));

    PipeDff #(5) MEM_WB_rd(.clk(clk),.bubble(bubble_wb),.stall(stall_wb),.default_val(`ZERO_REG),.data_in(rd_mem),.data_out(rd_wb));
    PipeDff #(1) MEM_WB_reg_write_mem(.clk(clk),.bubble(bubble_wb),.stall(stall_wb),.default_val(1'b0),.data_in(reg_write_mem),.data_out(reg_write_wb));

endmodule