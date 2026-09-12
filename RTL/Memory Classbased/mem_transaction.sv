package mem_transaction_pkg;
  import parameters_pkg::*;

  class mem_transaction;
    rand    logic rst_n;
    rand    logic mem_en;
    rand    logic mem_we;
    randc   logic [ADDR_WIDTH-1:0] mem_addr;
    rand    logic [DATA_WIDTH-1:0] mem_wdata;
    logic [DATA_WIDTH-1:0] mem_rdata; //sample

    // 1. Reset distribution 
    constraint rst_dist_c {
      rst_n dist {
        0 := 5,
        1 := 95
      };
    }

    // 2. Memory Enable distribution (Active high: enabled most of the time)
    constraint mem_en_dist_c {
      mem_en dist {
        1 := 90,
        0 := 10
      };
    }

    // 3. Write/Read balance when memory is enabled
    constraint mem_we_dist_c {
      mem_we dist {
        1 := 50,
        0 := 50
      };
    }

    // 4. Memory Address range constraint
    constraint mem_addr_range_c {mem_addr inside {[0 : DEPTH - 1]};}

    covergroup cg;
      // 1. Reset Transitions & States
      cp_rst_n: coverpoint rst_n;

      // 2. Memory Enable States & Transitions
      cp_mem_en: coverpoint mem_en;

      // 3. Write / Read Operation
      cp_mem_we: coverpoint mem_we {
        bins read_op = {1'b0};
        bins write_op = {1'b1};
        bins wr_to_rd = (1'b1 => 1'b0);
        bins rd_to_wr = (1'b0 => 1'b1);
      }
    endgroup

    function new();
      cg = new();
    endfunction

    function void display_transaction(input string tag = "TXN");

      string op_type;

      if (!rst_n) op_type = "RESET";
      else if (!mem_en) op_type = "IDLE";
      else if (mem_we) op_type = "WRITE";
      else op_type = "READ";

      $display("[%0t][%s] OP=%s | EN=%0b WE=%0b ADDR=0x%03h WDATA=0x%08h | RDATA=0x%08h", $time,
               tag, op_type, mem_en, mem_we, mem_addr, mem_wdata, mem_rdata);
    endfunction
  endclass
endpackage
