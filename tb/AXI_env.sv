package AXI_env_pkg;

    import axi_pkg::*;
    import axi_transaction_pkg::*;
    import axi_generator_pkg::*;
    import axi_driver_pkg::*;
    import AXI_monitor_pkg::*;
    import AXI_scoreboard_pkg::*;

    class AXI_env;

        // --- Components --------
        axi_generator   gen;
        axi_driver      drv;
        AXI_monitor     mon;
        AXI_scoreboard  scb;

        // --- Virtual interface --------
        virtual AXI_intrf.TB_side   vif;

        // --- Mail boxes --------
        // -- GEN to DRV --------
        mailbox #(axi_transaction)  gen2drv_mbx;
        mailbox #(int)              drv2gen_mbx;

        // -- MON to SCB --------
        mailbox #(axi_transaction)  mon2scb_mbx;
        mailbox #(int)              scb2mon_mbx;

        // -- GEN to SCB --------
        // mailbox #(axi_transaction)  gen2scb_mbx;
        // mailbox #(int)              scb2gen_mbx;

        task run_env();

            // --- Mail boxes creation --------
            gen2drv_mbx = new(1);
            drv2gen_mbx = new(1);
            mon2scb_mbx = new(1);
            scb2mon_mbx = new(1);
            // gen2scb_mbx = new(1);
            // scb2gen_mbx = new(1);

            // --- Components creation --------
            gen         = new();
            drv         = new();
            mon         = new();
            scb         = new();

            // --- Wiring generator mail boxes --------
            gen.gen2drv_mbx     = gen2drv_mbx;
            gen.drv2gen_mbx     = drv2gen_mbx;
            // gen.gen2scb_mbx     = gen2scb_mbx;
            // gen.scb2gen_mbx     = scb2gen_mbx;

            // --- Wiring driver mail boxes --------
            drv.gen2drv_mbx     = gen2drv_mbx;
            drv.drv2gen_mbx     = drv2gen_mbx;

            // --- Wiring monitor mail boxes --------
            mon.mon2scb_mbx     = mon2scb_mbx;
            mon.scb2mon_mbx     = scb2mon_mbx;

            // --- Wiring scoreboard mail boxes --------
            scb.mon2scb_mbx     = mon2scb_mbx;
            scb.scb2mon_mbx     = scb2mon_mbx;
            // scb.gen2scb_mbx     = gen2scb_mbx;
            // scb.scb2gen_mbx     = scb2gen_mbx;

            // --- Sharing the virtual interface --------
            drv.vif     = vif;
            mon.vif     = vif;
            //scb.vif     = vif;

            // --- Fork all tasks --------
            fork
                gen.run_gen();
                drv.run_driver();
                mon.run_monitor();
                scb.run_scoreboard();
            join_any

            // --- Waiting 2 cycles before finish --------
            @(posedge vif.ACLK);
            @(posedge vif.ACLK);

            scb.sum_report();
            $stop;
        endtask
    endclass
endpackage