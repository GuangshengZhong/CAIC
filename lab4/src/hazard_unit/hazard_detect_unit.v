`include "src/defines.v"
module Hazard_Detect_Unit(
    input rst,
    input pc_src_id,jal_id,jalr_id,branch_id,
    input [4:0] rs1_id,rs2_id,
    input [4:0] rd_mem, rd_ex,
    input mem_read_ex, mem_read_mem,
    output stall_if, bubble_if,
    output stall_id, bubble_id,
    output stall_ex, bubble_ex,
    output stall_mem, bubble_mem,
    output stall_wb, bubble_wb
)
	wire stall;
	wire bubble; 

    assign stall = ((mem_read_ex&&((rd_ex == rs1_id )||(rd_ex == rs2_id)))//load_use stall
	||(branch_id&&((rd_mem == rs1_id )||(rd_mem == rs2_id)||(rd_ex == rs1_id )||(rd_ex == rs2_id)))//branch stall
	||(jalr_id&&((rd_mem == rs1_id )||(rd_ex == rs1_id))&&(rs1_id!=0)))//jalr stall
	assign bubble = (!stall) && pc_src_id;
	
	assign stall_if = stall;
	assign stall_id = stall;//对if与id进行stall
	assign stall_ex = 1'b0;
	assign stall_mem = 1'b0;
	assign stall_wb = 1'b0;
	
	assign bubble_if = rst;
	assign bubble_id = (rst||bubble);
	assign bubble_ex = (rst||stall);
	assign bubble_mem = rst;
	assign bubble_wb = rst;

endmodule