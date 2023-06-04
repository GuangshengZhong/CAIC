`define LRU 1

`ifdef LRU
    `define MAX_AGE 32'h7fffffff
`endif 

module DataCache #(
    parameter LINE_ADDR_LEN = 3, // Each cache line has 2^LINE_ADDR_LEN words
    parameter SET_ADDR_LEN = 3, // This cache has 2^SET_ADDR_LEN cache sets
    parameter TAG_ADDR_LEN = 10, // should in alignment with main memory's space
    parameter WAY_CNT = 16, // each cache set contains WAY_CNT cache lines
    parameter BUFFER_SIZE = 16,
    parameter DATA_WIDTH = 16
) (
    input clk, rst, debug,
    // ports between cache and CPU
    input read_request, write_request,
    input [2:0] write_type,
    input [31:0] slave_addr, write_data,
    output miss, //给CPU传递状态机的状态信息
    output reg request_finish,
    output reg [31:0] read_data,
    // ports between cache and main memory
    // output reg mem_read_request, mem_write_request, //主存读写请求端口
    output mem_read_request, mem_write_request, //主存读写请求端口
    output [(32*(1<<LINE_ADDR_LEN)-1):0] mem_write_data,
    output [31:0] mem_addr, //主存地址端口、主存写数据端口
    input mem_request_finish, //主存请求完成端口
    input [(32*(1<<LINE_ADDR_LEN)-1):0] mem_read_data, //主存读数据端口
    // for ISA extension
    input cache_request_from_accelerator,
    input [BUFFER_SIZE*DATA_WIDTH-1:0] accelerator_cache_write_data,
    output reg [BUFFER_SIZE*DATA_WIDTH-1:0] accelerator_cache_read_data
);
    wire [31:0] addr;
    assign addr = slave_addr - `DATA_MEM_BASE_ADDR;
    // params to transfer bit number to count
    localparam WORD_ADDR_LEN = 2; // each word contains 4 bytes
    localparam MEM_ADDR_LEN = TAG_ADDR_LEN + SET_ADDR_LEN; // in cache line's granularity
    localparam UNUSED_ADDR_LEN = 32 - MEM_ADDR_LEN - LINE_ADDR_LEN - WORD_ADDR_LEN;
    localparam LINE_SIZE = 1 << LINE_ADDR_LEN; // each cache line has LINE_SIZE words
    localparam SET_SIZE = 1 << SET_ADDR_LEN; // This cache has SET_SIZE cache sets
    // cache state enumarations
    parameter [1:0] READY = 2'b00;
    parameter [1:0] REPLACE_OUT = 2'b01;
    parameter [1:0] REPLACE_IN = 2'b10;

    // cache units declaration
    reg [31:0]             cache_data [0:SET_SIZE-1][0:WAY_CNT-1][0:LINE_SIZE-1];
    reg [TAG_ADDR_LEN-1:0] tag [0:SET_SIZE-1][0:WAY_CNT-1];
    reg                    valid [0:SET_SIZE-1][0:WAY_CNT-1];
    reg                    dirty [0:SET_SIZE-1][0:WAY_CNT-1];

    // current cache state
    reg [1:0] cache_state;
    // reg [31:0] total_cnt, hit_cnt, miss_cnt; 

    // for replace policy, basically, we will implement FIFO policy
    // For simplicity, we can assign cache lines from way 0 to way WAY_CNT-1
    // In this way, FIFO is equivalant to round-robbin policy
    reg [31:0] replace_way [0:SET_SIZE-1];
    // for LRU, we need to record the age of each way in each set, and the way with the biggest age
`ifdef LRU
    // record each way's age
    reg [31:0] way_age [0:SET_SIZE-1][0:WAY_CNT-1];
