`include "src/defines.v"
`include "src/five_stages/if.v"
`include "src/five_stages/id.v"
`include "src/five_stages/ex.v"
`include "src/five_stages/mem.v"
`include "src/five_stages/wb.v"
`include "src/templates/pipe_dff.v"
`include "src/pipe_regs/if_id.v"
`include "src/pipe_regs/id_ex.v"
`include "src/pipe_regs/ex_mem.v"
`include "src/pipe_regs/mem_wb.v"
`include "src/hazard_unit/forward_unit_id.v"
`include "src/hazard_unit/forward_unit_ex.v"
`include "src/hazard_unit/hazard_detect_unit.v"

module RISCVPipeline (
    input clk, rst,
    input [31:0] instr, mem_read_data,
    output ram_write,
    output [2:0] write_type,
    output [31:0] instr_addr, mem_addr, mem_write_data
);

endmodule