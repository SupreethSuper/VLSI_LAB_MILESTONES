module vector_multiplier
#(
    parameter WEIGHT_WIDTH = 5,
    parameter FEATURE_WIDTH = 8,
    parameter FEATURE_COLS = 96,
    parameter WEIGHT_ROWS = 96,
    parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS = 3
)
(
    input  logic [WEIGHT_WIDTH - 1 : 0] scratchpad_in [0 : WEIGHT_ROWS - 1],
    input  logic [FEATURE_WIDTH - 1 : 0] features_in  [0 : FEATURE_ROWS - 1],
    output logic [FEATURE_WIDTH - 1 : 0] vector_mul_out [0 : FEATURE_ROWS - 1]
);

logic [FEATURE_WIDTH - 1 : 0] mac_unit [0 : FEATURE_ROWS - 1];

// FIXED: separate output bus
logic [WEIGHT_WIDTH - 1 : 0] scratchpad_out [0 : WEIGHT_ROWS - 1];

scratchpad sc (
    .data_in (scratchpad_in),
    .data_out(scratchpad_out)
);

always_comb begin
    for (int i = 0; i < FEATURE_ROWS; i++) begin
        mac_unit[i] = features_in[i];
        vector_mul_out[i] = mac_unit[i];
    end
end

endmodule
