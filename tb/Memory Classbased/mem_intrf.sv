interface mem_intrf 
    #(parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10,    // For 1024 locations
    parameter DEPTH = 1024) 
    (input logic clk);

    logic rst_n;
    logic                     mem_en;
    logic                     mem_we;
    logic [ADDR_WIDTH-1:0]    mem_addr;
    logic [DATA_WIDTH-1:0]    mem_wdata;
    logic  [DATA_WIDTH-1:0]   mem_rdata;


    modport TB_SIDE (input clk , mem_rdata,
    output rst_n , mem_en , mem_we , mem_addr , mem_wdata);
    
    modport DUT_SIDE (input clk , rst_n , mem_en , mem_we , mem_addr , mem_wdata,
    output mem_rdata);
    
endinterface 