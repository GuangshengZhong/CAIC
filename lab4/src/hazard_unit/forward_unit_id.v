`include "src/defines.v"
module Forward_Unit_Id(
    input reg_write_mem,
    input [4:0] rs1_id,rs2_id,rd_mem,
    input branch_id, jal_id, jalr_id,
    output rs1_fwd_id,rs2_fwd_id
)
    always @(*) begin
        if(branch_id&&(rd_mem!=5'b0)&&(rd_MEM == rs1_id)) rs1_fwd_id = 1'b1;
        if(branch_id&&(rd_mem!=5'b0)&&(rd_MEM == rs1_id)) rs2_fwd_id = 1'b1;
        if(jalr_id&&(rd_mem!=5'b0)&&(rd_MEM == rs1_id)) rs1_fwd_id = 1'b1;
        //jal?
    end
endmodule