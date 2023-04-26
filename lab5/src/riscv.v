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
`include "src/hazard_unit/stall_flush_detect_unit.v"
// add cache in Lab 5
`include "src/dp_components/data_cache.v"

# Your RISCVPipeline Module Here:
module RISCVPipeline (
    input clk, rst, debug,
    // for instr rom
    input [31:0] instr,
    output [31:0] instr_addr,
    // for main memory
    output mem_read_request, mem_write_request,
    output [(32*(1<<LINE_ADDR_LEN)-1):0] mem_write_data,
    output [31:0] mem_addr,
    input mem_request_finish,
    input [(32*(1<<LINE_ADDR_LEN)-1):0] mem_read_data
);