`include "src/defines.v"
// TODO
module ALU (
    input [31:0] alu_in1,
    input [31:0] alu_in2,
    input [3:0] alu_op,
    output reg [31:0] alu_result
);
    reg [31:0] temp;
    always@(*)begin
    case(alu_op)
    4'b0000: alu_result <= alu_in1 + alu_in2;
    4'b0001: alu_result <= alu_in1 << alu_in2;
    4'b0010: begin
        if(alu_in1[31]==1'b0&&alu_in2[31]==1'b0) 
            alu_result <= alu_in1 < alu_in2;
        else if(alu_in1[31]==1'b1&&alu_in2[31]==1'b1) 
            alu_result <= alu_in1 > alu_in2;
        else alu_result <= alu_in1[31] > alu_in2[31];
    end
    4'b0011: alu_result <= alu_in1 < alu_in2;
    4'b0100: alu_result <= alu_in1 ^ alu_in2;
    4'b0101: alu_result <= alu_in1 >> alu_in2;
    4'b0110: alu_result <= alu_in1 | alu_in2;
    4'b0111: alu_result <= alu_in1 & alu_in2;
    4'b1000: alu_result <= alu_in1 - alu_in2;
    4'b1101: alu_result <= {{32{alu_in1[31]}}, alu_in1} >> alu_in2;
    default:;
    endcase
    end
endmodule