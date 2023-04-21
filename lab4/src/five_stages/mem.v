`include "src/defines.v"
module MEM_MODULE(
    input mem_read,
    input [2:0] load_type,
    input [31:0] mem_read_data,
    output reg [31:0] mem2reg_data,
    output reg [31:0] reg_write_data_mem
);
    reg [31:0] temp;
    always@(*)begin
        if(mem_read)begin
            mem2reg_data = 32'b0;
            case(load_type)
            `LB:begin
                // temp[31:24] = mem_read_data[31:24];
                // mem2reg_data = $signed(temp)>>24;
                temp[31:24] = mem_read_data[7:0];//yes!
                mem2reg_data = $signed(temp)>>>24;
            end
            `LBU:begin
                //temp[31:24] = mem_read_data[31:24];
                temp[31:24] = mem_read_data[7:0];
                mem2reg_data = temp>>24;
            end
            `LH:begin
                //temp[31:16] = mem_read_data[31:16];
                temp[31:16] = mem_read_data[15:0];
                mem2reg_data = $signed(temp)>>>16;
            end
            `LHU:begin
                //temp[31:16] = mem_read_data[31:16];
                temp[31:16] = mem_read_data[15:0];
                mem2reg_data = temp>>16;
            end
            `LW:mem2reg_data = mem_read_data;
            default: mem2reg_data = 32'b0;
        endcase
        end
        reg_write_data_mem = mem2reg_data;
    end
endmodule