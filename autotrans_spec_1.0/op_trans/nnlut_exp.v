// module name：lut
// description�???? nn-lut中电路的硬件实现，其中判断数据范围不用数据比较器，�?�用减法�????+判断sign的方�????
// version 1�???? 曼婷写的lut.v
// version 2: 修改 by �????
// 修改的地方：1、修改成时序逻辑  2、x，b不需要expand，直接用32*8的乘法器ip，和40 + 32的加法器ip即可
// timing logiv�????
//  clk 1:  减法+sign，{cout[i],sum[i]} = x - breakpoint[i],   MUX给出k，b的�??
//  clk 2: k*x + b
module nnlut_exp
#(
    parameter x_WIDTH = 8,
    parameter k_WIDTH = 32,
    parameter b_WIDTH = 32, 
    parameter result_WIDTH = x_WIDTH + k_WIDTH + 1, // 41, 8bitxx * 32bit k + 32 bit b
    parameter bp_NUM = 16   //breakpoint的数�????
) (
    // input signal
    input                                            clk_p,
    input                                            rst_n,
    input       signed  [x_WIDTH - 1 : 0]            x,  
    input                                            input_valid_n,
    //output signal
    output reg  signed  [result_WIDTH-1:0]           result,
    output wire                                      nnlut_valid_n
);


//********************************* Middle Signal *********************************
 // 比较�???? 16�???? 15个比较器
    wire   signed  [x_WIDTH - 1 : 0]                 breakpoint  [bp_NUM - 1 : 0];
    wire           [x_WIDTH - 2 : 0]                 sum         [bp_NUM - 1 : 0];   
    wire           [bp_NUM-1 : 0]                    cout;
//********************************* Pipeline Output Enable Signal *********************************
    reg                                              en_p1_n; 
    reg                                              en_p2_n;
//********************************* Loop Integer *********************************
    integer                                          i,j;
    genvar                                           m;
//********************************* latency reg  *********************************
    reg    signed  [x_WIDTH - 1 : 0]                 x_reg1;


    assign nnlut_valid_n = en_p2_n;

    //breakpoint，用于比�????
    assign breakpoint[0] = 2;
    assign breakpoint[1] = 4;
    assign breakpoint[2] = 6;
    assign breakpoint[3] = 8;
    assign breakpoint[4] = 10;
    assign breakpoint[5] = 12;
    assign breakpoint[6] = 14;
    assign breakpoint[7] = 16;
    assign breakpoint[8] = 18;
    assign breakpoint[9] = 20;
    assign breakpoint[10] = 22;
    assign breakpoint[11] = 24;
    assign breakpoint[12] = 26;
    assign breakpoint[13] = 28;
    assign breakpoint[14] = 30;
    assign breakpoint[15] = 32;


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

    // ------------------------- reg latency logic -----------------------
    always @(posedge clk_p or negedge rst_n) begin
        if(!rst_n) begin 
            x_reg1 <= 'd0;
        end
        else begin
            x_reg1 <= x;
        end
    end


    // ------------------------------- Pipeline Begins -------------------------------------------
    // ---------------- pipeline 1: clk 1 ---------------------------
    // 减法+sign，{cout[i],sum[i]} = x - breakpoint[i],   MUX给出k，b的�??
    reg    signed   [x_WIDTH - 1 : 0]               inter_judge  [bp_NUM - 1 : 0];
    always @(posedge clk_p or negedge rst_n) begin
        if(!rst_n) begin 
            for(i = 0; i < bp_NUM ; i = i + 1) begin: rst_inter_judge
                inter_judge[i] <= 'd0;
            end
        end
        else begin
            for(j = 0; j < bp_NUM ; j = j + 1) begin: inst_inter_judge
                inter_judge[j] <= (!input_valid_n) ? (x - breakpoint[j]) : 'd0;
            end
        end
    end

    generate
        for(m = 0; m < bp_NUM ; m = m + 1) begin: assign_inter_judge
            assign {cout[m],sum[m]} = inter_judge[m];
        end
    endgenerate 

