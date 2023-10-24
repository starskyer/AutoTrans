module MAC_method1 #(
    
    parameter DATA_WIDTH = 'd8, //input_shape[1][0]
    parameter INPUT_SHAPE_1_1 = 'd128, //input_shape[1][1]
    parameter INPUT_SHAPE_1_2 = 'd768, //input_shape[1][2]
    parameter INPUT_SHAPE_2_1 = INPUT_SHAPE_1_2, 
    parameter INPUT_SHAPE_2_2 = 'd3072, //input_shape[0][1]
    parameter OUTPUT_SHAPE_1 = INPUT_SHAPE_1_1,
    parameter OUTPUT_SHAPE_2 = INPUT_SHAPE_2_2,
    parameter BIAS_WIDTH = INPUT_SHAPE_2_2
)
(
    //********************************* System Signal *********************************
    input                                                           clk_p,
    input                                                           rst_n,
    //********************************* Input Signal *********************************
    input signed  [DATA_WIDTH * INPUT_SHAPE_2_1 * INPUT_SHAPE_2_2 - 1   :   0]  matrix2,
    input signed  [DATA_WIDTH * INPUT_SHAPE_1_1 * INPUT_SHAPE_1_2 - 1   :   0]  matrix1,   
    input signed  [DATA_WIDTH * BIAS_WIDTH - 1   :   0]                         bias,
    //********************************* Output Signal *********************************
    output signed [DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 - 1     :   0]  mac_matrix
);

genvar  i, j;

wire    [DATA_WIDTH * OUTPUT_SHAPE_1 * BIAS_WIDTH - 1   :   0]           bias_matrix;

wire    [DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 - 1     :   0]     mul;

matmul #(.DATA_WIDTH(DATA_WIDTH), .INPUT_SHAPE_1_1(INPUT_SHAPE_1_1), .INPUT_SHAPE_1_2(INPUT_SHAPE_1_2), .INPUT_SHAPE_2_1(INPUT_SHAPE_2_1),
          .INPUT_SHAPE_2_2(INPUT_SHAPE_2_2), .OUTPUT_SHAPE_1(OUTPUT_SHAPE_1), .OUTPUT_SHAPE_2(OUTPUT_SHAPE_2))
u_matmul (.clk_p(clk_p), .rst_n(rst_n), .matrix1(matrix1), .matrix2(matrix2), .mul(mul));

generate
    for(i = 0; i < BIAS_WIDTH; i = i + 1) begin
        for(j = 0; j < OUTPUT_SHAPE_1; j = j + 1) begin
            assign bias_matrix[(i * OUTPUT_SHAPE_1 + j + 1) * DATA_WIDTH - 1 : (i * OUTPUT_SHAPE_1 + j) * DATA_WIDTH] = bias[(i + 1) * DATA_WIDTH - 1 : i * DATA_WIDTH];
        end
    end
endgenerate

assign mac_matrix = mul + bias_matrix;

endmodule