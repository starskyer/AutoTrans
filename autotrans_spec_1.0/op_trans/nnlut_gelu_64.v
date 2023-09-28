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
    parameter bp_NUM = 16,   //breakpoin
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
    assign  {x_mem[0],  x_mem[1],  x_mem[2],  x_mem[3],  x_mem[4],  x_mem[5],  x_mem[6],  x_mem[7],  
             x_mem[8],  x_mem[9],  x_mem[10], x_mem[11], x_mem[12], x_mem[13], x_mem[14], x_mem[15],
             x_mem[16], x_mem[17], x_mem[18], x_mem[19], x_mem[20], x_mem[21], x_mem[22], x_mem[23],
             x_mem[24], x_mem[25], x_mem[26], x_mem[27], x_mem[28], x_mem[29], x_mem[30], x_mem[31],
             x_mem[32], x_mem[33], x_mem[34], x_mem[35], x_mem[36], x_mem[37], x_mem[38], x_mem[39],
             x_mem[40], x_mem[41], x_mem[42], x_mem[43], x_mem[44], x_mem[45], x_mem[46], x_mem[47],
             x_mem[48], x_mem[49], x_mem[50], x_mem[51], x_mem[52], x_mem[53], x_mem[54], x_mem[55],
             x_mem[56], x_mem[57], x_mem[58], x_mem[59], x_mem[60], x_mem[61], x_mem[62], x_mem[63]
            } = x;

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

    assign gelu = {gelu_mem[0],  gelu_mem[1],  gelu_mem[2],  gelu_mem[3],  gelu_mem[4],  gelu_mem[5],  gelu_mem[6],  gelu_mem[7],  
             gelu_mem[8],  gelu_mem[9],  gelu_mem[10], gelu_mem[11], gelu_mem[12], gelu_mem[13], gelu_mem[14], gelu_mem[15],
             gelu_mem[16], gelu_mem[17], gelu_mem[18], gelu_mem[19], gelu_mem[20], gelu_mem[21], gelu_mem[22], gelu_mem[23],
             gelu_mem[24], gelu_mem[25], gelu_mem[26], gelu_mem[27], gelu_mem[28], gelu_mem[29], gelu_mem[30], gelu_mem[31],
             gelu_mem[32], gelu_mem[33], gelu_mem[34], gelu_mem[35], gelu_mem[36], gelu_mem[37], gelu_mem[38], gelu_mem[39],
             gelu_mem[40], gelu_mem[41], gelu_mem[42], gelu_mem[43], gelu_mem[44], gelu_mem[45], gelu_mem[46], gelu_mem[47],
             gelu_mem[48], gelu_mem[49], gelu_mem[50], gelu_mem[51], gelu_mem[52], gelu_mem[53], gelu_mem[54], gelu_mem[55],
             gelu_mem[56], gelu_mem[57], gelu_mem[58], gelu_mem[59], gelu_mem[60], gelu_mem[61], gelu_mem[62], gelu_mem[63]};





endmodule