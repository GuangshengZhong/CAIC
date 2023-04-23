`include "src/defines.v"
module ID_Control(
    input [31:0] rs1_data, rs2_data,
    input [31:0] reg_write_data_mem,
    input [1:0] rs1_fwd_id, rs2_fwd_id,
    input [2:0] funct3,
    input [3:0] alu_type,
    input branch,
    output [31:0] rs1_data_update, rs2_data_update,
    // output reg zero, less_than
    output zero, less_than
);
    // always@(*)begin
    //     rs1_data_update = (rs1_fwd_id == `FROM_MEM) ? reg_write_data_mem : rs1_data ;
    //     rs2_data_update = (rs2_fwd_id == `FROM_MEM) ? reg_write_data_mem : rs2_data ;
    //     zero  = (rs1_data_update == rs2_data_update) ;
    //     less_than = ((funct3 == `BLTU)||(funct3 == `BGEU)) ? (rs1_data_update < rs2_data_update) : ($signed(rs1_data_update)<$signed(rs1_data_update));
    // end

    assign rs1_data_update = (rs1_fwd_id == `FROM_MEM) ? reg_write_data_mem : rs1_data ;
    assign rs2_data_update = (rs2_fwd_id == `FROM_MEM) ? reg_write_data_mem : rs2_data ;
    // always@(*) begin
    //     case(alu_type)
    //     `SUB: zero = (rs1_data_update-rs2_data_update==0);
    //     `SLTU: less_than = (rs1_data_update < rs2_data_update);
    //     `SLT: less_than = ($signed(rs1_data_update)<$signed(rs2_data_update));
    //     endcase
    // end 
    assign rs1_data_update = (rs1_fwd_id == `FROM_MEM) ? reg_write_data_mem : rs1_data ;
    assign rs2_data_update = (rs2_fwd_id == `FROM_MEM) ? reg_write_data_mem : rs2_data ;
    assign zero  = (rs1_data_update == rs2_data_update) ;
    // assign zero  = (alu_type == `SUB)? (rs1_data_update == rs2_data_update): zero ;
    assign less_than = ((funct3 == `BLTU)||(funct3 == `BGEU)) ? (rs1_data_update < rs2_data_update) : ($signed(rs1_data_update)<$signed(rs2_data_update));
    // assign zero  = branch ? (rs1_data_update == rs2_data_update): zero ;
    // assign less_than = (alu_type == `SLT || alu_type == `SLTU) ? (((funct3 == `BLTU)||(funct3 == `BGEU)) ? (rs1_data_update < rs2_data_update) : ($signed(rs1_data_update)<$signed(rs1_data_update))) : less_than;
endmodule