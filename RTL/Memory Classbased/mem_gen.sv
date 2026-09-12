package mem_gen_pkg;

  import mem_transaction_pkg::*;

  class mem_gen;

    //mailboxes
    mailbox #(mem_transaction) gen2drv_mbx;
    mailbox #(int)             drv2gen_mbx;

    int unsigned               num_transactions = 20000;
    bit                        done             = 0;

    task run_generator;

      mem_transaction txn;
      int token;

      repeat (num_transactions) begin
        txn = new();

        if (!txn.randomize()) $fatal(1, "[GENERATOR] Randomization failed!");
        txn.cg.sample();
        gen2drv_mbx.put(txn);
        drv2gen_mbx.get(token);

      end

      done = 1;
      $display("[%0t][GEN] Generator finished. %0d transactions sent.", $time, num_transactions);
    endtask
  endclass
endpackage
