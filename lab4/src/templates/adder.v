module Adder #(parameter WIDTH=32) (
    input [WIDTH-1:0] op_num1,
    input [WIDTH-1:0] op_num2,
    output reg [WIDTH-1:0] res
);
    always@(*) begin 
    res = op_num1 + op_num2;
    end
endmodule