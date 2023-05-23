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
            if(accumulate_enable)
                result <= result + input_north * input_west;
            else
                result <= result;
        end
    end
endmodule