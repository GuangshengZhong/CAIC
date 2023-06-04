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

    // wire [DATA_WIDTH-1:0] west_inputs_unpacked[0:ARRAY_SIZE-1];
    // wire [DATA_WIDTH-1:0] north_inputs_unpacked[0:ARRAY_SIZE-1];
    wire [DATA_WIDTH-1:0] west_wire[0:ARRAY_SIZE][0:ARRAY_SIZE+1];
    wire [DATA_WIDTH-1:0] north_wire[0:ARRAY_SIZE+1][0:ARRAY_SIZE];
    generate
        for(j=0; j<ARRAY_SIZE; j=j+1)
        begin
            // assign west_inputs_unpacked[j] = west_inputs[(j+1)*DATA_WIDTH-1:j*DATA_WIDTH];
            // assign north_inputs_unpacked[j] = west_inputs[(j+1)*DATA_WIDTH-1:j*DATA_WIDTH];
            assign west_wire[0][j] = west_inputs[(ARRAY_SIZE-j)*DATA_WIDTH-1:(ARRAY_SIZE-j-1)*DATA_WIDTH];
            assign north_wire[j][0] = north_inputs[(ARRAY_SIZE-j)*DATA_WIDTH-1:(ARRAY_SIZE-j-1)*DATA_WIDTH];
        end
    endgenerate

    generate
        for(i = 0; i < ARRAY_SIZE; i = i+1)begin
            for(j = 0; j < ARRAY_SIZE; j = j+1)begin
                PE PE_ij(
                    .clk(clk),.rst(rst),
                    .accumulate_enable(accumulate_enable),
                    .input_north(north_wire[i][j]),
                    .output_south(north_wire[i][j+1]),
                    .input_west(west_wire[i][j]),
                    .output_east(west_wire[i+1][j]),
                    .result(results_unpacked[j][i])
                    //.result(results_unpacked[i][j])
                );
            end
        end
    endgenerate
endmodule
