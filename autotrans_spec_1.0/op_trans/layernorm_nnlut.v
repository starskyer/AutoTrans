`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////// 
// Create Date: 2022/10/14 10:15:29
// Module Name: layernorm
// Description: 瀹炵幇layernorm鐨勬暣鏁扮畻娉�
// Dependencies: 渚濊禆浜庝互涓嬫ā鍧楋�?
// add_group, adder_768, clip, divide768, (FIFO IP)fifo_8kb_32, long2short, 
// multiplier_group, short2long, reciprocal_24, sqrt_21_11
//////////////////////////////////////////////////////////////////////////////////


module layernorm_nnlut
#(
    parameter   INPUT_WIDTH = 8,
    parameter   INPUT_NUM = 768,
    parameter   OUTPUT_WIDTH = 8
)
(
//*************************************** System signal ***************************************//
    input                                                                           clk_p,
    input                                                                           rst_n,
//*************************************** Input signal ***************************************//
    input                                   [INPUT_WIDTH * INPUT_NUM - 1 : 0]       data,
    input                                                                           data_valid_n,
    input                                   [INPUT_WIDTH * INPUT_NUM - 1 : 0]       w,
    input                                                                           w_valid_n,
    input                                   [INPUT_WIDTH * INPUT_NUM - 1 : 0]       b,
    input                                                                           b_valid_n,
//*************************************** Output signal ***************************************//
    output                                  [OUTPUT_WIDTH * INPUT_NUM - 1 :0]       result,
    output                  reg                                                     result_valid_n    
);
//*************************************** Pipline enable ***************************************//
localparam  LATENCY = 34;
// 娉ㄦ剰杩欓噷涓轰簡绱㈠紩鏂�?�究锛孧SB璁惧湪绱㈠紩1涓�
// pipline_enable[i]鏈夋晥锛屾剰鍛崇潃t = i鐨勬暟鎹湁鏁堬紝涔熷氨鏄痶 = 0杈撳叆鐨勬暟鎹粡鍘嗕簡i clks锛� 浼犻�掑埌绗琲绾ф祦姘磋妭鎷嶄�?

reg                 [1 : LATENCY - 1]       pipline_enable;

always  @(posedge clk_p or negedge rst_n)   begin
    if(~rst_n)  begin
        pipline_enable <= 33'h1ffffffff;
    end
    else    begin
        pipline_enable <= {data_valid_n, pipline_enable[1 : LATENCY - 2]};
    end
end

always  @(posedge clk_p or negedge rst_n)   begin
    if(~rst_n)  begin
        result_valid_n <= 1;
    end
    else    begin
        result_valid_n <= pipline_enable[LATENCY - 1]; 
    end
end

//*************************************** add_768_1(t = 0) ***************************************// 
localparam  SUM1_WIDTH = 18;

wire    signed      [SUM1_WIDTH - 1 : 0]    sum1;
wire                                        sum1_valid_n;

adder_768_zh#(
    .NUM_ADDERTREE  ( 'd12 ),
    .ADDEND_WIDTH   ( INPUT_WIDTH ),
    .TREE_DIMENTION ( 'd64 ),
    .SUM_WIDTH      ( SUM1_WIDTH ),
    .ADD_TREE_LEVEL ( 'd6 )
)u_adder_768_1(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( data         ),
    .addend_valid_n ( data_valid_n ),
    .sum            ( sum1            ),
    .sum_valid_n    ( sum1_valid_n    )
);

//*************************************** divide768_1(t = 10) ***************************************// 
localparam  MEAN1_WIDTH = 9;

wire    signed      [MEAN1_WIDTH - 1 : 0]       mean1_pos;
wire    signed      [MEAN1_WIDTH - 1 : 0]       mean1;
wire                                            mean1_valid_n;

divide768#(
    .INPUT_WIDTH      ( SUM1_WIDTH ),
    .OUTPUT_WIDTH     ( MEAN1_WIDTH )
)u_divide768_1(
    .clk_p            ( clk_p            ),
    .rst_n            ( rst_n            ),
    .dividend         ( sum1         ),
    .dividend_valid_n ( sum1_valid_n ),
    .quotient         ( mean1_pos         ),
    .quotient_valid_n  ( mean1_valid_n  )
);

// 杈撳嚭缁撴灉姹傜浉鍙嶆暟
assign mean1 = -mean1_pos;

//*************************************** fifo1(t = 0) ***************************************//
wire                [INPUT_WIDTH * INPUT_NUM - 1 : 0]   data_r;

fifo_8kb_32#(
    .INPUT_WIDTH      ( INPUT_WIDTH ),
    .INPUT_NUM        ( INPUT_NUM ),
    .FIFO_WIDTH       ( 1024 ),
    .FIFO_NUM         ( 8 )
)u_fifo_8kb_32_1(
    .clk_p            ( clk_p            ),
    .rst_n            ( rst_n            ),
    .data             ( data             ),
    .data_valid_n     ( data_valid_n     ),
    .read_en_n        ( pipline_enable[10]),
    .result           ( data_r           )
);

//*************************************** add_group_1(t = 11) ***************************************// 
localparam  DEVIA_WIDTH = 10;
localparam  ADD_GROUP_NUM = 12;
localparam  NUM_ADDER = 64;

wire                [MEAN1_WIDTH * INPUT_NUM - 1 : 0]   data_r1;
wire                [MEAN1_WIDTH * NUM_ADDER - 1 : 0]   mean1_group           [ADD_GROUP_NUM - 1 : 0];
wire                [MEAN1_WIDTH * NUM_ADDER - 1 : 0]   data_r_group          [ADD_GROUP_NUM - 1 : 0];
wire                [DEVIA_WIDTH * NUM_ADDER - 1 : 0]   devia_group           [ADD_GROUP_NUM - 1 : 0];
wire                [ADD_GROUP_NUM - 1 : 0]             devia_group_valid_n;

assign  {mean1_group[11], mean1_group[10],mean1_group[9],mean1_group[8],
         mean1_group[7], mean1_group[6],mean1_group[5],mean1_group[4],
         mean1_group[3], mean1_group[2],mean1_group[1],mean1_group[0]
        } = {INPUT_NUM{mean1}};

genvar loop1var;
generate
  for (loop1var = 0; loop1var < INPUT_NUM; loop1var = loop1var + 1)
  begin: loop1
     short2long#(
        .INPUT_WIDTH(INPUT_WIDTH), 
        .OUTPUT_WIDTH(MEAN1_WIDTH))
     u_short2long_add_group_1(
        .datain(data_r[(loop1var + 1) * INPUT_WIDTH - 1 : loop1var * INPUT_WIDTH]),
        .dataout(data_r1[(loop1var + 1) * MEAN1_WIDTH - 1 : loop1var * MEAN1_WIDTH])
        );
  end
endgenerate

assign  {data_r_group[11], data_r_group[10], data_r_group[9], data_r_group[8],
        data_r_group[7], data_r_group[6], data_r_group[5], data_r_group[4],
        data_r_group[3], data_r_group[2], data_r_group[1], data_r_group[0]
} = data_r1;

genvar loop2var;
generate
  for (loop2var = 0; loop2var < ADD_GROUP_NUM; loop2var = loop2var + 1)
  begin: loop2
     add_group#(
    .INPUT_WIDTH     ( MEAN1_WIDTH ),
    .OUTPUT_WIDTH    ( DEVIA_WIDTH ),
    .NUM_ADDER       ( 'd64 )
    )u_add_group(
    .clk_p           ( clk_p           ),
    .rst_n           ( rst_n           ),
    .addend1         ( data_r_group[loop2var]          ),
    .addend2         ( mean1_group[loop2var]  ),
    .addend_valid_n ( mean1_valid_n ),
    .sum             ( devia_group[loop2var]             ),
    .sum_valid_n     ( devia_group_valid_n[loop2var]     )
    );
  end
endgenerate


wire        devia_valid_n;
assign      devia_valid_n = |devia_group_valid_n;

//*************************************** multiplier_group(t = 12) ***************************************//
localparam      DEVIA2_WIDTH = 20;
localparam      NUM_MULTIPLIER = 64;
localparam      MULTIPLIER_GROUP_NUM = 12;

wire        [DEVIA2_WIDTH * NUM_MULTIPLIER - 1 : 0]     devia2_group    [MULTIPLIER_GROUP_NUM - 1 : 0];
wire        [MULTIPLIER_GROUP_NUM - 1 : 0]              devia2_group_valid_n;

genvar loop3var;
generate
  for (loop3var = 0; loop3var < MULTIPLIER_GROUP_NUM; loop3var = loop3var + 1)
  begin: loop3
     multiplier_group#(
    .WIDTH_MUL_INPUT1 ( DEVIA_WIDTH ),
    .WIDTH_MUL_INPUT2 ( DEVIA_WIDTH ),
    .NUM_MULTIPLIER   ( 64 )
    )u_multiplier_group_1(
    .clk_p            ( clk_p            ),
    .rst_n            ( rst_n            ),
    .factor1          ( devia_group[loop3var]          ),
    .factor2          ( devia_group[loop3var]          ),
    .factor_valid_n   ( devia_valid_n   ),
    .product          ( devia2_group[loop3var]          ),
    .product_valid_n  ( devia2_group_valid_n[loop3var]  )
    );
  end
endgenerate

// wire        [DEVIA2_WIDTH * NUM_MULTIPLIER - 1 : 0]     devia2_group    [MULTIPLIER_GROUP_NUM - 1 : 0];
// wire        [MULTIPLIER_GROUP_NUM - 1 : 0]              devia2_group_valid_n;

wire        [DEVIA2_WIDTH * NUM_MULTIPLIER * MULTIPLIER_GROUP_NUM - 1 : 0]      devia2;
wire                                                                            devia2_valid_n;

assign  devia2 = {
    devia2_group[11], devia2_group[10], devia2_group[9], devia2_group[8],
    devia2_group[7], devia2_group[6], devia2_group[5], devia2_group[4],
    devia2_group[3], devia2_group[2], devia2_group[1], devia2_group[0]
};
assign  devia2_valid_n = |devia2_group_valid_n;

//*************************************** add_768_2(t = 13) ***************************************//
localparam  DEVIA2SUM_WIDTH = 30;

wire    signed    [DEVIA2SUM_WIDTH - 1 : 0]     devia2sum;
wire                                            devia2sum_valid_n;

adder_768_zh#(
    .ADDEND_WIDTH   ( DEVIA2_WIDTH ),
    .SUM_WIDTH      ( DEVIA2SUM_WIDTH )
)u_adder_768_2(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( devia2         ),
    .addend_valid_n ( devia2_valid_n ),
    .sum            ( devia2sum            ),
    .sum_valid_n    ( devia2sum_valid_n    )
);

//*************************************** devide768_2(t = 23) ***************************************//
localparam  VAR_WIDTH = 21;

wire    signed    [VAR_WIDTH - 1 : 0]   var;
wire                                    var_valid_n;

divide768#(
    .INPUT_WIDTH      ( DEVIA2SUM_WIDTH ),
    .OUTPUT_WIDTH     ( VAR_WIDTH )
)u_divide768(
    .clk_p            ( clk_p            ),
    .rst_n            ( rst_n            ),
    .dividend         ( devia2sum         ),
    .dividend_valid_n ( devia2sum_valid_n ),
    .quotient         ( var         ),
    .quotient_valid_n  ( var_valid_n  )
);

//*************************************** sqrt(t = 24) ***************************************//

wire    signed      [39             :   0]  stdd;
wire                                        stdd_valid_n;
wire                                        var_8;

assign var_8 = var[7 : 0];

nnlut u_nnlut1(
    // input signal
    .clk_p          (clk_p),
    .rst_n          (rst_n),
    .x              (var_8),  
    .input_valid_n  (var_valid_n),
    
    .result         (stdd),
    .nnlut_valid_n  (stdd_valid_n)
);

wire            [7      :   0]                          stdd_8;

assign  stdd_8 = stdd[7 : 0];

//*************************************** reciprocal(t = 31) ***************************************//


wire    signed  [40 - 1 : 0]                stddreci_40;
wire                                        stddreci_valid_n;

wire [23    :   0]  stddreci;

nnlut u_nnlut2(
    // input signal
    .clk_p          (clk_p),
    .rst_n          (rst_n),
    .x              (stdd_8),  
    .input_valid_n  (stdd_valid_n),
    
    .result         (stddreci),
    .nnlut_valid_n  (stddreci_valid_n)
);


assign stddreci = stddreci_40[23 : 0];


//*************************************** fifo2(t = 12) ***************************************//
wire    [DEVIA_WIDTH * NUM_ADDER * ADD_GROUP_NUM - 1 : 0]   devia;
wire    [DEVIA_WIDTH * NUM_ADDER * ADD_GROUP_NUM - 1 : 0]   devia_r;

assign  devia = {
    devia_group[11], devia_group[10], devia_group[9], devia_group[8],
    devia_group[7], devia_group[6], devia_group[5], devia_group[4], 
    devia_group[3], devia_group[2], devia_group[1], devia_group[0]
};

fifo_8kb_32#(
    .INPUT_WIDTH  ( DEVIA_WIDTH ),
    .INPUT_NUM    ( INPUT_NUM ),
    .FIFO_WIDTH   ( 1024 ),
    .FIFO_NUM     ( 8 )
)u_fifo_8kb_32_2(
    .clk_p        ( clk_p        ),
    .rst_n        ( rst_n        ),
    .data         ( devia         ),
    .data_valid_n ( devia_valid_n ),
    .read_en_n    ( pipline_enable[30]    ),
    .result       ( devia_r       )
);


//*************************************** multiplier_group_2(t = 31) ***************************************//
localparam      MULTIPLIER_NUM = 64;
localparam      WDEVIA_WIDTH = 18;

wire        [DEVIA_WIDTH * MULTIPLIER_NUM - 1 : 0]  devia_r_group   [MULTIPLIER_GROUP_NUM - 1 : 0];
wire        [INPUT_WIDTH * MULTIPLIER_NUM - 1 : 0]  w_group         [MULTIPLIER_GROUP_NUM - 1 : 0];
wire        [WDEVIA_WIDTH * MULTIPLIER_NUM - 1 : 0] wdevia_group    [MULTIPLIER_GROUP_NUM - 1 : 0];
wire        [MULTIPLIER_GROUP_NUM - 1 : 0]      wdevia_group_valid_n;

assign  {devia_r_group[11], devia_r_group[10], devia_r_group[9], devia_r_group[8],
        devia_r_group[7], devia_r_group[6], devia_r_group[5], devia_r_group[4],
        devia_r_group[3], devia_r_group[2], devia_r_group[1], devia_r_group[0]} = devia_r;

assign  {w_group[11], w_group[10],w_group[9],w_group[8],w_group[7],w_group[6],
        w_group[5], w_group[4],w_group[3],w_group[2],w_group[1],w_group[0]
        } = w;

genvar loop4var;
generate
  for (loop4var = 0; loop4var < MULTIPLIER_GROUP_NUM; loop4var = loop4var + 1)
  begin: loop4
     multiplier_group#(
    .WIDTH_MUL_INPUT1 ( DEVIA_WIDTH ),
    .WIDTH_MUL_INPUT2 ( INPUT_WIDTH ),
    .NUM_MULTIPLIER   ( 64 )
    )u_multiplier_group_2(
    .clk_p            ( clk_p            ),
    .rst_n            ( rst_n            ),
    .factor1          ( devia_r_group[loop4var]          ),
    .factor2          ( w_group[loop4var]          ),
    .factor_valid_n   ( pipline_enable[31]   ),
    .product          ( wdevia_group[loop4var]          ),
    .product_valid_n  ( wdevia_group_valid_n[loop4var]  )
    );
  end
endgenerate

wire            wdevia_valid_n;
assign  wdevia_valid_n = |wdevia_group_valid_n;

//*************************************** multiplier_group_3(t = 32) ***************************************//
localparam   STDD_WIDTH = 11;
localparam  STDDRECI_WIDTH = 24;
localparam  XBARW1_WIDTH = 42;
localparam  XBARW2_WIDTH = 20;
localparam  XBARW2_768 = XBARW2_WIDTH * MULTIPLIER_NUM * MULTIPLIER_GROUP_NUM;
localparam  XBARW1_768 = XBARW1_WIDTH * MULTIPLIER_NUM * MULTIPLIER_GROUP_NUM;

wire        [STDDRECI_WIDTH * MULTIPLIER_NUM - 1 : 0]       stddreci_group      [MULTIPLIER_GROUP_NUM - 1 : 0];
wire        [XBARW1_WIDTH * MULTIPLIER_NUM - 1 : 0]         xbarw1_group        [MULTIPLIER_GROUP_NUM - 1 : 0];
wire        [MULTIPLIER_GROUP_NUM - 1 : 0]                  xbarw1_group_valid_n;

assign  {stddreci_group[11], stddreci_group[10],stddreci_group[9],stddreci_group[8],
        stddreci_group[7], stddreci_group[6],stddreci_group[5],stddreci_group[4],
        stddreci_group[3], stddreci_group[2],stddreci_group[1],stddreci_group[0]
        } = {(MULTIPLIER_GROUP_NUM * MULTIPLIER_NUM){stddreci}};

genvar loop5var;
generate
  for (loop5var = 0; loop5var < MULTIPLIER_GROUP_NUM; loop5var = loop5var + 1)
  begin: loop5
    multiplier_group#(
    .WIDTH_MUL_INPUT1 ( STDDRECI_WIDTH ),
    .WIDTH_MUL_INPUT2 ( WDEVIA_WIDTH ),
    .NUM_MULTIPLIER   ( 64 )
    )u_multiplier_group_3_3(
    .clk_p            ( clk_p            ),
    .rst_n            ( rst_n            ),
    .factor1          ( stddreci_group[loop5var]          ),
    .factor2          ( wdevia_group[loop5var]          ),
    .factor_valid_n   ( wdevia_valid_n   ),
    .product          ( xbarw1_group[loop5var]          ),
    .product_valid_n  ( xbarw1_group_valid_n[loop5var]  )
    );
  end
endgenerate

wire    xbarw1_valid_n;
assign  xbarw1_valid_n = |xbarw1_group_valid_n;

wire        [XBARW1_WIDTH * MULTIPLIER_NUM * MULTIPLIER_GROUP_NUM - 1 : 0]      xbarw1;
assign  xbarw1 = {xbarw1_group[11], xbarw1_group[10], xbarw1_group[9], xbarw1_group[8],
                xbarw1_group[7], xbarw1_group[6], xbarw1_group[5], xbarw1_group[4],
                xbarw1_group[3], xbarw1_group[2], xbarw1_group[1], xbarw1_group[0]
};

wire        [XBARW2_768 - 1 : 0]      xbarw2;

genvar  loop6var;
generate
    for(loop6var = 0; loop6var < MULTIPLIER_NUM * MULTIPLIER_GROUP_NUM; loop6var = loop6var + 1)
        begin : loop6
        shifter#(
        .INPUT_WIDTH ( XBARW1_WIDTH ),
        .OUTPUT_WIDTH ( XBARW2_WIDTH )
        )u_shifter(
            .a           ( xbarw1[(loop6var + 1) * XBARW1_WIDTH - 1 : loop6var * XBARW1_WIDTH]           ),
            .b           ( xbarw2[(loop6var + 1) * XBARW2_WIDTH - 1 : loop6var * XBARW2_WIDTH]           )
        );
    end
endgenerate

wire    [XBARW2_WIDTH * MULTIPLIER_NUM - 1 : 0]   xbarw2_group    [MULTIPLIER_GROUP_NUM - 1 : 0];

assign  {xbarw2_group[11], xbarw2_group[10], xbarw2_group[9], xbarw2_group[8],
        xbarw2_group[7], xbarw2_group[6], xbarw2_group[5], xbarw2_group[4],
        xbarw2_group[3], xbarw2_group[2], xbarw2_group[1], xbarw2_group[0]
        } = xbarw2;

//*************************************** add_group_3(t = 33) ***************************************//
localparam  XBARWB_WIDTH = 21;
// localparam  ADD_GROUP_NUM = 12;
// localparam  NUM_ADDER = 64;

wire        [XBARW2_WIDTH * NUM_ADDER * ADD_GROUP_NUM - 1 : 0]  b1;
wire        [XBARWB_WIDTH * NUM_ADDER - 1 : 0]    xbarwb_group    [ADD_GROUP_NUM - 1 : 0];
wire        [ADD_GROUP_NUM - 1 : 0]               xbarwb_valid_n;

genvar  loop7var;
generate
    for(loop7var = 0; loop7var < NUM_ADDER * ADD_GROUP_NUM; loop7var = loop7var + 1)
        begin : loop7
        short2long#(
        .INPUT_WIDTH ( INPUT_WIDTH ),
        .OUTPUT_WIDTH ( XBARW2_WIDTH )
        )u_short2long(
        .datain      ( b[(loop7var + 1) * INPUT_WIDTH - 1 : loop7var * INPUT_WIDTH]      ),
        .dataout     ( b1[(loop7var + 1) * XBARW2_WIDTH - 1 : loop7var * XBARW2_WIDTH]     )
        );
    end
endgenerate

wire        [XBARW2_WIDTH * NUM_ADDER - 1 : 0]      b1_group    [ADD_GROUP_NUM - 1 : 0];

assign  {b1_group[11], b1_group[10],b1_group[9],b1_group[8],
        b1_group[7], b1_group[6],b1_group[5],b1_group[4],
        b1_group[3], b1_group[2],b1_group[1],b1_group[0]} = b1;

genvar  loop8var;
generate
    for(loop8var = 0; loop8var < ADD_GROUP_NUM; loop8var = loop8var + 1)
        begin : loop8
        add_group#(
        .INPUT_WIDTH     ( XBARW2_WIDTH ),
        .NUM_ADDER       ( 'd64 )
        )u_add_group(
        .clk_p           ( clk_p           ),
        .rst_n           ( rst_n           ),
        .addend1         ( xbarw2_group[loop8var]          ),
        .addend2         ( b1_group[loop8var]  ),
        .addend_valid_n ( xbarw1_valid_n ),
        .sum             ( xbarwb_group[loop8var]             ),
        .sum_valid_n     ( xbarwb_valid_n[loop8var]     )
        );
    end
endgenerate

wire    [XBARWB_WIDTH * NUM_ADDER * ADD_GROUP_NUM - 1 : 0]  xbarwb;

assign  xbarwb = {xbarwb_group[11],xbarwb_group[10],xbarwb_group[9],xbarwb_group[8],
                xbarwb_group[7],xbarwb_group[6],xbarwb_group[5],xbarwb_group[4],
                xbarwb_group[3],xbarwb_group[2],xbarwb_group[1],xbarwb_group[0]};

genvar  loop9var;
generate
    for(loop9var = 0; loop9var < NUM_ADDER * ADD_GROUP_NUM; loop9var = loop9var + 1)
        begin : loop9
        clip#(
            .INPUT_WIDTH ( XBARWB_WIDTH ),
            .OUTPUT_WIDTH ( OUTPUT_WIDTH )
        )u_clip(
            .x           ( xbarwb[(loop9var + 1) * XBARWB_WIDTH - 1 : loop9var * XBARWB_WIDTH]           ),
            .y           ( result[(loop9var + 1) * OUTPUT_WIDTH - 1 : loop9var * OUTPUT_WIDTH]           )
        );

    end
endgenerate  

// assign result_valid_n = &(~xbarwb_valid_n);

endmodule
