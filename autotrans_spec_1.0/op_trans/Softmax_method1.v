module Softmax_method1
#(
    parameter DATA_WIDTH = 'd8, //input_shape[0][0]
    parameter MATRIX_NUM = 'd12, //input_shape[0][1]
    parameter INPUT_SHAPE_1 = 'd128, //input_shape[0][2]
    parameter INPUT_SHAPE_2 = 'd128, //input_shape[0][3]
    parameter OUTPUT_SHAPE_1 = INPUT_SHAPE_1,
    parameter OUTPUT_SHAPE_2 = INPUT_SHAPE_2
)
(
//********************************* System Signal *********************************
    input                                                           clk_p,
    input                                                           rst_n,
//********************************* Input Signal *********************************
    input  signed [DATA_WIDTH * MATRIX_NUM * INPUT_SHAPE_1 * INPUT_SHAPE_2 - 1   :   0]                 matrix,
//********************************* Output Signal *********************************
    output signed [DATA_WIDTH * MATRIX_NUM * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 - 1 :   0]                 softmax_matrix
);

endmodule