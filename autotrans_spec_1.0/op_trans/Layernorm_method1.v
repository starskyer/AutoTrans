module Layernorm_method1
#(
    parameter   INPUT_WIDTH = 8, //input_shape[0][0]
    parameter   SENTENCE_NUM = 128, //input_shape[0][1]
    parameter   INPUT_NUM = 768, //input_shape[0][2]
    parameter   OUTPUT_WIDTH = INPUT_WIDTH
)
(
//*************************************** System signal ***************************************//
    input                                                                           clk_p,
    input                                                                           rst_n,
//*************************************** Input signal ***************************************//
    input                                   [INPUT_WIDTH * SENTENCE_NUM*INPUT_NUM - 1 : 0]       data,
    input                                                                           data_valid_n,
    input                                   [INPUT_WIDTH *SENTENCE_NUM* INPUT_NUM - 1 : 0]       w,
    input                                                                           w_valid_n,
    input                                   [INPUT_WIDTH *SENTENCE_NUM* INPUT_NUM - 1 : 0]       b,
    input                                                                                       b_valid_n,
//*************************************** Output signal ***************************************//
    output                                  [OUTPUT_WIDTH * SENTENCE_NUM* INPUT_NUM- 1 :0]       result,
    output                  reg                                                     result_valid_n    
);
genvar i;

wire [INPUT_WIDTH*INPUT_NUM-1:0]        data_mem[SENTENCE_NUM-1:0];
wire [INPUT_WIDTH*INPUT_NUM-1:0]        w_mem[SENTENCE_NUM-1:0];
wire [INPUT_WIDTH*INPUT_NUM-1:0]        b_mem[SENTENCE_NUM-1:0];
wire [OUTPUT_WIDTH * INPUT_NUM- 1 :0]   result_mem[SENTENCE_NUM-1:0];
wire [SENTENCE_NUM-1:0] result_valid_n_part;
generate
    for(i=0;i<SENTENCE_NUM;i=i+1)begin
        assign data_mem[i]=data[(i+1)*INPUT_WIDTH*INPUT_NUM-1:i*INPUT_WIDTH*INPUT_NUM];
        assign w_mem[i]=w[(i+1)*INPUT_WIDTH*INPUT_NUM-1:i*INPUT_WIDTH*INPUT_NUM];
        assign b_mem[i]=b[(i+1)*INPUT_WIDTH*INPUT_NUM-1:i*INPUT_WIDTH*INPUT_NUM];
        assign result[(i+1)*OUTPUT_WIDTH*INPUT_NUM-1 : i*OUTPUT_WIDTH*INPUT_NUM]=result_mem[i];
        layernorm_nnlut #(.INPUT_WIDTH(INPUT_WIDTH), .INPUT_NUM(INPUT_NUM), .OUTPUT_WIDTH(OUTPUT_WIDTH)) u_layernorm_nnlut
        (.clk(clk), .rst_n(rst_n), .data(data_mem[i]), .data_valid_n(data_valid_n), .w(w_mem[i]), .w_valid_n(w_valid_n),
        .b(b_mem[i]), .b_valid_n(b_valid_n), .result(result_mem[i]), .result_valid_n(result_valid_n_part[i]));
    end
endgenerate
assign result_valid_n= &result_valid_n_part;
endmodule