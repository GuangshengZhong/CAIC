`include "src/defines.v"
`include "src/dp_components/forward_mux.v"
module OpSelector(
    input alu_src1, alu_src2,
    input [31:0] rs1_data, rs2_data,
    input [31:0] reg_write_data_mem, reg_write_data_wb,
    input [1:0] fwd_ex1, fwd_ex2,
    input [31:0] pc, imm,
    output reg [31:0] op1, op2
);
    wire [31:0] data_op1, data_op2;
    FWD_MUX FWD_MUX_1(.Data_EX(rs1_data),.Data_MEM(reg_write_data_mem),.Data_WB(reg_write_data_wb),.Data_out(data_op1),.fwd_ex(fwd_ex1));
    FWD_MUX FWD_MUX_2(.Data_EX(rs2_data),.Data_MEM(reg_write_data_mem),.Data_WB(reg_write_data_wb),.Data_out(data_op2),.fwd_ex(fwd_ex2));
    always@(*) begin
        op1 = (alu_src1==1'b0) ? data_op1 : pc ;
        op2 = (alu_src2==1'b0) ? data_op2 : imm ;
    end
endmodule