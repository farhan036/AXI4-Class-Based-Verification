package axi_transaction_pkg;
  import axi_pkg::*;
  class axi_transaction;
    rand logic                  ARESETn;
    rand logic [ADDR_WIDTH-1:0] AWADDR;
    rand logic [           7:0] AWLEN;
    logic      [           2:0] AWSIZE;
    rand logic                  AWVALID;
    logic                       AWREADY;
    // Write data channel
    rand logic [DATA_WIDTH-1:0] WDATA     [];
    logic      [DATA_WIDTH-1:0] WDATA_MON;
    logic                       WVALID;
    logic                       WLAST;
    logic                       WREADY;

    // Write response channel
    logic      [           1:0] BRESP;
    logic                       BVALID;
    logic                       BREADY;

    // Read address channel
    rand logic [ADDR_WIDTH-1:0] ARADDR;
    rand logic [           7:0] ARLEN;
    logic      [           2:0] ARSIZE;
    rand logic                  ARVALID;
    logic                       ARREADY;

    // Read data channel
    logic      [DATA_WIDTH-1:0] RDATA     [];
    logic      [DATA_WIDTH-1:0] RDATA_MON;
    logic      [           1:0] RRESP;
    logic                       RVALID;
    logic                       RLAST;
    logic                       RREADY;


    rand logic [1:0] addr_mode;
    rand logic  len_mode;
    rand op_t                   op;

    constraint operation {
      op dist {
        WRITE := 35,
        READ  := 35,
        IDLE  := 30
      };
    }
    constraint rst
    {
      ARESETn dist {1:=95 , 0:=5};
    }

    constraint address_mode 
    {
      addr_mode dist {3:=10, 2:=20, 1:=40, 0:=30};
    }
    constraint length_mode 
    {
      len_mode dist { 1:=80, 0:=20};
    }

    constraint addr {
      if(addr_mode == 0)
      {
        AWADDR inside {[3211 : 4095]};
        ARADDR == AWADDR;
      }
      else if (addr_mode == 2'd1)
      {
        (AWADDR + ((AWLEN + 1) * 4)) <= 4096;
        ARADDR == AWADDR;  
      }
      else if (addr_mode == 2'd2) 
      {
        AWADDR inside {[4096 : 65536]};
        ARADDR == AWADDR;
      }
      else
      {
        AWADDR inside {2024};
        ARADDR == AWADDR;
      }
    }
    
    constraint burst_c {
      if(!len_mode)
      {
        AWLEN inside {[0:$]};
      }
      else
      {
        AWLEN inside {0};
      }
      WDATA.size() == AWLEN + 1;
      ARLEN == AWLEN;
    }
    
    constraint valid {
      if (op == WRITE) {
        AWVALID == 1;
        ARVALID == AWVALID; // To check Write is High Periority
      } else
      if (op == READ) {
        AWVALID == 0;
        ARVALID != AWVALID;
      } else {
        AWVALID == 0;
        ARVALID == 0;
      }
    }

    covergroup cg;

        cp_awaddr: coverpoint AWADDR {
            bins low_addr  = {[0 : 1023]};
            bins mid_addr  = {[1024 : 3071]};
            bins high_addr = {[3072 : 4095]};
        }

        cp_awlen: coverpoint AWLEN {
            bins len_single = {0};                 // Single beat
            bins len_short  = {[1 : 15]};          // Short burst
            bins len_med    = {[16 : 127]};        // Medium burst
            bins len_max    = {[128 : 255]};       // Long burst
        }


        cp_araddr: coverpoint ARADDR {
            bins low_addr  = {[0 : 1023]};
            bins mid_addr  = {[1024 : 3071]};
            bins high_addr = {[3072 : 4095]};
        }

        cp_arlen: coverpoint ARLEN {
            bins len_single = {0};
            bins len_short  = {[1 : 15]};
            bins len_med    = {[16 : 127]};
            bins len_max    = {[128 : 255]};
        }

        cp_awvalid: coverpoint AWVALID;
        cp_arvalid: coverpoint ARVALID;
        cp_op: coverpoint op;
        cp_address_mode: coverpoint addr_mode {
            bins mode_0 = {0};
            bins mode_1 = {1};
            bins mode_2 = {2};
        }
        cp_op_mode:cross cp_op, cp_address_mode;
        cp_wadd_len:cross cp_awaddr, cp_awlen
        {
          bins low_singlelen = binsof(cp_awaddr.low_addr) && binsof(cp_awlen.len_single);
        }
        cp_radd_len:cross cp_araddr, cp_arlen
        {
          bins low_singlelen = binsof(cp_araddr.low_addr) && binsof(cp_arlen.len_single);
        }
        
    endgroup
    function new();
      cg = new();

    endfunction

    // Display  Method
    function void display_transaction(string tag = "TR");

      $display("\n====================================================");
      $display("[%s]    Transaction @ %0t", tag, $time);
      $display("----------------------------------------------------");

      // Write Address Channel
      $display("Write Address Channel");
      $display("  AWADDR  = 0x%0d", AWADDR / 4);
      $display("  AWLEN   = %0d", AWLEN);
      $display("  AWSIZE  = %0d", AWSIZE);
      $display("  AWVALID = %0b", AWVALID);
      $display("  AWREADY = %0b", AWREADY);

      // Write Data Channel
      $display("Write Data Channel");
      foreach (WDATA[i]) $display("  WDATA   = 0x%0h", WDATA[i]);
      $display("  WDATA_MON  = %0h", WDATA_MON);
      $display("  WVALID  = %0b", WVALID);
      $display("  WREADY  = %0b", WREADY);
      $display("  WLAST   = %0b", WLAST);

      // Write Response Channel
      $display("Write Response Channel");
      $display("  BRESP   = %0b", BRESP);
      $display("  BVALID  = %0b", BVALID);
      $display("  BREADY  = %0b", BREADY);

      // Read Address Channel
      $display("Read Address Channel");
      $display("  ARREADY = %0b", ARREADY);
      $display("  ARADDR  = 0x%0d", ARADDR / 4);
      $display("  ARLEN   = %0d", ARLEN);
      $display("  ARSIZE  = %0d", ARSIZE);
      $display("  ARVALID = %0b", ARVALID);
      $display("  ARREADY = %0b", ARREADY);

      // Read Data Channel
      $display("Read Data Channel");
      foreach (RDATA[j]) $display("  RDATA   = 0x%0h", RDATA[j]);
      $display("  RDATA_MON   = 0x%0h", RDATA_MON);
      $display("  RRESP   = %0b", RRESP);
      $display("  RVALID  = %0b", RVALID);
      $display("  RLAST   = %0b", RLAST);

      $display("====================================================\n");

    endfunction





  endclass
endpackage
