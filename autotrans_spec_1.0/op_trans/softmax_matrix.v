module softmax_matrix
#(
    parameter DATA_WIDTH = 'd8, //input_shape[0][0]
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
    input  signed [DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2 - 1   :   0]                 matrix,
    input                                                                                  input_valid_n,
//********************************* Output Signal *********************************
    output signed [DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 - 1 :   0]                 softmax_matrix,
    output                                                                                 output_valid_n
);

//********************************* Loop Integer **********************************
    genvar                                               i;

    wire    [DATA_WIDTH * INPUT_SHAPE_2 - 1 : 0]  matrix_mem         [INPUT_SHAPE_1 - 1 : 0];
    wire    [DATA_WIDTH * INPUT_SHAPE_2 - 1 : 0]  softmax_matrix_mem [INPUT_SHAPE_1 - 1 : 0];
    wire    [INPUT_SHAPE_1 - 1 : 0]               output_block_valid_n;

    assign output_valid_n = (output_block_valid_n) ? 1 : 0;

    generate 
        for(i = 0; i < INPUT_SHAPE_1; i = i + 1) begin
            assign matrix_mem[i] = matrix[(i + 1) * DATA_WIDTH * INPUT_SHAPE_2 - 1 : i * DATA_WIDTH * INPUT_SHAPE_2];
            assign softmax_matrix[(i + 1) * DATA_WIDTH * OUTPUT_SHAPE_2 - 1 : i * DATA_WIDTH * OUTPUT_SHAPE_2] = softmax_matrix_mem[i];
            softmax #(.DATA_WIDTH(DATA_WIDTH), .INPUT_NUM(INPUT_SHAPE_2), .OUTPUT_NUM(OUTPUT_SHAPE_2))
            u_softmax (.clk_p(clk_p), .rst_n(rst_n), .inputs(matrix_mem[i]), .input_valid_n(input_valid_n),
                       .outputs(softmax_matrix_mem[i], .output_valid_n(output_block_valid_n[i])));
        end
    endgenerate

endmodule