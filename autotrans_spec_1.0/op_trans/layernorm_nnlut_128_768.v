`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////// 
// Create Date: 2022/10/14 10:15:29
// Module Name: layernorm
// Description: 瀹炵幇layernorm鐨勬暣鏁扮畻娉�
// Dependencies: 渚濊禆浜庝互涓嬫ā鍧楋�?
// add_group, adder_768, clip, divide768, (FIFO IP)fifo_8kb_32, long2short, 
// multiplier_group, short2long, reciprocal_24, sqrt_21_11
//////////////////////////////////////////////////////////////////////////////////


module layernorm_nnlut_128_768
#(
    parameter   INPUT_WIDTH = 8,
    parameter   INPUT_NUM = 768,
    parameter   OUTPUT_WIDTH = 8,
    parameter   SENTENCE_NUM=128
)
(
//*************************************** System signal ***************************************//
    input                                                                           clk_p,
    input                                                                           rst_n,
//*************************************** Input signal ***************************************//
    input                                   [INPUT_WIDTH * SENTENCE_NUM*INPUT_NUM - 1 : 0]       data,
    input                                                                           data_valid_n,
    input                                   [INPUT_WIDTH *SENTENCE_NUM* INPUT_NUM - 1 : 0]       w,
    input                                                                         w_valid_n,
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
assign result= &result_valid_n_part;
endmodule