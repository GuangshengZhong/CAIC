module PC (
    input clk,
    input rst,
    input [31:0] pc_plus4,
    input pc_src,
    input stall_if,
    input bubble_if,
    input [31:0] new_pc,
    output reg [31:0] pc
);
    always@(posedge clk, posedge rst)begin//posedge rst注意！
        if(rst || bubble_if)begin
            pc <= 32'b0;
        end
        else begin
            if (stall_if) pc <= pc;
            else if(pc_src == 1'b1) pc<= new_pc;
            else pc <= pc_plus4;
        end
    end
endmodule