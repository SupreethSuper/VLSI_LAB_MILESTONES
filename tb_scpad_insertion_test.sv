`timescale 1ps/1ps

module tb_scpad_insertion_test  #(parameter FEATURE_COLS = 96,
    parameter WEIGHT_ROWS  = 96,
    parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS  = 3,
    parameter FEATURE_WIDTH = 5,
    parameter WEIGHT_WIDTH  = 5,
    parameter DOT_PROD_WIDTH = 16,
    parameter ADDRESS_WIDTH = 13,
    parameter COUNTER_WEIGHT_WIDTH  = $clog2(WEIGHT_COLS),
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS),
    parameter MAX_ADDRESS_WIDTH = 2,
    parameter NUM_OF_NODES   = 6,
    parameter COO_NUM_OF_COLS = 6,
    parameter COO_NUM_OF_ROWS = 2,
    parameter COO_BW = $clog2(COO_NUM_OF_COLS)
)

();

	logic clk;		// Clock
	logic reset;		// Dut Reset
	logic start;		// Start Signal: This is asserted in the testbench
	logic done;		// All the Calculations are do

  logic read_enable;
  logic write_enable;    
  logic [WEIGHT_WIDTH-1:0] data_in [0:WEIGHT_ROWS-1];
    logic [COO_BW-1:0]       coo_in  [0:1];
     logic [COO_BW-1:0]       coo_address;
     logic [ADDRESS_WIDTH-1:0] read_address;
     logic                    enable_read;
     logic [MAX_ADDRESS_WIDTH-1:0] max_addi_answer [0:FEATURE_ROWS-1];



    GCN dut(
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .read_enable(read_enable),
        .data_in(data_in),
        .coo_in(coo_in),
        .read_address(read_address),
        .enable_read(enable_read),
        .max_addi_answer(max_addi_answer)
    );

    initial clk = '0;
    initial begin
        reset = 1'b1;
        #0.5;
        reset = 1'b0;
        #1 start = 1'b1;
    end

    always begin
        clk = ~clk;
        #1;
    end

    always begin
        for(i = 0; i < 1; i++) begin
            coo_in[i]
        end
    end











endmodule