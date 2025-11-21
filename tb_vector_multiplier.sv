module tb_vector_multiplier;

    // -----------------------------
    // Use smaller parameters for testing
    // -----------------------------
    localparam WEIGHT_WIDTH  = 5;
    localparam FEATURE_WIDTH = 8;
    localparam FEATURE_ROWS  = 6;
    localparam WEIGHT_ROWS   = 6;
    localparam FEATURE_COLS  = 6;
    localparam WEIGHT_COLS   = 3;

    // -----------------------------
    // Testbench signals
    // -----------------------------
    logic [WEIGHT_WIDTH-1:0]  scratchpad_in  [0:WEIGHT_ROWS-1];
    logic [FEATURE_WIDTH-1:0] features_in     [0:FEATURE_ROWS-1];
    logic [FEATURE_WIDTH-1:0] vector_mul_out  [0:FEATURE_ROWS-1];

    // -----------------------------
    // Instantiate DUT
    // -----------------------------
    vector_multiplier #(
        .WEIGHT_WIDTH (WEIGHT_WIDTH),
        .FEATURE_WIDTH(FEATURE_WIDTH),
        .FEATURE_COLS (FEATURE_COLS),
        .WEIGHT_ROWS  (WEIGHT_ROWS),
        .FEATURE_ROWS (FEATURE_ROWS),
        .WEIGHT_COLS  (WEIGHT_COLS)
    ) uut (
        .scratchpad_in (scratchpad_in),
        .features_in   (features_in),
        .vector_mul_out(vector_mul_out)
    );

    // -----------------------------
    // Stimulus
    // -----------------------------
    initial begin
        // Initialize inputs
        for (int i = 0; i < WEIGHT_ROWS; i++) begin
            scratchpad_in[i] = i;   // 0,1,2,3,4,5
            $display("scratchpad_in[%0d] = %0d", i, scratchpad_in[i]);
        end

        for (int j = 0; j < FEATURE_ROWS; j++) begin
            features_in[j] = j + 10; // 10,11,12,13,14,15
            $display("features_in[%0d] = %0d", j, features_in[j]);
        end

        #5;

        // Print output
        $display("\nvector_mul_out:");
        for (int k = 0; k < FEATURE_ROWS; k++) begin
            $display("vector_mul_out[%0d] = %0d", k, vector_mul_out[k]);
        end

        #10;
        $finish;
    end

endmodule
