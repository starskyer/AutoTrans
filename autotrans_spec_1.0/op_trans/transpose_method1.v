module Transpose_method1
#(
    parameter DATA_WIDTH     = 'd8, //input_shape[0][0]
    parameter INPUT_SHAPE_1  = 'd128, //input_shape[0][1]
    parameter INPUT_SHAPE_2  = 'd768, //input_shape[0][2]
    parameter INPUT_SHAPE_3  = 'd1, //input_shape[0][3]
    parameter OUTPUT_SHAPE_1 = 'd768, //output_shape[0][1]
    parameter OUTPUT_SHAPE_2 = 'd128, //output_shape[0][2]
    parameter OUTPUT_SHAPE_3 = 'd1 //output_shape[0][3]
) (
    //********************************* System Signal *********************************
    input                                                           clk_p,
    input                                                           rst_n,
    //********************************* Input Signal *********************************
    input  signed [INPUT_SHAPE_1 * INPUT_SHAPE_2 * INPUT_SHAPE_3 * DATA_WIDTH - 1 : 0]    matrix,

    //********************************* Output Signal *********************************
    output signed [OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 * OUTPUT_SHAPE_3 * DATA_WIDTH - 1 : 0]  transpose_matrix
);

assign transpose_matrix = matrix;

endmodule