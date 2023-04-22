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
    wire stall_if, bubble_if, stall_id, bubble_id, stall_ex, bubble_ex, stall_mem, bubble_mem, stall_wb, bubble_wb;
    //IF
    wire pc_src;
    wire [31:0] instr_if, pc_if, pc_plus4_if, new_pc;

    IF_MODULE if_module(
        .rst(rst), .clk(clk),
        .pc_src(pc_src), .new_pc(new_pc),
        .pc_plus4(pc_plus4_if),
        .stall_if(stall_if), .bubble_if(bubble_if),
        //.instr(instr_if), 
        .pc(pc_if)//??
    );
    assign instr_if = bubble_if ? `INST_NOP : instr;
    assign instr_addr = pc_if;
    assign mem_write_data = rs2_data_mem;
    // assign mem_addr = ?
    
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
        .instr_if(instr),
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
        .reg_write_data_mem(reg_write_data_mem),
        .reg_write_data_wb(reg_write_data_wb),
        //From if_id
        .pc(pc_id),.pc_plus4(pc_plus4_id),
        //To id_ex
        .branch(branch_id),.jal(jal_id),.jalr(jalr_id),
        .mem_read(mem_read_id),.mem_write(mem_write_id),
        .alu_src1(alu_src1_id),.alu_src2(alu_src2_id),
        .reg_write(reg_write_id),.reg_src(reg_src_id),
        .instr_funct3(instr_funct3_id),.alu_type(alu_type_id),
        .rd(rd_id),.rs1(rs1_id),.rs2(rs2_id),
        .rs1_data(rs1_data_id),.rs2_data(rs2_data_id),.imm(imm_id),
        //.branch_type(branch_type_id),.load_type(load_type_id), .store_type(store_type_id);
        //From fwd_unit_id
        .rs1_fwd_id(rs1_fwd_id),.rs2_fwd_id(rs2_fwd_id),
        //To hazard & To if
        .pc_src(pc_src),.new_pc(new_pc)//??
    );    

    //EX
    wire [3:0] alu_type_ex;
    wire alu_src1_ex, alu_src2_ex;
    wire [31:0] pc_ex, pc_plus4_ex, rs1_data_ex, rs2_data_ex, imm_ex, alu_result_ex;
    wire [4:0] rs1_ex, rs2_ex, rd_ex;
    wire [31:0] reg_write_data_mem, reg_write_data_wb;
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
        .reg_write_data_mem(reg_write_data_mem),
        .reg_write_data_wb(reg_write_data_wb),
        .rs1_fwd_ex(rs1_fwd_ex),.rs2_fwd_ex(rs2_fwd_ex),
        .alu_result(alu_result_ex)
    );

    //MEM
    wire mem_read_mem, mem_write_mem, reg_write_mem;
    wire [1:0] reg_src_mem;
    wire [2:0] instr_funct3_mem, load_type_mem;
    wire [4:0] rd_mem;
    wire [31:0] imm_mem, rs2_data_mem, alu_result_mem, pc_plus4_mem, mem2reg_data;

    //wire mem_write_inn;
    //wire [2:0] write_type_inn;
    //wire [31:0] write_data_inn, mem_addr_inn;

    assign mem_addr = alu_result_mem;
    // assign mem_addr = alu_result_ex;//Totally Wrong
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
        //.rs2_data_ex(rs2_data_ex),
        .alu_result_ex(alu_result_ex),
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
        .write_data(mem_write_data),
        .mem_addr(mem_addr),
        //To mem_wb
        .reg_write_mem(reg_write_mem),.rd_mem(rd_mem),
        .imm_mem(imm_mem),.pc_plus4_mem(pc_plus4_mem)
    );
    assign ram_write = mem_write_mem;
    assign write_type = instr_funct3_mem;
    assign load_type_mem = instr_funct3_mem;

    assign reg_write_data_mem = (reg_src_mem == `FROM_ALU) ? alu_result_mem : ((reg_src_mem == `FROM_MEM)? mem2reg_data : ((reg_src_mem == `FROM_IMM)? imm_mem:pc_plus4_mem));

    MEM_MODULE mem_module(
        //From ex_mem
        .mem_read(mem_read_mem),
        .load_type(load_type_mem),//???
        //还有一堆信号干嘛去了？？
        //.reg_write_data_mem(reg_write_data_mem),
        //To mem_wb
        .mem2reg_data(mem2reg_data),
        //From memory
        .mem_read_data(mem_read_data)
    );
    //WB
    wire reg_write_wb;
    wire [1:0] reg_src_wb;
    wire [4:0] rd_wb;
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
        .reg_write_data(reg_write_data_wb)
    );

    //Hazard_detect_unit
    Hazard_Detect_Unit hazard_detect_unit(
        .rst(rst),
        .pc_src_id(pc_src),
        .jal_id(jal_id), .jalr_id(jalr_id), .branch_id(branch_id),
        .rs1_id(rs1_id), .rs2_id(rs2_id), 
        .rd_mem(rd_mem), .rd_ex(rd_ex),
        .mem_read_ex(mem_read_ex), .mem_read_mem(mem_read_mem),.reg_write_ex(reg_write_ex),
        .stall_if(stall_if), .bubble_if(bubble_if),
        .stall_id(stall_id), .bubble_id(bubble_id),
        .stall_ex(stall_ex), .bubble_ex(bubble_ex),
        .stall_mem(stall_mem), .bubble_mem(bubble_mem),
        .stall_wb(stall_wb), .bubble_wb(bubble_wb)
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
endmodule