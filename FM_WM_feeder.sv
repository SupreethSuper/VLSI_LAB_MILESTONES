module FM_WM_feeder 
  #(parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS = 3,
    parameter DOT_PROD_WIDTH = 16,
    parameter ADDRESS_WIDTH = 13,
    parameter FEATURE_WIDTH = $clog2(FEATURE_ROWS),
    parameter WEIGHT_ROWS = 96,
    parameter WEIGHT_WIDTH = 5,
    parameter COO_NUM_OF_COLS = 6,
    parameter COO_NUM_OF_ROWS = 2,
    parameter COO_BW = $clog2(COO_NUM_OF_COLS)    
)

(
     input  logic [WEIGHT_WIDTH-1:0] weight_col_out_feeder [0:WEIGHT_ROWS-1],             // {src,dst} for current column

    input logic [WEIGHT_WIDTH-1:0] data_in_b     [0:WEIGHT_ROWS-1],
    input logic clk,
    input logic rst,
    input logic start,
    output logic [DOT_PROD_WIDTH - 1 : 0] feeder_output,
    // output logic complete_flag,
    output logic [WEIGHT_WIDTH - 1 : 0] col_num,
    output logic [FEATURE_WIDTH -1 : 0] row_num
);

    logic [WEIGHT_WIDTH - 1 : 0] col_num_writer;
    logic [FEATURE_WIDTH -1 : 0] row_num_writer;
    // logic flag_handler;
    logic [2 : 0] state_machine_handler;
    logic torch;

    logic [$clog2(COO_NUM_OF_COLS)-1:0] i;
    logic [$clog2(WEIGHT_ROWS)-1:0] j;







    logic [DOT_PROD_WIDTH - 1 : 0] feeder_output_combi;

    logic [DOT_PROD_WIDTH - 1 : 0] mem_mult [0 : WEIGHT_ROWS - 1][0 : 1];

    localparam STATES = 5;
    localparam BIT_STATES = $clog2(STATES);
    localparam IDLE = 3'b000;
    localparam MULTIPLY = 3'b001;
    // localparam ADD = 3;b010;
    // localparam ROW_COL_ASSIGN = 3'b011;
    localparam DONE = 3'b100;


    // --------------------------------------------------------------------
    // FSM + datapath: nested loops over columns (i) and rows (j)
    // - reset is ACTIVE HIGH (per your requirement)
    // - j is inner loop (0..WEIGHT_ROWS-1)
    // - i is outer loop (0..COO_NUM_OF_COLS-1)
    // - accumulator cleared at start of each column
    // --------------------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Active-HIGH reset (you said reset is high)
            feeder_output_combi   <= '0;
            col_num_writer        <= '0;
            row_num_writer        <= '0;
            state_machine_handler <= IDLE; // legal starting state
            torch                 <= 1'b0;
            i                     <= '0;
            j                     <= '0;
        end else begin
            case (state_machine_handler)

                IDLE: begin
                    // Keep datapath registers stable; clear accumulator so column starts fresh
                    torch <= 1'b0;
                    feeder_output_combi <= '0;
                    // col_num_writer / row_num_writer retained from reset or last run
                    i <= '0;
                    j <= '0;

                    if (start) begin
                        torch <= 1'b1;
                        state_machine_handler <= MULTIPLY;
                    end
                end // IDLE

                MULTIPLY: begin
                    if (torch) begin
                        // If this is the first row of a column, zero the accumulator
                        if (j == 0)
                            feeder_output_combi <= '0 + (weight_col_out_feeder[j] * data_in_b[j]);
                        else
                            feeder_output_combi <= feeder_output_combi + (weight_col_out_feeder[j] * data_in_b[j]);

                        // update row/col writers for visibility
                        row_num_writer <= j;
                        col_num_writer <= i;

                        // advance inner loop (rows)
                        if (j == WEIGHT_ROWS - 1) begin
                            // finished this column
                            if (i == (COO_NUM_OF_COLS - 1)) begin
                                // finished all columns
                                state_machine_handler <= DONE;
                                // keep feeder_output_combi holding last column's result
                            end else begin
                                // move to next column: increment i, reset j
                                i <= i + 1;
                                j <= 0;
                                // accumulator will be cleared next cycle by the j==0 path
                            end
                        end else begin
                            // continue scanning rows for current column
                            j <= j + 1;
                        end
                    end
                end // MULTIPLY

                DONE: begin
                    torch <= 1'b0;
                    // Optionally hold the result for one cycle, then go back to IDLE to allow restart
                    state_machine_handler <= IDLE;
                end

                default: begin
                    torch <= 1'b0;
                    state_machine_handler <= IDLE;
                end

            endcase
        end
    end




    assign col_num = col_num_writer;
    assign row_num = row_num_writer;
    // assign complete_flag = flag_handler;
    assign feeder_output = feeder_output_combi;
    // assign FSM_ops = state_machine_handler;

    






endmodule