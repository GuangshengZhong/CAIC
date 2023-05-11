
`ifdef LRU
    `define MAX_AGE 32'h7fffffff
`endif 

module DataCache #(
    parameter LINE_ADDR_LEN = 3, // Each cache line has 2^LINE_ADDR_LEN words
    parameter SET_ADDR_LEN = 3, // This cache has 2^SET_ADDR_LEN cache sets
    parameter TAG_ADDR_LEN = 10, // should in alignment with main memory's space
    parameter WAY_CNT = 4 // each cache set contains WAY_CNT cache lines
) (
    input clk, rst, debug,
    // ports between cache and CPU
    input read_request, write_request,
    input [2:0] write_type,
    input [31:0] addr, write_data,
    output miss, //给CPU传递状态机的状态信息
    output reg request_finish,
    output reg [31:0] read_data,
    // ports between cache and main memory
    output reg mem_read_request, mem_write_request, //主存读写请求端口
    output [(32*(1<<LINE_ADDR_LEN)-1):0] mem_write_data,
    output [31:0] mem_addr, //主存地址端口、主存写数据端口
    input mem_request_finish, //主存请求完成端口
    input [(32*(1<<LINE_ADDR_LEN)-1):0] mem_read_data //主存读数据端口
);
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
    genvar line;
    generate
        for(line=0; line<LINE_SIZE; line=line+1)
        begin : memory_interface
            assign mem_write_data[32*(LINE_SIZE-line)-1:32*(LINE_SIZE-line-1)] = mem_write_line[line];
            assign mem_read_line[line] = mem_read_data[32*(LINE_SIZE-line)-1:32*(LINE_SIZE-line-1)];
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
    reg hit;
    integer hit_way = -1;
    reg [TAG_ADDR_LEN-1:0] tag_to_compare;

    // always @(posedge clk or negedge clk) begin
    always @(posedge clk or negedge clk) begin:hitlop
        for (integer way = 0; way < WAY_CNT; way++)begin
         if(valid[set_addr][way]&&(tag[set_addr][way] == tag_addr))begin
            tag_to_compare = tag[set_addr][way];
            hit = 1'b1;
            hit_way = way;
            disable hitlop;
         end
         else begin
            tag_to_compare = tag[set_addr][way];
            hit = 1'b0;
            hit_way = -1; //用负数标志
         end
        end
    end
    assign miss = (read_request || write_request) && !(hit && cache_state == READY);
    /*****************************************/


//替换策略描述
`ifdef LRU
    // combination logic to choose the way with max age
    /*****************************************/
    integer age_max;
    integer age_max_way;
    //似乎不太方便用组合逻辑
    /*****************************************/
