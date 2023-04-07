`include"src/ram.v"
`include"src/alu.v"

module TOP (
    input clk,
    input write_enable,
    input [2:0] write_type,
    input [31:0] addr,
    input [31:0] data_in,
    input [3:0] aluop,
    input [31:0] data_in2,
    output [31:0] data_out
);
    wire [31:0] data_in1;
    RAM dataram(.clk(clk),.write_enable(write_enable),.write_type(write_type),.addr(addr),.data_in(data_in),.data_out(data_in1));
    ALU dataalu(.alu_in1(data_in1),.alu_in2(data_in2),.alu_op(aluop),.alu_result(data_out));
endmodule