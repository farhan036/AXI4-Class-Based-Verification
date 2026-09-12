package axi_generator_pkg;

import axi_transaction_pkg::*;
import axi_pkg::*;
    
    class axi_generator;

    // --- Virtual interface --------
    virtual AXI_intrf.TB_side   vif;

    //MailBoxes
    mailbox #(axi_transaction) gen2drv_mbx;
    mailbox #(int) drv2gen_mbx;

    // mailbox #(axi_transaction) gen2scb_mbx;
    // mailbox #(int) scb2gen_mbx;

    int unsigned num_transaction = 800;
    bit          done            = 0;

    task  run_gen();
        axi_transaction  txn ;
        int token;

        repeat(num_transaction)
        begin
            txn = new();
            if(!txn.randomize())
            $fatal(1,"Generator randomization failed");
            txn.cg.sample();

            // send to driver
            gen2drv_mbx.put(txn);
            drv2gen_mbx.get(token);

            // // send to scoreboard
            // gen2scb_mbx.put(txn);
            // scb2gen_mbx.get(token);
        end
        done = 1;
        $display("Gen finished");

    endtask //automatic 
        
    endclass 
endpackage