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
    input signed  [BIAS_WIDTH - 1   :   0]                                      bias,
    //********************************* Output Signal *********************************
    output signed [DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 - 1     :   0]  softmax_matrix
);

endmodule