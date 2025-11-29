`timescale 1ps/1ps
module tb1;

    localparam WEIGHT_WIDTH = 5;
    localparam WEIGHT_ROWS  = 100;
    // localparam WEIGHT_COLS  = 3;

    logic [WEIGHT_WIDTH-1:0] data_in  [0:WEIGHT_ROWS-1];
    logic [WEIGHT_WIDTH-1:0] data_out [0:WEIGHT_ROWS-1];
    logic clk;
    logic reset;
    logic write_enable;

    Scratch_Pad #(
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .WEIGHT_ROWS(WEIGHT_ROWS)
    ) uut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .weight_col_in (data_in),
        .weight_col_out (data_out)
    );

    // ------------------------
    // CLOCK: proper 1ps period
    // ------------------------
    initial clk = 0;
    always #0.5 clk = ~clk;   // 1ps period

    // ------------------------
    // RESET
    // ------------------------
    initial begin
        reset = 1;
        #2;
        reset = 0;
    end

    // ------------------------
    // STIMULUS
    // ------------------------
    initial begin
        write_enable = 1;

        // Fill inputs
        for (int i = 0; i < WEIGHT_ROWS; i++) begin
            data_in[i] = i;
        end

        #5;

        $display("Scratchpad output:");
        for (int i = 0; i < WEIGHT_ROWS; i = i++) begin
            $display("data_out[%0d] = %0d", i, data_out[i]);
        end

        #20;
        $finish;
    end

    // Monitor (not in always!)
    initial
        $monitor("clk=%0b reset=%0b time=%0t", clk, reset, $time);

endmodule
