module top(
//*************************************** System signal ***************************************//
    input                                                                           clk_p,
    input                                                                           rst_n,
    output                                                                          vd
);

    
    // layernorm_nnlut
    localparam   LN_INPUT_WIDTH = 8;
    localparam   LN_INPUT_NUM = 768;
    localparam   LN_OUTPUT_WIDTH = 8;

    (* dont_touch = "true" *) wire                                   [LN_INPUT_WIDTH * LN_INPUT_NUM - 1 : 0]       data;
    (* dont_touch = "true" *) wire                                                                                 data_valid_n;
    (* dont_touch = "true" *) wire                                   [LN_INPUT_WIDTH * LN_INPUT_NUM - 1 : 0]       w;
    (* dont_touch = "true" *) wire                                                                                 w_valid_n;
    (* dont_touch = "true" *) wire                                   [LN_INPUT_WIDTH * LN_INPUT_NUM - 1 : 0]       b;
    (* dont_touch = "true" *) wire                                                                                 b_valid_n;

    wire                                  [LN_OUTPUT_WIDTH * LN_INPUT_NUM - 1 :0]       result;
    wire                                                                                result_valid_n;  


    layernorm_nnlut u_0 (clk_p, rst_n, data, data_valid_n, w, w_valid_n, b, b_valid_n, result, result_valid_n);


    // nnlut_gelu_64
    localparam GELU_DIMENTION = 64;
    localparam GELU_x_WIDTH = 8;
    localparam GELU_k_WIDTH = 32;
    localparam GELU_b_WIDTH = 32; 
    localparam GELU_result_WIDTH = x_WIDTH + k_WIDTH + 1; // 41, 8bitxx * 32bit k + 32 bit b
    localparam GELU_bp_NUM = 16;   //breakpoint的数�?????
    localparam GELU_OUTPUT_WIDTH = 8;

    (* dont_touch = "true" *) wire       signed  [GELU_x_WIDTH * GELU_DIMENTION - 1 : 0]            x;  
    (* dont_touch = "true" *) wire                                                                  gelu_input_valid_n;

    wire signed  [GELU_OUTPUT_WIDTH * GELU_DIMENTION - 1:0]         gelu;
    wire                                                            gelu_valid_n;


    nnlut_gelu_64 u_1 (clk_p, rst_n, x, gelu_input_valid_n, gelu, gelu_valid_n);


    // nnlut_softmax
    localparam DIMENTION = 'd128; 
    localparam DIMENTION_EXP = 'd64; 
    localparam NUM = 'd2;
    localparam WIDTH_Q = 'd8;              // in softmax, input q is from former MM, 8bit
    localparam WIDTH_QQ = 'd9;             // in softmax, qq_min = -256 qq_max = 0 qq_width = 9
    localparam WIDTH_QEXP = 'd24;          // in softmax, qexp_min = 0 qexp_max = 5308721.0  qexp_width = 24.0
    localparam WIDTH_QSUM = 'd64;          // in softmax, qsum_min = 0 qsum_max = 4077097728.0  qsum_width = 33.0  + 31 
    localparam WIDTH_INTERVAL = 'd33;      // in softmax, interval_min = 0.0 interval_max = 32103132.0  interval_width = 33
    localparam WIDTH_QSOFTMAX_QUANT = 'd8;  // in softmax_quant, qsoftmax_quant_min = 0 qsoftmax_quant_max = 127  qsoftmax_quant_width = 8

    // parameters for i-exp
    localparam WIDTH_QLN2 = 'd5;  // in softmax, qln2_min = 5.0 qln2_max = 12.0  qln2_width = 5.0; 
    localparam WIDTH_Z = 'd7;     // in softmax, z_min = 0 z_max = 51.0  z_width = 7.0
    localparam WIDTH_Z_DIV = 'd16; // WIDTH_Z = 'd7, but for divider_9_5 (16bit+8bit output), the output int should be 16bit 
    localparam WIDTH_QP = 'd11;   // in softmax, qp_min = -256.0 qp_max = 612.0  qp_width = 11.0
    localparam WIDTH_QL = 'd24;   // in softmax, ql_min = 131.0 ql_max = 5308721.0  ql_width = 24.0
    localparam WIDTH_QB = WIDTH_QP;
    localparam WIDTH_QC = 'd24;

    // parameter for nnlut_exp
    localparam x_WIDTH = 8;
    localparam k_WIDTH = 32;
    localparam b_WIDTH = 32; 
    localparam result_WIDTH = x_WIDTH + k_WIDTH + 1; // 41, 8bitxx * 32bit k + 32 bit b
    localparam bp_NUM = 16;   //breakpoint的数�??????

    (* dont_touch = "true" *) wire  signed [WIDTH_Q * DIMENTION - 1   :   0]                  q;  
    (* dont_touch = "true" *) wire  signed [WIDTH_QLN2 - 1   :   0]                           qln2;    
    (* dont_touch = "true" *) wire  signed [WIDTH_QB - 1   :   0]                             qb; 
    (* dont_touch = "true" *) wire  signed [WIDTH_QC - 1   :   0]                             qc;   
    (* dont_touch = "true" *) wire                                                            input_valid_n;
    // softmax valid num
    (* dont_touch = "true" *) wire         [7              :   0]                             INPUT_DIMENSION;
    wire signed [WIDTH_QSOFTMAX_QUANT * DIMENTION - 1 :   0]  softmax_quant;
    wire                                                      softmax_quant_valid_n;

    nnlut_softmax_128_quant u_2 (clk_p, rst_n, q, qln2, qb, qc, input_valid_n, INPUT_DIMENSION, softmax_quant, softmax_quant_valid_n);


    // pe
    // parameter pe_INPUT_WIDTH   =   'd8;
    // parameter pe_OUTPUT_WIDTH  =   pe_INPUT_WIDTH + 'd14;

    // (* dont_touch = "true" *) wire                                                      done;
    // (* dont_touch = "true" *) wire                      [pe_INPUT_WIDTH - 1 : 0]           input_A;
    // (* dont_touch = "true" *) wire                      [pe_INPUT_WIDTH - 1 : 0]           input_B;
    // (* dont_touch = "true" *) wire                      [pe_INPUT_WIDTH - 1 : 0]           input_D;
    // wire                      [pe_OUTPUT_WIDTH - 1 : 0]          resulta;
    // wire            [pe_OUTPUT_WIDTH - 1 : 0]          resultb;
    // wire            [16 : 0]                        P_change_sign_1;
    // wire            [16 : 0]                        P_change_sign_2;
    // wire           [47 : 0]                        P;
    // wire           [47 : 0]                        C_in;
    // wire           [6 : 0]                        result_h_1;
    // wire           [6 : 0]                        result_h_2;

    // pe u_3 (clk_p, done, input_A, input_B, input_D, rst_n, resulta, resultb, P_change_sign_1, P_change_sign_2, P, 
    //         C_in, result_h_1, result_h_2);



    // pe_array
    localparam    NUM_ROW = 'd128;
    localparam    NUM_COL = 'd64;
    localparam    WIDTH_DATA = 'd8;
    localparam    NUM_PE_ROW = 'd64;
    localparam    NUM_PE_COL = 'd64;    // 128/2=64
    
    wire           [NUM_ROW * WIDTH_DATA - 1 : 0]                        data_row;
    wire           [NUM_COL * WIDTH_DATA - 1 : 0]                        data_col;
    wire                                                                 r_c_sel;    // read data from fifo by row or col, 0 by row, 1 by col
    wire           [0 : NUM_COL * WIDTH_DATA - 1]                        pe_array_result_row;
    wire           [0 : NUM_ROW * WIDTH_DATA - 1]                        pe_array_result_col;
    
    dsp_pe_array #(.NUM_ROW(NUM_ROW), .NUM_COL(NUM_COL), .WIDTH_DATA(WIDTH_DATA), .NUM_PE_ROW(NUM_PE_ROW), .NUM_PE_COL(NUM_PE_COL)) 
                   (clk_p, rst_n, data_row, data_col, r_c_sel, pe_array_result_row, pe_array_result_col);


    // assign vd = (|result) | result_valid_n | (|gelu) | gelu_valid_n | (|softmax_quant) | softmax_quant_valid_n | (|resulta) | 
    //             (|resultb) | (P_change_sign_1) | (P_change_sign_2) | (|P) | (|C_in) | (|result_h_1) | (|result_h_2);


    assign vd = (|result) | result_valid_n | (|gelu) | gelu_valid_n | (|softmax_quant) | softmax_quant_valid_n | (|pe_array_result_row) | (|pe_array_result_col);


    // assign vd = (|gelu) | gelu_valid_n | (|softmax_quant) | softmax_quant_valid_n;

endmodule