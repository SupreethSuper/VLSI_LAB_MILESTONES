`timescale 1ns/1ps

module tb_FM_WM_feeder;

  // ----------------------------
  // Parameters (match DUT)
  // ----------------------------
  localparam FEATURE_ROWS   = 6;
  localparam WEIGHT_COLS    = 3;
  localparam DOT_PROD_WIDTH = 16;
  localparam ADDRESS_WIDTH  = 13;
  localparam FEATURE_WIDTH  = $clog2(FEATURE_ROWS);
  localparam WEIGHT_ROWS    = 96;
  localparam WEIGHT_WIDTH   = 5;

  // ----------------------------
  // DUT signals
  // ----------------------------
  logic clk;
  logic rst;
  logic start;

  logic [WEIGHT_WIDTH-1:0] weight_col_out_feeder [0:WEIGHT_ROWS-1];
  logic [WEIGHT_WIDTH-1:0] data_in_b             [0:WEIGHT_ROWS-1];

  logic [DOT_PROD_WIDTH-1:0] feeder_output;
  logic [WEIGHT_WIDTH-1:0] col_num;
  logic [FEATURE_WIDTH-1:0] row_num;

  // ----------------------------
  // DUT
  // ----------------------------
  FM_WM_feeder #(
    .FEATURE_ROWS(FEATURE_ROWS),
    .WEIGHT_COLS(WEIGHT_COLS),
    .DOT_PROD_WIDTH(DOT_PROD_WIDTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .FEATURE_WIDTH(FEATURE_WIDTH),
    .WEIGHT_ROWS(WEIGHT_ROWS),
    .WEIGHT_WIDTH(WEIGHT_WIDTH)
  ) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .weight_col_out_feeder(weight_col_out_feeder),
    .data_in_b(data_in_b),
    .feeder_output(feeder_output),
    .col_num(col_num),
    .row_num(row_num)
  );

  // ----------------------------
  // Clock
  // ----------------------------
  always #5 clk = ~clk;

  // ----------------------------
  // Golden model
  // ----------------------------
  integer k;
  int golden_sum;

  task automatic compute_expected;
    begin
      golden_sum = 0;
      for (k = 0; k < WEIGHT_ROWS; k++)
        golden_sum += weight_col_out_feeder[k] * data_in_b[k];
    end
  endtask

  // ----------------------------
  // Stimulus
  // ----------------------------
  initial begin
    $display("\n---- HW-AWARE TESTBENCH START ----");

    clk = 0;
    rst = 1;
    start = 0;

    // Init vectors
    for (int i = 0; i < WEIGHT_ROWS; i++) begin
      weight_col_out_feeder[i] = i % 8;
      data_in_b[i]             = (i + 1) % 4;
    end

    // Release reset
    #20 rst = 0;

    // Compute expected once per run
    compute_expected();
    $display("EXPECTED DOT PRODUCT = %0d", golden_sum);

    // Start is ALWAYS HIGH
    start = 1;

    // Run long enough for multiple passes
    #(WEIGHT_ROWS * 15);

    $display("\n---- SIMULATION COMPLETE ----");
    $stop;
  end

  // ----------------------------
  // FSM-AWARE MONITOR
  // ----------------------------
  logic [$clog2(WEIGHT_ROWS)-1:0] last_row;
  int pass_count = 0;

  always @(posedge clk) begin
    // Detect vector completion (row wraps)
    if (row_num == 0 && last_row == WEIGHT_ROWS-1) begin
      if (feeder_output === golden_sum) begin
        $display("✅ PASS #%0d at T=%0t | Output=%0d",
                  ++pass_count, $time, feeder_output);
      end
      else begin
        $error("❌ FAIL at T=%0t | Got=%0d Expected=%0d",
                $time, feeder_output, golden_sum);
      end
    end
    last_row <= row_num;
  end

  // ----------------------------
  // Debug Monitor (optional)
  // ----------------------------
  always @(posedge clk) begin
    $display("T=%0t | row=%0d col=%0d | out=%0d | start=%b",
              $time, row_num, col_num, feeder_output, start);
  end

endmodule
