package AXI_scoreboard_pkg;
    import axi_transaction_pkg::*;
    import axi_pkg::*;
    class AXI_scoreboard;

        // --- Virtual interface --------
        virtual AXI_intrf.TB_side   vif;

        // --- Mail boxes --------
        mailbox #(axi_transaction)  mon2scb_mbx;
        mailbox #(int)              scb2mon_mbx;

        mailbox #(axi_transaction)  gen2scb_mbx;
        mailbox #(int)              scb2gen_mbx;

        // --- Parameters to report --------
        int pass_count      = 0;
        int fail_count      = 0;
        string error_logs[$]; 

        // --- Variables for golden model --------
        logic   [1:0]       CS_W    = 2'b00;
        logic   [2:0]       CS_R    = 3'b000;  // Update this to 3 bits
        logic   [DATA_WIDTH-1 : 0]  mem_TE  [0:1023];
        typedef struct packed {
            logic   [ADDR_WIDTH-1 : 0]          addr;
            logic   [7:0]                       len;
            logic   [2:0]                       size;
        } addr_struct;
        addr_struct addr_pkt_W [$], addr_pkt_R[$];
        int offset_W        = 0;
        int offset_R        = 0;
        logic blocker       = 1'b0;

        // --- Golden model --------
        task golden_model(            
            // Reset
            input                           ARESETn,

            // Write address channel
            input   [ADDR_WIDTH-1:0]        AWADDR,
            input   [7:0]                   AWLEN,
            input   [2:0]                   AWSIZE,
            input                           AWVALID,
            ref                             AWREADY,

            // Write data channel
            input   [DATA_WIDTH-1:0]        WDATA,
            input                           WVALID,
            input                           WLAST,
            ref                             WREADY,

            // Write response channel
            ref  [1:0]                      BRESP,
            ref                             BVALID,
            input                           BREADY,

            // Read address channel
            input   [ADDR_WIDTH-1:0]        ARADDR,
            input   [7:0]                   ARLEN,
            input   [2:0]                   ARSIZE,
            input                           ARVALID,
            ref                             ARREADY,

            // Read data channel
            ref  [DATA_WIDTH-1:0]           RDATA,
            ref  [1:0]                      RRESP,
            ref                             RVALID,
            ref                             RLAST,
            input                           RREADY
        );
            if(!ARESETn) begin
                //$display(" \n   ------------ [SCB -- GLD MDL]    Reset case ");
                AWREADY     = 1'b1;
                WREADY      = 1'b0;
                BRESP       = 1'b0;
                BVALID      = 1'b0;
                
                ARREADY     = 1'b1;
                RDATA       = {DATA_WIDTH{1'b0}};
                RRESP       = 2'b00;
                RVALID      = 1'b0;
                RLAST       = 1'b0;

                CS_W        = 2'b00;
                CS_R        = 3'b000;  // Update this to 3'b000
            end
            else begin
                //$display(" \n ------------ [SCB -- GLD MDL]    Not reset case ");

                case(CS_W)
                    2'b00: begin
                        //$display(" ------------ [SCB -- GLD MDL]    Write case (IDLE) ");
                        // - expected output signals for writing operation --------
                        AWREADY     = 1'b1;
                        WREADY      = 1'b0;
                        BRESP       = 1'b0;
                        BVALID      = 1'b0;
                        addr_pkt_W  = {};

                        // - Checking AWVALID --------
                        if(AWVALID) begin
                            //$display(" ------------ [SCB -- GLD MDL]    Write case (IDLE -> AW^VALID) ");
                            // - Pushing the address data in the Q --------
                            addr_pkt_W.push_back('{addr: AWADDR, len: AWLEN, size: AWSIZE});

                            // - Go to the next stage --------
                            CS_W          = 2'b10;
                            AWREADY       = 1'b0;
                        end
                        else begin
                            // - Stay in IDLE --------
                            //$display(" ------------ [SCB -- GLD MDL]    Write case (IDLE -> AW^INVALID) ");
                            case(CS_R)
                                3'd0: begin
                                    //$display(" ------------ [SCB -- GLD MDL]    Read case (IDLE) ");
                                    // - expected output signals for Reading operation --------
                                    ARREADY     = 1'b1;
                                    //RRESP       = 2'b00; <<
                                    RVALID      = 1'b0;
                                    RLAST       = 1'b0;

                                    if(ARVALID) begin
                                        //$display(" ------- [SCB -- GLD MDL]    Read case (IDLE -> AR^VALID) ");
                                        
                                        // - De-assert the ARREADY after getting ARVALID --------
                                        ARREADY     = 1'b0;

                                        // - Pushing addr info in the Q --------
                                        addr_pkt_R.push_back('{addr: ARADDR, len: ARLEN, size: ARSIZE});

                                        // - Go to the bridge state --------
                                        CS_R        = 3'd1; // Go to BRIDGE 1
                                    end
                                    else begin
                                        //$display(" ------------ [SCB -- GLD MDL]    Read case (IDLE -> AW^INVALID) ");
                                        // - Waiting for ARVALID --------
                                        CS_R        = 3'd0;
                                    end
                                end

                                3'd1: begin
                                    //$display(" ------------ [SCB -- GLD MDL]    Read case (BRIDGE 1) ");
                                    ARREADY     = 1'b0;
                                    //RRESP       = 2'b00; <<
                                    RVALID      = 1'b0;
                                    RLAST       = 1'b0;
                                    // - Go to the bridge state --------
                                    CS_R        = 3'd2;
                                end

                                3'd2: begin
                                    //$display(" ------------ [SCB -- GLD MDL]    Read case (BRIDGE 2) ");
                                    ARREADY     = 1'b0;
                                    //RRESP       = 2'b00; <<
                                    RVALID      = 1'b0;
                                    RLAST       = 1'b0;
                                    // - Go to the reading state --------
                                    CS_R        = 3'd4;
                                end

                                3'd3: begin
                                    //$display(" ------------ [SCB -- GLD MDL]    Read case (BRIDGE 3) ");
                                    ARREADY     = 1'b0;
                                    //RRESP       = 2'b00; <<
                                    RVALID      = 1'b0;
                                    RLAST       = 1'b0;
                                    CS_R        = 3'd4; // Go to DATA
                                end

                                3'd4: begin
                                    //$display(" ------------ [SCB -- GLD MDL]    Read case (DATA) ");
                                    // - expected output signals for Reading operation --------
                                    ARREADY     = 1'b0;
                                    RVALID      = 1'b1;

                                    if ((addr_pkt_R[0].addr < 16'd4096) && 
                                        ((addr_pkt_R[0].addr + ((addr_pkt_R[0].len + 1) << addr_pkt_R[0].size)) < 16'd4096) && 
                                        !(((addr_pkt_R[0].addr & 12'hFFF) + (addr_pkt_R[0].len << addr_pkt_R[0].size)) > 12'hFFF)) begin //Edited

                                        // - Reading from TE memory if and only if the address and the length pass the boundary checks --------
                                       //$display(" ------------ [SCB -- GLD MDL]    Read case (S4 -> VALID ADDR),   offset_R: %d", offset_R);
                                        //$display(" ------------ [SCB -- GLD MDL]    Read case (S4 -> VALID ADDR - MEM[%h])   Value: %h", (addr_pkt_R[0].addr >> 2) + offset_R, mem_TE[(addr_pkt_R[0].addr >> 2) + offset_R]);
                                        //$display(" ------------ [SCB -- GLD MDL]    READ case (S2 -> VALID ADDR - ADDR_PKT), Value:   %p", addr_pkt_R);

                                        RDATA       = mem_TE[(addr_pkt_R[0].addr >> 2) + offset_R];
                                        RRESP       = 2'b00;

                                        if(offset_R == int'(addr_pkt_R[0].len)) begin
                                            // - Asserting RLAST --------
                                            //$display(" ------------ [SCB -- GLD MDL]    Read case (S4 -> LAST) ");
                                            RLAST       = 1'b1;

                                            if(RREADY) begin
                                                // - Hand shacking is done, and will go for recovery state --------
                                                //$display(" ------------ [SCB -- GLD MDL]    Read case (S4 -> SHACKING) ");
                                                CS_R        = 3'd6;

                                                // - Reseting the address offset and the address info packet --------
                                                offset_R    = 0;
                                                addr_pkt_R = {};
                                            end
                                        end
                                        else begin
                                            // - Continue reading --------
                                          //  $display(" ------------ [SCB -- GLD MDL]    Read case (S4 -> CONT READ) ");
                                            RLAST       = 1'b0;
                                            if(RREADY) begin
                                                // - Hand shacking is done, incresing the offset and go to bridge before reading again --------
                                                offset_R    = offset_R + 1;
                                                CS_R        = 3'd3;
                                            end
                                        end
                                    end
                                    else begin
                                        // - Incorrect Address and the length --------
                                        RDATA       = {DATA_WIDTH{1'b0}};
                                        RRESP       = 2'b10;
                                        RVALID      = 1'b1;

                                        if(offset_R == int'(addr_pkt_R[0].len)) begin
                                            // - Asserting RLAST --------
                                            //$display(" ------------ [SCB -- GLD MDL]    Read case (S4 -> LAST) ");
                                            RLAST       = 1'b1;

                                            if(RREADY) begin
                                                // - Hand shacking with the master, and go to the recovery state --------
                                              //  $display(" ------------ [SCB -- GLD MDL]    Read case (S4 -> SHACKING) ");
                                                CS_R        = 3'd6;

                                                // - Reseting the address offset and the address info packet --------
                                                offset_R    = 0;
                                                addr_pkt_R = {};
                                            end
                                            else begin
                                                // - Waiting for RREADY hand shacking --------
                                                //$display(" ------------ [SCB -- GLD MDL]    Read case (S4 -> WAITING FOR RREADY) ");
                                                CS_R        = 3'd4;
                                            end
                                        end
                                        else begin
                                            // - The frame doesn't end, waiting till the end --------
                                        //    $display(" ------------ [SCB -- GLD MDL]    Read case (S4 -> CONT READ) ");
                                            RLAST       = 1'b0;
                                            offset_R    = offset_R + 1;

                                            if(RREADY) begin
                                                CS_R        = 3'd3;
                                            end
                                            else begin
                                                CS_R        = 3'd4;
                                            end
                                        end
                                    end
                                end
                                3'd5: begin             // will be removed
                                    if(RREADY) begin
                                        //$display(" ------------ [SCB -- GLD MDL]    Read case (S5) ");
                                        CS_R        = 3'd6;
                                        RDATA       = {DATA_WIDTH{1'b0}};
                                        RRESP       = 2'b00;
                                        RLAST       = 1'b0;
                                        RVALID      = 1'b0;
                                    end
                                    else
                                        CS_R        = 3'd5;
                                end
                                3'd6: begin
                                    //$display(" ------------ [SCB -- GLD MDL]    Read case (RECOVERY) ");
                                    ARREADY     = 1'b0;
                                    // RDATA       = {DATA_WIDTH{1'b0}};
                                    //RRESP       = 2'b00;
                                    RVALID      = 1'b0;
                                    RLAST       = 1'b0;
                                    CS_R        = 3'd0; // Return to IDLE
                                    offset_R    = 0;
                                end
                            endcase
                            CS_W          = 2'b0;
                            AWREADY       = 1'b1;
                        end
                    end
                    2'b01: begin
                        // - Filling the gab between address phase and writing phase --------
                        //$display(" ------- [SCB -- GLD MDL]    Write case (BRIDGE STATE) ");
                        AWREADY     = 1'b0;
                        WREADY      = 1'b0;
                        BRESP       = 1'b0;
                        BVALID      = 1'b0;
                        CS_W        = 2'b10;
                    end
                    2'b10: begin
                       // $display(" ------------ [SCB -- GLD MDL]    Write case (S2) ");
                        // - expected output signals --------
                        AWREADY         = 1'b0;
                        BRESP           = 1'b0;
                        BVALID          = 1'b0;
                        WREADY          = 1'b1;

                        // - Starting writing phase --------
                        if(WVALID) begin
                         //   $display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> W^VALID), offset_W:   %d", offset_W);

                            // - Writing in TE memory if and only if the address and the length pass the boundary checks --------
                            if ((addr_pkt_W[0].addr < 16'd4096) && ((addr_pkt_W[0].addr + ((addr_pkt_W[0].len + 1) << addr_pkt_W[0].size)) < 16'd4096) && 
                            !(((addr_pkt_W[0].addr & 12'hFFF) + (addr_pkt_W[0].len << addr_pkt_W[0].size)) > 12'hFFF)) begin

                            mem_TE[(addr_pkt_W[0].addr >> 2) + offset_W] = WDATA;
                            end

                           // $display(" ------------ [SCB -- GLD MDL]    Write case (S4 -> VALID ADDR - MEM[%h])   Value: %h", (addr_pkt_W[0].addr >> 2) + offset_W, mem_TE[(addr_pkt_W[0].addr >> 2) + offset_W]);
                            //$display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> VALID ADDR - WDATA[%h]), Value:   %h", (addr_pkt_W[0].addr >> 2) + offset_W, WDATA);
                            //$display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> VALID ADDR - ADDR_PKT), Value:   %p", addr_pkt_W);

                            // - Checking WLAST --------
                            if(WLAST) begin
                              //  $display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> W^LAST) ");
                                // - De-assert WREADY --------
                                WREADY        = 1'b0;

                                // - Address and the length boundaries checks --------
                                if ((addr_pkt_W[0].addr < 16'd4096) && ((addr_pkt_W[0].addr + ((addr_pkt_W[0].len + 1) << addr_pkt_W[0].size)) < 16'd4096) && 
                                    !(((addr_pkt_W[0].addr & 12'hFFF) + (addr_pkt_W[0].len << addr_pkt_W[0].size)) > 12'hFFF)) begin //Edited

                                    // - Correct Address and the length --------
                                //    $display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> VALID ADDR) ");
                                    BVALID      = 1'b1;
                                    BRESP       = 2'b00;
                                end
                                else begin
                                    // - Incorrect Address and the length --------
                                  //  $display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> INVALID ADDR) ");
                                    BVALID      = 1'b1;
                                    BRESP       = 2'b10;
                                end

                                // - BREADY checking --------
                                if(BREADY) begin
                                    // - Hand shacking is done --------
                                   // $display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> DONE) ");
                                    CS_W      = 2'b00;
                                end
                                else begin
                                    // - Waiting BREADY --------
                                   // $display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> WAITING) ");
                                    CS_W      = 2'b11;
                                end

                                // - Reset the address offset --------
                                offset_W      = 0;
                            end
                            else begin
                                // - Continue writing in a correct way --------
                               // $display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> W^CONT) ");
                                offset_W      = offset_W + 1;
                            end
                        end
                        else begin
                            // - Waiting for WVALID --------
                          //  $display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> W^INVALID) ");
                            CS_W        = 2'b10;
                        end
                    end
                    2'b11: begin
                        // - State for waiting the BREADY and passing the correct BRESP, and BVALID --------
                      //  $display(" ------------ [SCB -- GLD MDL]    Write case (S3) ");
                        // - expected output signals for writing operation --------
                        AWREADY     = 1'b0;
                        WREADY      = 1'b0;
                        BVALID      = 1'b1;

                        // - Address and the length boundaries checks --------
                        if ((addr_pkt_W[0].addr < 16'd4096) && ((addr_pkt_W[0].addr + ((addr_pkt_W[0].len + 1) << addr_pkt_W[0].size)) < 16'd4096) && 
                            !(((addr_pkt_W[0].addr & 12'hFFF) + (addr_pkt_W[0].len << addr_pkt_W[0].size)) > 12'hFFF)) begin //Edited

                            // - Correct Address and the length --------
                        //    $display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> VALID ADDR) ");
                            BRESP       = 2'b00;
                        end
                        else begin
                            // - Incorrect Address and the length --------
                          //  $display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> INVALID ADDR) ");
                            BRESP       = 2'b10;
                        end

                        // - BREADY checking --------
                        if(BREADY) begin
                            // - Hand shacking is done --------
                          //  $display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> DONE) ");
                            CS_W      = 2'b00;
                        end
                        else begin
                            // - Waiting BREADY --------
                           // $display(" ------------ [SCB -- GLD MDL]    Write case (S2 -> WAITING) ");
                            CS_W      = 2'b11;
                        end

                        // - Clear the Q of address information --------
                        addr_pkt_W = {};
                    end
                endcase
            end
        endtask

        // --- Main checker -------- 
        task main_checker(
            // Write address channel
            input                           exp_AWREADY,
            input                           act_AWREADY,

            // Write data channel
            input                           exp_WREADY,
            input                           act_WREADY,

            // Write response channel
            input  [1:0]                    exp_BRESP,
            input  [1:0]                    act_BRESP,
            input                           exp_BVALID,
            input                           act_BVALID,

            // Read address channel
            input                           exp_ARREADY,
            input                           act_ARREADY,

            // Read data channel
            input  [DATA_WIDTH-1:0]        exp_RDATA,
            input  [1:0]                   exp_RRESP,
            input                          exp_RVALID,
            input                          exp_RLAST,
            input  [DATA_WIDTH-1:0]        act_RDATA,
            input  [1:0]                   act_RRESP,
            input                          act_RVALID,
            input                          act_RLAST
        );
            string msg;

            // - AWREADY checker --------
            if(exp_AWREADY !== act_AWREADY) begin
                fail_count = fail_count + 1;
                $sformat(msg, "@%0t: [ERROR] AWREADY mismatch | exp: %b, act: %b", $time, exp_AWREADY, act_AWREADY);
                $display("%s", msg);
                error_logs.push_back(msg);
            end else begin
                pass_count = pass_count + 1;
              //  $display("[INFO]    exp_AWREADY:    %b, act_AWREADY:    %b", exp_AWREADY, act_AWREADY);
            end

            // - WREADY checker --------
            if(exp_WREADY !== act_WREADY) begin
                $sformat(msg, "@%0t: [ERROR] WREADY mismatch | exp: %b, act: %b", $time, exp_WREADY, act_WREADY);
                $display("%s", msg);
                error_logs.push_back(msg);
            end else begin
                pass_count = pass_count + 1;
                //$display("[INFO]    exp_WREADY:    %b, act_WREADY:    %b", exp_WREADY, act_WREADY);
            end

            // - BRESP checker --------
            if(exp_BRESP !== act_BRESP) begin
                fail_count = fail_count + 1;
                $sformat(msg, "@%0t: [ERROR] BRESP mismatch | exp: %b, act: %b", $time, exp_BRESP, act_BRESP);
                $display("%s", msg);
                error_logs.push_back(msg);
            end else begin
                pass_count = pass_count + 1;
                //$display("[INFO]    exp_BRESP:    %b, act_BRESP:    %b", exp_BRESP, act_BRESP);
            end

            // - BVALID checker --------
            if(exp_BVALID !== act_BVALID) begin
                fail_count = fail_count + 1;
                $sformat(msg, "@%0t: [ERROR] BVALID mismatch | exp: %b, act: %b", $time, exp_BVALID, act_BVALID);
                //$display("%s", msg);
                error_logs.push_back(msg);
            end else begin
                pass_count = pass_count + 1;
                //$display("[INFO]    exp_BVALID:    %b, act_BVALID:    %b", exp_BVALID, act_BVALID);
            end

            // - ARREADY checker --------
            if(exp_ARREADY !== act_ARREADY) begin
                fail_count = fail_count + 1;
                $sformat(msg, "@%0t: [ERROR] ARREADY mismatch | exp: %b, act: %b", $time, exp_ARREADY, act_ARREADY);
                //$display("%s", msg);
                error_logs.push_back(msg);
            end else begin
                pass_count = pass_count + 1;
                //$display("[INFO]    exp_ARREADY:    %b, act_ARREADY:    %b", exp_ARREADY, act_ARREADY);
            end

            // - RDATA checker --------
            if(exp_RDATA !== act_RDATA) begin
                fail_count = fail_count + 1;
                $sformat(msg, "@%0t: [ERROR] RDATA mismatch | exp: %h, act: %h, TE value: %h, TE addr:  %h", $time, exp_RDATA, act_RDATA, mem_TE[(addr_pkt_R[0].addr >> 2) + offset_R], (addr_pkt_R[0].addr >> 2) + offset_R);
                //$display("%s", msg);
                error_logs.push_back(msg);
            end else begin
                pass_count = pass_count + 1;
               //$display("[INFO]    exp_RDATA:    %h, act_RDATA:    %h", exp_RDATA, act_RDATA);
            end

            // - RRESP checker --------
            if(exp_RRESP !== act_RRESP) begin
                fail_count = fail_count + 1;
                $sformat(msg, "@%0t: [ERROR] RRESP mismatch | exp: %b, act: %b", $time, exp_RRESP, act_RRESP);
                //$display("%s", msg);
                error_logs.push_back(msg);
            end else begin
                pass_count = pass_count + 1;
                //$display("[INFO]    exp_RRESP:    %b, act_RRESP:    %b", exp_RRESP, act_RRESP);
            end

            // - RVALID checker --------
            if(exp_RVALID !== act_RVALID) begin
                fail_count = fail_count + 1;
                $sformat(msg, "@%0t: [ERROR] RVALID mismatch | exp: %b, act: %b", $time, exp_RVALID, act_RVALID);
                //$display("%s", msg);
                error_logs.push_back(msg);
            end else begin
                pass_count = pass_count + 1;
                //$display("[INFO]    exp_RVALID:    %b, act_RVALID:    %b", exp_RVALID, act_RVALID);
            end

            // - RLAST checker --------
            if(exp_RLAST !== act_RLAST) begin
                fail_count = fail_count + 1;
                $sformat(msg, "@%0t: [ERROR] RLAST mismatch | exp: %b, act: %b", $time, exp_RLAST, act_RLAST);
                //$display("%s", msg);
                error_logs.push_back(msg);
            end else begin
                pass_count = pass_count + 1;
                //$display("[INFO]    exp_RLAST:    %b, act_RLAST:    %b", exp_RLAST, act_RLAST);
            end
            $display("[SAMPLE END @%t]    ", $time);
        endtask

        // --- Summary Report Task -------- 
        task sum_report();
            $display("\n\n======================================");
            $display("========= END OF SIMULATION ==========");
            $display("============== SUMMARY ===============");

            if ((pass_count + fail_count) > 0) begin
                $display("[RATE]:         Total Pass Rate: %0d%%", (pass_count * 100) / (pass_count + fail_count));
                $display("[PASS COUNT]:   %0d", pass_count);
                $display("[FAIL COUNT]:   %0d", fail_count);
                $display("[TOTAL CHECKS]: %0d", (pass_count + fail_count) / 9); 
            end else begin
                $display("[WARNING]:      No checks were executed!");
            end
            $display("======================================\n");

            // --- Error Log Post-Summary Report --------
            if (error_logs.size() > 0) begin
                $display("=========== ERROR LOG DETAILS ===========");
                foreach (error_logs[i]) begin
                    $display("  [%0d] %s", i + 1, error_logs[i]);
                end
                $display("=========================================\n");
            end else begin
                $display("============ NO ERRORS LOGGED ===========\n");
            end
        endtask

        task run_scoreboard();
            axi_transaction                 mon_tr, gen_tr;
            logic                           exp_AWREADY;
            logic                           exp_WREADY;
            logic   [1:0]                   exp_BRESP;
            logic                           exp_BVALID;
            logic                           exp_ARREADY;
            logic   [DATA_WIDTH-1:0]        exp_RDATA;
            logic   [1:0]                   exp_RRESP;
            logic                           exp_RVALID;
            logic                           exp_RLAST;

            foreach(mem_TE[i])
                mem_TE[i]   = 0;
            
            forever begin
                mon2scb_mbx.get(mon_tr);

                golden_model(
                    mon_tr.ARESETn, mon_tr.AWADDR, mon_tr.AWLEN,  
                    mon_tr.AWSIZE, mon_tr.AWVALID, exp_AWREADY,
                    mon_tr.WDATA_MON, mon_tr.WVALID, mon_tr.WLAST, exp_WREADY,
                    exp_BRESP, exp_BVALID, mon_tr.BREADY, mon_tr.ARADDR,
                    mon_tr.ARLEN, mon_tr.ARSIZE, mon_tr.ARVALID, 
                    exp_ARREADY, exp_RDATA, exp_RRESP, exp_RVALID, 
                    exp_RLAST, mon_tr.RREADY
                );

                main_checker(
                    exp_AWREADY, mon_tr.AWREADY,
                    exp_WREADY, mon_tr.WREADY,
                    exp_BRESP, mon_tr.BRESP,
                    exp_BVALID, mon_tr.BVALID,
                    exp_ARREADY, mon_tr.ARREADY,
                    exp_RDATA, exp_RRESP, 
                    exp_RVALID, exp_RLAST,
                    mon_tr.RDATA_MON, mon_tr.RRESP, 
                    mon_tr.RVALID, mon_tr.RLAST
                );

                scb2mon_mbx.put(1);
            end
        endtask
    endclass
endpackage