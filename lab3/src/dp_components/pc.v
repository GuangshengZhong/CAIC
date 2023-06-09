module PC (
    input clk,
    input rst,
    input [31:0] pc_plus4,
    input pc_src,
    input [31:0] new_pc,
    output reg [31:0] pc
);
    always@(posedge clk)begin
        if(rst == 1'b1)begin
            pc <= 32'b0;
        end
        else begin
            if(pc_src == 1'b1) pc<= new_pc;
            else pc <= pc_plus4;
        end
    end
endmodule