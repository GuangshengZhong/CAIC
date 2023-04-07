`include "src/defines.v"
module ID_IF(
    input clk,
    input [31:0] instr_if, pc_if, pc_plus4_if,
    input stall_id, bubble_id,
    output [31:0] instr_id, pc_id, pc_plus4_id
)
    PipeDff IF_ID_pc(
        .clk(ck),
        .bubble(bubble_id),
        .stall(stall_id),
        .default_val(`ZERO_WORD),
        .data_in(pc_if),
        .data_out(pc_id)
    );
    PipeDff IF_ID_pc_plus4(
        .clk(clk),
        .bubble(bubble_id),
        .stall(stall_id),
        .default_val(`ZERO_WORD),
        .data_in(pc_plus4_if),
        .data_out(pc_plus4_id)
    );
endmodule