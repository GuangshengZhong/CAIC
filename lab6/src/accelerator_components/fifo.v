module FIFOBuffer #(
    parameter DATA_WIDTH=16,
    parameter BUFFER_SIZE = 16 // the buffer can hold 63 elements at most
) (
    input clk, rst, 
    // inject: if high, inject buffer_input into registers
    // bubble: if high, pop out data from the 0th register (Tips: check the bit order)
    input inject, bubble,
    input [BUFFER_SIZE*DATA_WIDTH-1:0] buffer_input,
    output reg [DATA_WIDTH-1:0] buffer_output
);

endmodule