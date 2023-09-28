`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2022/09/30 12:35:20
// Module Name: add_tree_64
// Description: 
// add tree of a 64 dimention var
// 6 clk : 64 --> 32 --> 16 --> 8 --> 4 --> 2 --> 1
// Dependencies: 
// adder -> adder_tree_64
//////////////////////////////////////////////////////////////////////////////////


module add_tree_64
#(
    parameter   DIMENTION           = 'd64,
    parameter   WIDTH_ADDEND        = 'd8,
    parameter   NUM_LEVEL           = 'd6,
    parameter   WIDTH_SUM           = WIDTH_ADDEND + NUM_LEVEL
)
(
//********************************* System Signal *********************************
    input                                                                           clk_p,
    input                                                                           rst_n,
//********************************* Input Signal *********************************
    input               signed      [WIDTH_ADDEND * DIMENTION - 1   :   0]          addend,
    input                                                           addend_valid_n,
//********************************* Output Signal *********************************
    output      reg     signed      [WIDTH_SUM - 1                  :   0]          sum,
    output      reg                                                                 sum_valid_n              
);
//********************************* Middle Result Param *********************************
localparam  WIDTH_MIDDLE_SUM_1  = WIDTH_ADDEND + 1;
localparam  WIDTH_MIDDLE_SUM_2  = WIDTH_ADDEND + 2;
localparam  WIDTH_MIDDLE_SUM_3  = WIDTH_ADDEND + 3;
localparam  WIDTH_MIDDLE_SUM_4  = WIDTH_ADDEND + 4;
localparam  WIDTH_MIDDLE_SUM_5  = WIDTH_ADDEND + 5;

localparam  NUM_ADDER_1         = DIMENTION / (2 ** 1);
localparam  NUM_ADDER_2         = DIMENTION / (2 ** 2);
localparam  NUM_ADDER_3         = DIMENTION / (2 ** 3);
localparam  NUM_ADDER_4         = DIMENTION / (2 ** 4);
localparam  NUM_ADDER_5         = DIMENTION / (2 ** 5);

//********************************* Addend *********************************
wire    [WIDTH_ADDEND - 1   :   0]  addend_mem      [DIMENTION - 1  :   0];
assign  {
    addend_mem[0],  addend_mem[1],  addend_mem[2],  addend_mem[3],  addend_mem[4],  addend_mem[5],  addend_mem[6],  addend_mem[7], 
    addend_mem[8],  addend_mem[9],  addend_mem[10], addend_mem[11], addend_mem[12], addend_mem[13], addend_mem[14], addend_mem[15], 
    addend_mem[16], addend_mem[17], addend_mem[18], addend_mem[19], addend_mem[20], addend_mem[21], addend_mem[22], addend_mem[23], 
    addend_mem[24], addend_mem[25], addend_mem[26], addend_mem[27], addend_mem[28], addend_mem[29], addend_mem[30], addend_mem[31], 
    addend_mem[32], addend_mem[33], addend_mem[34], addend_mem[35], addend_mem[36], addend_mem[37], addend_mem[38], addend_mem[39], 
    addend_mem[40], addend_mem[41], addend_mem[42], addend_mem[43], addend_mem[44], addend_mem[45], addend_mem[46], addend_mem[47], 
    addend_mem[48], addend_mem[49], addend_mem[50], addend_mem[51], addend_mem[52], addend_mem[53], addend_mem[54], addend_mem[55], 
    addend_mem[56], addend_mem[57], addend_mem[58], addend_mem[59], addend_mem[60], addend_mem[61], addend_mem[62], addend_mem[63] 
} = addend;

//********************************* Middle Result *********************************
reg     [WIDTH_MIDDLE_SUM_1 - 1 :   0]  middle_sum_1    [NUM_ADDER_1 - 1    :   0];
reg     [WIDTH_MIDDLE_SUM_2 - 1 :   0]  middle_sum_2    [NUM_ADDER_2 - 1    :   0];
reg     [WIDTH_MIDDLE_SUM_3 - 1 :   0]  middle_sum_3    [NUM_ADDER_3 - 1    :   0];
reg     [WIDTH_MIDDLE_SUM_4 - 1 :   0]  middle_sum_4    [NUM_ADDER_4 - 1    :   0];
reg     [WIDTH_MIDDLE_SUM_5 - 1 :   0]  middle_sum_5    [NUM_ADDER_5 - 1    :   0];

wire    [WIDTH_MIDDLE_SUM_1 - 1 :   0]  middle_sum_choise_1    [NUM_ADDER_1 - 1    :   0];
wire    [WIDTH_MIDDLE_SUM_2 - 1 :   0]  middle_sum_choise_2    [NUM_ADDER_2 - 1    :   0];
wire    [WIDTH_MIDDLE_SUM_3 - 1 :   0]  middle_sum_choise_3    [NUM_ADDER_3 - 1    :   0];
wire    [WIDTH_MIDDLE_SUM_4 - 1 :   0]  middle_sum_choise_4    [NUM_ADDER_4 - 1    :   0];
wire    [WIDTH_MIDDLE_SUM_5 - 1 :   0]  middle_sum_choise_5    [NUM_ADDER_5 - 1    :   0];

wire    [WIDTH_MIDDLE_SUM_5     :   0]  sum_choise;

//********************************* Pipline Enable *********************************
reg     [NUM_LEVEL - 3      :   -1]      en_pipline_n;

always  @(posedge clk_p or negedge rst_n)   begin
    if(~rst_n)  begin
        en_pipline_n  <= 5'b11111;
    end
    else    begin
        en_pipline_n[NUM_LEVEL - 3 : -1] <= {addend_valid_n, en_pipline_n[NUM_LEVEL - 3 : 0]};
    end
end

always  @(posedge clk_p or negedge rst_n)   begin
    if(~rst_n)  begin
        sum_valid_n <= 1'b1;
    end
    else    begin
        sum_valid_n <= en_pipline_n[-1];
    end
end

//********************************* Pipline Adder Tree *********************************
// level 1: 32 adder   64 --> 32
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_1(.addend1 (addend_mem[0]), .addend2 (addend_mem[1]), .sum (middle_sum_choise_1[0]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_2(.addend1 (addend_mem[2]), .addend2 (addend_mem[3]), .sum (middle_sum_choise_1[1]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_3(.addend1 (addend_mem[4]), .addend2 (addend_mem[5]), .sum (middle_sum_choise_1[2]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_4(.addend1 (addend_mem[6]), .addend2 (addend_mem[7]), .sum (middle_sum_choise_1[3]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_5(.addend1 (addend_mem[8]), .addend2 (addend_mem[9]), .sum (middle_sum_choise_1[4]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_6(.addend1 (addend_mem[10]), .addend2 (addend_mem[11]), .sum (middle_sum_choise_1[5]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_7(.addend1 (addend_mem[12]), .addend2 (addend_mem[13]), .sum (middle_sum_choise_1[6]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_8(.addend1 (addend_mem[14]), .addend2 (addend_mem[15]), .sum (middle_sum_choise_1[7]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_9(.addend1 (addend_mem[16]), .addend2 (addend_mem[17]), .sum (middle_sum_choise_1[8]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_10(.addend1 (addend_mem[18]), .addend2 (addend_mem[19]), .sum (middle_sum_choise_1[9]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_11(.addend1 (addend_mem[20]), .addend2 (addend_mem[21]), .sum (middle_sum_choise_1[10]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_12(.addend1 (addend_mem[22]), .addend2 (addend_mem[23]), .sum (middle_sum_choise_1[11]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_13(.addend1 (addend_mem[24]), .addend2 (addend_mem[25]), .sum (middle_sum_choise_1[12]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_14(.addend1 (addend_mem[26]), .addend2 (addend_mem[27]), .sum (middle_sum_choise_1[13]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_15(.addend1 (addend_mem[28]), .addend2 (addend_mem[29]), .sum (middle_sum_choise_1[14]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_16(.addend1 (addend_mem[30]), .addend2 (addend_mem[31]), .sum (middle_sum_choise_1[15]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_17(.addend1 (addend_mem[32]), .addend2 (addend_mem[33]), .sum (middle_sum_choise_1[16]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_18(.addend1 (addend_mem[34]), .addend2 (addend_mem[35]), .sum (middle_sum_choise_1[17]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_19(.addend1 (addend_mem[36]), .addend2 (addend_mem[37]), .sum (middle_sum_choise_1[18]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_20(.addend1 (addend_mem[38]), .addend2 (addend_mem[39]), .sum (middle_sum_choise_1[19]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_21(.addend1 (addend_mem[40]), .addend2 (addend_mem[41]), .sum (middle_sum_choise_1[20]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_22(.addend1 (addend_mem[42]), .addend2 (addend_mem[43]), .sum (middle_sum_choise_1[21]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_23(.addend1 (addend_mem[44]), .addend2 (addend_mem[45]), .sum (middle_sum_choise_1[22]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_24(.addend1 (addend_mem[46]), .addend2 (addend_mem[47]), .sum (middle_sum_choise_1[23]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_25(.addend1 (addend_mem[48]), .addend2 (addend_mem[49]), .sum (middle_sum_choise_1[24]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_26(.addend1 (addend_mem[50]), .addend2 (addend_mem[51]), .sum (middle_sum_choise_1[25]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_27(.addend1 (addend_mem[52]), .addend2 (addend_mem[53]), .sum (middle_sum_choise_1[26]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_28(.addend1 (addend_mem[54]), .addend2 (addend_mem[55]), .sum (middle_sum_choise_1[27]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_29(.addend1 (addend_mem[56]), .addend2 (addend_mem[57]), .sum (middle_sum_choise_1[28]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_30(.addend1 (addend_mem[58]), .addend2 (addend_mem[59]), .sum (middle_sum_choise_1[29]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_31(.addend1 (addend_mem[60]), .addend2 (addend_mem[61]), .sum (middle_sum_choise_1[30]));
adder #(.WIDTH_ADDEND(WIDTH_ADDEND)) u_adder_l1_32(.addend1 (addend_mem[62]), .addend2 (addend_mem[63]), .sum (middle_sum_choise_1[31]));
integer i;
always  @(posedge clk_p or negedge rst_n)   begin
    if(~rst_n)  begin
        for(i = 0; i < NUM_ADDER_1; i = i + 1)    begin
            middle_sum_1[i] <= 'd0;
        end
    end
    else    begin
        for(i = 0; i < NUM_ADDER_1; i = i + 1)    begin
            middle_sum_1[i] <= addend_valid_n ? middle_sum_1[i] : middle_sum_choise_1[i];
        end
    end
end

// level 2: 16 adder   32 --> 16
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_1(.addend1 (middle_sum_1[0]), .addend2 (middle_sum_1[1]), .sum (middle_sum_choise_2[0]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_2(.addend1 (middle_sum_1[2]), .addend2 (middle_sum_1[3]), .sum (middle_sum_choise_2[1]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_3(.addend1 (middle_sum_1[4]), .addend2 (middle_sum_1[5]), .sum (middle_sum_choise_2[2]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_4(.addend1 (middle_sum_1[6]), .addend2 (middle_sum_1[7]), .sum (middle_sum_choise_2[3]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_5(.addend1 (middle_sum_1[8]), .addend2 (middle_sum_1[9]), .sum (middle_sum_choise_2[4]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_6(.addend1 (middle_sum_1[10]), .addend2 (middle_sum_1[11]), .sum (middle_sum_choise_2[5]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_7(.addend1 (middle_sum_1[12]), .addend2 (middle_sum_1[13]), .sum (middle_sum_choise_2[6]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_8(.addend1 (middle_sum_1[14]), .addend2 (middle_sum_1[15]), .sum (middle_sum_choise_2[7]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_9(.addend1 (middle_sum_1[16]), .addend2 (middle_sum_1[17]), .sum (middle_sum_choise_2[8]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_10(.addend1 (middle_sum_1[18]), .addend2 (middle_sum_1[19]), .sum (middle_sum_choise_2[9]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_11(.addend1 (middle_sum_1[20]), .addend2 (middle_sum_1[21]), .sum (middle_sum_choise_2[10]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_12(.addend1 (middle_sum_1[22]), .addend2 (middle_sum_1[23]), .sum (middle_sum_choise_2[11]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_13(.addend1 (middle_sum_1[24]), .addend2 (middle_sum_1[25]), .sum (middle_sum_choise_2[12]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_14(.addend1 (middle_sum_1[26]), .addend2 (middle_sum_1[27]), .sum (middle_sum_choise_2[13]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_15(.addend1 (middle_sum_1[28]), .addend2 (middle_sum_1[29]), .sum (middle_sum_choise_2[14]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_1)) u_adder_l2_16(.addend1 (middle_sum_1[30]), .addend2 (middle_sum_1[31]), .sum (middle_sum_choise_2[15]));

always  @(posedge clk_p or negedge rst_n)   begin
    if(~rst_n)  begin
        for(i = 0; i < NUM_ADDER_2; i = i + 1)    begin
            middle_sum_2[i] <= 'd0;
        end
    end
    else    begin
        for(i = 0; i < NUM_ADDER_2; i = i + 1)    begin
            middle_sum_2[i] <= en_pipline_n[NUM_LEVEL - 3] ? middle_sum_2[i] : middle_sum_choise_2[i];
        end
    end
end

// level 3: 8 adder   16 --> 8
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_2)) u_adder_l3_1(.addend1 (middle_sum_2[0]), .addend2 (middle_sum_2[1]), .sum (middle_sum_choise_3[0]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_2)) u_adder_l3_2(.addend1 (middle_sum_2[2]), .addend2 (middle_sum_2[3]), .sum (middle_sum_choise_3[1]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_2)) u_adder_l3_3(.addend1 (middle_sum_2[4]), .addend2 (middle_sum_2[5]), .sum (middle_sum_choise_3[2]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_2)) u_adder_l3_4(.addend1 (middle_sum_2[6]), .addend2 (middle_sum_2[7]), .sum (middle_sum_choise_3[3]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_2)) u_adder_l3_5(.addend1 (middle_sum_2[8]), .addend2 (middle_sum_2[9]), .sum (middle_sum_choise_3[4]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_2)) u_adder_l3_6(.addend1 (middle_sum_2[10]), .addend2 (middle_sum_2[11]), .sum (middle_sum_choise_3[5]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_2)) u_adder_l3_7(.addend1 (middle_sum_2[12]), .addend2 (middle_sum_2[13]), .sum (middle_sum_choise_3[6]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_2)) u_adder_l3_8(.addend1 (middle_sum_2[14]), .addend2 (middle_sum_2[15]), .sum (middle_sum_choise_3[7]));

always  @(posedge clk_p or negedge rst_n)   begin
    if(~rst_n)  begin
        for(i = 0; i < NUM_ADDER_3; i = i + 1)    begin
            middle_sum_3[i] <= 'd0;
        end
    end
    else    begin
        for(i = 0; i < NUM_ADDER_3; i = i + 1)    begin
            middle_sum_3[i] <= en_pipline_n[NUM_LEVEL - 4] ? middle_sum_3[i] : middle_sum_choise_3[i];
        end
    end
end

// level 4: 4 adder   8 --> 4
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_3)) u_adder_l4_1(.addend1 (middle_sum_3[0]), .addend2 (middle_sum_3[1]), .sum (middle_sum_choise_4[0]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_3)) u_adder_l4_2(.addend1 (middle_sum_3[2]), .addend2 (middle_sum_3[3]), .sum (middle_sum_choise_4[1]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_3)) u_adder_l4_3(.addend1 (middle_sum_3[4]), .addend2 (middle_sum_3[5]), .sum (middle_sum_choise_4[2]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_3)) u_adder_l4_4(.addend1 (middle_sum_3[6]), .addend2 (middle_sum_3[7]), .sum (middle_sum_choise_4[3]));

always  @(posedge clk_p or negedge rst_n)   begin
    if(~rst_n)  begin
        for(i = 0; i < NUM_ADDER_4; i = i + 1)    begin
            middle_sum_4[i] <= 'd0;
        end
    end
    else    begin
        for(i = 0; i < NUM_ADDER_4; i = i + 1)    begin
            middle_sum_4[i] <= en_pipline_n[NUM_LEVEL - 5] ? middle_sum_4[i] : middle_sum_choise_4[i];
        end
    end
end

// level 5: 2 adder   4 --> 2
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_4)) u_adder_l5_1(.addend1 (middle_sum_4[0]), .addend2 (middle_sum_4[1]), .sum (middle_sum_choise_5[0]));
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_4)) u_adder_l5_2(.addend1 (middle_sum_4[2]), .addend2 (middle_sum_4[3]), .sum (middle_sum_choise_5[1]));

always  @(posedge clk_p or negedge rst_n)   begin
    if(~rst_n)  begin
        for(i = 0; i < NUM_ADDER_5; i = i + 1)    begin
            middle_sum_5[i] <= 'd0;
        end
    end
    else    begin
        for(i = 0; i < NUM_ADDER_5; i = i + 1)    begin
            middle_sum_5[i] <= en_pipline_n[NUM_LEVEL - 6] ? middle_sum_5[i] : middle_sum_choise_5[i];
        end
    end
end

// level 6: 1 adder   2 --> 1
adder #(.WIDTH_ADDEND(WIDTH_MIDDLE_SUM_5)) u_adder_l6_1(.addend1 (middle_sum_5[0]), .addend2 (middle_sum_5[1]), .sum (sum_choise));

always  @(posedge clk_p or negedge rst_n)   begin
    if(~rst_n)  begin
        sum <= 'd0;
    end
    else    begin
        sum <= en_pipline_n[NUM_LEVEL - 7] ? sum : sum_choise;
    end
end

endmodule
