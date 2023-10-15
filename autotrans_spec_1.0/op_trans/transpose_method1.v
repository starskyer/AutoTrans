module Transpose_method1
#(
    parameter INPUT_SIZE_1  = 'd128, //input_shape[0][0]
    parameter INPUT_SIZE_2  = 'd768, //input_shape[0][1]
    parameter DATA_WIDTH    = 'd8,
    parameter OUTPUT_SIZE_1 = INPUT_SIZE_2,
    parameter OUTPUT_SIZE_2 = INPUT_SIZE_1
) (
    //********************************* Input Signal *********************************
    input  signed [INPUT_SIZE_1 * INPUT_SIZE_2 * DATA_WIDTH - 1 : 0]    matrix,

    //********************************* Output Signal *********************************
    output signed [OUTPUT_SIZE_1 * OUTPUT_SIZE_2 * DATA_WIDTH - 1 : 0]  transpose_matrix
);

genvar i, j;

generate
    for(i = 0; i < INPUT_SIZE_1; i = i + 1) begin
        for(j = 0; j < INPUT_SIZE_2; j = j + 1) begin
            transpose_matrix[(j * OUTPUT_SIZE_2 + i + 1) * DATA_WIDTH - 1 : (j * OUTPUT_SIZE_2 + i) * DATA_WIDTH]
            = matrix        [(i * INPUT_SIZE_2 + j + 1) * DATA_WIDTH - 1 : (i * INPUT_SIZE_2 + j) * DATA_WIDTH];
        end
    end
endgenerate

endmodule