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

  logic [WEIGHT_WIDTH-1:0] weight_col_out_scratchpad [0:WEIGHT_ROWS-1];
  //logic [WEIGHT_WIDTH - 1 : 0] wight_col_read;
  logic [FEATURE_WIDTH - 1 : 0] write_row_matix;
  logic [FEATURE_WIDTH - 1 : 0] read_row_matrix;
  logic [WEIGHT_WIDTH-1:0] write_col_matrix;
  logic [DOT_PROD_WIDTH - 1:0] fm_wm_in_matrix;
  logic [DOT_PROD_WIDTH - 1:0] fm_wm_row_out_matrix  [0:WEIGHT_COLS-1];
  // logic counter_fw;
  // logic weight_width;
  logic [COO_BW - 1 : 0] coo_address_comb;
  logic [ADDRESS_WIDTH - 1 : 0] read_address_comb;
  logic [MAX_ADDRESS_WIDTH - 1 : 0] max_addi_answer_comb [0 : FEATURE_ROWS - 1];

  assign coo_address = coo_address_comb;
  assign read_address = read_address_comb;
  assign max_addi_answer = max_addi_answer_comb;


Scratch_Pad Scratch_Pad_inst
#(
  .WEIGHT_ROWS(WEIGHT_ROWS),
  .WEIGHT_WIDTH(WEIGHT_WIDTH)
)
(
  //control signals
  .clk(clk), .reset(reset), .write_enable(start),

  //input data
  .weight_col_in(data_in), 

  //output data
  .weight_col_out(weight_col_out_scratchpad) //we have to create a logic, that feeds to matric_fm_wm..
);

Matrix_FM_WM_Memory Matrix_FM_WM_Memory_inst
#(
  .FEATURE_ROWS(FEATURE_ROWS),
  .WEIGHT_COLS(WEIGHT_COLS),
  .DOT_PROD_WIDTH(DOT_PROD_WIDTH),
  .ADDRESS_WIDTH(ADDRESS_WIDTH),
  .WEIGHT_WIDTH(WEIGHT_WIDTH),
  .FEATURE_WIDTH(FEATURE_WIDTH)
)

(
  //control signals
  .clk(clk), .rst(reset), wr_en(start),

  //input data
  .write_row(write_row_matix),
  .write_col(write_col_matrix),
  .read_row(read_row_matrix),
  .fm_wm_in(fm_wm_in_matrix),
  .fm_wm_row_out(fm_wm_row_out_matrix)
);

//might delete this later

// always_comb begin : params_to_logic_assignments
//   counter_fw = COUNTER_FEATURE_WIDTH;
//   weight_Width = WEIGHT_WIDTH;
// end

  always_ff @(posedge clk or negedge reset) begin : matrix_and_weights_multiplication
    if(!reset) begin
      coo_address_comb <= '0;
      read_address_comb <= '0;

      for(int k = 0; k<FEATURE_ROWS; k++) begin
        max_addi_answer_comb[k] <= '0;
      end
    end
    
    

  end



endmodule
