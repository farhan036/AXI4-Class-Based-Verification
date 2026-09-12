package mem_scoreboard_pkg;

    import parameters_pkg::*;
    import mem_transaction_pkg::*;

    class mem_scoreboard;
        mailbox #(mem_transaction) mon2scb_mbx;
        mailbox #(int)             scb2mon_mbx;

        logic [DATA_WIDTH-1:0] memory_golden [0:DEPTH-1];
        logic [DATA_WIDTH-1:0] golden_rdata; // latch rdata form function 
        int pass_count = 0;
        int fail_count = 0;

        function new();
            for (int i = 0; i < DEPTH; i++) 
            begin
                memory_golden[i] = '0;
            end
            golden_rdata = '0;
        endfunction

        function void golden_mem(
            input  logic                     rst_n,      
            input  logic                     mem_en,
            input  logic                     mem_we,
            input  logic [ADDR_WIDTH-1:0]    mem_addr,
            input  logic [DATA_WIDTH-1:0]    mem_wdata,
            output logic [DATA_WIDTH-1:0]    mem_rdata
        );
            if (!rst_n) 
                begin
                    golden_rdata = '0;
                end else if (mem_en) 
                begin
                    if (mem_we)
                        memory_golden[mem_addr] = mem_wdata;
                    else
                        golden_rdata = memory_golden[mem_addr];
                end
            mem_rdata = golden_rdata;
        endfunction

        task run_scoreboard();
            mem_transaction mon_txn;
            logic [DATA_WIDTH-1:0] exp_mem_rdata;
            bit out_ok;

            forever begin
                mon2scb_mbx.get(mon_txn);
                
                golden_mem(mon_txn.rst_n, mon_txn.mem_en, mon_txn.mem_we, mon_txn.mem_addr, mon_txn.mem_wdata, exp_mem_rdata);

                // 1. Reset Check
                if (!mon_txn.rst_n) 
                begin
                    out_ok = (mon_txn.mem_rdata === exp_mem_rdata);
                    if (out_ok) begin
                        $display("[%0t][SCB] PASS | OP=RESET ADDR=0x%03h | DUT: 0x%08h | EXP: 0x%08h",
                                $time, mon_txn.mem_addr, mon_txn.mem_rdata, exp_mem_rdata);
                        pass_count++;
                    end else begin
                        $display("[%0t][SCB] FAIL | OP=RESET ADDR=0x%03h | DUT: 0x%08h | EXP: 0x%08h",
                                $time, mon_txn.mem_addr, mon_txn.mem_rdata, exp_mem_rdata);
                        fail_count++;
                    end
                end
                // 2. Memory Enabled Operations
                else if (mon_txn.mem_en) 
                begin
                    // Write Transaction
                    if (mon_txn.mem_we) 
                    begin
                        if(memory_golden[mon_txn.mem_addr] === mon_txn.mem_wdata)
                        begin
                        $display("[%0t][SCB] PASS | OP=WRITE ADDR=0x%03h | DATA=0x%08h", 
                                $time, mon_txn.mem_addr, mon_txn.mem_wdata);
                        pass_count++;
                        end
                        else
                        begin
                            $display("[%0t][SCB] Failed | OP=Write  ADDR=0x%03h | DUT: 0x%08h | EXP: 0x%08h",
                                    $time, mon_txn.mem_addr, mon_txn.mem_wdata,memory_golden[mon_txn.mem_addr]);
                        fail_count++;
                        end
                    end 
                    // Read Transaction Check
                    else 
                    begin
                        out_ok = (mon_txn.mem_rdata === exp_mem_rdata);
                        if (out_ok) 
                        begin
                            $display("[%0t][SCB] PASS | OP=READ  ADDR=0x%03h | DUT: 0x%08h | EXP: 0x%08h",
                                    $time, mon_txn.mem_addr, mon_txn.mem_rdata, exp_mem_rdata);
                            pass_count++;
                        end 
                        else 
                        begin
                            $display("[%0t][SCB] FAIL | OP=READ  ADDR=0x%03h | DUT: 0x%08h | EXP: 0x%08h",
                                    $time, mon_txn.mem_addr, mon_txn.mem_rdata, exp_mem_rdata);
                            fail_count++;
                        end
                    end
                end
                // 3. Memory Disabled / Idle Transaction
                else 
                begin
                    $display("[%0t][SCB] PASS | OP=IDLE (mem_en=0)", $time);
                    pass_count++;
                end

                scb2mon_mbx.put(1);
            end
        endtask

        function void report();
            $display("----------------------------------------");
            $display("          FINAL TEST SUMMARY            ");
            $display("----------------------------------------");
            $display(" TOTAL PASSED : %0d", pass_count);
            $display(" TOTAL FAILED : %0d", fail_count);
            if (fail_count == 0 && pass_count > 0)
                $display(" STATUS       : TEST PASSED SUCCESSFULLY");
            else
                $display(" STATUS       : TEST FAILED");
            $display("----------------------------------------");
        endfunction

    endclass

endpackage