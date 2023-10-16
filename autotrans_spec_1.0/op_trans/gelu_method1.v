module Gelu_method1
#( 
    parameter GELU_NUM = 128, //input_shape[0][1]
    parameter DIMENTION = 64, //input_shape[0][2]
    parameter x_WIDTH = 8, //input_shape[0][0]
    parameter k_WIDTH = 32,
    parameter b_WIDTH = 32, 
    parameter result_WIDTH = x_WIDTH + k_WIDTH + 1, // 41, 8bitxx * 32bit k + 32 bit b
    parameter bp_NUM = 16,   //breakpoint
    parameter OUTPUT_WIDTH = 8  
)(
    input                                                            clk_p,
    input                                                            rst_n,
    input       signed  [x_WIDTH * GELU_NUM * DIMENTION - 1 : 0]     x,  
    input                                                            input_valid_n,
    output wire signed  [OUTPUT_WIDTH * GELU_NUM * DIMENTION - 1:0]  gelu,
    output wire                                                      gelu_valid_n
);

//********************************* Middle Signal *********************************
wire    signed      [x_WIDTH * DIMENTION - 1 : 0]           x_mem           [GELU_NUM - 1 : 0];
wire    signed      [OUTPUT_WIDTH * DIMENTION - 1 : 0]      gelu_mem        [GELU_NUM - 1 : 0];
wire                [GELU_NUM - 1 : 0]                      gelu_block_valid_n;

//********************************* Loop Integer **********************************
genvar i;

// ----------------------------------- Enable Signal Logic ------------------------------------
assign en_p1_n = (gelu_block_valid_n) ? 1 : 0;
assign gelu_valid_n = en_p2_n;

always @(posedge clk_p or negedge rst_n) begin
    if(!rst_n) begin 
        en_p2_n <= 'b1;
    end
    else begin
        en_p2_n <= (!en_p1_n) ? 0 : 1;
    end
end

generate
    for(i = 0; i < GELU_NUM ; i = i + 1) begin
        assign x_mem[i] = x[(i + 1) * x_WIDTH * DIMENTION - 1 : i * x_WIDTH * DIMENTION];
        assign gelu[(i + 1) * OUTPUT_WIDTH * DIMENTION - 1 : i * OUTPUT_WIDTH * DIMENTION] = gelu_mem[i];
        nnlut_gelu_64 #(.DIMENTION(DIMENTION), .x_WIDTH(x_WIDTH), .k_WIDTH(k_WIDTH), .b_WIDTH(b_WIDTH),
                        .result_WIDTH(result_WIDTH), .bp_NUM(bp_NUM), .OUTPUT_WIDTH(OUTPUT_WIDTH)) 
                        u_nnlut_gelu_64
                        (.clk_p(clk_p), .rst_n(rst_n),
                            .x(x_mem[i]), .input_valid_n(input_valid_n), 
                            .gelu(gelu_mem[i]), .gelu_valid_n(gelu_block_valid_n[i]));
    end
endgenerate


endmodule