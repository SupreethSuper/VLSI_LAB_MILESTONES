module GCN
  #(parameter FEATURE_COLS = 96,
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
(
  // control
  input  logic clk,
  input  logic reset,
  input  logic start,

  // data in from TB
  input  logic [WEIGHT_WIDTH-1:0] data_in [0:WEIGHT_ROWS-1], // feature/weight column
  input  logic [COO_BW-1:0]       coo_in  [0:1],             // {src,dst} for current column

  // address/control back to TB
  output logic [COO_BW-1:0]       coo_address,
  output logic [ADDRESS_WIDTH-1:0] read_address,
  output logic                    enable_read,
  output logic                    done,

  // final argmax
  output logic [MAX_ADDRESS_WIDTH-1:0] max_addi_answer [0:FEATURE_ROWS-1]
);

  logic [WEIGHT_WIDTH-1:0] weight_col_out_to_feeder [0:WEIGHT_ROWS-1] 
  logic [DOT_PROD_WIDTH - 1 : 0] feeder_output_to_fm_wm; 
 Scratch_Pad #(
  .WEIGHT_ROWS(WEIGHT_ROWS),
  .WEIGHT_WIDTH(WEIGHT_WIDTH)
 )

 scratch_Pad_gcn(
    .clk(clk),
    .reset(reset),
    .write_enable(start),
    .weight_col_in(data_in),
    .weight_col_out(weight_col_out_to_feeder)
 );

  FM_WM_feeder fm_wm_multiply_ops (
    .coo_in_a(weight_col_out_to_feeder),
    .data_in_b(data_in),
    .feeder_output(feeder_output_to_fm_wm)
  );

  










endmodule
