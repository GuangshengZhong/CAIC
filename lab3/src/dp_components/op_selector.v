`include "src/defines.v"
module OpSelector(
    input alu_src1, alu_src2,
    input [31:0] rs1_data, rs2_data,
    input [31:0] pc, imm,
    output reg [31:0] op1, op2
);
    always@(*) begin
        op1 = (alu_src1==1'b0) ? rs1_data : pc ;
        op2 = (alu_src2==1'b0) ? rs2_data : imm ;
    end
endmodule