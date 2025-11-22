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

logic counter

scratchpad #(
    .WEIGHT_WIDTH(WEIGHT_WIDTH),
    .WEIGHT_ROWS(WEIGHT_ROWS),   // <- important
    .WEIGHT_COLS(WEIGHT_COLS)
) sc (
    .data_in(scratchpad_in),
    .data_out(scratchpad_out)
);


always_comb begin


end

endmodule
