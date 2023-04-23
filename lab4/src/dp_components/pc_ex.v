`include "src/defines.v"
module PC_EX(
    input branch, jal, jalr,
    input [2:0] branch_type,
    input [31:0] pc,
    input [31:0] pc_plus4,
    input [31:0] rs1_data, //rs2_data,
    input [31:0] imm,
    input zero, less_than,
    //input [31:0] alu_result,
    output reg pc_src,//0:+4;1:new
    output reg [31:0] new_pc
);
    reg [31:0] new_pc_temp;
    always@(*)begin
        if (jal) begin
            new_pc = pc + imm;
            pc_src = 1'b1;
        end
        else if (jalr) begin
            new_pc = rs1_data + imm;
            pc_src = 1'b1;
        end
        else if(branch)begin
            new_pc_temp = pc + imm;
            pc_src = 1'b1;
            case(branch_type)
            `BEQ: new_pc = zero ? new_pc_temp : pc_plus4;
            `BNE: new_pc = (!zero) ? new_pc_temp : pc_plus4;
            `BLTU,`BLT: new_pc = less_than ? new_pc_temp : pc_plus4;
            //`BLT: pc_src = ($signed(rs1_data)<$signed(rs2_data));
            `BGEU, `BGE: new_pc = (!less_than) ? new_pc_temp : pc_plus4;
            //`BGE: pc_src = !($signed(rs1_data)<$signed(rs2_data));
            default: new_pc = pc_plus4;
        endcase end
        else begin
            pc_src = 1'b0;
            new_pc = pc_plus4;
        end
    end
endmodule