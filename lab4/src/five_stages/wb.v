`include "src/defines.v"
module WB_MODULE(
    input [1:0] reg_src,
    //input [31:0] pc_plus4,
    input [31:0] nxpc,//Change for lab4
    input [31:0] imm,
    input [31:0] alu_result,
    input [31:0] mem2reg_data,
    // output reg_write_wb,
    // output [4:0] rd_wb,//For mem_wb???
    output reg [31:0] reg_write_data
);
    always@(*)begin
        case(reg_src)
        `FROM_ALU: reg_write_data = alu_result;
        `FROM_MEM: reg_write_data = mem2reg_data;
        `FROM_IMM: reg_write_data = imm;
        `FROM_PC: reg_write_data = pc_plus4;
        default: reg_write_data = 32'b0;
        endcase
    end
endmodule