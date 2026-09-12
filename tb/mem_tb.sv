module axi4_memory_tb;

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 10;    // For 1024 locations
    parameter DEPTH = 1024;

    bit clk;
    logic rst_n;
    logic mem_en;
    logic mem_we;
    logic [ADDR_WIDTH-1:0] mem_addr;
    logic [DATA_WIDTH-1:0] mem_wdata;
    logic [DATA_WIDTH-1:0] mem_rdata;

    logic [DATA_WIDTH-1:0] test_wdata_queue[$];
    logic [DATA_WIDTH-1:0] test_rdata_queue[$];
    logic [DATA_WIDTH-1:0] expected_queue[$];

    axi4_memory #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH), .DEPTH(DEPTH)) DUT(.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 1;

        $display("\n==================================================");
        $display("   STARTING AXI4 MEMORY TESTBENCH SIMULATION     ");
        $display("==================================================");

        // Reset Sequence
        $display("[%0t ns] [RST] Asserting Reset...", $time);
        @(posedge clk);
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        expected_queue = '{1024{32'h0}};
        $display("[%0t ns] [RST] Deasserting Reset. Memory Ready.", $time);

        // --------------------------------------------------
        // TEST 1: Write Operations when enable = 0
        // --------------------------------------------------
        $display("\n[%0t ns] [WRITE] Starting Write Operations when enable = 0...", $time);
        for (int i = 0; i < 1024; i++) begin
            write_mem_enableiszero(i, $random, test_wdata_queue);    
        end

        $display("\n[%0t ns] [READ] Starting Read Operations...", $time);
        for (int i = 0; i < 1024; i++) begin
            read_mem(i, test_rdata_queue);    
        end
        
        $display("\n[%0t ns] [CHECK] Executing Data Integrity Verification when enable = 0...", $time);
        checker_data(expected_queue, test_rdata_queue);
        
        // --------------------------------------------------
        // RESET BETWEEN TESTS
        // --------------------------------------------------
        $display("\n--- Resetting Queues & Driving Signals for Test 2 ---");
        test_rdata_queue.delete();
        test_wdata_queue.delete();
        mem_en = 0;
        mem_we = 0;
        @(posedge clk);

        // --------------------------------------------------
        // TEST 2: Normal Write & Read Operations
        // --------------------------------------------------
        $display("\n[%0t ns] [WRITE] Starting Write Operations (1024 Locations)...", $time);
        for (int i = 0; i < 1024; i++) begin
            write_mem(i, $random, test_wdata_queue);    
        end

        $display("\n[%0t ns] [READ] Starting Read Operations (1024 Locations)...", $time);
        for (int i = 0; i < 1024; i++) begin
            read_mem(i, test_rdata_queue);    
        end

        $display("\n[%0t ns] [CHECK] Executing Data Integrity Verification...", $time);
        checker_data(test_wdata_queue, test_rdata_queue);

        #20;
        $display("==================================================\n");
        $stop;
    end

    // Use "automatic" and "ref" for dynamic queues to prevent simulator scoping bugs
    task automatic write_mem(
        input logic [ADDR_WIDTH-1:0] mem_addr_t,
        input logic [DATA_WIDTH-1:0] mem_wdata_t,
        ref   logic [DATA_WIDTH-1:0] mem_wdata_queue[$]
    );
        @(negedge clk);
        mem_en = 1;
        mem_we = 1;
        mem_addr = mem_addr_t;
        mem_wdata = mem_wdata_t;
        mem_wdata_queue.push_back(mem_wdata_t);
    endtask

    task automatic write_mem_enableiszero(
        input logic [ADDR_WIDTH-1:0] mem_addr_t,
        input logic [DATA_WIDTH-1:0] mem_wdata_t,
        ref   logic [DATA_WIDTH-1:0] mem_wdata_queue[$]
    );
        @(negedge clk);
        mem_en = 0;
        mem_we = 1;
        mem_addr = mem_addr_t;
        mem_wdata = mem_wdata_t;
        mem_wdata_queue.push_back(mem_wdata_t);
    endtask

    task automatic read_mem(
        input logic [ADDR_WIDTH-1:0] mem_addr_t,
        ref   logic [DATA_WIDTH-1:0] mem_rdata_queue[$]
    );
        @(negedge clk);
        mem_en = 1;
        mem_we = 0;
        mem_addr = mem_addr_t;
        @(posedge clk);
        #1;
        mem_rdata_queue.push_back(mem_rdata);
    endtask

    task automatic checker_data(
        ref logic [DATA_WIDTH-1:0] test_wdata_queue_task[$],
        ref logic [DATA_WIDTH-1:0] test_rdata_queue_task[$]
    );
        int pass = 0;
        int fail = 0;

        $display("--------------------------------------------------");
        $display(" ADDR   | EXP DATA   | ACT DATA   | STATUS ");
        $display("--------------------------------------------------");

        for (int i = 0; i < 1024; i++) begin
            if (test_wdata_queue_task[i] === test_rdata_queue_task[i]) begin
                pass++;
            end else begin
                fail++;
                $display(" 0x%03X  | 0x%08X | 0x%08X | [FAIL]", i, test_wdata_queue_task[i], test_rdata_queue_task[i]);
            end
        end

        $display("--------------------------------------------------");
        $display("                 VERIFICATION RESULTS             ");
        $display("--------------------------------------------------");
        $display("  TOTAL TESTS : %0d", pass + fail);
        $display("  PASSED      : %0d", pass);
        $display("  FAILED      : %0d", fail);
        if (fail == 0) begin
            $display("  OVERALL STATUS: [ SUCCESS ]");
        end else begin
            $display("  OVERALL STATUS: [ FAILURE ]");
        end
        $display("--------------------------------------------------");
    endtask 

endmodule