module top_module(
input clk_p,
input rst_n,
input	signed  [( 32) * (  768) * ( 768) - 1   :   0]onnx_MatMul_1623,
input	signed  [( 32) * ( 128) * ( 768) - 1   :   0]input_8,
input	signed  [( 32) * (  768 ) - 1   :   0]bert_encoder_layer_0_attention_self_value_bias,
input	signed  [( 32) * ( 128) * ( 768) - 1   :   0]mixed_query_layer,
input	signed  [( 4 )   :   0]onnx_Reshape_1628,
input	signed  [( 32) * ( 128) * ( 768) - 1   :   0]mixed_key_layer,
input	signed  [( 3 )   :   0]onnx_Reshape_1642,
output	output_valid_n_Reshape_87,
output	signed [( 32) * ( 128) * ( 768)- 1     :   0]onnx_MatMul_295
);
wire	signed [( 32) * (  128) * (  768) - 1     :   0]mixed_value_layer;
wire	signed [( 32) * ( 128) * ( 4) * ( 64) - 1     :   0]onnx_Transpose_245;
wire	signed [( 4) * ( 128) * ( 64 ) * ( 32) - 1 : 0]onnx_MatMul_246;
wire	signed [( 32) * ( 128) * ( 4) * ( 64) - 1     :   0]onnx_Transpose_260;
wire	signed [( 32) * ( 128) * ( 4) * ( 64) - 1     :   0]onnx_Transpose_274;
wire	signed [( 4) * ( 128) * ( 64 ) * ( 32) - 1 : 0]onnx_MatMul_275;
wire	signed [( 4) * ( 64) * ( 128 ) * ( 32) - 1 : 0]onnx_MatMul_276;
wire	signed [( 32) * ( 4) * (  128) * (  64 ) - 1     :   0]input_12;
wire	signed [( 32) * ( 4) * (  128) * (  128 ) - 1     :   0]onnx_Transpose_283;
wire	signed [( 128) * ( 4) * ( 64 ) * ( 32) - 1 : 0]onnx_Reshape_284;
wire	input_valid_n_Reshape_73;
wire	input_valid_n_Reshape_75;
wire	input_valid_n_Reshape_76;
wire	input_valid_n_Reshape_87;
wire	output_valid_n_Reshape_73;
wire	output_valid_n_Reshape_75;
wire	output_valid_n_Reshape_76;

assign input_valid_n_Reshape_76 =  'b1;
assign input_valid_n_Reshape_73 = 'b1 ;
assign input_valid_n_Reshape_75 = 'b1 ;
assign input_valid_n_Reshape_87 =  'b1;
MAC_3_opID_26   MAC_3
(
	.clk_p(clk_p),
	.rst_n(rst_n),
	.matrix2(onnx_MatMul_1623),
	.matrix1(input_8),
	.bias(bert_encoder_layer_0_attention_self_value_bias),
	.mac_matrix(mixed_value_layer)
);
Reshape_73_opID_28   Reshape_73
(
	.clk_p(clk_p),
	.rst_n(rst_n),
	.matrix(mixed_query_layer),
	.num(onnx_Reshape_1628),
	.input_valid_n(input_valid_n_Reshape_73),
	.split_matrix(onnx_Transpose_245),
	.output_valid_n(output_valid_n_Reshape_73)
);
Transpose_74_opID_29   Transpose_74
(
	.clk_p(clk_p),
	.rst_n(rst_n),
	.matrix(onnx_Transpose_245),
	.transpose_matrix(onnx_MatMul_246)
);
Reshape_75_opID_30   Reshape_75
(
	.clk_p(clk_p),
	.rst_n(rst_n),
	.matrix(mixed_key_layer),
	.num(onnx_Reshape_1628),
	.input_valid_n(input_valid_n_Reshape_75),
	.split_matrix(onnx_Transpose_260),
	.output_valid_n(output_valid_n_Reshape_75)
);
Reshape_76_opID_31   Reshape_76
(
	.clk_p(clk_p),
	.rst_n(rst_n),
	.matrix(mixed_value_layer),
	.num(onnx_Reshape_1628),
	.input_valid_n(input_valid_n_Reshape_76),
	.split_matrix(onnx_Transpose_274),
	.output_valid_n(output_valid_n_Reshape_76)
);
Transpose_77_opID_32   Transpose_77
(
	.clk_p(clk_p),
	.rst_n(rst_n),
	.matrix(onnx_Transpose_274),
	.transpose_matrix(onnx_MatMul_275)
);
Transpose_78_opID_33   Transpose_78
(
	.clk_p(clk_p),
	.rst_n(rst_n),
	.matrix(onnx_Transpose_260),
	.transpose_matrix(onnx_MatMul_276)
);
MatMul_1_opID_34   MatMul_1
(
	.clk_p(clk_p),
	.rst_n(rst_n),
	.matrix1(onnx_MatMul_246),
	.matrix2(onnx_MatMul_276),
	.mul(input_12)
);
MatMul_85_opID_40   MatMul_85
(
	.clk_p(clk_p),
	.rst_n(rst_n),
	.matrix1(input_12),
	.matrix2(onnx_MatMul_275),
	.mul(onnx_Transpose_283)
);
Transpose_86_opID_41   Transpose_86
(
	.clk_p(clk_p),
	.rst_n(rst_n),
	.matrix(onnx_Transpose_283),
	.transpose_matrix(onnx_Reshape_284)
);
Reshape_87_opID_42   Reshape_87
(
	.clk_p(clk_p),
	.rst_n(rst_n),
	.matrix(onnx_Reshape_284),
	.num(onnx_Reshape_1642),
	.input_valid_n(input_valid_n_Reshape_87),
	.merge_matrix(onnx_MatMul_295),
	.output_valid_n(output_valid_n_Reshape_87)
);

endmodule