package mem_driver_pkg;

  import mem_transaction_pkg::*;

  class mem_driver;
    virtual mem_intrf.TB_SIDE  vif;
    event                      drv_done_e;

    // Mailboxes
    mailbox #(mem_transaction) gen2drv_mbx;
    mailbox #(int)             drv2gen_mbx;

    task run_driver();
      mem_transaction txn;

      @(negedge vif.clk);
      vif.rst_n     = 1'b0;
      vif.mem_en    = 1'b0;
      vif.mem_we    = 1'b0;
      vif.mem_addr  = '0;
      vif.mem_wdata = '0;

      @(negedge vif.clk);
      vif.rst_n <= 1'b1;  // Deassert reset

      // 2. Main Driving Loop
      forever begin
        gen2drv_mbx.get(txn);

        @(negedge vif.clk);
        vif.rst_n     <= txn.rst_n;
        vif.mem_en    <= txn.mem_en;
        vif.mem_we    <= txn.mem_we;
        vif.mem_addr  <= txn.mem_addr;
        vif.mem_wdata <= txn.mem_wdata;

        // Notify monitor and generator
        ->drv_done_e;
        drv2gen_mbx.put(1);
      end
    endtask
  endclass

endpackage
