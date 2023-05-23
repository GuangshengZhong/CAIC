`include "src/accelerator_components/pe.v"

module SystolicArray #(
    parameter ARRAY_SIZE=16, // this systolic array is organized as ARRAY_SIZE*ARRAY_SIZE
    parameter DATA_WIDTH=16 // data width of inputs
) (
    input clk, rst,
    input accumulate_enable, read_enable,
    input [ARRAY_SIZE*DATA_WIDTH-1:0] west_inputs, north_inputs,
    input [31:0] row_index,
    output [ARRAY_SIZE*DATA_WIDTH-1:0] results
);
    // receive each PE's output
    wire [DATA_WIDTH-1:0] results_unpacked[0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];
    // pack the outputs of selected row
    genvar i, j;
    generate
        for(j=0; j<ARRAY_SIZE; j=j+1)
        begin
            assign results[(ARRAY_SIZE-j)*DATA_WIDTH-1 : (ARRAY_SIZE-j-1)*DATA_WIDTH] = (read_enable && (row_index<ARRAY_SIZE)) ? results_unpacked[row_index][j] : 0;
        end
    endgenerate
    
endmodule