`endif

    // Used for memory read/write ports' unpack/pack
    // 由于 Verilog 不支持使用 数组定义接口，我们还为大家提供了将主存的读写数据接口转换成以 word 为单位的数组的 解包/打包 代码
    reg [31:0] mem_write_line [0:LINE_SIZE-1];
    wire [31:0] mem_read_line [0:LINE_SIZE-1];
    wire acc_write_cache_data_unpacked[0:LINE_SIZE-1]; //要整行写cache时的接口
    genvar line;
    generate
        for(line=0; line<LINE_SIZE; line=line+1)
        begin : memory_interface
            assign mem_write_data[32*(LINE_SIZE-line)-1:32*(LINE_SIZE-line-1)] = mem_write_line[line];
            assign mem_read_line[line] = mem_read_data[32*(LINE_SIZE-line)-1:32*(LINE_SIZE-line-1)];
            assign acc_write_cache_data_unpacked[line] = accelerator_cache_write_data[32*(LINE_SIZE-line)-1:32*(LINE_SIZE-line-1)];
        end
    endgenerate
    wire [32*LINE_SIZE-1 : 0] cache_read_line[0:SET_SIZE-1][0:WAY_CNT-1]; //要整行读cache时的接口
    genvar line1, i1, j1;
    generate
        for(i1 = 0; i1 < SET_SIZE; i1 = i1 + 1)
            for (j1 = 0; j1 < WAY_CNT; j1 = j1 + 1)
                for(line1=0; line1<LINE_SIZE; line1=line1+1)
                begin : cache_acc_interface
                    assign cache_read_line[i1][j1][32*(LINE_SIZE-line1)-1:32*(LINE_SIZE-line1-1)] = cache_data[i1][j1][line1];
                    
                end
    endgenerate
    

    // address translation
    /*****************************************/
    wire [WORD_ADDR_LEN - 1 : 0] word_addr;
    assign word_addr = addr[WORD_ADDR_LEN - 1 : 0];
    wire [LINE_ADDR_LEN - 1 : 0] line_addr;
    assign line_addr = addr[LINE_ADDR_LEN + WORD_ADDR_LEN - 1 : WORD_ADDR_LEN];
    wire [SET_ADDR_LEN - 1 : 0] set_addr;
    assign set_addr = addr[SET_ADDR_LEN + LINE_ADDR_LEN + WORD_ADDR_LEN - 1 : LINE_ADDR_LEN + WORD_ADDR_LEN];
    wire [TAG_ADDR_LEN - 1 : 0] tag_addr;
    assign tag_addr = addr[TAG_ADDR_LEN + SET_ADDR_LEN + LINE_ADDR_LEN + WORD_ADDR_LEN - 1 : SET_ADDR_LEN + LINE_ADDR_LEN + WORD_ADDR_LEN];
    /*****************************************/
    

    // check whether current request hits cache line
    // if cache hits, record the way hit by this request
    /*****************************************/
    wire hit;
    integer hit_way = -1;
    reg [TAG_ADDR_LEN-1:0] tag_to_compare;
    
    wire [WAY_CNT-1:0] hit_i;
    wire [WAY_CNT-1:0] way_ok[7:0];
    genvar way;
    generate
        for (way = 0; way < WAY_CNT; way = way + 1)begin:hitloop
            assign hit_i[way] = (valid[set_addr][way]&&(tag[set_addr][way] == tag_addr));
        end
    endgenerate
    assign hit = |hit_i;
    integer way_i;
    always@(*) begin
    // always@(hit_i) begin
        for(way_i = 0 ; way_i < WAY_CNT; way_i++)begin
            if(hit_i[way_i])
                hit_way = way_i;
        end
    end

    // assign miss = (read_request || write_request) && ((!(hit && cache_state === READY))||!request_finish);
    assign miss = ((read_request || write_request)&&(!request_finish));
    /*****************************************/


//替换策略描述
`ifdef LRU
    // combination logic to choose the way with max age
    /*****************************************/
    reg[31:0] age_max;
    reg[31:0] age_max_way;
    //在READY中更新age后使用组合逻辑进行判断
    /*****************************************/
