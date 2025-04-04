`timescale 1ns / 1ps

/*
 * This module contains the instantiation of a simple dual-port Block RAM with 
 * dual clocks. 
*/
module fifo_mem
#(
    parameter PIPELINE = 1,                                     //Determines whether an extra pipeline stage is implemented on read end
    parameter DATA_WIDTH = 8,
    parameter MEM_DEPTH = 64,
    parameter ADDR_BITS = $clog2(MEM_DEPTH)
)
(
    input wire i_wr_clk,                                        //Clock for the write domain
    input wire i_rd_clk,                                        //Clock for the reading domain
    
    /* Control Signals */
    input wire i_wr_en, i_rd_en,                                //Enables reading/writing in each domain
    input wire i_full,                                          //Indicates the pointers are full
    input wire i_empty,
    
    /* Data from the Memory */
    input wire [DATA_WIDTH-1:0] i_wr_data,                      
    output reg [DATA_WIDTH-1:0] o_rd_data,
    
    /* Addresses calculated by FIFO components */
    input wire [ADDR_BITS-1:0] i_wr_addr, i_rd_addr
);

/* Output BRAM reg used to improve timing budget */
reg [DATA_WIDTH-1:0] data_reg_pipeline = '0;

/* Inferred BRAM Declaration */
(* ram_style="block" *) reg [DATA_WIDTH-1:0] dual_port_ram [0:MEM_DEPTH-1];

// synthesis translate_off
initial begin
    //This is used for simulation - In hardware the BRAM will be initialized to all 0's
    for(int i = 0; i < MEM_DEPTH; i++) begin
        dual_port_ram[i] = {DATA_WIDTH{1'b0}};
    end
end
// synthesis translate_on

/* Synchronous Logic to write into Block RAM */
always@(posedge i_wr_clk) begin
    if(i_wr_en && !i_full) 
        dual_port_ram[i_wr_addr] <= i_wr_data;    
end

/////////////////////////////////////////////////////////////////////
// An extra FF is added on the read end of the FIFO to improve the timing
// budget. This FF should be inferred into the BRAM, and adds an extra 
// clock cycle delay of reading data out of the FIFO.
////////////////////////////////////////////////////////////////////////

generate 
    //If PIPELINE is enabled, add an extra pipeline stage on the read end 
    if(PIPELINE == 1) begin
        always @(posedge i_rd_clk) begin
            data_reg_pipeline <= dual_port_ram[i_rd_addr];
        end

        assign o_rd_data = data_reg_pipeline;
    //If PIPELINE is disabled, the read data should immediately fall through (FWFT)
    end else begin       
        always @(posedge i_rd_clk) begin
            if(i_rd_en & !i_empty)
                o_rd_data <= dual_port_ram[i_rd_addr];
        end           
    end             

endgenerate

endmodule
