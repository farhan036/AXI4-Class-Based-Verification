package axi_driver_pkg;
import axi_pkg::*;
import axi_transaction_pkg::*;
class axi_driver;
    virtual AXI_intrf.TB_side vif;
    //MailBoxes
    mailbox #(axi_transaction) gen2drv_mbx;
    mailbox #(int) drv2gen_mbx;

    // --- Control signals --------
    shortint    i = 0;
    task run_driver();

    axi_transaction txn;

    forever begin
        if(i < 2) 
        begin                                 
            @(negedge vif.ACLK);                        
            vif.ARESETn     <= 1'b0;                    
        end                                             
        else 
        begin
        if (i == 2) 
        begin
        vif.ARESETn <= 1'b1;
        @(negedge vif.ACLK);
        end                                      
            

            gen2drv_mbx.get(txn);
            vif.ARESETn <= txn.ARESETn;   
        @(negedge vif.ACLK);

        if(!vif.ARESETn)
        begin
            // Reset all outputs
            vif.AWREADY <= 1'b1;  // Ready to accept address
            vif.WREADY <= 1'b0;
            vif.BVALID <= 1'b0;
            vif.BRESP <= 2'b00;
            
            vif.ARREADY <= 1'b1;  // Ready to accept address
            vif.RVALID <= 1'b0;
            vif.RRESP <= 2'b00;
            vif.RDATA <= {DATA_WIDTH{1'b0}};
            vif.RLAST <= 1'b0;
        end
        else
        begin
            case (txn.op)
                WRITE: begin
                    @(negedge vif.ACLK);
                    vif.AWVALID <= txn.AWVALID;
                    vif.AWADDR  <= txn.AWADDR;
                    vif.AWLEN   <= txn.AWLEN;
                    vif.AWSIZE  <= 'd2;

                    while (!vif.AWREADY)
                        @(posedge vif.ACLK);

                    @(negedge vif.ACLK);
                    vif.AWVALID <= 0;

                    $display("WDATA size = %0d", txn.WDATA.size());

                    foreach (txn.WDATA[i]) begin

                        @(negedge vif.ACLK);                                          // Commented: Delay insertion.

                        vif.WVALID <= 1;
                        vif.BREADY <= 1;
                        vif.WLAST  <= (i == txn.WDATA.size()-1);
                        vif.WDATA  <= txn.WDATA[i];

                        while (!vif.WREADY)
                            @(posedge vif.ACLK);

                        @(negedge vif.ACLK);
                        vif.WVALID <= 0;
                        vif.WLAST  <= 0;

                    end

                    while (!vif.BVALID)
                        @(posedge vif.ACLK);
                    txn.BRESP = vif.BRESP;
                    
                    @(negedge vif.ACLK);      // keep this — don't remove it   -- removed for sim cases
                    // #50ps;
                    vif.BREADY <= 0;
                    
                end

                READ: begin
                    @(negedge vif.ACLK);
                    //repeat(2) @(posedge vif.ACLK);
                    vif.ARADDR  <= txn.ARADDR;
                    vif.ARLEN   <= txn.ARLEN;
                    vif.ARVALID <= txn.ARVALID;
                    vif.ARSIZE  <= 'd2;
                    vif.AWVALID <= txn.AWVALID;
                    vif.AWADDR  <= txn.AWADDR;
                    vif.AWLEN   <= txn.AWLEN;
                    vif.AWSIZE  <= 'd2;
                    
                    while (!vif.ARREADY)
                        @(posedge vif.ACLK);

                    @(negedge vif.ACLK);            // making it with negative edge not the positive edge
                    vif.ARVALID <= 0;

                    txn.RDATA = new[txn.ARLEN+1];

                    foreach (txn.RDATA[i]) begin

                    @(negedge vif.ACLK);
                    vif.RREADY <= 1;

                    while (!vif.RVALID)
                        @(negedge vif.ACLK);

                    txn.RDATA[i] = vif.RDATA;
                    txn.RRESP    = vif.RRESP;              // capture response while you're here

                    
                end

                    @(negedge vif.ACLK);
                    vif.RREADY <= 0;
                    
                end
                IDLE: begin
                    @(negedge vif.ACLK);

                    vif.AWVALID <= txn.AWVALID;
                    vif.WVALID  <= 0;
                    vif.BREADY  <= 0;
                    vif.AWADDR  <= txn.AWADDR;
                    vif.AWLEN   <= txn.AWLEN;
                    vif.AWSIZE  <= 'd2;

                    vif.ARVALID <= txn.ARVALID;
                    vif.RREADY  <= 0;
                    vif.WLAST   <= 0;
                    vif.ARADDR  <= txn.ARADDR;
                    vif.ARLEN   <= txn.ARLEN;
                    vif.ARSIZE  <= 'd2;

                    @(posedge vif.ACLK);

                end

            endcase
        end
            drv2gen_mbx.put(1);
        end             // new
        i = i + 1;      // new
    end
endtask
endclass 
endpackage