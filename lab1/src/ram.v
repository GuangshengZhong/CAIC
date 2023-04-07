`include "src/defines.v"

module RAM (
    input clk,
    input write_enamble,
    input [2:0] write_type,
    input [31:0] addr,
    input [31:0] data_in,
    output reg [31:0] data_out
);

    parameter LEN = 65536;
    reg [31:0] mem_core [0:LEN-1];
    wire [15:0] address = addr[17:2];
    wire [1:0] pos = addr[1:0];

    initial 
    begin
        $readmemh("tb/ram_data.hex", mem_core);
    end

    always @(posedge clk) begin
        if(write_enable==1'b1)
        begin// write data to memory
            case(write_type)
            3'b000:
            begin
                case(pos)
                2'b00: mem_core[address][31:24] <= data_in[7:0];
                2'b01: mem_core[address][23:16] <= data_in[7:0];
                2'b10: mem_core[address][15:8] <= data_in[7:0];
                2'b11: mem_core[address][7:0] <= data_in[7:0];
                endcase
            end
            3'b001:
            begin
                case(pos)
                2'b00: mem_core[address][31:16] <= data_in[15:0];
                2'b10: mem_core[address][15:0] <= data_in[15:0];
                endcase
            end
            3'b010:
            begin
                mem_core[address][31:0] <= data_in[31:0];
            end
            default:;
            endcase
        end
        else if(write_enable==1'b0)
        begin
            data_out <= mem_core[address];
        end
        else;
    end
endmodule