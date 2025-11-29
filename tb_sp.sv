`timescale 1ps/1ps

module tb_sp #(
    parameter WEIGHT_ROWS = 96,
    parameter WEIGHT_WIDTH = 5
)
();

logic clk, reset, write_enable;
logic [WEIGHT_WIDTH-1:0] weight_col_in [0:WEIGHT_ROWS-1];
logic [WEIGHT_WIDTH-1:0] weight_col_out [0:WEIGHT_ROWS-1];
logic [WEIGHT_WIDTH-1:0] weight_col_in_always_block [0:WEIGHT_ROWS-1];

int j;

scratch_Pad #(
    .WEIGHT_ROWS(WEIGHT_ROWS),
    .WEIGHT_WIDTH(WEIGHT_WIDTH)
)
uut
(
    .clk(clk), .reset(reset),
    .write_enable(write_enable),
    .weight_col_in(weight_col_in),
    .weight_col_out(weight_col_out)
);


initial begin
    clk <= 1'b1;
    reset <= 1'b1;
end

always  begin
    clk <= ~clk;
    #0.5;
    write_enable <= 1'b0;
end

always  begin
    write_enable <= ~write_enable;
    #10;
end

always begin

    reset <= 1'b0;
    #1;
    
        for( j = 0; j<WEIGHT_ROWS; j++) begin
            weight_col_in[j] <= weight_col_in_always_block[j];
            wait(clk);

        end
 




end

always begin
    $monitor(" j = %0d ", j);
end





endmodule