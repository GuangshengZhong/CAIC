module PE #(
    parameter DATA_WIDTH=16 // 8bit inputs
) (
    input clk, rst,
    input accumulate_enable,
    input [DATA_WIDTH-1:0] input_north, input_west,
    output reg [DATA_WIDTH-1:0] output_south, output_east,
    output reg [DATA_WIDTH-1:0] result
);

endmodule