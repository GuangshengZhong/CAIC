`include "src/defines.v"
module ID_Control(
    input [31:0] rs1_data, rs2_data,
    input [31:0] reg_write_data_mem,
    input [1:0] rs1_fwd_id, rs2_fwd_id,
    input [2:0] funct3,
    output [31:0] rs1_data_update, rs2_data_update,
    output zero, less_than
);
    always@(*)begin
        rs1_data_update = (rs1_fwd_id == `FROM_MEM) ? reg_write_data_mem : rs1_data ;
        rs2_data_update = (rs2_fwd_id == `FROM_MEM) ? reg_write_data_mem : rs2_data ;
        zero  = (rs1_data_update == rs2_data_update) ;
        less_than = ((funct3 == `BLTU)||(funct3 == `BGEU)) ? (rs1_data_update < rs2_data_update) : ($signed(rs1_data_update)<$signed(rs1_data_update));
    end
endmodule