module RegFile (
    input [4:0] R_Addr1,
    input [4:0] R_Addr2,
    input [4:0] W_Addr,
    input [31:0] W_Data,
    input clk,
    input write_enable,
    //input write_type,
    output reg [31:0] alu_op1, alu_op2,
    output reg [31:0] R_Data1,
    output reg [31:0] R_Data2
);
    reg [31:0] register_file [0:31];
    integer i;
    initial
    begin
        for(i=1; i<=32; i+=1) begin
            register_file[i-1] = i-1;
        end    
    end
    always @(*) begin
        // if(write_enable==1'b1)
        // //TODO
        // else if(write_enable==1'b0)
        R_Data1 = register_file[R_Addr1];
        R_Data2 = register_file[R_Addr2];
        // else;
    end
endmodule