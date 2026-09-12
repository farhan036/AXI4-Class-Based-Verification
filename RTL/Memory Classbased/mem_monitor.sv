package mem_monitor_pkg;
import mem_transaction_pkg::*;

class mem_monitor;
    virtual mem_intrf.TB_SIDE vif;
    event drv_done_e;
    mailbox #(mem_transaction) mon2scb_mbx;
    mailbox #(int)             scb2mon_mbx;    

    task run_monitor;

    mem_transaction sampled;
    int token;

    forever 
    begin
        @drv_done_e;
        sampled = new();
        sampled.mem_en    = vif.mem_en;    
        sampled.mem_we    = vif.mem_we;    
        sampled.mem_addr  = vif.mem_addr;    
        sampled.mem_wdata = vif.mem_wdata;
        sampled.rst_n     = vif.rst_n;
        @(posedge vif.clk);
        #10ps;
        sampled.mem_rdata = vif.mem_rdata;

        //sampled.display_transaction("MON");

        mon2scb_mbx.put(sampled);
        scb2mon_mbx.get(token);
    end
    endtask
endclass
endpackage