// ============================================================================
// 8. TOP-LEVEL TESTBENCH MODULE
// ============================================================================
module MEM_tb;

    import parameters_pkg::*;
    import mem_transaction_pkg::*;
    import mem_gen_pkg::*;
    import mem_driver_pkg::*;
    import mem_monitor_pkg::*;
    import mem_scoreboard_pkg::*;
    import mem_env_pkg::*;
    // Clock generation (100 MHz)
    logic clk;
    initial  clk = 0;
    always #5 clk = ~clk;

    // Interface instantiation
    mem_intrf intrf (.clk(clk));

    // DUT instantiation
    axi4_memory #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .DEPTH      (DEPTH)
    ) DUT (
        .clk       (intrf.clk),
        .rst_n     (intrf.rst_n),
        .mem_en    (intrf.mem_en),
        .mem_we    (intrf.mem_we),
        .mem_addr  (intrf.mem_addr),
        .mem_wdata (intrf.mem_wdata),
        .mem_rdata (intrf.mem_rdata)
    );
    

    // Test environment
    MEM_Env env;

    initial 
    begin
        env     = new();
        env.vif = intrf.TB_SIDE;
        env.run_env();
    end

    // Waveform dumping
    initial begin
        $dumpfile("MEM_tb.vcd");
        $dumpvars(0, MEM_tb);
    end

endmodule