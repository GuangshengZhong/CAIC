`include "src/defines.v"
module FWD_MUX(
    input [31:0] Data_EX,
    input [31:0] Data_MEM,
    input [31:0] Data_WB,
    input [1:0] fwd_ex,
    output reg [31:0] Data_out
);
    always@(*) begin
        case(fwd_ex)
        `NO_FWD: Data_out = Data_EX;
        `FWD_MEM: Data_out = Data_MEM;
        `FWD_WB: Data_out = Data_WB;
        default: Data_out = Data_EX;
        endcase
    end
endmodule