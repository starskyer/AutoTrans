module  multiplier_group
//Break two large numbers into standard groups of multiply operations
#(
    parameter WIDTH_MUL_INPUT1    =   'd18,
    parameter WIDTH_MUL_INPUT2    =   'd24,
    parameter WIDTH_MUL    =   WIDTH_MUL_INPUT1 + WIDTH_MUL_INPUT2,
    parameter NUM_MULTIPLIER = 64
)
(
//*************************************** System signal ***************************************//
    input                                                                           clk_p,
    input                                                                           rst_n,
//*************************************** Input signal ***************************************//
    input       wire    signed      [WIDTH_MUL_INPUT1 * NUM_MULTIPLIER - 1 : 0]     factor1,
    input       wire    signed      [WIDTH_MUL_INPUT2 * NUM_MULTIPLIER - 1 : 0]     factor2,
    input                                                                           factor_valid_n,
//*************************************** Output signal ***************************************//
    output      reg     signed      [WIDTH_MUL * NUM_MULTIPLIER - 1 : 0]            product,
    output      reg                                                                 product_valid_n
);

wire    signed      [WIDTH_MUL_INPUT1 - 1   :   0]      factor1_mem     [NUM_MULTIPLIER - 1 :   0];
wire    signed      [WIDTH_MUL_INPUT2 - 1   :   0]      factor2_mem     [NUM_MULTIPLIER - 1 :   0];
wire    signed      [WIDTH_MUL - 1          :   0]      product_mem     [NUM_MULTIPLIER - 1 :   0];

assign {            factor1_mem[63],
                    factor1_mem[62],
                    factor1_mem[61],
                    factor1_mem[60],
                    factor1_mem[59],
                    factor1_mem[58],
                    factor1_mem[57],
                    factor1_mem[56],
                    factor1_mem[55],
                    factor1_mem[54],
                    factor1_mem[53],
                    factor1_mem[52],
                    factor1_mem[51],
                    factor1_mem[50],
                    factor1_mem[49],
                    factor1_mem[48],
                    factor1_mem[47],
                    factor1_mem[46],
                    factor1_mem[45],
                    factor1_mem[44],
                    factor1_mem[43],
                    factor1_mem[42],
                    factor1_mem[41],
                    factor1_mem[40],
                    factor1_mem[39],
                    factor1_mem[38],
                    factor1_mem[37],
                    factor1_mem[36],
                    factor1_mem[35],
                    factor1_mem[34],
                    factor1_mem[33],
                    factor1_mem[32],
                    factor1_mem[31],
                    factor1_mem[30],
                    factor1_mem[29],
                    factor1_mem[28],
                    factor1_mem[27],
                    factor1_mem[26],
                    factor1_mem[25],
                    factor1_mem[24],
                    factor1_mem[23],
                    factor1_mem[22],
                    factor1_mem[21],
                    factor1_mem[20],
                    factor1_mem[19],
                    factor1_mem[18],
                    factor1_mem[17],
                    factor1_mem[16],
                    factor1_mem[15],
                    factor1_mem[14],
                    factor1_mem[13],
                    factor1_mem[12],
                    factor1_mem[11],
                    factor1_mem[10],
                    factor1_mem[9],
                    factor1_mem[8],
                    factor1_mem[7],
                    factor1_mem[6],
                    factor1_mem[5],
                    factor1_mem[4],
                    factor1_mem[3],
                    factor1_mem[2],
                    factor1_mem[1],
                    factor1_mem[0]
} = factor1;

assign {            factor2_mem[63],
                    factor2_mem[62],
                    factor2_mem[61],
                    factor2_mem[60],
                    factor2_mem[59],
                    factor2_mem[58],
                    factor2_mem[57],
                    factor2_mem[56],
                    factor2_mem[55],
                    factor2_mem[54],
                    factor2_mem[53],
                    factor2_mem[52],
                    factor2_mem[51],
                    factor2_mem[50],
                    factor2_mem[49],
                    factor2_mem[48],
                    factor2_mem[47],
                    factor2_mem[46],
                    factor2_mem[45],
                    factor2_mem[44],
                    factor2_mem[43],
                    factor2_mem[42],
                    factor2_mem[41],
                    factor2_mem[40],
                    factor2_mem[39],
                    factor2_mem[38],
                    factor2_mem[37],
                    factor2_mem[36],
                    factor2_mem[35],
                    factor2_mem[34],
                    factor2_mem[33],
                    factor2_mem[32],
                    factor2_mem[31],
                    factor2_mem[30],
                    factor2_mem[29],
                    factor2_mem[28],
                    factor2_mem[27],
                    factor2_mem[26],
                    factor2_mem[25],
                    factor2_mem[24],
                    factor2_mem[23],
                    factor2_mem[22],
                    factor2_mem[21],
                    factor2_mem[20],
                    factor2_mem[19],
                    factor2_mem[18],
                    factor2_mem[17],
                    factor2_mem[16],
                    factor2_mem[15],
                    factor2_mem[14],
                    factor2_mem[13],
                    factor2_mem[12],
                    factor2_mem[11],
                    factor2_mem[10],
                    factor2_mem[9],
                    factor2_mem[8],
                    factor2_mem[7],
                    factor2_mem[6],
                    factor2_mem[5],
                    factor2_mem[4],
                    factor2_mem[3],
                    factor2_mem[2],
                    factor2_mem[1],
                    factor2_mem[0]
} = factor2;

multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_0(
    .mul_input1       ( factor1_mem[0]       ),
    .mul_input2       ( factor2_mem[0]       ),
    .mul              ( product_mem[0]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_1(
    .mul_input1       ( factor1_mem[1]       ),
    .mul_input2       ( factor2_mem[1]       ),
    .mul              ( product_mem[1]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_2(
    .mul_input1       ( factor1_mem[2]       ),
    .mul_input2       ( factor2_mem[2]       ),
    .mul              ( product_mem[2]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_3(
    .mul_input1       ( factor1_mem[3]       ),
    .mul_input2       ( factor2_mem[3]       ),
    .mul              ( product_mem[3]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_4(
    .mul_input1       ( factor1_mem[4]       ),
    .mul_input2       ( factor2_mem[4]       ),
    .mul              ( product_mem[4]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_5(
    .mul_input1       ( factor1_mem[5]       ),
    .mul_input2       ( factor2_mem[5]       ),
    .mul              ( product_mem[5]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_6(
    .mul_input1       ( factor1_mem[6]       ),
    .mul_input2       ( factor2_mem[6]       ),
    .mul              ( product_mem[6]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_7(
    .mul_input1       ( factor1_mem[7]       ),
    .mul_input2       ( factor2_mem[7]       ),
    .mul              ( product_mem[7]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_8(
    .mul_input1       ( factor1_mem[8]       ),
    .mul_input2       ( factor2_mem[8]       ),
    .mul              ( product_mem[8]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_9(
    .mul_input1       ( factor1_mem[9]       ),
    .mul_input2       ( factor2_mem[9]       ),
    .mul              ( product_mem[9]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_10(
    .mul_input1       ( factor1_mem[10]       ),
    .mul_input2       ( factor2_mem[10]       ),
    .mul              ( product_mem[10]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_11(
    .mul_input1       ( factor1_mem[11]       ),
    .mul_input2       ( factor2_mem[11]       ),
    .mul              ( product_mem[11]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_12(
    .mul_input1       ( factor1_mem[12]       ),
    .mul_input2       ( factor2_mem[12]       ),
    .mul              ( product_mem[12]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_13(
    .mul_input1       ( factor1_mem[13]       ),
    .mul_input2       ( factor2_mem[13]       ),
    .mul              ( product_mem[13]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_14(
    .mul_input1       ( factor1_mem[14]       ),
    .mul_input2       ( factor2_mem[14]       ),
    .mul              ( product_mem[14]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_15(
    .mul_input1       ( factor1_mem[15]       ),
    .mul_input2       ( factor2_mem[15]       ),
    .mul              ( product_mem[15]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_16(
    .mul_input1       ( factor1_mem[16]       ),
    .mul_input2       ( factor2_mem[16]       ),
    .mul              ( product_mem[16]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_17(
    .mul_input1       ( factor1_mem[17]       ),
    .mul_input2       ( factor2_mem[17]       ),
    .mul              ( product_mem[17]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_18(
    .mul_input1       ( factor1_mem[18]       ),
    .mul_input2       ( factor2_mem[18]       ),
    .mul              ( product_mem[18]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_19(
    .mul_input1       ( factor1_mem[19]       ),
    .mul_input2       ( factor2_mem[19]       ),
    .mul              ( product_mem[19]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_20(
    .mul_input1       ( factor1_mem[20]       ),
    .mul_input2       ( factor2_mem[20]       ),
    .mul              ( product_mem[20]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_21(
    .mul_input1       ( factor1_mem[21]       ),
    .mul_input2       ( factor2_mem[21]       ),
    .mul              ( product_mem[21]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_22(
    .mul_input1       ( factor1_mem[22]       ),
    .mul_input2       ( factor2_mem[22]       ),
    .mul              ( product_mem[22]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_23(
    .mul_input1       ( factor1_mem[23]       ),
    .mul_input2       ( factor2_mem[23]       ),
    .mul              ( product_mem[23]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_24(
    .mul_input1       ( factor1_mem[24]       ),
    .mul_input2       ( factor2_mem[24]       ),
    .mul              ( product_mem[24]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_25(
    .mul_input1       ( factor1_mem[25]       ),
    .mul_input2       ( factor2_mem[25]       ),
    .mul              ( product_mem[25]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_26(
    .mul_input1       ( factor1_mem[26]       ),
    .mul_input2       ( factor2_mem[26]       ),
    .mul              ( product_mem[26]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_27(
    .mul_input1       ( factor1_mem[27]       ),
    .mul_input2       ( factor2_mem[27]       ),
    .mul              ( product_mem[27]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_28(
    .mul_input1       ( factor1_mem[28]       ),
    .mul_input2       ( factor2_mem[28]       ),
    .mul              ( product_mem[28]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_29(
    .mul_input1       ( factor1_mem[29]       ),
    .mul_input2       ( factor2_mem[29]       ),
    .mul              ( product_mem[29]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_30(
    .mul_input1       ( factor1_mem[30]       ),
    .mul_input2       ( factor2_mem[30]       ),
    .mul              ( product_mem[30]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_31(
    .mul_input1       ( factor1_mem[31]       ),
    .mul_input2       ( factor2_mem[31]       ),
    .mul              ( product_mem[31]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_32(
    .mul_input1       ( factor1_mem[32]       ),
    .mul_input2       ( factor2_mem[32]       ),
    .mul              ( product_mem[32]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_33(
    .mul_input1       ( factor1_mem[33]       ),
    .mul_input2       ( factor2_mem[33]       ),
    .mul              ( product_mem[33]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_34(
    .mul_input1       ( factor1_mem[34]       ),
    .mul_input2       ( factor2_mem[34]       ),
    .mul              ( product_mem[34]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_35(
    .mul_input1       ( factor1_mem[35]       ),
    .mul_input2       ( factor2_mem[35]       ),
    .mul              ( product_mem[35]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_36(
    .mul_input1       ( factor1_mem[36]       ),
    .mul_input2       ( factor2_mem[36]       ),
    .mul              ( product_mem[36]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_37(
    .mul_input1       ( factor1_mem[37]       ),
    .mul_input2       ( factor2_mem[37]       ),
    .mul              ( product_mem[37]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_38(
    .mul_input1       ( factor1_mem[38]       ),
    .mul_input2       ( factor2_mem[38]       ),
    .mul              ( product_mem[38]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_39(
    .mul_input1       ( factor1_mem[39]       ),
    .mul_input2       ( factor2_mem[39]       ),
    .mul              ( product_mem[39]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_40(
    .mul_input1       ( factor1_mem[40]       ),
    .mul_input2       ( factor2_mem[40]       ),
    .mul              ( product_mem[40]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_41(
    .mul_input1       ( factor1_mem[41]       ),
    .mul_input2       ( factor2_mem[41]       ),
    .mul              ( product_mem[41]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_42(
    .mul_input1       ( factor1_mem[42]       ),
    .mul_input2       ( factor2_mem[42]       ),
    .mul              ( product_mem[42]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_43(
    .mul_input1       ( factor1_mem[43]       ),
    .mul_input2       ( factor2_mem[43]       ),
    .mul              ( product_mem[43]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_44(
    .mul_input1       ( factor1_mem[44]       ),
    .mul_input2       ( factor2_mem[44]       ),
    .mul              ( product_mem[44]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_45(
    .mul_input1       ( factor1_mem[45]       ),
    .mul_input2       ( factor2_mem[45]       ),
    .mul              ( product_mem[45]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_46(
    .mul_input1       ( factor1_mem[46]       ),
    .mul_input2       ( factor2_mem[46]       ),
    .mul              ( product_mem[46]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_47(
    .mul_input1       ( factor1_mem[47]       ),
    .mul_input2       ( factor2_mem[47]       ),
    .mul              ( product_mem[47]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_48(
    .mul_input1       ( factor1_mem[48]       ),
    .mul_input2       ( factor2_mem[48]       ),
    .mul              ( product_mem[48]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_49(
    .mul_input1       ( factor1_mem[49]       ),
    .mul_input2       ( factor2_mem[49]       ),
    .mul              ( product_mem[49]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_50(
    .mul_input1       ( factor1_mem[50]       ),
    .mul_input2       ( factor2_mem[50]       ),
    .mul              ( product_mem[50]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_51(
    .mul_input1       ( factor1_mem[51]       ),
    .mul_input2       ( factor2_mem[51]       ),
    .mul              ( product_mem[51]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_52(
    .mul_input1       ( factor1_mem[52]       ),
    .mul_input2       ( factor2_mem[52]       ),
    .mul              ( product_mem[52]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_53(
    .mul_input1       ( factor1_mem[53]       ),
    .mul_input2       ( factor2_mem[53]       ),
    .mul              ( product_mem[53]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_54(
    .mul_input1       ( factor1_mem[54]       ),
    .mul_input2       ( factor2_mem[54]       ),
    .mul              ( product_mem[54]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_55(
    .mul_input1       ( factor1_mem[55]       ),
    .mul_input2       ( factor2_mem[55]       ),
    .mul              ( product_mem[55]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_56(
    .mul_input1       ( factor1_mem[56]       ),
    .mul_input2       ( factor2_mem[56]       ),
    .mul              ( product_mem[56]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_57(
    .mul_input1       ( factor1_mem[57]       ),
    .mul_input2       ( factor2_mem[57]       ),
    .mul              ( product_mem[57]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_58(
    .mul_input1       ( factor1_mem[58]       ),
    .mul_input2       ( factor2_mem[58]       ),
    .mul              ( product_mem[58]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_59(
    .mul_input1       ( factor1_mem[59]       ),
    .mul_input2       ( factor2_mem[59]       ),
    .mul              ( product_mem[59]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_60(
    .mul_input1       ( factor1_mem[60]       ),
    .mul_input2       ( factor2_mem[60]       ),
    .mul              ( product_mem[60]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_61(
    .mul_input1       ( factor1_mem[61]       ),
    .mul_input2       ( factor2_mem[61]       ),
    .mul              ( product_mem[61]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_62(
    .mul_input1       ( factor1_mem[62]       ),
    .mul_input2       ( factor2_mem[62]       ),
    .mul              ( product_mem[62]       )
); 
multiplier#(
    .WIDTH_MUL_INPUT1 ( WIDTH_MUL_INPUT1 ),
    .WIDTH_MUL_INPUT2 ( WIDTH_MUL_INPUT2 )
)u_multiplier_63(
    .mul_input1       ( factor1_mem[63]       ),
    .mul_input2       ( factor2_mem[63]       ),
    .mul              ( product_mem[63]       )
); 

// product_valid_n
always @(posedge clk_p or negedge rst_n) begin
    if(~rst_n)  begin
        product_valid_n <= 1'b1;
    end
    else    begin
        product_valid_n <= factor_valid_n ? 1'b1 : 1'b0;
    end
end

// product
always @(posedge clk_p or negedge rst_n) begin
    if(~rst_n)  begin
        product <= 0;
    end
    else    begin
        product <= factor_valid_n ? 0 : 
        {
            product_mem[63],
            product_mem[62],
            product_mem[61],
            product_mem[60],
            product_mem[59],
            product_mem[58],
            product_mem[57],
            product_mem[56],
            product_mem[55],
            product_mem[54],
            product_mem[53],
            product_mem[52],
            product_mem[51],
            product_mem[50],
            product_mem[49],
            product_mem[48],
            product_mem[47],
            product_mem[46],
            product_mem[45],
            product_mem[44],
            product_mem[43],
            product_mem[42],
            product_mem[41],
            product_mem[40],
            product_mem[39],
            product_mem[38],
            product_mem[37],
            product_mem[36],
            product_mem[35],
            product_mem[34],
            product_mem[33],
            product_mem[32],
            product_mem[31],
            product_mem[30],
            product_mem[29],
            product_mem[28],
            product_mem[27],
            product_mem[26],
            product_mem[25],
            product_mem[24],
            product_mem[23],
            product_mem[22],
            product_mem[21],
            product_mem[20],
            product_mem[19],
            product_mem[18],
            product_mem[17],
            product_mem[16],
            product_mem[15],
            product_mem[14],
            product_mem[13],
            product_mem[12],
            product_mem[11],
            product_mem[10],
            product_mem[9],
            product_mem[8],
            product_mem[7],
            product_mem[6],
            product_mem[5],
            product_mem[4],
            product_mem[3],
            product_mem[2],
            product_mem[1],
            product_mem[0]
        };
    end
end

endmodule