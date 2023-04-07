`include "src/defines.v"
module id_ex_reg(
    input [31:0] pc_id, pc_plus4_id, 
    input [31:0] imm_id, rs1_data_id, rs2_data_id,
    input branch_id, jal_id, jalr_id, 
    input mem_read_id, mem_write_id, reg_write_id, // 3rd =reg_write_enable 
    input [1:0] reg_src_id,
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
)
    reg [31:0] id_ex_reg_data = 32'b0;
    always@(*) begin
        
    end
endmodule