`timescale 1ns/1ps

import axi_pkg::*;
import axi_transaction_pkg::*;
import axi_generator_pkg::*;
import axi_driver_pkg::*;
import AXI_monitor_pkg::*;
import AXI_scoreboard_pkg::*;
import AXI_env_pkg::*;

module AXI_tb;

    // --- clock generation --------
    logic ACLK;
    initial
        ACLK = 1;
    always #5 ACLK = ~ACLK;

    // --- interface instantiation --------
    AXI_intrf #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MEMORY_DEPTH(MEMORY_DEPTH)
    ) intrf (
        .ACLK(ACLK)
    );

    // --- DUT instantiation --------
    axi4 DUT (
        .ACLK      (ACLK),
        .ARESETn   (intrf.ARESETn),

        // Write Address
        .AWADDR    (intrf.AWADDR),
        .AWLEN     (intrf.AWLEN),
        .AWSIZE    (intrf.AWSIZE),
        .AWVALID   (intrf.AWVALID),
        .AWREADY   (intrf.AWREADY),

        // Write Data
        .WDATA     (intrf.WDATA),
        .WVALID    (intrf.WVALID),
        .WLAST     (intrf.WLAST),
        .WREADY    (intrf.WREADY),

        // Write Response
        .BRESP     (intrf.BRESP),
        .BVALID    (intrf.BVALID),
        .BREADY    (intrf.BREADY),

        // Read Address
        .ARADDR    (intrf.ARADDR),
        .ARLEN     (intrf.ARLEN),
        .ARSIZE    (intrf.ARSIZE),
        .ARVALID   (intrf.ARVALID),
        .ARREADY   (intrf.ARREADY),

        // Read Data
        .RDATA     (intrf.RDATA),
        .RRESP     (intrf.RRESP),
        .RVALID    (intrf.RVALID),
        .RLAST     (intrf.RLAST),
        .RREADY    (intrf.RREADY)
    );

    // --- Environment --------
    AXI_env env;

    initial begin
        env         = new();
        env.vif     = intrf.TB_side;

        intrf.ARESETn = 0;
        @(posedge ACLK);
        @(posedge ACLK);
        @(posedge ACLK);
        intrf.ARESETn = 1;
        @(posedge ACLK);

        env.run_env();
    end

    initial begin
        $dumpfile("AXI_tb.vcd");
        $dumpvars(0, AXI_tb);
    end
endmodule