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
     input  logic [COO_BW-1:0]       coo_in_a  [0:1],             // {src,dst} for current column

    input logic [WEIGHT_WIDTH-1:0] data_in_b     [0:WEIGHT_ROWS-1],
    output logic [DOT_PROD_WIDTH - 1 : 0] feeder_output
);
    logic [DOT_PROD_WIDTH - 1 : 0] feeder_output_combi;

    logic [DOT_PROD_WIDTH - 1 : 0] mem_mult [0 : WEIGHT_ROWS - 1][0 : 1];

    always_comb begin
        for(int i = 0; i<=1; i++) begin
            for(int j = 0; j < WEIGHT_ROWS; j++) begin
                mem_mult[j][i] = coo_in_a[i] * data_in_b[j];
            end
        end
    end


        always_comb begin
        feeder_output_combi = '0;
        for (int i = 0; i <= 1; i++) begin
            for (int j = 0; j < WEIGHT_ROWS; j++) begin
                feeder_output_combi += mem_mult[j][i];
            end
        end
    end

    assign feeder_output = feeder_output_combi;






endmodule