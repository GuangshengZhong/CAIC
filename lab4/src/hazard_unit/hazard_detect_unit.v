`include "src/defines.v"
module Hazard_Detect_Unit(
    input rst,
    input pc_src_id,jal_id,jalr_id,branch_id,
    input rs1_id,rs2_id,
    input mem_read_ex, rd_ex,
    input rd_mem, mem_read_mem,
    output stall_if, bubble_if,
    output stall_id, bubble_id,
    output stall_ex, bubble_ex,
    output stall_mem, bubble_mem,
    output stall_wb, bubble_wb
)
endmodule