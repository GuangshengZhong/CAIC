`include "src/defines.v"
module Hazard_Detect_Unit(
    input rst,
    input pc_src_id,jal_id,jalr_id,branch_id,
    input [4:0] rs1_id,rs2_id,
    input [4:0] rd_mem, rd_ex,
    input mem_read_ex, mem_read_mem, reg_write_ex, mem_read_id,
	input miss,
	input data_bus_request_finish,
	input cache_request_finish,
    output stall_if, bubble_if,
    output stall_id, bubble_id,
    output stall_ex, bubble_ex,
    output stall_mem, bubble_mem,
    output stall_wb, bubble_wb,
	//for ISA extend
	input [2:0] instr_funct3_mem,
	input accelerator_instr_mem,
	input accelerator_request_finish
);
	wire stall;
	wire bubble; 

    // assign stall = ((mem_read_ex&&((rd_ex == rs1_id )||(rd_ex == rs2_id)))//load_use stall
	// ||(branch_id&&((rd_mem == rs1_id )||(rd_mem == rs2_id)||(rd_ex == rs1_id )||(rd_ex == rs2_id)))//branch stall
	// ||(jalr_id&&((rd_mem == rs1_id )||(rd_ex == rs1_id))&&(rs1_id!=0)));//jalr stall

	//assign stall = (branch_id || jalr_id) && ((reg_write_ex&&((rd_ex == rs1_id )||(rd_ex == rs2_id)))||(mem_read_mem&&((rd_mem == rs1_id)||(rd_mem == rs2_id))));
	assign stall = ((branch_id || jalr_id) && ((reg_write_ex&&((rd_ex == rs1_id )||(rd_ex == rs2_id)))||(mem_read_mem&&((rd_mem == rs1_id)||(rd_mem == rs2_id)))));
	//||(mem_read_ex&&((rd_ex == rs1_id)||(rd_ex == rs2_id)))
	assign bubble = (branch_id || jalr_id || jal_id);

	assign stall_if = stall||miss;
	assign stall_id = stall||miss;//对if与id进行stall
	// assign stall_ex = 1'b0;
	// assign stall_mem = 1'b0;
	// assign stall_wb = 1'b0;
	assign stall_ex = miss;
	assign stall_mem = miss;
	assign stall_wb = miss;
	
	assign bubble_if = 1'b0 || rst;
	assign bubble_id = bubble || rst;
	assign bubble_ex = stall || rst;
	assign bubble_mem = 1'b0 || rst;
	assign bubble_wb = 1'b0 || rst;

endmodule