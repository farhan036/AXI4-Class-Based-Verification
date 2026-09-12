package mem_env_pkg;

import mem_transaction_pkg::*;
import mem_gen_pkg::*;
import mem_driver_pkg::*;
import mem_monitor_pkg::*;
import mem_scoreboard_pkg::*;
import parameters_pkg::*;

class MEM_Env;
    // Components
    mem_gen  gen;
    mem_driver     drv;
    mem_monitor    mon;
    mem_scoreboard scb;

    virtual mem_intrf.TB_SIDE vif;

    // Mailboxes
    mailbox #(mem_transaction) gen2drv_mbx;
    mailbox #(int)             drv2gen_mbx;
   
    mailbox #(mem_transaction) mon2scb_mbx;
    mailbox #(int)             scb2mon_mbx;

    task run_env();
        // 1. Create mailboxes (bound size = 1 for back-pressure)
        gen2drv_mbx = new(1);
        drv2gen_mbx = new(1);
        
        mon2scb_mbx = new(1);
        scb2mon_mbx = new(1);
        
        // 2. Create components
        gen = new();
        drv = new();
        mon = new();
        scb = new();
        mon.drv_done_e = drv.drv_done_e;
        // 3. Connect Mailboxes to components
        gen.gen2drv_mbx = gen2drv_mbx;
        gen.drv2gen_mbx = drv2gen_mbx;
       
        drv.gen2drv_mbx = gen2drv_mbx;
        drv.drv2gen_mbx = drv2gen_mbx;

        mon.mon2scb_mbx = mon2scb_mbx;
        mon.scb2mon_mbx = scb2mon_mbx;

        
        scb.mon2scb_mbx = mon2scb_mbx;
        scb.scb2mon_mbx = scb2mon_mbx;

        // 4. Share virtual interface
        drv.vif = vif;
        mon.vif = vif;

        // 5. Fork all tasks concurrently
        fork
            gen.run_generator();
            drv.run_driver();
            mon.run_monitor();
            scb.run_scoreboard();
            
        join_any

        // Wait extra time after generator finishes, then finish
        @(posedge vif.clk);
        @(posedge vif.clk);
        scb.report();
        $stop;
    endtask
endclass

endpackage