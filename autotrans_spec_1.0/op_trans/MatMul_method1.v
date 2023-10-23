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

genvar i;

wire [DATA_WIDTH * INPUT_SHAPE_1_1 * INPUT_SHAPE_1_2 - 1 : 0]     matrix1_mem [MATMUL_NUM - 1 : 0];
wire [DATA_WIDTH * INPUT_SHAPE_2_1 * INPUT_SHAPE_2_2 - 1 : 0]     matrix2_mem [MATMUL_NUM - 1 : 0];
wire [DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 - 1 : 0]       mul_mem     [MATMUL_NUM - 1 : 0];

generate
    for(i = 0; i < MATMUL_NUM; i = i + 1) begin
        assign matrix1_mem[i] = matrix1[((i + 1) * DATA_WIDTH * INPUT_SHAPE_1_1 * INPUT_SHAPE_1_2 - 1) : i * DATA_WIDTH * INPUT_SHAPE_1_1 * INPUT_SHAPE_1_2];
        assign matrix2_mem[i] = matrix2[((i + 1) * DATA_WIDTH * INPUT_SHAPE_2_1 * INPUT_SHAPE_2_2 - 1) : i * DATA_WIDTH * INPUT_SHAPE_2_1 * INPUT_SHAPE_2_2];
        assign mul[(i + 1) * DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 - 1 : i * DATA_WIDTH * MATMUL_NUM * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2] = mul_mem[i];
        matmul #(.DATA_WIDTH(DATA_WIDTH), .INPUT_SHAPE_1_1(INPUT_SHAPE_1_1), .INPUT_SHAPE_1_2(INPUT_SHAPE_1_2), .INPUT_SHAPE_2_1(INPUT_SHAPE_2_1),
                 .INPUT_SHAPE_2_2(INPUT_SHAPE_2_2), .OUTPUT_SHAPE_1(OUTPUT_SHAPE_1), .OUTPUT_SHAPE_2(OUTPUT_SHAPE_2))
        u_matmul (.clk_p(clk_p), .rst_n(rst_n), .matrix1(matrix1_mem[i]), .matrix2(matrix2_mem[i]), .mul(mul_mem[i]));    
    end
endgenerate

endmodule