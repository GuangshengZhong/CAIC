module PC (
    //TODO
    input clk,
    input rst,
    input [31:0] new_pc,
    output reg [31:0] pc
);
    //TODO
    always@(posedge clk)begin
        if(rst == 1'b1)begin
            pc <= 32'b0;
        end
        else begin
            pc <= new_pc;
        end
    end
endmodule