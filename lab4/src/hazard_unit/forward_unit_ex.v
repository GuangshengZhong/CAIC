`include "src/defines.v"
module Forward_Unit_Ex(
    input reg_write_mem,
    input [4:0] rs1_ex, rs2_ex,rd_mem,rd_wb,
    input reg_write_wb,
    output reg [1:0] rs1_fwd_ex, rs2_fwd_ex
);
    always @(*) begin
        //EX_MEM hazard && MEM_WB hazard
        // if((reg_write_mem)&&(rd_mem!=5'b0)&&(rd_mem == rs1_ex))
        if((reg_write_mem)&&(rd_mem == rs1_ex))
            rs1_fwd_ex = `FWD_MEM;//From Slides P47
        else if((reg_write_wb)&&(rd_mem!=rs1_ex)&&(rd_wb == rs1_ex))
        //else if((reg_write_wb)&&(rd_wb == rs1_ex)) 
            rs1_fwd_ex = `FWD_WB;//From Slides P50
        else rs1_fwd_ex = `NO_FWD;
        // if((reg_write_mem)&&(rd_mem!=5'b0)&&(rd_mem == rs2_ex))
        if((reg_write_mem)&&(rd_mem == rs2_ex)) 
            rs2_fwd_ex = `FWD_MEM;
        else if((reg_write_wb)&&(rd_mem!=rs2_ex)&&(rd_wb == rs2_ex))
        //else if((reg_write_wb)&&(rd_wb == rs2_ex)) 
            rs2_fwd_ex = `FWD_WB;
        else rs2_fwd_ex = `NO_FWD;
    end
endmodule
