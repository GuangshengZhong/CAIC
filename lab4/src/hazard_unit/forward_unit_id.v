`include "src/defines.v"
module Forward_Unit_Id(
    input reg_write_mem,
    input [4:0] rs1_id,rs2_id,rd_mem,
    input branch_id, jal_id, jalr_id,
    output reg [1:0] rs1_fwd_id,rs2_fwd_id
);
    always @(*) begin
        if(reg_write_mem&&branch_id&&(rd_mem!=5'b0)&&(rd_mem == rs1_id)) rs1_fwd_id = `FWD_MEM;
        else if(reg_write_mem&&jalr_id&&(rd_mem!=5'b0)&&(rd_mem == rs1_id)) rs1_fwd_id = `FWD_MEM;
        else rs1_fwd_id = `NO_FWD;
        if(reg_write_mem&&branch_id&&(rd_mem!=5'b0)&&(rd_mem == rs2_id)) rs2_fwd_id = `FWD_MEM;
        else rs2_fwd_id = `NO_FWD;
        //jal?
    end
endmodule