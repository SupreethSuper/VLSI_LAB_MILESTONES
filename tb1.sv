module tb1;

    localparam WEIGHT_WIDTH = 5;
    localparam WEIGHT_ROWS  = 6;   // smaller for easy printing
    localparam WEIGHT_COLS  = 3;   // smaller for easy printing

    logic [WEIGHT_WIDTH-1:0] data_in  [0:WEIGHT_ROWS-1];
    logic [WEIGHT_WIDTH-1:0] data_out [0:WEIGHT_ROWS-1];

    // Instantiate scratchpad
    scratchpad #(
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .WEIGHT_ROWS(WEIGHT_ROWS),
        .WEIGHT_COLS(WEIGHT_COLS)

    ) uut (
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin

        // Fill data_in with known values
        for (int i = 0; i < WEIGHT_ROWS; i++) begin
            data_in[i] = i;  // 0,1,2,3,4,5
            $display("data in[%0d] = %0d", i, data_in[i]);
        end

        #1; // allow combinational logic to settle

        $display("Scratchpad output:");
        for (int i = 0; i < WEIGHT_ROWS; i++) begin
            $display("data_out[%0d] = %0d", i, data_out[i]);
        end

        $finish;
    end

endmodule
