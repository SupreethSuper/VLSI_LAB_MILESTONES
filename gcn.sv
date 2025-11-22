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
  input logic clk,
  input logic reset,
  input logic start,
  input logic [WEIGHT_WIDTH-1:0] data_in [0:WEIGHT_ROWS-1],    // Feature matrix or weight matrix data
  input logic [COO_BW - 1:0] coo_in [0:1],                     // COO edges: row[0]=src, row[1]=dst

  output logic [COO_BW - 1:0] coo_address,                     // The column of the COO Matrix 
  output logic [ADDRESS_WIDTH-1:0] read_address,               // Address for feature/weight data
  output logic enable_read,                                    // Read enable signal
  output logic done,                                           // Asserted when all steps finish
  output logic [MAX_ADDRESS_WIDTH-1:0] max_addi_answer [0:FEATURE_ROWS-1] // Argmax result
);

  // Memory registers
  logic [FEATURE_WIDTH-1:0] feature_matrix [0:FEATURE_ROWS-1][0:FEATURE_COLS-1];
  logic [WEIGHT_WIDTH-1:0] weight_matrix [0:WEIGHT_ROWS-1];
  logic [DOT_PROD_WIDTH-1:0] fm_wm_matrix [0:FEATURE_ROWS-1][0:WEIGHT_COLS-1]; // Intermediate matrix
  logic [DOT_PROD_WIDTH-1:0] comb_matrix [0:FEATURE_ROWS-1][0:WEIGHT_COLS-1];  // After adjacency sum

  // Control registers/states
  typedef enum logic [2:0] {IDLE, LOAD_FEAT, LOAD_WT, MULT_FM_WM, COMB_ADJ, ARGMAX, ALL_DONE} state_t;
  state_t state, next_state;
  integer i, j, k;

  // COO edge iterators
  integer coo_idx;

  // Temp maximums/argmax for each node
  logic [DOT_PROD_WIDTH-1:0] maxval [0:FEATURE_ROWS-1];
  logic [MAX_ADDRESS_WIDTH-1:0] maxidx [0:FEATURE_ROWS-1];

  // Output wires
  assign coo_address     = (state == COMB_ADJ) ? coo_idx : '0;
  assign read_address    = '0; // no bursting in this demo design, tie low or expand for burst read
  assign enable_read     = (state == LOAD_FEAT || state == LOAD_WT);
  assign max_addi_answer = maxidx;

  // Main FSM
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      done  <= 1'b0;
      for (i = 0; i < FEATURE_ROWS; i = i + 1) begin
        for (j = 0; j < WEIGHT_COLS; j = j + 1) begin
          fm_wm_matrix[i][j] <= '0;
          comb_matrix[i][j]  <= '0;
        end
        maxval[i] <= '0;
        maxidx[i] <= '0;
      end
      coo_idx <= 0;
    end else begin
      state <= next_state;
      // State actions:
      case (state)
        IDLE: begin
          done <= 0;
        end
        LOAD_FEAT: begin
          // Load feature matrix directly from data_in (use only up to FEATURE_COLS/FEATURE_ROWS slots)
          for (i = 0; i < FEATURE_ROWS; i = i + 1)
            for (j = 0; j < FEATURE_COLS; j = j + 1)
              feature_matrix[i][j] <= data_in[j];
        end
        LOAD_WT: begin
          for (i = 0; i < WEIGHT_ROWS; i = i + 1)
            weight_matrix[i] <= data_in[i];
        end
        MULT_FM_WM: begin
          for (i = 0; i < FEATURE_ROWS; i = i + 1) begin
            for (j = 0; j < WEIGHT_COLS; j = j + 1) begin
              fm_wm_matrix[i][j] <= '0;
              for (k = 0; k < FEATURE_COLS; k = k + 1) begin
                fm_wm_matrix[i][j] <= fm_wm_matrix[i][j] +
                  feature_matrix[i][k] * weight_matrix[k*WEIGHT_COLS+j]; // mapping flat weight matrix
              end
            end
          end
        end
        COMB_ADJ: begin
          // For each edge, accumulate the source row into the destination row
          for (coo_idx = 0; coo_idx < COO_NUM_OF_COLS; coo_idx = coo_idx + 1) begin
            logic [COO_BW-1:0] src, dst;
            src = coo_in[0];
            dst = coo_in[1];
            for (j = 0; j < WEIGHT_COLS; j = j + 1)
              comb_matrix[dst][j] <= comb_matrix[dst][j] + fm_wm_matrix[src][j];
          end
        end
        ARGMAX: begin
          for (i = 0; i < FEATURE_ROWS; i = i + 1) begin
            maxval[i] = comb_matrix[i][0];
            maxidx[i] = 0;
            for (j = 1; j < WEIGHT_COLS; j = j + 1) begin
              if (comb_matrix[i][j] > maxval[i]) begin
                maxval[i] = comb_matrix[i][j];
                maxidx[i] = j[MAX_ADDRESS_WIDTH-1:0];
              end
            end
          end
        end
        ALL_DONE: begin
          done <= 1'b1;
        end
      endcase
    end
  end

  // Next state logic
  always_comb begin
    next_state = state;
    case (state)
      IDLE:      if (start) next_state = LOAD_FEAT;
      LOAD_FEAT: next_state = LOAD_WT;
      LOAD_WT:   next_state = MULT_FM_WM;
      MULT_FM_WM:next_state = COMB_ADJ;
      COMB_ADJ:  next_state = ARGMAX;
      ARGMAX:    next_state = ALL_DONE;
      ALL_DONE:  next_state = ALL_DONE;
    endcase
  end

endmodule