`endif


    // interact with memory interface when cache miss/replacement occurs
    /*****************************************/
    reg  [ SET_ADDR_LEN - 1 : 0] mem_read_set_addr = 0;
    reg  [ TAG_ADDR_LEN - 1 : 0] mem_read_tag_addr = 0;
    // wire [   MEM_ADDR_LEN - 1 : 0] mem_read_addr = {mem_read_tag_addr, mem_read_set_addr};
    reg [ MEM_ADDR_LEN - 1 : 0] mem_read_addr = 0;
    reg [ MEM_ADDR_LEN -1 : 0 ] mem_write_addr = 0;
    assign mem_addr = mem_read_request ? mem_read_addr : (mem_write_request ? mem_write_addr : 0); 
    /*****************************************/

    //为了debug定义的一些东西
    wire [TAG_ADDR_LEN - 1 :0] tag_replace_in_now;
    wire [31:0] replace_way_now;
    assign tag_replace_in_now = mem_read_tag_addr;
    assign replace_way_now = replace_way[mem_read_set_addr];
    reg now_valid = 0;

    // cache state machine update logic
    integer i, j, k;
    reg [31:0] write_data_temp = 32'b0;
    always @(posedge clk)
    begin
        if(rst)
        begin
            // init CPU-cache interfaces
            request_finish <= 1'b0;
            read_data <= 32'h00000000;
            
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
                        
                        /*****************************************/

                        // update cache data
                        // for read request, fetch corresponding data
                        // for write request, dirty bit should also be updated
                        if(read_request)
                        begin
                            /*****************************************/
                            read_data <= cache_data[set_addr][hit_way][line_addr];
                            request_finish <= 1'b1;
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
                            endcase
                            dirty[set_addr][hit_way] <= 1'b1;
                            request_finish <= 1'b1;
                            /*****************************************/
                        end
                        else
                        begin
                            read_data <= 32'h00000000;
                        end
                        // update cache age and replace way for LRU
                        /*****************************************/
                        `ifdef LRU
                            if (read_request||write_request)begin
                                for(integer way = 0; way < WAY_CNT; way++)
                                if(way == hit_way)
                                    way_age[set_addr][way] <= 0;
                                else if(valid[set_addr][way])
                                    way_age[set_addr][way] <= way_age[set_addr][way];//为了不越界
                                for (integer way = 0; way< WAY_CNT; way++)
                                    if(valid[set_addr][way]&&(way_age[set_addr][way]>age_max))begin
                                        age_max = way_age [set_addr][way];
                                        age_max_way = way;
                                    end
                                replace_way[set_addr] <= age_max_way;
                                age_max_way <=0;
                                age_max <=0; //进行一些个复原？
                            end
                        `endif
                        cache_state <= READY;
                        /*****************************************/
                    end

                    else //not hit
                    begin
                        // if current request does not hit, change cache state
                        /*****************************************/
                        if(write_request || read_request) begin
                            mem_read_request <= read_request;
                            mem_write_request <= write_request;
                            if(valid[set_addr][replace_way[set_addr]] && dirty[set_addr][replace_way[set_addr]])begin
                                cache_state <= REPLACE_OUT;
                                mem_write_addr <= {tag[set_addr][replace_way[set_addr]], set_addr}; 
                                for(integer line = 0; line < LINE_SIZE; line++)
                                    mem_write_line[line] <= cache_data[set_addr][replace_way[set_addr]][line]; 
                            end
                            else begin
                                cache_state <= REPLACE_IN;
                            end
                            mem_read_tag_addr <= tag_addr;
                            mem_read_set_addr <= set_addr;
                            mem_read_addr <= {mem_read_tag_addr, mem_read_set_addr};
                        end
                        /*****************************************/
                    end
                end 
                
                REPLACE_OUT:
                begin
                    // switch to REPLACE_IN when memory write finishes
                    /*****************************************/
                    
                    // mem_write_line <= cache_data[set_addr][replace_way[set_addr]];
                    // mem_write_addr <= {tag[set_addr][replace_way[set_addr]], set_addr}; //这两行放到原来的周期里
                    if(mem_request_finish)begin
                        cache_state <= REPLACE_IN;
                    end
                    /*****************************************/
                end 

                REPLACE_IN:
                begin
                    // When memory read finishes, fill in corresponding cache line,
                    // set the cache line's state, then swtich to READY
                    // From the next cycle, the request is hit.
                    /*****************************************/
                    if(mem_request_finish)begin
                        for(integer i = 0; i < LINE_SIZE; i++ )
                            cache_data[mem_read_set_addr][replace_way[mem_read_set_addr]][i] <= mem_read_line[i];
                        tag[mem_read_set_addr][replace_way[mem_read_set_addr]] <= mem_read_tag_addr;
                        valid[mem_read_set_addr][replace_way[mem_read_set_addr]] <= 1'b1;
                        now_valid <= 1'b1;
                        dirty[mem_read_set_addr][replace_way[mem_read_set_addr]] <= 1'b0;
                        cache_state <= READY;
                        `ifdef LRU
                        `else
                        // replace_way[mem_read_set_addr] <= (replace_way[mem_read_set_addr] + 1) % WAY_CNT;
                        if(replace_way[mem_read_set_addr] == WAY_CNT - 1)
                            replace_way[mem_read_set_addr] <= 0;
                        else 
                            replace_way[mem_read_set_addr] <= replace_way[mem_read_set_addr]+1;
                        `endif
                    end
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
        end    
    end

endmodule