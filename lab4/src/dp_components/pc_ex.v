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
            new_pc = pc + imm;
            case(branch_type)
            `BEQ: pc_src = zero;
            `BNE: pc_src = ~zero;
            `BLTU,`BLT: pc_src = less_than;
            //`BLT: pc_src = ($signed(rs1_data)<$signed(rs2_data));
            `BGEU, `BGE: pc_src = ~less_than;
            //`BGE: pc_src = !($signed(rs1_data)<$signed(rs2_data));
        endcase end
        else begin
            pc_src = 1'b0;
            new_pc = pc_plus4;
        end
    end
endmodule