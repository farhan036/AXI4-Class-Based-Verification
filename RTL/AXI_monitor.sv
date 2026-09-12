package AXI_monitor_pkg;
  import axi_transaction_pkg::*;
  class AXI_monitor;

    // --- Virtual Interface --------
    virtual AXI_intrf.TB_side  vif;

    // --- Mail boxes --------
    mailbox #(axi_transaction) mon2scb_mbx;  // Monitor to Scoreboard mail box.
    mailbox #(int)             scb2mon_mbx;  // Scoreboard to Monitor mail box.

    task run_monitor();

      axi_transaction sampled;
      int token;

      forever begin
        @(posedge vif.ACLK);
        #100ps;

        sampled = new();

        sampled.ARESETn  = vif.ARESETn;

        sampled.AWADDR   = vif.AWADDR;
        sampled.AWLEN    = vif.AWLEN;
        sampled.AWSIZE   = vif.AWSIZE;
        sampled.AWVALID  = vif.AWVALID;

        sampled.WDATA    = new[1];      // Added
        //sampled.WDATA[0] = vif.WDATA;   // Modified
        sampled.WDATA_MON = vif.WDATA;  // Add this line to fix WDATA_MON
        sampled.WVALID   = vif.WVALID;
        sampled.WLAST    = vif.WLAST;

        sampled.BREADY   = vif.BREADY;

        sampled.ARADDR   = vif.ARADDR;
        sampled.ARLEN    = vif.ARLEN;
        sampled.ARSIZE   = vif.ARSIZE;
        sampled.ARVALID  = vif.ARVALID;

        sampled.RREADY   = vif.RREADY;

        sampled.AWREADY  = vif.AWREADY;
        sampled.WREADY   = vif.WREADY;
        sampled.BRESP    = vif.BRESP;
        sampled.BVALID   = vif.BVALID;
        sampled.ARREADY  = vif.ARREADY;

        sampled.RDATA    = new[1];  // Added
        //sampled.RDATA[0] = vif.RDATA; //modified
        sampled.RDATA_MON = vif.RDATA;  // Add this line to fix RDATA_MON
        sampled.RRESP    = vif.RRESP;
        sampled.RVALID   = vif.RVALID;
        sampled.RLAST    = vif.RLAST;

        // sampled.display_transaction("MON");

        mon2scb_mbx.put(sampled);
        scb2mon_mbx.get(token);
      end
    endtask
  endclass
endpackage
