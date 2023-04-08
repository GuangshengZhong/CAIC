`include "src/defines.v"
module Forward_Unit_Id(
    input reg_write_mem,
    input [4:0] rs1_id,rs2_id,rd_mem,
    input branch_id, jal_id, jalr_id,
    output [1:0] rs1_fwd_id,rs2_fwd_id
)

endmodule