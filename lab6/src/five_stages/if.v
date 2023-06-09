`include "src/dp_components/pc.v"
//`include "src/inst_mem.v"
`include "src/templates/adder.v"

module IF_MODULE(
    input rst,
    input clk,
    input pc_src,
    input [31:0] new_pc,
    input stall_if, bubble_if,//new
    output [31:0] pc_plus4,
    //output [31:0] instr,
    output [31:0] pc
);
    wire [31:0] pc_incre = 32'h00000004;
    wire [31:0] pc_plus4_inn;
    PC IF_PC(
        .clk(clk),
        .rst(rst),
        .pc_src(pc_src),
        .new_pc(new_pc),
        .pc_plus4(pc_plus4_inn),
        .stall_if(stall_if),
        .bubble_if(bubble_if),
        .pc(pc)
        );
    Adder IF_ADD(
        .op_num1(pc),
        .op_num2(pc_incre),
        .res(pc_plus4_inn)
        );
    assign pc_plus4 = pc_plus4_inn;
endmodule