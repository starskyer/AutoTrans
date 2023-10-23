module matmul #(
    parameter DATA_WIDTH = 'd8,
    parameter INPUT_SHAPE_1_1 = 'd128,
    parameter INPUT_SHAPE_1_2 = 'd128,
    parameter INPUT_SHAPE_2_1 = INPUT_SHAPE_1_2, 
    parameter INPUT_SHAPE_2_2 = 'd128,
    parameter OUTPUT_SHAPE_1 = INPUT_SHAPE_1_1,
    parameter OUTPUT_SHAPE_2 = INPUT_SHAPE_2_2
)
(
    //********************************* System Signal *********************************
    input                                                           clk_p,
    input                                                           rst_n,
    //********************************* Input Signal *********************************
    input signed  [DATA_WIDTH * INPUT_SHAPE_1_1 * INPUT_SHAPE_1_2 - 1   :   0]  matrix1,
    input signed  [DATA_WIDTH * INPUT_SHAPE_2_1 * INPUT_SHAPE_2_2 - 1   :   0]  matrix2,

    //********************************* Output Signal *********************************
    output signed [DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 - 1     :   0]  mul
);

genvar i, j, k;

generate
    for(i = 0; i < INPUT_SHAPE_1_1; i = i + 1) begin
        for(j = 0; j < INPUT_SHAPE_2_2; j = j + 1) begin
            for(k = 0; k < INPUT_SHAPE_1_2; k = k + 1) begin
                mul[(i * OUTPUT_SHAPE_2 + j + 1) * DATA_WIDTH - 1 : (i * OUTPUT_SHAPE_2 + j) * DATA_WIDTH]
                = matrix1[(i * INPUT_SHAPE_1_2 + k + 1) * DATA_WIDTH - 1 : (i * INPUT_SHAPE_1_2 + k) * DATA_WIDTH]
                * matrix2[(k * INPUT_SHAPE_2_2 + j + 1) * DATA_WIDTH - 1 : (k * INPUT_SHAPE_2_2 + j) * DATA_WIDTH];
            end
        end
    end
endgenerate

endmodule