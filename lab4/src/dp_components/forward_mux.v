`include "src/defines.v"
module FWD_MUX(
    input [31:0] Data_EX,
    input [31:0] Data_MEM,
    input [31:0] Data_WB,
    input [1:0] fwd_ex,
    output [31:0] Data_out
)
    assign Data_out = 
        case(fwd_ex)
        `NO_FWD: Data_EX;
        `FWD_MEM: Data_MEM;
        `FWD_WB: Data_WB;
        default: Data_EX;
        endcase
endmodule