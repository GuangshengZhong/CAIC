`timescale 1ns/1ns

`include "src/top.v"

module TB_IFID;
    initial begin            
        $dumpfile("wave.vcd");  // generate wave.vcd
        $dumpvars(0, TB_IFID);   // dump all of the TB module data
    end

    reg clk;
    initial clk = 0;
    always #1 clk = ~clk;

    reg rst;
    reg [31:0] write_data;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] alu_op1, alu_op2;
    wire branch, jal, jalr, mem_read, mem_write, alu_src1, alu_src2;
    wire [3:0] alu_type;
    wire reg_write_enable; wire [31:0] instr_out;

    integer out_file;
    initial 
    begin
        #0
        rst = 1;
        write_data = 32'h00000000;
        out_file = $fopen("output.txt", "w");
        
        #2
        rst = 0;
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %3d %3d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, alu_op1, alu_op2, branch, jal, jalr, mem_read, mem_write, alu_type, reg_write_enable);
        #2
        $stop;
    end

    TOP top_module(
        .clk(clk), .rst(rst),
        .write_data(write_data),
        .rs1_data(rs1_data), .rs2_data(rs2_data),
        .branch(branch), .jal(jal), .jalr(jalr),
        .mem_read(mem_read), .mem_write(mem_write),
        .alu_src1(alu_src1), .alu_src2(alu_src2),
        .alu_type(alu_type),
        .reg_write_enable(reg_write_enable),
        .instr_out(instr_out),
        .alu_op1(alu_op1), .alu_op2(alu_op2)
    );

    
endmodule