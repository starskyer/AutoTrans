`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2023/3/6 16:40
// Module Name: nnlut_softmax_128_quant
// Description: 
// integer-only cal of softmax cal of I-BERT: exp, div are calculated by the nn-lut method
// quantization at the output end, first quant to 32bit, then quant to 8bit**
// timing logic, 14 clk total:
//      pipeline 1(clk 1):      qmax = max(q)
//      pipeline 2(clk 2):      qq = q - qmax
//      pipeline 3(clk 3-4):    quant qq to 8bit, exp cal by nn-lut, qexp quant to 41 --> 24 bit, qexp_set0 = qexp * 2^31 with outline part set to 0
//      pipeline 4(clk 5-11):   qsum = adder_128(qexp_set0) 
//      pipeline 5(clk 12-13):  interval_32bit = floor(qsum/2^31),  
//                              quant interval_32bit to 8bit, 
//                              nnlut_div = 1/interval_8bit (div cal by nn-lut)
//      pipeline 6(clk 14):     qsoftmax_quant_32bit = nnlut_div * qexp_set0 (41bit * 55bit = 96bit)
//                              qsoftmax_quant = qsoftmax_quant_32bit >> 88 (8bit)
// the input/output of each pipeline are all concate to be a long var
// called module:
//      maximum
//      2 adder_64
//      2 i_exp_64
//      adder_128
//      128 divider_55_33
// default dimension: 128
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

module nnlut_softmax_128_quant
#(
    parameter DIMENTION = 'd128, 
    parameter DIMENTION_EXP = 'd64, 
    parameter NUM = 'd2,
    parameter WIDTH_Q = 'd8,              // in softmax, input q is from former MM, 8bit
    parameter WIDTH_QQ = 'd9,             // in softmax, qq_min = -256 qq_max = 0 qq_width = 9
    parameter WIDTH_QEXP = 'd24,          // in softmax, qexp_min = 0 qexp_max = 5308721.0  qexp_width = 24.0
    parameter WIDTH_QSUM = 'd64,          // in softmax, qsum_min = 0 qsum_max = 4077097728.0  qsum_width = 33.0  + 31 
    parameter WIDTH_INTERVAL = 'd33,      // in softmax, interval_min = 0.0 interval_max = 32103132.0  interval_width = 33
    parameter WIDTH_QSOFTMAX_QUANT = 'd8,  // in softmax_quant, qsoftmax_quant_min = 0 qsoftmax_quant_max = 127  qsoftmax_quant_width = 8

    // parameters for i-exp
    parameter WIDTH_QLN2 = 'd5,  // in softmax, qln2_min = 5.0 qln2_max = 12.0  qln2_width = 5.0; 
    parameter WIDTH_Z = 'd7,     // in softmax, z_min = 0 z_max = 51.0  z_width = 7.0
    parameter WIDTH_Z_DIV = 'd16, // WIDTH_Z = 'd7, but for divider_9_5 (16bit+8bit output), the output int should be 16bit 
    parameter WIDTH_QP = 'd11,   // in softmax, qp_min = -256.0 qp_max = 612.0  qp_width = 11.0
    parameter WIDTH_QL = 'd24,   // in softmax, ql_min = 131.0 ql_max = 5308721.0  ql_width = 24.0
    parameter WIDTH_QB = WIDTH_QP,
    parameter WIDTH_QC = 'd24,

    // parameter for nnlut_exp
    parameter x_WIDTH = 8,
    parameter k_WIDTH = 32,
    parameter b_WIDTH = 32, 
    parameter result_WIDTH = x_WIDTH + k_WIDTH + 1, // 41, 8bitxx * 32bit k + 32 bit b
    parameter bp_NUM = 16   //breakpoint的数�??????
)
(
//********************************* System Signal *********************************
    input                                                           clk_p,
    input                                                           rst_n,
//********************************* Input Signal *********************************
    input  signed [WIDTH_Q * DIMENTION - 1   :   0]                  q,  
    input  signed [WIDTH_QLN2 - 1   :   0]                           qln2,    
    input  signed [WIDTH_QB - 1   :   0]                             qb, 
    input  signed [WIDTH_QC - 1   :   0]                             qc,    
    input                                                            input_valid_n,
    // softmax valid num
    input         [7              :   0]                             INPUT_DIMENSION,
//********************************* Output Signal *********************************
    output wire signed [WIDTH_QSOFTMAX_QUANT * DIMENTION - 1 :   0]  softmax_quant,
    output wire                                                      softmax_quant_valid_n  
);

//********************************* Middle Signal *********************************
    wire     signed   [WIDTH_Q - 1 :   0]                            qmax;
    reg      signed   [WIDTH_QQ * DIMENTION - 1   :   0]             qq; 
    wire     signed   [WIDTH_QEXP * DIMENTION - 1   :   0]           qexp;
    wire     signed   [WIDTH_QSUM - 1   :   0]                       qsum;
    wire     signed   [WIDTH_INTERVAL - 1   :   0]                   interval;

//************** Pipeline Output Enable Signal, 6 pipelines total *****************
    reg                                                              en_p1_n;  // qmax = max(q)
    reg                                                              en_p2_n;  // qq = q - qmax
    wire                                                             en_p3_n;  // qexp = i-exp(qq)
    wire                                                             en_p4_n;  // qsum = adder_768(qexp) 
    wire                                                             en_p5_n;  // interval_32bit = floor(qsum/2^31), quant interval_32bit to 8bit,  nnlut_div = 1/interval_8bit (div cal by nn-lut)
    reg                                                              en_p6_n;  // qsoftmax_quant_32bit = nnlut_div * qexp_set0 (41bit * 55bit = 96bit), qsoftmax_quant = qsoftmax_quant_32bit >> 88 (8bit)

//********************************* Loop Integer *********************************
    genvar                                                           i, j, k, m, n, r, h, o, p, u;

//********************************* latency reg  *********************************
    // We also need qexp with 11 clk delayed, which is realized by FIFO
    reg  signed [WIDTH_Q * DIMENTION - 1   :   0]                    q_reg1;

    reg  signed [WIDTH_QLN2 - 1            :   0]                    qln2_reg1;
    reg  signed [WIDTH_QLN2 - 1            :   0]                    qln2_reg2;

    reg  signed [WIDTH_QB - 1              :   0]                    qb_reg1;
    reg  signed [WIDTH_QB - 1              :   0]                    qb_reg2;

    reg  signed [WIDTH_QC - 1              :   0]                    qc_reg1;
    reg  signed [WIDTH_QC - 1              :   0]                    qc_reg2;

    reg  signed [(WIDTH_QEXP + 31) * DIMENTION - 1   :   0]                 qexp_set0_reg1;
    reg  signed [(WIDTH_QEXP + 31) * DIMENTION - 1   :   0]                 qexp_set0_reg2;
    reg  signed [(WIDTH_QEXP + 31) * DIMENTION - 1   :   0]                 qexp_set0_reg3;
    reg  signed [(WIDTH_QEXP + 31) * DIMENTION - 1   :   0]                 qexp_set0_reg4;
    reg  signed [(WIDTH_QEXP + 31) * DIMENTION - 1   :   0]                 qexp_set0_reg5;
    reg  signed [(WIDTH_QEXP + 31) * DIMENTION - 1   :   0]                 qexp_set0_reg6;
    reg  signed [(WIDTH_QEXP + 31) * DIMENTION - 1   :   0]                 qexp_set0_reg7;
    reg  signed [(WIDTH_QEXP + 31) * DIMENTION - 1   :   0]                 qexp_set0_reg8;


    assign softmax_quant_valid_n = en_p6_n;
// ----------------------------------- Enable Signal Logic ------------------------------------
    always @(posedge clk_p or negedge rst_n) begin
        if(!rst_n) begin 
            en_p1_n <= 'b1;
        end
        else begin
            en_p1_n <= (!input_valid_n) ? 0 : 1;
        end
    end
    always @(posedge clk_p or negedge rst_n) begin
        if(!rst_n) begin 
            en_p2_n <= 'b1;
        end
        else begin
            en_p2_n <= (!en_p1_n) ? 0 : 1;
        end
    end
    always @(posedge clk_p or negedge rst_n) begin
        if(!rst_n) begin 
            en_p6_n <= 'b1;
        end
        else begin
            en_p6_n <= (!en_p5_n) ? 0 : 1;
        end
    end

// ------------------------- reg latency logic -----------------------
    always @(posedge clk_p or negedge rst_n) begin
        if(!rst_n) begin 
            q_reg1 <= 'd0;
        end
        else begin
            q_reg1 <= q;
        end
    end
    always @(posedge clk_p or negedge rst_n) begin
        if(!rst_n) begin 
            qln2_reg1 <= 'd0;
            qln2_reg2 <= 'd0;
        end
        else begin
            qln2_reg1 <= qln2;
            qln2_reg2 <= qln2_reg1;
        end
    end
    always @(posedge clk_p or negedge rst_n) begin
        if(!rst_n) begin 
            qb_reg1 <= 'd0;
            qb_reg2 <= 'd0;
        
            qc_reg1 <= 'd0;
            qc_reg2 <= 'd0;
        end
        else begin
            qb_reg1 <= qb;
            qb_reg2 <= qb_reg1;
            
            qc_reg1 <= qc;
            qc_reg2 <= qc_reg1;
        end
    end


    // ----------------------------------------------- Pipeline Begin ----------------------------------------------
    // pipeline 1(clk 1):      qmax = max(q)
    maximum #(.NUM(DIMENTION), .WIDTH_MAX_INPUT(WIDTH_Q), .WIDTH_MAX_OUTPUT(WIDTH_Q)) u_softmax_p1_maximum 
             (.inputend(q), 
              .max(qmax));

    reg     signed   [WIDTH_Q - 1 :   0]                            qmax_mem; 
    always @(posedge clk_p or negedge rst_n) begin
        if (!rst_n) begin
            qmax_mem <= 'd0;
        end
        else begin
            qmax_mem <= (!input_valid_n) ? qmax : 0;
        end
    end


    // pipeline 2(clk 2):      qq = q - qmax
    wire     signed   [WIDTH_Q * DIMENTION_EXP - 1 :   0]            q_reg1_mem          [NUM - 1   :   0]; 
    assign {q_reg1_mem[0], q_reg1_mem[1]} 
            = q_reg1;

    wire     signed   [WIDTH_Q * DIMENTION_EXP - 1 :   0]            minus_qmax_mem_64;
    assign   minus_qmax_mem_64 = {64{-qmax_mem}};


    wire     signed   [WIDTH_QQ * DIMENTION_EXP - 1 :   0]           qq_mem         [NUM - 1   :   0];     

    generate
        for(i = 0; i < NUM ; i = i + 1) begin: inst_2_adder64
            adder_64 #(.DIMENTION(DIMENTION_EXP), .WIDTH_ADDEND(WIDTH_Q), .WIDTH_SUM(WIDTH_QQ)) u_softmax_p2_adder_64 
            (.addend1(q_reg1_mem[i]), .addend2(minus_qmax_mem_64),
            .sum(qq_mem[i]));
        end
    endgenerate

    always @(posedge clk_p or negedge rst_n) begin
        if (!rst_n) begin
            qq <= 'd0;
        end
        else begin
            qq <= (!en_p1_n) ? {qq_mem[0], qq_mem[1]} : 0;
        end
    end


    // pipeline 3(clk 3-4):    quant qq to 8bit, exp cal by nn-lut, qexp quant to 41 --> 24 bit, qexp_set0 = qexp * 2^31 with outline part set to 0
    wire     [NUM - 1 : 0]    en_p3_n_mem;  
    wire     signed   [WIDTH_QQ  - 1 :   0]              qq_mem_128         [DIMENTION - 1   :   0];
    assign {qq_mem[0], qq_mem[1], qq_mem[2], qq_mem[3], qq_mem[4], qq_mem[5], qq_mem[6], qq_mem[7], 
            qq_mem[8], qq_mem[9], qq_mem[10], qq_mem[11], qq_mem[12], qq_mem[13], qq_mem[14], qq_mem[15], 
            qq_mem[16], qq_mem[17], qq_mem[18], qq_mem[19], qq_mem[20], qq_mem[21], qq_mem[22], qq_mem[23], 
            qq_mem[24], qq_mem[25], qq_mem[26], qq_mem[27], qq_mem[28], qq_mem[29], qq_mem[30], qq_mem[31], 
            qq_mem[32], qq_mem[33], qq_mem[34], qq_mem[35], qq_mem[36], qq_mem[37], qq_mem[38], qq_mem[39], 
            qq_mem[40], qq_mem[41], qq_mem[42], qq_mem[43], qq_mem[44], qq_mem[45], qq_mem[46], qq_mem[47], 
            qq_mem[48], qq_mem[49], qq_mem[50], qq_mem[51], qq_mem[52], qq_mem[53], qq_mem[54], qq_mem[55], 
            qq_mem[56], qq_mem[57], qq_mem[58], qq_mem[59], qq_mem[60], qq_mem[61], qq_mem[62], qq_mem[63], 
            qq_mem[64], qq_mem[65], qq_mem[66], qq_mem[67], qq_mem[68], qq_mem[69], qq_mem[70], qq_mem[71], 
            qq_mem[72], qq_mem[73], qq_mem[74], qq_mem[75], qq_mem[76], qq_mem[77], qq_mem[78], qq_mem[79], 
            qq_mem[80], qq_mem[81], qq_mem[82], qq_mem[83], qq_mem[84], qq_mem[85], qq_mem[86], qq_mem[87], 
            qq_mem[88], qq_mem[89], qq_mem[90], qq_mem[91], qq_mem[92], qq_mem[93], qq_mem[94], qq_mem[95], 
            qq_mem[96], qq_mem[97], qq_mem[98], qq_mem[99], qq_mem[100], qq_mem[101], qq_mem[102], qq_mem[103], 
            qq_mem[104], qq_mem[105], qq_mem[106], qq_mem[107], qq_mem[108], qq_mem[109], qq_mem[110], qq_mem[111], 
            qq_mem[112], qq_mem[113], qq_mem[114], qq_mem[115], qq_mem[116], qq_mem[117], qq_mem[118], qq_mem[119], 
            qq_mem[120], qq_mem[121], qq_mem[122], qq_mem[123], qq_mem[124], qq_mem[125], qq_mem[126], qq_mem[127]} 
            = qq;

    wire     signed   [x_WIDTH  - 1 :   0]             qq_mem_8bit       [DIMENTION - 1   :   0];

    generate
        for(u = 0; u < DIMENTION ; u = u + 1) begin: quant_qq_to_8bit
            assign qq_mem_8bit[u] = qq_mem_128[u] >> (WIDTH_QQ - x_WIDTH);
        end
    endgenerate

    wire              [DIMENTION - 1 : 0]              nnlut_valid_n;
    wire     signed   [result_WIDTH - 1 :   0]         qexp_mem          [DIMENTION - 1   :   0];
    generate
        for(j = 0; j < DIMENTION ; j = j + 1) begin: inst_128_nnlut
            nnlut_exp #(.x_WIDTH(x_WIDTH), .k_WIDTH(k_WIDTH), .b_WIDTH(b_WIDTH), .result_WIDTH(result_WIDTH), .bp_NUM(bp_NUM)) u_nnlut
                   (.clk_p(clk_p), .rst_n(rst_n),
                    .x(qq_mem_8bit[j]), .input_valid_n(en_p2_n), 
                    .result(qexp_mem[j]), .nnlut_valid_n(nnlut_valid_n[j]));
        end
    endgenerate

    assign en_p3_n = (!nnlut_valid_n) ? 0 : 1;

    // quant nnlut_exp output to 24 bit
    wire     signed   [WIDTH_QEXP - 1 :   0]           qexp_mem_p4    [DIMENTION - 1   :   0];
    generate
        for(h = 0; h < DIMENTION ; h = h + 1) begin: qexp_nnlut_quant
            assign qexp_mem_p4[h] = qexp_mem[h] >> (result_WIDTH - WIDTH_QEXP);
        end
    endgenerate


    // set the exp value of outline part to 0
    // for example,if there are 49 valid input word
    // then the LSB 79 qexp are set to 0
    // the HSB 49 qexp are qexp * 2^31 (for later cal of quant interval)
    wire signed   [WIDTH_QEXP + 30 :   0]         qexp_mem_p4_set0          [DIMENTION - 1   :   0];
    generate
        for(n = 0; n < DIMENTION ; n = n + 1) begin: set_exp_outline_to0
            assign qexp_mem_p4_set0[n] = (DIMENTION - 1 - n >= INPUT_DIMENSION) ? 0 : (qexp_mem_p4[n] << 31);
        end
    endgenerate

    wire     signed   [(WIDTH_QEXP + 31) * DIMENTION - 1   :   0]           qexp_set0;
    assign qexp_set0 = {qexp_mem_p4_set0[0], qexp_mem_p4_set0[1], qexp_mem_p4_set0[2], qexp_mem_p4_set0[3], qexp_mem_p4_set0[4], qexp_mem_p4_set0[5], qexp_mem_p4_set0[6], qexp_mem_p4_set0[7], 
             qexp_mem_p4_set0[8], qexp_mem_p4_set0[9], qexp_mem_p4_set0[10], qexp_mem_p4_set0[11], qexp_mem_p4_set0[12], qexp_mem_p4_set0[13], qexp_mem_p4_set0[14], qexp_mem_p4_set0[15], 
             qexp_mem_p4_set0[16], qexp_mem_p4_set0[17], qexp_mem_p4_set0[18], qexp_mem_p4_set0[19], qexp_mem_p4_set0[20], qexp_mem_p4_set0[21], qexp_mem_p4_set0[22], qexp_mem_p4_set0[23], 
             qexp_mem_p4_set0[24], qexp_mem_p4_set0[25], qexp_mem_p4_set0[26], qexp_mem_p4_set0[27], qexp_mem_p4_set0[28], qexp_mem_p4_set0[29], qexp_mem_p4_set0[30], qexp_mem_p4_set0[31], 
             qexp_mem_p4_set0[32], qexp_mem_p4_set0[33], qexp_mem_p4_set0[34], qexp_mem_p4_set0[35], qexp_mem_p4_set0[36], qexp_mem_p4_set0[37], qexp_mem_p4_set0[38], qexp_mem_p4_set0[39], 
             qexp_mem_p4_set0[40], qexp_mem_p4_set0[41], qexp_mem_p4_set0[42], qexp_mem_p4_set0[43], qexp_mem_p4_set0[44], qexp_mem_p4_set0[45], qexp_mem_p4_set0[46], qexp_mem_p4_set0[47], 
             qexp_mem_p4_set0[48], qexp_mem_p4_set0[49], qexp_mem_p4_set0[50], qexp_mem_p4_set0[51], qexp_mem_p4_set0[52], qexp_mem_p4_set0[53], qexp_mem_p4_set0[54], qexp_mem_p4_set0[55], 
             qexp_mem_p4_set0[56], qexp_mem_p4_set0[57], qexp_mem_p4_set0[58], qexp_mem_p4_set0[59], qexp_mem_p4_set0[60], qexp_mem_p4_set0[61], qexp_mem_p4_set0[62], qexp_mem_p4_set0[63], 
             qexp_mem_p4_set0[64], qexp_mem_p4_set0[65], qexp_mem_p4_set0[66], qexp_mem_p4_set0[67], qexp_mem_p4_set0[68], qexp_mem_p4_set0[69], qexp_mem_p4_set0[70], qexp_mem_p4_set0[71], 
             qexp_mem_p4_set0[72], qexp_mem_p4_set0[73], qexp_mem_p4_set0[74], qexp_mem_p4_set0[75], qexp_mem_p4_set0[76], qexp_mem_p4_set0[77], qexp_mem_p4_set0[78], qexp_mem_p4_set0[79], 
             qexp_mem_p4_set0[80], qexp_mem_p4_set0[81], qexp_mem_p4_set0[82], qexp_mem_p4_set0[83], qexp_mem_p4_set0[84], qexp_mem_p4_set0[85], qexp_mem_p4_set0[86], qexp_mem_p4_set0[87], 
             qexp_mem_p4_set0[88], qexp_mem_p4_set0[89], qexp_mem_p4_set0[90], qexp_mem_p4_set0[91], qexp_mem_p4_set0[92], qexp_mem_p4_set0[93], qexp_mem_p4_set0[94], qexp_mem_p4_set0[95], 
             qexp_mem_p4_set0[96], qexp_mem_p4_set0[97], qexp_mem_p4_set0[98], qexp_mem_p4_set0[99], qexp_mem_p4_set0[100], qexp_mem_p4_set0[101], qexp_mem_p4_set0[102], qexp_mem_p4_set0[103], 
             qexp_mem_p4_set0[104], qexp_mem_p4_set0[105], qexp_mem_p4_set0[106], qexp_mem_p4_set0[107], qexp_mem_p4_set0[108], qexp_mem_p4_set0[109], qexp_mem_p4_set0[110], qexp_mem_p4_set0[111], 
             qexp_mem_p4_set0[112], qexp_mem_p4_set0[113], qexp_mem_p4_set0[114], qexp_mem_p4_set0[115], qexp_mem_p4_set0[116], qexp_mem_p4_set0[117], qexp_mem_p4_set0[118], qexp_mem_p4_set0[119], 
             qexp_mem_p4_set0[120], qexp_mem_p4_set0[121], qexp_mem_p4_set0[122], qexp_mem_p4_set0[123], qexp_mem_p4_set0[124], qexp_mem_p4_set0[125], qexp_mem_p4_set0[126], qexp_mem_p4_set0[127]
            };

    always @(posedge clk_p or negedge rst_n) begin
        if(!rst_n) begin 
            qexp_set0_reg1 <= 'd0;
            qexp_set0_reg2 <= 'd0;
            qexp_set0_reg3 <= 'd0;
            qexp_set0_reg4 <= 'd0;
            qexp_set0_reg5 <= 'd0;
            qexp_set0_reg6 <= 'd0;
            qexp_set0_reg7 <= 'd0;
            qexp_set0_reg8 <= 'd0;
        end
        else begin
            qexp_set0_reg1 <= qexp_set0;
            qexp_set0_reg2 <= qexp_set0_reg1;
            qexp_set0_reg3 <= qexp_set0_reg2;
            qexp_set0_reg4 <= qexp_set0_reg3;
            qexp_set0_reg5 <= qexp_set0_reg4;
            qexp_set0_reg6 <= qexp_set0_reg5;
            qexp_set0_reg7 <= qexp_set0_reg6;
            qexp_set0_reg8 <= qexp_set0_reg7;
        end
    end

    // pipeline 4(clk 5-11):  qsum = adder_128(qexp_set0)
    adder_128 #(.NUM_ADDERTREE(NUM), .ADDEND_WIDTH(WIDTH_QEXP + 31), .TREE_DIMENTION(DIMENTION_EXP), .SUM_WIDTH(WIDTH_QSUM)) u_softmax_p4_adder_128
    (.clk_p(clk_p), .rst_n(rst_n),
     .addend(qexp_set0), .addend_valid_n(en_p3_n),
     .sum(qsum), .sum_valid_n(en_p4_n));

    
    // pipeline 5(clk 12-13):     interval_32bit = floor(qsum/2^31),  
    //                         quant interval_32bit to 8bit, 
    //                         nnlut_div = 1/interval_8bit (div cal by nn-lut)
    assign   interval = qsum >> 31;  // interval = floor(qsum/2^31), 33bit
    wire     signed   [x_WIDTH - 1   :   0]       interval_8bit;
    assign   interval_8bit = interval >> (WIDTH_INTERVAL - x_WIDTH);

    wire     [result_WIDTH - 1 : 0]               nnlut_div;
    
    nnlut_div #(.x_WIDTH(x_WIDTH), .k_WIDTH(k_WIDTH), .b_WIDTH(b_WIDTH), .result_WIDTH(result_WIDTH), .bp_NUM(bp_NUM)) u_nnlut
               (.clk_p(clk_p), .rst_n(rst_n),
                .x(interval_8bit), .input_valid_n(en_p4_n), 
                .result(nnlut_div), .nnlut_valid_n(en_p5_n));


    // pipeline 6(clk 14):     qsoftmax_quant_32bit = nnlut_div * qexp_set0 (41bit * 55bit = 96bit)
    //                         qsoftmax_quant = qsoftmax_quant_32bit >> 88 (8bit)
    wire signed   [WIDTH_QEXP + 30 :   0]         qexp_reg8_mem_p6          [DIMENTION - 1   :   0];
    assign  {qexp_reg8_mem_p6[0], qexp_reg8_mem_p6[1], qexp_reg8_mem_p6[2], qexp_reg8_mem_p6[3], qexp_reg8_mem_p6[4], qexp_reg8_mem_p6[5], qexp_reg8_mem_p6[6], qexp_reg8_mem_p6[7], 
             qexp_reg8_mem_p6[8], qexp_reg8_mem_p6[9], qexp_reg8_mem_p6[10], qexp_reg8_mem_p6[11], qexp_reg8_mem_p6[12], qexp_reg8_mem_p6[13], qexp_reg8_mem_p6[14], qexp_reg8_mem_p6[15], 
             qexp_reg8_mem_p6[16], qexp_reg8_mem_p6[17], qexp_reg8_mem_p6[18], qexp_reg8_mem_p6[19], qexp_reg8_mem_p6[20], qexp_reg8_mem_p6[21], qexp_reg8_mem_p6[22], qexp_reg8_mem_p6[23], 
             qexp_reg8_mem_p6[24], qexp_reg8_mem_p6[25], qexp_reg8_mem_p6[26], qexp_reg8_mem_p6[27], qexp_reg8_mem_p6[28], qexp_reg8_mem_p6[29], qexp_reg8_mem_p6[30], qexp_reg8_mem_p6[31], 
             qexp_reg8_mem_p6[32], qexp_reg8_mem_p6[33], qexp_reg8_mem_p6[34], qexp_reg8_mem_p6[35], qexp_reg8_mem_p6[36], qexp_reg8_mem_p6[37], qexp_reg8_mem_p6[38], qexp_reg8_mem_p6[39], 
             qexp_reg8_mem_p6[40], qexp_reg8_mem_p6[41], qexp_reg8_mem_p6[42], qexp_reg8_mem_p6[43], qexp_reg8_mem_p6[44], qexp_reg8_mem_p6[45], qexp_reg8_mem_p6[46], qexp_reg8_mem_p6[47], 
             qexp_reg8_mem_p6[48], qexp_reg8_mem_p6[49], qexp_reg8_mem_p6[50], qexp_reg8_mem_p6[51], qexp_reg8_mem_p6[52], qexp_reg8_mem_p6[53], qexp_reg8_mem_p6[54], qexp_reg8_mem_p6[55], 
             qexp_reg8_mem_p6[56], qexp_reg8_mem_p6[57], qexp_reg8_mem_p6[58], qexp_reg8_mem_p6[59], qexp_reg8_mem_p6[60], qexp_reg8_mem_p6[61], qexp_reg8_mem_p6[62], qexp_reg8_mem_p6[63], 
             qexp_reg8_mem_p6[64], qexp_reg8_mem_p6[65], qexp_reg8_mem_p6[66], qexp_reg8_mem_p6[67], qexp_reg8_mem_p6[68], qexp_reg8_mem_p6[69], qexp_reg8_mem_p6[70], qexp_reg8_mem_p6[71], 
             qexp_reg8_mem_p6[72], qexp_reg8_mem_p6[73], qexp_reg8_mem_p6[74], qexp_reg8_mem_p6[75], qexp_reg8_mem_p6[76], qexp_reg8_mem_p6[77], qexp_reg8_mem_p6[78], qexp_reg8_mem_p6[79], 
             qexp_reg8_mem_p6[80], qexp_reg8_mem_p6[81], qexp_reg8_mem_p6[82], qexp_reg8_mem_p6[83], qexp_reg8_mem_p6[84], qexp_reg8_mem_p6[85], qexp_reg8_mem_p6[86], qexp_reg8_mem_p6[87], 
             qexp_reg8_mem_p6[88], qexp_reg8_mem_p6[89], qexp_reg8_mem_p6[90], qexp_reg8_mem_p6[91], qexp_reg8_mem_p6[92], qexp_reg8_mem_p6[93], qexp_reg8_mem_p6[94], qexp_reg8_mem_p6[95], 
             qexp_reg8_mem_p6[96], qexp_reg8_mem_p6[97], qexp_reg8_mem_p6[98], qexp_reg8_mem_p6[99], qexp_reg8_mem_p6[100], qexp_reg8_mem_p6[101], qexp_reg8_mem_p6[102], qexp_reg8_mem_p6[103], 
             qexp_reg8_mem_p6[104], qexp_reg8_mem_p6[105], qexp_reg8_mem_p6[106], qexp_reg8_mem_p6[107], qexp_reg8_mem_p6[108], qexp_reg8_mem_p6[109], qexp_reg8_mem_p6[110], qexp_reg8_mem_p6[111], 
             qexp_reg8_mem_p6[112], qexp_reg8_mem_p6[113], qexp_reg8_mem_p6[114], qexp_reg8_mem_p6[115], qexp_reg8_mem_p6[116], qexp_reg8_mem_p6[117], qexp_reg8_mem_p6[118], qexp_reg8_mem_p6[119], 
             qexp_reg8_mem_p6[120], qexp_reg8_mem_p6[121], qexp_reg8_mem_p6[122], qexp_reg8_mem_p6[123], qexp_reg8_mem_p6[124], qexp_reg8_mem_p6[125], qexp_reg8_mem_p6[126], qexp_reg8_mem_p6[127]} 
            = qexp_set0_reg8;
    // qexp_reg7_mem_p5

    wire signed [WIDTH_QEXP + 31 + result_WIDTH - 1 :   0]   qsoftmax_quant_32bit_mem    [DIMENTION - 1 : 0]; 

    generate
        for(o = 0; o < DIMENTION ; o = o + 1) begin: inst_128_mul_41_55
            mul_41_55 u_softmax_mul_41_55 (.A(nnlut_div), .B(qexp_reg8_mem_p6[o]), .P(qsoftmax_quant_32bit_mem[o]));
        end
    endgenerate

    wire signed [WIDTH_QSOFTMAX_QUANT - 1 : 0]               softmax_quant_mem           [DIMENTION - 1 : 0]; 

    generate
        for(p = 0; p < DIMENTION ; p = p + 1) begin: quant_to_8bit_128
            assign softmax_quant_mem[p] = (!en_p5_n) ? (qsoftmax_quant_32bit_mem[p] >> (WIDTH_QEXP + 31 + result_WIDTH - WIDTH_QSOFTMAX_QUANT)) : 'd0;
        end
    endgenerate

    assign softmax_quant = {softmax_quant_mem[0], softmax_quant_mem[1], softmax_quant_mem[2], softmax_quant_mem[3], softmax_quant_mem[4], softmax_quant_mem[5], softmax_quant_mem[6], softmax_quant_mem[7], 
             softmax_quant_mem[8], softmax_quant_mem[9], softmax_quant_mem[10], softmax_quant_mem[11], softmax_quant_mem[12], softmax_quant_mem[13], softmax_quant_mem[14], softmax_quant_mem[15], 
             softmax_quant_mem[16], softmax_quant_mem[17], softmax_quant_mem[18], softmax_quant_mem[19], softmax_quant_mem[20], softmax_quant_mem[21], softmax_quant_mem[22], softmax_quant_mem[23], 
             softmax_quant_mem[24], softmax_quant_mem[25], softmax_quant_mem[26], softmax_quant_mem[27], softmax_quant_mem[28], softmax_quant_mem[29], softmax_quant_mem[30], softmax_quant_mem[31], 
             softmax_quant_mem[32], softmax_quant_mem[33], softmax_quant_mem[34], softmax_quant_mem[35], softmax_quant_mem[36], softmax_quant_mem[37], softmax_quant_mem[38], softmax_quant_mem[39], 
             softmax_quant_mem[40], softmax_quant_mem[41], softmax_quant_mem[42], softmax_quant_mem[43], softmax_quant_mem[44], softmax_quant_mem[45], softmax_quant_mem[46], softmax_quant_mem[47], 
             softmax_quant_mem[48], softmax_quant_mem[49], softmax_quant_mem[50], softmax_quant_mem[51], softmax_quant_mem[52], softmax_quant_mem[53], softmax_quant_mem[54], softmax_quant_mem[55], 
             softmax_quant_mem[56], softmax_quant_mem[57], softmax_quant_mem[58], softmax_quant_mem[59], softmax_quant_mem[60], softmax_quant_mem[61], softmax_quant_mem[62], softmax_quant_mem[63], 
             softmax_quant_mem[64], softmax_quant_mem[65], softmax_quant_mem[66], softmax_quant_mem[67], softmax_quant_mem[68], softmax_quant_mem[69], softmax_quant_mem[70], softmax_quant_mem[71], 
             softmax_quant_mem[72], softmax_quant_mem[73], softmax_quant_mem[74], softmax_quant_mem[75], softmax_quant_mem[76], softmax_quant_mem[77], softmax_quant_mem[78], softmax_quant_mem[79], 
             softmax_quant_mem[80], softmax_quant_mem[81], softmax_quant_mem[82], softmax_quant_mem[83], softmax_quant_mem[84], softmax_quant_mem[85], softmax_quant_mem[86], softmax_quant_mem[87], 
             softmax_quant_mem[88], softmax_quant_mem[89], softmax_quant_mem[90], softmax_quant_mem[91], softmax_quant_mem[92], softmax_quant_mem[93], softmax_quant_mem[94], softmax_quant_mem[95], 
             softmax_quant_mem[96], softmax_quant_mem[97], softmax_quant_mem[98], softmax_quant_mem[99], softmax_quant_mem[100], softmax_quant_mem[101], softmax_quant_mem[102], softmax_quant_mem[103], 
             softmax_quant_mem[104], softmax_quant_mem[105], softmax_quant_mem[106], softmax_quant_mem[107], softmax_quant_mem[108], softmax_quant_mem[109], softmax_quant_mem[110], softmax_quant_mem[111], 
             softmax_quant_mem[112], softmax_quant_mem[113], softmax_quant_mem[114], softmax_quant_mem[115], softmax_quant_mem[116], softmax_quant_mem[117], softmax_quant_mem[118], softmax_quant_mem[119], 
             softmax_quant_mem[120], softmax_quant_mem[121], softmax_quant_mem[122], softmax_quant_mem[123], softmax_quant_mem[124], softmax_quant_mem[125], softmax_quant_mem[126], softmax_quant_mem[127]
            };


endmodule