`endif


    // interact with memory interface when cache miss/replacement occurs
    /*****************************************/
    //reg  [ SET_ADDR_LEN - 1 : 0] mem_read_set_addr = 0;
    //reg  [ TAG_ADDR_LEN - 1 : 0] mem_read_tag_addr = 0;
    wire [ 31 : 0] mem_read_addr;
    reg [ 31 : 0 ] mem_write_addr = 0;
    // assign mem_addr = mem_read_request ? mem_read_addr : (mem_write_request ? mem_write_addr : 0); 
    wire [31:0] mem_addr_local;
    assign mem_addr_local = mem_read_request ? mem_read_addr : (mem_write_request ? mem_write_addr : 0); 
    assign mem_addr = mem_addr_local + `DATA_MEM_BASE_ADDR;
    assign mem_write_request = (cache_state == REPLACE_OUT);
    assign mem_read_request = (cache_state == REPLACE_IN);
    assign mem_read_addr = {addr[31:LINE_ADDR_LEN+WORD_ADDR_LEN],{(LINE_ADDR_LEN+WORD_ADDR_LEN){1'b0}}};
    /*****************************************/

    //为了debug定义的一些东西
    //wire [TAG_ADDR_LEN - 1 :0] tag_replace_in_now;
    //wire [31:0] replace_in_way_now;
    //reg [31:0] replace_ready;
    //reg valid_ready, dirty_ready;
    //reg [SET_ADDR_LEN-1: 0] replace_set_ready;
    //assign tag_replace_in_now = mem_read_tag_addr;
    //assign replace_in_way_now = replace_way[mem_read_set_addr];
    //reg now_valid = 0;

    // cache state machine update logic
    integer i, j, k;
    reg [31:0] write_data_temp = 32'b0;
    always @(posedge clk)
    if(!cache_request_from_accelerator)begin
        // hit_cnt = total_cnt - miss_cnt;
        if(rst)
        begin
            // init CPU-cache interfaces
            request_finish <= 1'b0;
            read_data <= 32'h00000000;
            //total_cnt <= 0;
            //hit_cnt <= 0;
            //miss_cnt <= 0;
            // init cache state
            cache_state <= READY;
            
            // init cache lines
            for(i=0; i<SET_SIZE; i=i+1)
            begin
                replace_way[i] <= 0;
                for(j=0; j<WAY_CNT; j=j+1)
                begin
                    valid[i][j] <= 1'b0;
                    dirty[i][j] <= 1'b0;
                    `ifdef LRU
                    way_age[i][j] <= `MAX_AGE;
                    age_max <= 0;
                    age_max_way <=0;
                    `endif 
                end
            end
            
            // init cache-memory interfaces
            for(k=0; k<LINE_SIZE; k=k+1)
            begin
                mem_write_line[k] <= 32'h00000000;
            end
        end

        else
        begin
            case (cache_state)
                READY:
                begin
                    if(hit)
                    begin
                        // notify CPU whether the request can be finished
                        /*****************************************/
                        if(write_request || read_request) begin
                            request_finish <= !request_finish;
                            //if(request_finish) total_cnt <= total_cnt + 1'b1;
                        end
                        /*****************************************/

                        // update cache data
                        // for read request, fetch corresponding data
                        // for write request, dirty bit should also be updated
                        if(read_request)
                        begin
                            /*****************************************/
                            read_data <= cache_data[set_addr][hit_way][line_addr];
                            //request_finish <= 1'b1;
                            //request_finish <= 1'b0;
                            /*****************************************/
                        end
                        else if(write_request)
                        begin
                            /*****************************************/
                            case(write_type)
                            `SB: begin
                                case(word_addr)
                                2'b00: cache_data[set_addr][hit_way][line_addr][31:24] <= write_data[7:0];
                                2'b01: cache_data[set_addr][hit_way][line_addr][23:16] <= write_data[7:0];
                                2'b10: cache_data[set_addr][hit_way][line_addr][15:8] <= write_data[7:0];
                                2'b11: cache_data[set_addr][hit_way][line_addr][7:0] <= write_data[7:0];
                                endcase
                            end
                            `SH: begin
                                case(word_addr)
                                2'b00: cache_data[set_addr][hit_way][line_addr][31:16] <= write_data[15:0];
                                2'b10: cache_data[set_addr][hit_way][line_addr][15:0] <= write_data[15:0];
                                endcase
                            end
                            `SW: begin
                                cache_data[set_addr][hit_way][line_addr][31:0] <= write_data[31:0];
                            end
                            default: cache_data[set_addr][hit_way][line_addr][31:0] <= write_data[31:0];
                            endcase
                            dirty[set_addr][hit_way] <= 1'b1;
                            //request_finish <= 1'b1;
                            /*****************************************/
                        end
                        else
                        begin
                            read_data <= 32'h00000000;
                            //request_finish <= 1'b0;
                        end
                        // update cache age and replace way for LRU
                        /*****************************************/
                        `ifdef LRU
                            if ((read_request||write_request)&&!request_finish)begin
                                for(i = 0; i < WAY_CNT; i++)
                                if(i == hit_way)
                                    way_age[set_addr][i] <= 0;
                                else if(way_age[set_addr][i] < `MAX_AGE)
                                    way_age[set_addr][i] <= way_age[set_addr][i]+1;//为了不越界
                                else way_age[set_addr][i] <= way_age[set_addr][i];
                            end        
                            age_max = 0;
                            for (i = 0; i <WAY_CNT; i++)begin
                                if(way_age[set_addr][i] > age_max)
                                    begin
                                        age_max = way_age[set_addr][i];
                                        age_max_way = i;
                                    end
                            end
                            replace_way[set_addr] <= age_max_way;
                        `endif
                        /*****************************************/
                        // cache_state <= READY;
                    end

                    else //not hit
                    begin
                        // read_data <= 32'b0;
                        // if current request does not hit, change cache state
                        /*****************************************/
                        if(write_request || read_request) begin
                            request_finish <= 1'b0;
                            //miss_cnt <= miss_cnt + 1'b1;
                            //mem_read_request <= read_request;//!!!!!!!!
                            //mem_write_request <= write_request;//改成阻塞或者非阻塞，很有不同
                            // replace_ready <= replace_way[set_addr];
                            // replace_set_ready <= set_addr;
                            // valid_ready <= valid[set_addr][replace_way[set_addr]];
                            // dirty_ready <= dirty[set_addr][replace_way[set_addr]];
                            if(valid[set_addr][replace_way[set_addr]] && dirty[set_addr][replace_way[set_addr]])begin
                                cache_state <= REPLACE_OUT;
                                // replace_ready[16] = 1'b1;//这里从不置1，说明没进入过这层循环
                                mem_write_addr <= {{(UNUSED_ADDR_LEN){1'b0}},tag[set_addr][replace_way[set_addr]], set_addr, {(LINE_ADDR_LEN+WORD_ADDR_LEN){1'b0}}}; 
                                for(i = 0; i < LINE_SIZE; i++)
                                    mem_write_line[i] <= cache_data[set_addr][replace_way[set_addr]][i]; 
                            end
                            else begin
                                cache_state <= REPLACE_IN;
                            end
                            // mem_read_tag_addr <= tag_addr;
                            // mem_read_set_addr <= set_addr;
                            // mem_read_addr <= {mem_read_tag_addr, mem_read_set_addr};
                            // mem_read_addr <= {addr[31:LINE_ADDR_LEN+WORD_ADDR_LEN],{(LINE_ADDR_LEN+WORD_ADDR_LEN){1'b0}}};
                        end
                        request_finish <= 1'b0;
                        // else cache_state <= READY;
                        /*****************************************/
                    end
                    // mem_read_request <= 1'b0;
                    // mem_write_request <= 1'b0;
                end 
                
                REPLACE_OUT:
                begin
                    // switch to REPLACE_IN when memory write finishes
                    /*****************************************/
                    // mem_read_request <= 1'b0;
                    // mem_write_request <= 1'b1;
                    if(mem_request_finish)begin
                         cache_state <= REPLACE_IN;
                    end
                    request_finish <= 1'b0;
                    /*****************************************/
                end 

                REPLACE_IN:
                begin
                    // When memory read finishes, fill in corresponding cache line,
                    // set the cache line's state, then swtich to READY
                    // From the next cycle, the request is hit.
                    /*****************************************/
                    // mem_read_request <= 1'b1;
                    // mem_write_request <= 1'b0;
                    if(mem_request_finish)begin
                        for(i = 0; i < LINE_SIZE; i++ )
                            cache_data[set_addr][replace_way[set_addr]][i] <= mem_read_line[i];
                        tag[set_addr][replace_way[set_addr]] <= tag_addr;
                        valid[set_addr][replace_way[set_addr]] <= 1'b1;
                        dirty[set_addr][replace_way[set_addr]] <= 1'b0;
                        cache_state <= READY;
                        `ifdef LRU
                            // do nothing
                        `else
                            if(replace_way[set_addr] == WAY_CNT - 1)
                                replace_way[set_addr] <= 0;
                            else 
                                replace_way[set_addr] <= replace_way[set_addr]+1;
                        `endif
                    end 
                    request_finish <= 1'b0;
                    /*****************************************/
                end

            endcase
        end
    end
    else begin
        if(rst)
        begin
            // init CPU-cache interfaces
            request_finish <= 1'b0;
            accelerator_cache_read_data <= 0;
            // init cache state
            cache_state <= READY;
            
            // init cache lines
            for(i=0; i<SET_SIZE; i=i+1)
            begin
                replace_way[i] <= 0;
                for(j=0; j<WAY_CNT; j=j+1)
                begin
                    valid[i][j] <= 1'b0;
                    dirty[i][j] <= 1'b0;
                    `ifdef LRU
                    way_age[i][j] <= `MAX_AGE;
                    age_max <= 0;
                    age_max_way <=0;
                    `endif 
                end
            end
            
            // init cache-memory interfaces
            for(k=0; k<LINE_SIZE; k=k+1)
            begin
                mem_write_line[k] <= 32'h00000000;
            end
        end

        else
        begin
            case (cache_state)
                READY:
                begin
                    if(hit)
                    begin
                        // notify CPU whether the request can be finished
                        /*****************************************/
                        if(write_request || read_request) begin
                            request_finish <= !request_finish;
                        end
                        /*****************************************/

                        // update cache data
                        // for read request, fetch corresponding data
                        // for write request, dirty bit should also be updated
                        if(read_request)
                        begin
                            /*****************************************/
                            accelerator_cache_read_data <= cache_read_line[set_addr][hit_way];
                            /*****************************************/
                        end
                        else if(write_request)
                        begin
                            /*****************************************/
                            for(k=0; k<LINE_SIZE; k=k+1)begin 
                                    cache_data[set_addr][hit_way][k] <=  accelerator_cache_write_data[k];
                            end
                            dirty[set_addr][hit_way] <= 1'b1;
                            /*****************************************/
                        end
                        else
                        begin
                            read_data <= 0;
                        end
                        // update cache age and replace way for LRU
                        /*****************************************/
                        `ifdef LRU
                            if ((read_request||write_request)&&!request_finish)begin
                                for(i = 0; i < WAY_CNT; i++)
                                if(i == hit_way)
                                    way_age[set_addr][i] <= 0;
                                else if(way_age[set_addr][i] < `MAX_AGE)
                                    way_age[set_addr][i] <= way_age[set_addr][i]+1;//为了不越界
                                else way_age[set_addr][i] <= way_age[set_addr][i];
                            end        
                            age_max = 0;
                            for (i = 0; i <WAY_CNT; i++)begin:oldlop
                                if(way_age[set_addr][i] > age_max)
                                    begin
                                        age_max = way_age[set_addr][i];
                                        age_max_way = i;
                                    end
                            end
                            replace_way[set_addr] <= age_max_way;
                        `endif
                        /*****************************************/
                        // cache_state <= READY;
                    end

                    else //not hit
                    begin
                        // read_data <= 32'b0;
                        // if current request does not hit, change cache state
                        /*****************************************/
                        if(write_request || read_request) begin
                            request_finish <= 1'b0;
                            if(valid[set_addr][replace_way[set_addr]] && dirty[set_addr][replace_way[set_addr]])begin
                                cache_state <= REPLACE_OUT;
                                mem_write_addr <= {{(UNUSED_ADDR_LEN){1'b0}},tag[set_addr][replace_way[set_addr]], set_addr, {(LINE_ADDR_LEN+WORD_ADDR_LEN){1'b0}}}; 
                                for(i = 0; i < LINE_SIZE; i++)
                                    mem_write_line[i] <= cache_data[set_addr][replace_way[set_addr]][i]; 
                            end
                            else begin
                                cache_state <= REPLACE_IN;
                            end
                        end
                        request_finish <= 1'b0;
                        /*****************************************/
                    end
                end 
                
                REPLACE_OUT:
                begin
                    // switch to REPLACE_IN when memory write finishes
                    /*****************************************/
                    // mem_read_request <= 1'b0;
                    // mem_write_request <= 1'b1;
                    if(mem_request_finish)begin
                         cache_state <= REPLACE_IN;
                    end
                    request_finish <= 1'b0;
                    /*****************************************/
                end 

                REPLACE_IN:
                begin
                    // When memory read finishes, fill in corresponding cache line,
                    // set the cache line's state, then swtich to READY
                    // From the next cycle, the request is hit.
                    /*****************************************/
                    // mem_read_request <= 1'b1;
                    // mem_write_request <= 1'b0;
                    if(mem_request_finish)begin
                        for(i = 0; i < LINE_SIZE; i++ )
                            cache_data[set_addr][replace_way[set_addr]][i] <= mem_read_line[i];
                        tag[set_addr][replace_way[set_addr]] <= tag_addr;
                        valid[set_addr][replace_way[set_addr]] <= 1'b1;
                        dirty[set_addr][replace_way[set_addr]] <= 1'b0;
                        cache_state <= READY;
                        `ifdef LRU
                            // do nothing
                        `else
                            if(replace_way[set_addr] == WAY_CNT - 1)
                                replace_way[set_addr] <= 0;
                            else 
                                replace_way[set_addr] <= replace_way[set_addr]+1;
                        `endif
                    end 
                    request_finish <= 1'b0;
                    /*****************************************/
                end

            endcase
        end
    end



    // for your ease of debug
    integer out_file;
`ifdef LRU
    initial 
    begin
        if(`TEST_TYPE==0)
        begin
            out_file = $fopen("cache0.txt", "w");
        end
        else if(`TEST_TYPE==1)
        begin
            out_file = $fopen("cache1.txt", "w");
        end
        else if(`TEST_TYPE==2)
        begin
            out_file = $fopen("cache2.txt", "w");
        end
        else if(`TEST_TYPE==3)
        begin
            out_file = $fopen("cache3.txt", "w");
        end
        else
        begin
            out_file = $fopen("cache_else0.txt", "w");
        end
    end
`else
    initial 
    begin
        if(`TEST_TYPE==0)
        begin
            out_file = $fopen("cache4.txt", "w");
        end
        else if(`TEST_TYPE==1)
        begin
            out_file = $fopen("cache5.txt", "w");
        end
        else if(`TEST_TYPE==2)
        begin
            out_file = $fopen("cache6.txt", "w");
        end
        else if(`TEST_TYPE==3)
        begin
            out_file = $fopen("cache7.txt", "w");
        end
        else
        begin
            out_file = $fopen("cache_else1.txt", "w");
        end
    end
`endif

    integer set_index, way_index, line_index;
    always @(posedge clk) 
    begin
        if(debug)
        begin
            for(set_index=0; set_index<SET_SIZE; set_index=set_index+1)
            begin
                for(way_index=0; way_index<WAY_CNT; way_index=way_index+1)
                begin
                    $fwrite(out_file, "%d %d %8h ", valid[set_index][way_index], dirty[set_index][way_index], tag[set_index][way_index]);
`ifdef LRU
                    $fwrite(out_file, "%8h ", way_age[set_index][way_index]);
`endif 
                    for(line_index=0; line_index<LINE_SIZE; line_index=line_index+1)
                    begin
                        $fwrite(out_file, "%8h ", cache_data[set_index][way_index][line_index]);
                    end
                    $fwrite(out_file, "\n");
                end
                $fwrite(out_file, "\n");
            end
            // $display("Total cnt = %d . Hit cnt = %d . Miss cnt = %d . ", total_cnt, hit_cnt, miss_cnt);
        end
    end

endmodule