`include "src/defines.v"
module ALU (
    input [31:0] alu_in1,
    input [31:0] alu_in2,
    input [3:0] alu_type,
    output reg [31:0] alu_result,
    output reg zero,//if zero then one
    output reg less_than
);
    reg [31:0] temp;
    always@(*)begin
    case(alu_type)
    `ADD:begin
        alu_result = alu_in1 + alu_in2;
        zero = !(|alu_result);
    end
    `SLL: begin
        alu_result = alu_in1 << alu_in2;
        zero = !(|alu_result);
    end
    `SLT: begin
        alu_result = $signed(alu_in1) < $signed(alu_in2);
        zero = !(|alu_result);
    end
    `SLTU: begin 
        alu_result = alu_in1 < alu_in2;
        zero = !(|alu_result);
    end
    `XOR: begin 
        alu_result = alu_in1 ^ alu_in2;
        zero = !(|alu_result);
    end
    `SRL: begin
        alu_result = alu_in1 >> alu_in2;
        zero = !(|alu_result);
    end
    `OR: begin
        alu_result = alu_in1 | alu_in2;
        zero = !(|alu_result);
    end
    `AND: begin
        alu_result = alu_in1 & alu_in2;
        zero = !(|alu_result);
    end
    `SUB: begin
        alu_result = alu_in1 - alu_in2;
        zero = !(|alu_result);
    end
    `SRA: begin
        alu_result = $signed(alu_in1) >>> alu_in2;
        zero = !(|alu_result);
    end
    default: begin alu_result = 32'b0;
            zero = 1'b1;
    end
    endcase
    less_than = alu_in1 < alu_in2;
    end
endmodule