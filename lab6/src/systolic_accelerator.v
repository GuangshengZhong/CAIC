`include "src/accelerator_components/controller.v"
`include "src/accelerator_components/fifo.v"
`include "src/accelerator_components/systolic_array.v"

module SystolicAccelerator #(
    parameter ARRAY_SIZE=16,
    parameter DATA_WIDTH=16,
    parameter FIFO_BUFFER_SIZE=16,
    parameter BUS_PACKET_WIDTH=256

) (
    input clk, rst, debug,
    // slave ports on bus
    input [BUS_PACKET_WIDTH-1:0] bus_slave_input,
    input [31:0] bus_slave_addr,
    input bus_slave_read_request, bus_slave_write_request,
    output bus_slave_request_finish,
    output [BUS_PACKET_WIDTH-1:0] bus_slave_output
);
    #TODO


    // used for output. save systolic array's results
    // DO NOT CHANGE↓
    integer out_file;
    initial 
        begin
            if(`TEST_TYPE==0)
            begin 
                out_file = $fopen("systolic_output0.txt", "w");    
            end
            else if(`TEST_TYPE==1)
            begin 
                out_file = $fopen("systolic_output1.txt", "w");    
            end
            else if(`TEST_TYPE==2)
            begin 
                out_file = $fopen("systolic_output2.txt", "w");    
            end
            else if(`TEST_TYPE==3)
            begin 
                out_file = $fopen("systolic_output3.txt", "w");    
            end
            else if(`TEST_TYPE==4)
            begin 
                out_file = $fopen("systolic_output4.txt", "w");    
            end
        end

    integer x, y;
    always @(posedge clk) 
    begin
        if(debug)
        begin
            for(x=0; x<ARRAY_SIZE; x=x+1)
            begin
                for(y=0; y<ARRAY_SIZE; y=y+1)
                begin
                    $fwrite(out_file, "%4h ", systolic_array.results_unpacked[x][y]);
                end
                $fwrite(out_file, "\n");
            end
        end    
    end

    
endmodule