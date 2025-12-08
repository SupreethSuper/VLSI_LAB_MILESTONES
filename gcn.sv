module GCN
  #(parameter FEATURE_COLS = 96,
    parameter WEIGHT_ROWS = 96,
    parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS = 3,
    parameter FEATURE_WIDTH = 5,
    parameter WEIGHT_WIDTH = 5,
    parameter DOT_PROD_WIDTH = 16,
    parameter ADDRESS_WIDTH = 13,
    parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS),
    parameter MAX_ADDRESS_WIDTH = 2,
    parameter NUM_OF_NODES = 6,			 
    parameter COO_NUM_OF_COLS = 6,			
    parameter COO_NUM_OF_ROWS = 2,			
    parameter COO_BW = $clog2(COO_NUM_OF_COLS)	
)
(
  input logic clk,	// Clock
  input logic reset,	// Reset 
  input logic start,
  input logic [WEIGHT_WIDTH-1:0] data_in [0:WEIGHT_ROWS-1], //FM and WM Data
  input logic [COO_BW - 1:0] coo_in [0:1], //row 0 and row 1 of the COO Stream

  output logic [COO_BW - 1:0] coo_address, // The column of the COO Matrix 
  output logic [ADDRESS_WIDTH-1:0] read_address, // The Address to read the FM and WM Data
  output logic enable_read, // Enabling the Read of the FM and WM Data
  output logic done, // Done signal indicating that all the calculations have been completed
  output logic [MAX_ADDRESS_WIDTH - 1:0] max_addi_answer [0:FEATURE_ROWS - 1] // The answer to the argmax and matrix multiplication 
); 


  logic [WEIGHT_WIDTH-1:0] weight_col_out_to_feeder [0:WEIGHT_ROWS-1] 
  logic [DOT_PROD_WIDTH - 1 : 0] feeder_output_to_fm_wm; 
  logic handover_flag;
  logic sc_pad_auth;
  logic enable_write_fm_wm_prod_auth;
  logic [FEATURE_WIDTH-1:0] write_to_row_num;
  logic [WEIGHT_WIDTH-1:0] write_to_col_num;

 Transformation_FSM Master_FSM(
  .clk(clk), .reset(reset), .start(start),
  .weight_count(data_in), .feature_count(coo_in),
  .enable_scratch_pad(sc_pad_auth), 
  .enable_write_fm_wm_prod(enable_write_fm_wm_prod_auth)
 );

 Scratch_Pad #(
  .WEIGHT_ROWS(WEIGHT_ROWS),
  .WEIGHT_WIDTH(WEIGHT_WIDTH)
 )


//scratch pad  done
 scratch_Pad_gcn(
    .clk(clk),
    .reset(reset),
    .write_enable(sc_pad_auth),
    .weight_col_in(data_in),
    .weight_col_out(weight_col_out_to_feeder)
 );

  FM_WM_feeder fm_wm_multiply_ops (
    .weight_col_out_feeder(weight_col_out_to_feeder),
    .data_in_b(data_in),
    .feeder_output(feeder_output_to_fm_wm),
    .clk(clk), .rst(reset), .start(enable_write_fm_wm_prod_auth),
    .col_num(write_to_col_num), .row_num(write_to_row_num)

  );










  










endmodule