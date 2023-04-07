`include "src/defines.v"
module if_id_reg(
    input clk,
    input [31:0] instr_if, pc_if, pc_plus4_if,
    input stall_id, bubble_id,
    output [31:0] instr_id, pc_id, pc_plus4_id
)
    PipeDff ex_mem_register(
        .clk(clk),
        .bubble(bubble_id),
        .stall(stall_id),
        .default_val(`ZERO_WORD),
        .data_in(instr_if),
        .data_out(instr_id)
    );
endmodule