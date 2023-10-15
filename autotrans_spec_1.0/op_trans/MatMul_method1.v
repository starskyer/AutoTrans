module MatMul_method1 #(
    parameter DATA_WIDTH = 'd8, //input_shape[0][0]
    parameter MATMUL_NUM = 'd12, //input_shape[0][1]
    parameter INPUT_SHAPE_1_1 = 'd128, //input_shape[0][2]
    parameter INPUT_SHAPE_1_2 = 'd128, //input_shape[0][2]
    parameter INPUT_SHAPE_2_1 = INPUT_SHAPE_1_2, 
    parameter INPUT_SHAPE_2_2 = 'd128, //input_shape[1][2]
    parameter OUTPUT_SHAPE_1 = INPUT_SHAPE_1_1,
    parameter OUTPUT_SHAPE_2 = INPUT_SHAPE_2_2
)
(
    //********************************* System Signal *********************************
    input                                                           clk_p,
    input                                                           rst_n,
    //********************************* Input Signal *********************************
    input signed  [DATA_WIDTH * MATMUL_NUM * INPUT_SHAPE_1_1 * INPUT_SHAPE_1_2 - 1   :   0]  matrix1,
    input signed  [DATA_WIDTH * MATMUL_NUM * INPUT_SHAPE_2_1 * INPUT_SHAPE_2_2 - 1   :   0]  matrix2,

    //********************************* Output Signal *********************************
    output signed [DATA_WIDTH * MATMUL_NUM * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 - 1     :   0]  mul
);

endmodule