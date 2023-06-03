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
// add cache in Lab 5
`include "src/dp_components/data_cache.v"

module RISCVPipeline (
    input clk, rst, debug,
    // for instr rom
    input [31:0] instr,
    output [31:0] instr_addr,
    // for main memory
    output data_bus_read_request, data_bus_write_request,
    output [(32*(1<<LINE_ADDR_LEN)-1):0] data_bus_write_data,
    output [31:0] data_bus_addr,
    input data_bus_request_finish,
    input [(32*(1<<LINE_ADDR_LEN)-1):0] data_bus_read_data
);
    parameter LINE_ADDR_LEN = 3;

    wire stall_if, bubble_if, stall_id, bubble_id, stall_ex, bubble_ex, stall_mem, bubble_mem, stall_wb, bubble_wb;
    wire reg_write_wb;
    wire [4:0] rd_wb;

    // wires for accelerator ISA extension
    // instruction indication signal
    wire accelerator_instr_id, accelerator_instr_ex, accelerator_instr_mem;
    // wires for signal muxing between accelerator instruction and RISC-V memory instruction
    // accelerator bus wires
    wire accelerator_bus_read_request, accelerator_bus_write_request, accelerator_bus_request_finish;
    wire [31:0] accelerator_bus_addr;
    wire [(32*(1<<LINE_ADDR_LEN)-1):0] accelerator_bus_write_data, accelerator_bus_read_data;
    // accelerator cache wires
    // wire accelerator_cache_read_request, accelerator_cache_write_request, accelerator_cache_request_finish;
    wire [(32*(1<<LINE_ADDR_LEN)-1):0] accelerator_cache_write_data, accelerator_cache_read_data;
    // cache wires, need to be muxed between accelerator and memory
    // wire cache_read_request, cache_write_request, cache_request_from_accelerator;
    wire [(32*(1<<LINE_ADDR_LEN)-1):0] cache_write_line_data, cache_read_line_data;
    wire [2:0] cache_write_type;
    wire [31:0] cache_write_data;
    // wires for the cache to communicate with memory, need to be muxed with accelerator
    wire mem_read_request, mem_write_request;
    wire [(32*(1<<LINE_ADDR_LEN)-1):0] mem_write_data;
    wire [31:0] mem_addr;
    wire mem_request_finish;
    wire [(32*(1<<LINE_ADDR_LEN)-1):0] mem_read_data;
    // register to record the finish state of accelerator requests
    // we need to leave a cycle for the IF stage to fetch the correct instruction
    reg accelerator_request_finish;
    wire accelerator_request_finish_wire;
    

    //IF
    wire pc_src;
    // wire pc_src;
    wire [31:0] instr_if, pc_if, pc_plus4_if, new_pc;
    wire [31:0] reg_write_data_mem_tp, reg_write_data_wb_tp;
    IF_MODULE if_module(
        .rst(rst), .clk(clk),
        .pc_src(pc_src), .new_pc(new_pc),
        .pc_plus4(pc_plus4_if),
        .stall_if(stall_if), .bubble_if(bubble_if),
        //.instr(instr_if), 
        .pc(pc_if)//??
    );
    // instruction fetch is executed outside logic module
    wire [31:0] cache_write_data, cache_read_data;
    assign instr_if = bubble_if ? `INST_NOP : instr;
    assign instr_addr = pc_if;
    assign cache_write_data = rs2_data_mem;

    //ID
    wire [31:0] instr_id, pc_id, pc_plus4_id, imm_id, rs1_data_id, rs2_data_id ;
    wire branch_id, jal_id, jalr_id, mem_read_id, mem_write_id, reg_write_id, alu_src1_id, alu_src2_id;
    wire [1:0] rs1_fwd_id,rs2_fwd_id;
    wire [1:0] reg_src_id;
    wire [2:0] branch_type_id, load_type_id, store_type_id, instr_funct3_id;//branch_type_id 暂时没用？
    wire [3:0] alu_type_id;
    wire [4:0] rd_id, rs1_id, rs2_id;

    IF_ID if_id(
        .clk(clk),
        .instr_if(instr_if),
        .pc_if(pc_if), .pc_plus4_if(pc_plus4_if),
        .instr_id(instr_id), 
        .pc_id(pc_id), .pc_plus4_id(pc_plus4_id),
        .stall_id(stall_id), .bubble_id(bubble_id)
    );

    ID_MODULE id_module(
        .clk(clk),
        //From if
        .instr(instr_id),
        //From mem & wb
        .reg_write_data_mem(reg_write_data_mem_tp),
        .reg_write_data_wb(reg_write_data_wb_tp),
        //From if_id
        .pc(pc_id),.pc_plus4(pc_plus4_id),
        //To id_ex
        .branch(branch_id),.jal(jal_id),.jalr(jalr_id),
        .mem_read(mem_read_id),.mem_write(mem_write_id),
        .alu_src1(alu_src1_id),.alu_src2(alu_src2_id),
        .reg_write_in(reg_write_wb),
        .reg_write_out(reg_write_id),
        .reg_src(reg_src_id),
        .instr_funct3(instr_funct3_id),.alu_type(alu_type_id),
        .rd(rd_id),.rs1(rs1_id),.rs2(rs2_id),
        .rs1_data(rs1_data_id),.rs2_data(rs2_data_id),.imm(imm_id),
        .rd_wb(rd_wb),
        // .stall_id(stall_id), .bubble_id(bubble_id),
        //.branch_type(branch_type_id),.load_type(load_type_id), .store_type(store_type_id);
        //From fwd_unit_id
        .rs1_fwd_id(rs1_fwd_id),.rs2_fwd_id(rs2_fwd_id),
        //To hazard & To if
        .pc_src(pc_src),.new_pc(new_pc)//??
        // for ISA extension
        .accelerator_instr(accelerator_instr_id)
    ); 

    //EX
    wire [3:0] alu_type_ex;
    wire alu_src1_ex, alu_src2_ex;
    wire [31:0] pc_ex, pc_plus4_ex, rs1_data_ex, rs2_data_ex, imm_ex, alu_result_ex;
    wire [4:0] rs1_ex, rs2_ex, rd_ex;

    wire [1:0] rs1_fwd_ex, rs2_fwd_ex;

    wire mem_read_ex, mem_write_ex, reg_write_ex;
    wire [2:0] instr_funct3_ex;
    wire [1:0] reg_src_ex;

    ID_EX id_ex(
        //input
        .clk(clk),
        .branch_id(branch_id),.jal_id(jal_id),.jalr_id(jalr_id),
        .mem_read_id(mem_read_id),.mem_write_id(mem_write_id),
        .alu_src1_id(alu_src1_id),.alu_src2_id(alu_src2_id),
        .reg_write_id(reg_write_id),.reg_src_id(reg_src_id),
        .instr_funct3_id(instr_funct3_id),.alu_type_id(alu_type_id),
        .rd_id(rd_id),.rs1_id(rs1_id),.rs2_id(rs2_id),
        .rs1_data_id(rs1_data_id),.rs2_data_id(rs2_data_id),.imm_id(imm_id),
        .pc_id(pc_id),.pc_plus4_id(pc_plus4_id),
        .stall_ex(stall_ex),.bubble_ex(bubble_ex),
        // for ISA extension
        .accelerator_instr_id(accelerator_instr_id),
        //To ex
        .alu_src1_ex(alu_src1_ex),.alu_src2_ex(alu_src2_ex),
        .alu_type_ex(alu_type_ex),.pc_ex(pc_ex),
        .rs1_data_ex(rs1_data_ex),.rs2_data_ex(rs2_data_ex),
        .imm_ex(imm_ex),.rs1_ex(rs1_ex),.rs2_ex(rs2_ex),
        //To ex_mem
        .mem_read_ex(mem_read_ex),.mem_write_ex(mem_write_ex),.reg_write_ex(reg_write_ex),
        .instr_funct3_ex(instr_funct3_ex),
        .reg_src_ex(reg_src_ex),
        .rd_ex(rd_ex),
        .pc_plus4_ex(pc_plus4_ex)
        // for ISA extension
        .accelerator_instr_ex(accelerator_instr_ex)
    );

    wire [31:0] rs2_data_ex_new;

    EX_MODULE ex_module(
        .alu_type(alu_type_ex),
        .alu_src1(alu_src1_ex),.alu_src2(alu_src2_ex),
        .pc(pc_ex),
        .rs1_data(rs1_data_ex),.rs2_data(rs2_data_ex),
        .rs2_data_ex_new(rs2_data_ex_new),
        .imm(imm_ex),
        //.rs1_ex(rs1_ex),rs2_ex(rs2_ex),
        .reg_write_data_mem(reg_write_data_mem_tp),
        .reg_write_data_wb(reg_write_data_wb_tp),
        .rs1_fwd_ex(rs1_fwd_ex),.rs2_fwd_ex(rs2_fwd_ex),
        .alu_result(alu_result_ex)
    );

    //MEM
    wire mem_read_mem, mem_write_mem, reg_write_mem;
    wire cache_read_mem, cache_write_mem;
    wire [1:0] reg_src_mem;
    wire [2:0] instr_funct3_mem, load_type_mem;
    wire [4:0] rd_mem;
    wire [31:0] imm_mem, rs2_data_mem, alu_result_mem, pc_plus4_mem, mem2reg_data;
    wire [2:0] write_type;
    wire [31:0] cache_addr;

    EX_MEM ex_mem(
        //From id_ex
        .clk(clk),
        .mem_read_ex(mem_read_ex),.mem_write_ex(mem_write_ex),.reg_write_ex(reg_write_ex),
        .imm_ex(imm_ex),
        .instr_funct3_ex(instr_funct3_ex),
        .reg_src_ex(reg_src_ex),
        .rd_ex(rd_ex),
        .pc_plus4_ex(pc_plus4_ex),
        //From ex
        .rs2_data_ex(rs2_data_ex_new),
        .alu_result_ex(alu_result_ex),
        // for ISA extension
        .accelerator_instr_ex(accelerator_instr_ex),
        //To mem_module
        .mem_read_mem(mem_read_mem),.mem_write_mem(mem_write_mem),
        .instr_funct3_mem(instr_funct3_mem),
        .rs2_data_mem(rs2_data_mem),
        .alu_result_mem(alu_result_mem),
        .reg_src_mem(reg_src_mem),
        //From hazard
        .stall_mem(stall_mem),.bubble_mem(bubble_mem),
        //To Memory
        .write_type(write_type),
        .write_data(cache_write_data),
        .mem_addr(cache_addr),
        //To mem_wb
        .reg_write_mem(reg_write_mem),.rd_mem(rd_mem),
        .imm_mem(imm_mem),.pc_plus4_mem(pc_plus4_mem)
        // for ISA extension
        .accelerator_instr_mem(accelerator_instr_mem)
    );
    assign write_type = instr_funct3_mem;
    
    assign load_type_mem = instr_funct3_mem;

    assign reg_write_data_mem_tp = (reg_src_mem == `FROM_ALU) ? alu_result_mem : ((reg_src_mem == `FROM_MEM)? mem2reg_data : ((reg_src_mem == `FROM_IMM)? imm_mem:pc_plus4_mem));
    

    // maintain the state register of accelerator request finish
    // TODO
    wire miss, cache_miss, bus_not_finish;
    assign bus_not_finish = (data_bus_read_request||data_bus_write_request)&&(!data_bus_request_finish);
    assign miss = cache_miss||bus_not_finish;

    // logic for accelerator ISA extension
    // judge whether to take up the bus for the accelerator
    wire accelerator_take_up_bus = (accelerator_instr_mem && (instr_funct3_mem==`LOAD || instr_funct3_mem==`SAVE)) ? (cache_request_finish && !accelerator_request_finish) :
                                   (accelerator_instr_mem && (instr_funct3_mem==`MATMUL || instr_funct3_mem==`RESET || instr_funct3_mem==`MOVE)) ? (!accelerator_request_finish) :
                                   1'b0; 
    // muxing between accelerator and cache
    assign data_bus_read_request = accelerator_take_up_bus ? accelerator_bus_read_request : mem_read_request;
    assign data_bus_write_request = accelerator_take_up_bus ? accelerator_bus_write_request : mem_write_request;
    assign data_bus_write_data = accelerator_take_up_bus ? accelerator_bus_write_data : mem_write_data;
    assign data_bus_addr = accelerator_take_up_bus ? accelerator_bus_addr : mem_addr;
    
    //TODO
        //accelerator <-> cpu
    wire [2:0] acc_funct3;
    assign acc_funct3 = instr_funct3_mem;
    assign accelerator_bus_read_request = ((acc_funct3==`SAVE)||(acc_funct3 == `LOAD)||(acc_funct3 == `RESET)||(acc_funct3 == `MOVE));
    assign accelerator_bus_write_request = ((acc_funct3==`LOAD)||(acc_funct3 == `LOAD)||(acc_funct3 == `RESET)||(acc_funct3 == `MOVE));
    assign accelerator_bus_write_data = accelerator_instr_mem && cache_read_data;//???
    always@(*)begin
        case(acc_funct3)
            `LOAD, `SAVE, `RESET: accelerator_bus_addr = cache_addr + `ACCELERATOR_MEM_BASE_ADDR; // 是用cache_addr加还是用mem_addr加？
            `MATMUL: accelerator_bus_addr = `ACCELERATOR_MEM_BASE_ADDR + `OUTPUT_BUFFER_BASE_ADDR;
            `MOVE: accelerator_bus_addr = `ACCELERATOR_MEM_BASE_ADDR + `MOVE;
            default: accelerator_bus_addr = `ACCELERATOR_MEM_BASE_ADDR;
        endcase
    end
        //cache <-> cpu


    // memory access stage is partially executed outside the logic module
    wire cache_request_finish;
    DataCache #(.LINE_ADDR_LEN(LINE_ADDR_LEN)) data_cache(
        .clk(clk),.rst(rst),.debug(debug),
        // cache <-> cpu
        .read_request(mem_read_mem),.write_request(mem_write_mem),
        .write_type(write_type),
        .addr(cache_addr),
        .write_data(cache_write_data),
        .miss(cache_miss),
        .request_finish(cache_request_finish),//?
        .read_data(cache_read_data),
        //cache <-> maim_mem
        .mem_read_request(mem_read_request), .mem_write_request(mem_write_request),
        .mem_write_data(mem_write_data),
        .mem_addr(mem_addr),
        .mem_request_finish(mem_request_finish),
        .mem_read_data(mem_read_data)
        // for accelerator ISA extension
        .cache_request_from_accelerator(cache_request_from_accelerator),
        .accelerator_cache_read_data(cache_read_line_data), 
        .accelerator_cache_write_data(cache_write_line_data)
    );
    MEM_MODULE mem_module(
        //From ex_mem
        .mem_read(mem_read_mem),
        .load_type(load_type_mem),
        //To mem_wb
        .mem2reg_data(mem2reg_data),
        //From memory
        .mem_read_data(cache_read_data)
    );
    // bypassing data selection
    // note that memory data cannot be accessed at bypassing's point
    
    // assign reg_write_data_mem = (reg_src_mem == `FROM_ALU) ? alu_result_mem : (reg_src_mem == `FROM_IMM) ? imm_mem :(reg_src_mem == `FROM_PC) ? nxpc_mem : 32'h00000000;

    //WB
    wire [1:0] reg_src_wb;
    wire [31:0] alu_result_wb, mem2reg_data_wb, imm_wb, nxpc_wb, pc_plus4_wb;
    MEM_WB mem_wb(
        .clk(clk),
        //From ex_mem
        .reg_write_mem(reg_write_mem),.rd_mem(rd_mem),
        .imm_mem(imm_mem),.pc_plus4_mem(pc_plus4_mem),
        .reg_src_mem(reg_src_mem),.alu_result_mem(alu_result_mem),
        //From mem
        .mem2reg_data_mem(mem2reg_data),
        //From hazard
        .stall_wb(stall_wb),.bubble_wb(bubble_wb),
        //To wb
        .reg_src_wb(reg_src_wb),.alu_result_wb(alu_result_wb),
        .mem2reg_data_wb(mem2reg_data_wb),
        .imm_wb(imm_wb),.nxpc_wb(nxpc_wb),
        .pc_plus4_wb(pc_plus4_wb),
        .reg_write_wb(reg_write_wb),.rd_wb(rd_wb)
    );

    WB_MODULE wb_module(
        .reg_src(reg_src_wb),.alu_result(alu_result_wb),
        .mem2reg_data(mem2reg_data_wb),
        .imm(imm_wb),.nxpc(nxpc_wb),
        .pc_plus4(pc_plus4_wb),
        .reg_write_data(reg_write_data_wb_tp)
    );

     //Forward_unit_id
    Forward_Unit_Id forward_unit_id(
        .jal_id(jal_id), .jalr_id(jalr_id), .branch_id(branch_id),
        .rs1_id(rs1_id), .rs2_id(rs2_id), 
        .reg_write_mem(reg_write_mem),
        .rd_mem(rd_mem),
        .rs1_fwd_id(rs1_fwd_id), .rs2_fwd_id(rs2_fwd_id)
    );

    //Forward_unit_ex
    Forward_Unit_Ex forward_unit_ex(
        .reg_write_mem(reg_write_mem),
        .rd_mem(rd_mem),
        .rs1_fwd_ex(rs1_fwd_ex), .rs2_fwd_ex(rs2_fwd_ex),
        .rs1_ex(rs1_ex), .rs2_ex(rs2_ex),
        .reg_write_wb(reg_write_wb), .rd_wb(rd_wb)
    );

    //Hazard_detect_unit
    Hazard_Detect_Unit hazard_detect_unit(
        .rst(rst),
        .pc_src_id(pc_src),
        .jal_id(jal_id), .jalr_id(jalr_id), .branch_id(branch_id),
        .rs1_id(rs1_id), .rs2_id(rs2_id), 
        .rd_mem(rd_mem), .rd_ex(rd_ex),
        //.mem_read_ex(mem_read_ex), .mem_read_mem(mem_read_mem),.reg_write_ex(reg_write_ex),
        .mem_read_ex(mem_read_ex), .mem_read_mem(mem_read_mem),.reg_write_ex(reg_write_ex),.mem_read_id(mem_read_id),
        .cache_request_finish(cache_request_finish),
        //for bus
        .data_bus_request_finish(data_bus_request_finish),
        // for accelerator ISA extension
        .accelerator_instr_mem(accelerator_instr_mem), 
        .accelerator_request_finish(accelerator_request_finish),
        .instr_funct3_mem(instr_funct3_mem),
        //output
        .stall_if(stall_if), .bubble_if(bubble_if),
        .stall_id(stall_id), .bubble_id(bubble_id),
        .stall_ex(stall_ex), .bubble_ex(bubble_ex),
        .stall_mem(stall_mem), .bubble_mem(bubble_mem),
        .stall_wb(stall_wb), .bubble_wb(bubble_wb)
    );
    
endmodule