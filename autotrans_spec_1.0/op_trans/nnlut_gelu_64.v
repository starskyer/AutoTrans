// module name: nnlut_gelu_64
// description: gelu implementation by nn-lut method, 64 inst of nn-lut
// DIMENTION: 64
// k,b: 32bit;   x, breakpoint: 8bit
// timing logic: 3 clk in total
//   pipeline 1: clk 1-2: nn-lut
//   pipeline 2: clk 3: quant to 8bit
module nnlut_gelu_64
#(
    parameter DIMENTION = 64,
    parameter x_WIDTH = 8,
    parameter k_WIDTH = 32,
    parameter b_WIDTH = 32, 
    parameter result_WIDTH = x_WIDTH + k_WIDTH + 1, // 41, 8bitxx * 32bit k + 32 bit b
    parameter bp_NUM = 16,   //breakpoint
    parameter OUTPUT_WIDTH = 8  
)
(
    // input signal
    input                                                        clk_p,
    input                                                        rst_n,
    input       signed  [x_WIDTH * DIMENTION - 1 : 0]            x,  
    input                                                        input_valid_n,
    // output signal
    output wire signed  [OUTPUT_WIDTH * DIMENTION - 1:0]         gelu,
    output wire                                                  gelu_valid_n
);

//********************************* Middle Signal *********************************
// 41bit output of nnlut
    wire        signed  [result_WIDTH-1:0]                       nnlut_result  [DIMENTION - 1 : 0];
    wire                [DIMENTION - 1 : 0]                      nnlut_valid_n;
// quant value of nn-lut
    reg         signed  [OUTPUT_WIDTH - 1 : 0]                   gelu_mem  [DIMENTION - 1 : 0];
//********************************* Loop Integer *********************************
    genvar                                                       i;
    integer                                                     j, k;


//********************************* Pipeline Output Enable Signal *********************************
    wire                                                         en_p1_n; 
    reg                                                          en_p2_n;

    assign en_p1_n = (nnlut_valid_n) ? 1 : 0;
    assign gelu_valid_n = en_p2_n;


// ----------------------------------- Enable Signal Logic ------------------------------------
    always @(posedge clk_p or negedge rst_n) begin
        if(!rst_n) begin 
            en_p2_n <= 'b1;
        end
        else begin
            en_p2_n <= (!en_p1_n) ? 0 : 1;
        end
    end
// ------------------------------- Pipeline Begins -------------------------------------------
    // ---------------- pipeline 1: clk 1-2: nn-lut ---------------------------
    wire   signed   [x_WIDTH - 1   :   0]    x_mem    [DIMENTION - 1  :   0];
    generate
        for(i = 0; i < DIMENTION ; i = i + 1) begin
            assign x_mem[i] = x[(i + 1) * x_WIDTH - 1 : i * x_WIDTH];
        end
    endgenerate

    generate
        for(i = 0; i < DIMENTION ; i = i + 1) begin: inst_gelu_64nnlut
            nnlut_gelu #(.x_WIDTH(x_WIDTH), .k_WIDTH(k_WIDTH), .b_WIDTH(b_WIDTH), .result_WIDTH(result_WIDTH), .bp_NUM(bp_NUM)) u_nnlut
                   (.clk_p(clk_p), .rst_n(rst_n),
                    .x(x_mem[i]), .input_valid_n(input_valid_n), 
                    .result(nnlut_result[i]), .nnlut_valid_n(nnlut_valid_n[i]));
        end
    endgenerate 


    // ---------------- pipeline 2: clk 3: quant to 8bit ---------------------------
    always @(posedge clk_p or negedge rst_n) begin
        if(!rst_n) begin 
            for(j = 0; j < DIMENTION ; j = j + 1) begin: rst_quant_nnlut
                gelu_mem[j] <= 'd0;
            end
        end
        else begin
            for(k = 0; k < DIMENTION ; k = k + 1) begin: quant_nnlut
                gelu_mem[k] <= (!en_p1_n) ? (nnlut_result[k] >> (result_WIDTH - OUTPUT_WIDTH)) : 'd0;
            end
        end
    end

    generate
        for(i = 0; i < DIMENTION ; i = i + 1) begin
            assign gelu[(i + 1) * OUTPUT_WIDTH - 1 : i * OUTPUT_WIDTH] = gelu_mem[i];
        end
    endgenerate




endmodule