// LUT查表
    wire signed [k_WIDTH - 1 : 0] k_lut [bp_NUM - 1 : 0]; 
    wire signed [b_WIDTH - 1 : 0] b_lut [bp_NUM - 1 : 0];
    reg signed [k_WIDTH - 1 : 0] k;
    reg signed [b_WIDTH - 1 : 0] b;

    //可改成，for循环，读文件
    assign k_lut[0] = 1;  assign k_lut[1] = 2;  assign k_lut[2] = 3;  assign k_lut[3] = 4;  
    assign k_lut[4] = 5;  assign k_lut[5] = 6;  assign k_lut[6] = 7;  assign k_lut[7] = 8;
    assign k_lut[8] = 9;  assign k_lut[9] = 10;  assign k_lut[10] = 11;  assign k_lut[11] = 12;
    assign k_lut[12] = 13;  assign k_lut[13] = 14;  assign k_lut[14] = 15;  assign k_lut[15] = 16;

    assign b_lut[0] = 1;  assign b_lut[1] = 2;  assign b_lut[2] = 3;  assign b_lut[3] = 4;
    assign b_lut[4] = 5;  assign b_lut[5] = 6;  assign b_lut[6] = 7;  assign b_lut[7] = 8;
    assign b_lut[8] = 9;  assign b_lut[9] = 10;  assign b_lut[10] = 11;  assign b_lut[11] = 12;
    assign b_lut[12] = 13;  assign b_lut[13] = 14;  assign b_lut[14] = 15;  assign b_lut[15] = 16;

    // 确定k，b�?
    always@(*)begin
        if(!rst_n) begin 
            k <= 'd0;
            b <= 'd0;
        end
        else if (cout[0] == 1'b1) begin  //比bp0�?
            k <= k_lut[0];
            b <= b_lut[0]; 
        end
        else if (cout[1] == 1'b1) begin    //大于等于bp0，小于bp1
            k <= k_lut[1];
            b <= b_lut[1];
        end 
        else if (cout[2] == 1'b1) begin    //大于等于bp1，小于bp2
            k <= k_lut[2];
            b <= b_lut[2];
        end 
        else if (cout[3] == 1'b1) begin     //大于等于bp2，小于bp3
            k <= k_lut[3];
            b <= b_lut[3];
        end 
        else if (cout[4] == 1'b1) begin     //大于等于bp3，小于bp4
            k <= k_lut[4];
            b <= b_lut[4];
        end 
        else if (cout[5] == 1'b1) begin
            k <= k_lut[5];
            b <= b_lut[5];
        end 
        else if (cout[6] == 1'b1) begin
            k <= k_lut[6];
            b <= b_lut[6];
        end 
        else if (cout[7] == 1'b1) begin
            k <= k_lut[7];
            b <= b_lut[7];
        end 
        else if (cout[8] == 1'b1) begin
            k <= k_lut[8];
            b <= b_lut[8];
        end 
        else if (cout[9] == 1'b1) begin
            k <= k_lut[9];
            b <= b_lut[9];
        end 
        else if (cout[10] == 1'b1) begin
            k <= k_lut[10];
            b <= b_lut[10];
        end 
        else if (cout[11] == 1'b1) begin
            k <= k_lut[11];
            b <= b_lut[11];
        end 
        else if (cout[12] == 1'b1) begin
            k <= k_lut[12];
            b <= b_lut[12];
        end 
        else if (cout[13] == 1'b1) begin
            k <= k_lut[13];
            b <= b_lut[13];
        end 
        else if (cout[14] == 1'b1) begin
            k <= k_lut[14];
            b <= b_lut[14];
        end 
        else if (cout[15] == 1'b1) begin    //大于bp14，小于bp15
            k <= k_lut[15];
            b <= b_lut[15];
        end  
        else begin  //大于bp15
            k <= k_lut[15];
            b <= b_lut[15];
        end
    end


// ---------------- pipeline 2: clk 2 ---------------------------
// 乘加运算: k*x + b
    wire signed  [x_WIDTH + k_WIDTH -1 :0]       temp;
    wire signed  [result_WIDTH-1:0]              result_temp;

// �????要调用IP核，不然会综合为DSP
// �????�????32*8位有符号乘法器，40位有符号加法�????
    mult_zmt mul (.A(k), .B(x_reg1), .P(temp));
    addsub_zmt add (.A(temp), .B(b), .S(result_temp));

    always @(posedge clk_p or negedge rst_n) begin
        if(!rst_n) begin 
            result <= 'd0;
        end
        else begin
            result <= (!en_p1_n) ? result_temp : 'd0;
        end
    end


endmodule