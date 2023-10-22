module Split_method1 #(
    parameter DATA_WIDTH = 'd8, //input_shape[0][0]
    parameter INPUT_SHAPE_1 = 'd128, //input_shape[0][1]
    parameter INPUT_SHAPE_2 = 'd768, //input_shape[0][2]
    parameter OUTPUT_SHAPE_1 = 'd128, //output_shape[0][1]
    parameter OUTPUT_SHAPE_2 = 'd12, //output_shape[0][2]
    parameter OUTPUT_SHAPE_3 = 'd64, //output_shape[0][3]
    parameter HEAD_NUM = 'd12,
    parameter NUM_WIDTH = 'd4 //input_shape[1]
)
(
    //********************************* System Signal *********************************
    input                                                           clk_p,
    input                                                           rst_n,
    //********************************* Input Signal *********************************
    input signed  [DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2 - 1   :   0]                          matrix,
    input signed  [NUM_WIDTH   :   0]                                                               num,

    //********************************* Output Signal *********************************
    output signed [DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 * OUTPUT_SHAPE_3 - 1     :   0]     split_matrix
);

endmodule