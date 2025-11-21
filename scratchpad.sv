module scratchpad 
#(
    parameter WEIGHT_WIDTH = 5,
    parameter WEIGHT_ROWS = 96,
    parameter WEIGHT_COLS   = 3
)

(
    input logic [WEIGHT_WIDTH - 1 : 0] data_in [0 : WEIGHT_ROWS - 1],
    output logic [WEIGHT_WIDTH - 1 : 0] data_out [0 : WEIGHT_ROWS - 1]
);

always_comb begin
    for (int i = 0; i < WEIGHT_ROWS; i++) begin
        data_out[i] = data_in[i];
    end
end


endmodule