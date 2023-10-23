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
    input                                                                                               input_valid_n,
//********************************* Output Signal *********************************
    output signed [DATA_WIDTH * MATRIX_NUM * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 - 1 :   0]                 softmax_matrix,
    output                                                                                              output_valid_n
);

//********************************* Loop Integer **********************************
    genvar                                               i;

    wire    [DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2 - 1 : 0]  matrix_mem         [MATRIX_NUM - 1 : 0];
    wire    [DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2 - 1 : 0]  softmax_matrix_mem [MATRIX_NUM - 1 : 0];
    wire    [MATRIX_NUM - 1 : 0]               output_block_valid_n;

    assign output_valid_n = (output_block_valid_n) ? 1 : 0;

    generate 
        for(i = 0; i < MATRIX_NUM; i = i + 1) begin
            assign matrix_mem[i] = matrix[(i + 1) * DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2 - 1 : i * DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2];
            assign softmax_matrix[(i + 1) * DATA_WIDTH * INPUT_SHAPE_1 * OUTPUT_SHAPE_2 - 1 : i * DATA_WIDTH * INPUT_SHAPE_1 * OUTPUT_SHAPE_2] = softmax_matrix_mem[i];
            softmax_matrix #(.DATA_WIDTH(DATA_WIDTH), .INPUT_SHAPE1(INPUT_SHAPE_1), .INPUT_SHAPE2(INPUT_SHAPE_2),
                             .OUTPUT_SHAPE1(OUTPUT_SHAPE_1), .OUTPUT_SHAPE2(OUTPUT_SHAPE_2))
            u_softmax_matrix (.clk_p(clk_p), .rst_n(rst_n), .matrix(matrix_mem[i]), .input_valid_n(input_valid_n),
                              .softmax_matrix(softmax_matrix_mem[i], .output_valid_n(output_block_valid_n[i])));
        end
    endgenerate

endmodule