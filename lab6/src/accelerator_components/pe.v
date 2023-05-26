module PE #(
    parameter DATA_WIDTH=16 // 8bit inputs
) (
    input clk, rst,
    input accumulate_enable,
    input [DATA_WIDTH-1:0] input_north, input_west,
    output reg [DATA_WIDTH-1:0] output_south, output_east,
    output reg [DATA_WIDTH-1:0] result
);
    always@(posedge clk)begin
        if(rst)begin
            output_south <= 0;
            output_east <= 0;
            result <= 0;
        end
        else begin
            if(accumulate_enable) begin
                result <= result + input_north * input_west;
                output_south <= input_north;
                output_east <= input_west;
            end
            else begin
                result <= result;
                output_south <= output_south;
                output_east <= output_east;
            end
        end
    end
endmodule