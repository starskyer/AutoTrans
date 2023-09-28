// pe_array, composed of pe unit 
// fifo_array

module dsp_pe_array
#(
    parameter    NUM_ROW = 'd128,
    parameter    NUM_COL = 'd64,
    parameter    WIDTH_DATA = 'd8,
    parameter    NUM_PE_ROW = 'd64,
    parameter    NUM_PE_COL = 'd64    // 128/2=64
)
(
    input                                                                 clk_p,
    input                                                                 rst_n,
    input           [NUM_ROW * WIDTH_DATA - 1 : 0]                        data_row,
    input           [NUM_COL * WIDTH_DATA - 1 : 0]                        data_col,
    input                                                                 r_c_sel,    // read data from fifo by row or col, 0 by row, 1 by col
    output   reg    [0 : NUM_COL * WIDTH_DATA - 1]                        result_row,    // data read from fifo, one row
    output   reg    [0 : NUM_ROW * WIDTH_DATA - 1]                        result_col    // data read from fifo, one col
);


    localparam NUM_FIFO = NUM_PE_ROW * NUM_PE_COL;
    localparam WIDTH_PE_RESULT = WIDTH_DATA + 'd14;


    wire    [WIDTH_DATA - 1 : 0]    data_col_mem      [NUM_PE_COL - 1 : 0];    // B 
    wire    [WIDTH_DATA - 1 : 0]    data_row_mem_0    [NUM_PE_ROW - 1 : 0];    // A
    wire    [WIDTH_DATA - 1 : 0]    data_row_mem_1    [NUM_PE_ROW - 1 : 0];    // D

    wire    [WIDTH_PE_RESULT - 1 : 0]    pe_result_l     [NUM_PE_ROW * NUM_PE_COL - 1 : 0];    // low 8 bit of pe result
    wire    [WIDTH_PE_RESULT - 1 : 0]    pe_result_h     [NUM_PE_ROW * NUM_PE_COL - 1 : 0];    // high 8 bit of pe result


    wire    wr_en_l;
    reg     rd_en_l;
    wire    wr_en_h;
    wire    rd_en_h;
    wire    [NUM_FIFO - 1 : 0]    valid_l;
    wire    [NUM_FIFO - 1 : 0]    valid_h;
    wire    [WIDTH_DATA - 1 : 0]  fifo_data_l    [NUM_PE_ROW * NUM_PE_COL - 1 : 0];
    wire    [WIDTH_DATA - 1 : 0]  fifo_data_h    [NUM_PE_ROW * NUM_PE_COL - 1 : 0];


    assign  {data_col_mem[63], data_col_mem[62], data_col_mem[61], data_col_mem[60], data_col_mem[59], data_col_mem[58], data_col_mem[57], data_col_mem[56], 
             data_col_mem[55], data_col_mem[54], data_col_mem[53], data_col_mem[52], data_col_mem[51], data_col_mem[50], data_col_mem[49], data_col_mem[48], 
             data_col_mem[47], data_col_mem[46], data_col_mem[45], data_col_mem[44], data_col_mem[43], data_col_mem[42], data_col_mem[41], data_col_mem[40], 
             data_col_mem[39], data_col_mem[38], data_col_mem[37], data_col_mem[36], data_col_mem[35], data_col_mem[34], data_col_mem[33], data_col_mem[32], 
             data_col_mem[31], data_col_mem[30], data_col_mem[29], data_col_mem[28], data_col_mem[27], data_col_mem[26], data_col_mem[25], data_col_mem[24], 
             data_col_mem[23], data_col_mem[22], data_col_mem[21], data_col_mem[20], data_col_mem[19], data_col_mem[18], data_col_mem[17], data_col_mem[16], 
             data_col_mem[15], data_col_mem[14], data_col_mem[13], data_col_mem[12], data_col_mem[11], data_col_mem[10], data_col_mem[9], data_col_mem[8], 
             data_col_mem[7], data_col_mem[6], data_col_mem[5], data_col_mem[4], data_col_mem[3], data_col_mem[2], data_col_mem[1], data_col_mem[0]} = data_col;

    assign  {data_row_mem_1[63], data_row_mem_0[63], data_row_mem_1[62], data_row_mem_0[62], data_row_mem_1[61], data_row_mem_0[61], data_row_mem_1[60], data_row_mem_0[60], 
                        data_row_mem_1[59], data_row_mem_0[59], data_row_mem_1[58], data_row_mem_0[58], data_row_mem_1[57], data_row_mem_0[57], data_row_mem_1[56], data_row_mem_0[56], 
                        data_row_mem_1[55], data_row_mem_0[55], data_row_mem_1[54], data_row_mem_0[54], data_row_mem_1[53], data_row_mem_0[53], data_row_mem_1[52], data_row_mem_0[52], 
                        data_row_mem_1[51], data_row_mem_0[51], data_row_mem_1[50], data_row_mem_0[50], data_row_mem_1[49], data_row_mem_0[49], data_row_mem_1[48], data_row_mem_0[48], 
                        data_row_mem_1[47], data_row_mem_0[47], data_row_mem_1[46], data_row_mem_0[46], data_row_mem_1[45], data_row_mem_0[45], data_row_mem_1[44], data_row_mem_0[44], 
                        data_row_mem_1[43], data_row_mem_0[43], data_row_mem_1[42], data_row_mem_0[42], data_row_mem_1[41], data_row_mem_0[41], data_row_mem_1[40], data_row_mem_0[40], 
                        data_row_mem_1[39], data_row_mem_0[39], data_row_mem_1[38], data_row_mem_0[38], data_row_mem_1[37], data_row_mem_0[37], data_row_mem_1[36], data_row_mem_0[36], 
                        data_row_mem_1[35], data_row_mem_0[35], data_row_mem_1[34], data_row_mem_0[34], data_row_mem_1[33], data_row_mem_0[33], data_row_mem_1[32], data_row_mem_0[32], 
                        data_row_mem_1[31], data_row_mem_0[31], data_row_mem_1[30], data_row_mem_0[30], data_row_mem_1[29], data_row_mem_0[29], data_row_mem_1[28], data_row_mem_0[28], 
                        data_row_mem_1[27], data_row_mem_0[27], data_row_mem_1[26], data_row_mem_0[26], data_row_mem_1[25], data_row_mem_0[25], data_row_mem_1[24], data_row_mem_0[24], 
                        data_row_mem_1[23], data_row_mem_0[23], data_row_mem_1[22], data_row_mem_0[22], data_row_mem_1[21], data_row_mem_0[21], data_row_mem_1[20], data_row_mem_0[20], 
                        data_row_mem_1[19], data_row_mem_0[19], data_row_mem_1[18], data_row_mem_0[18], data_row_mem_1[17], data_row_mem_0[17], data_row_mem_1[16], data_row_mem_0[16], 
                        data_row_mem_1[15], data_row_mem_0[15], data_row_mem_1[14], data_row_mem_0[14], data_row_mem_1[13], data_row_mem_0[13], data_row_mem_1[12], data_row_mem_0[12], 
                        data_row_mem_1[11], data_row_mem_0[11], data_row_mem_1[10], data_row_mem_0[10], data_row_mem_1[9], data_row_mem_0[9], data_row_mem_1[8], data_row_mem_0[8], 
                        data_row_mem_1[7], data_row_mem_0[7], data_row_mem_1[6], data_row_mem_0[6], data_row_mem_1[5], data_row_mem_0[5], data_row_mem_1[4], data_row_mem_0[4], 
                        data_row_mem_1[3], data_row_mem_0[3], data_row_mem_1[2], data_row_mem_0[2], data_row_mem_1[1], data_row_mem_0[1], data_row_mem_1[0], data_row_mem_0[0]} = data_row;

    // pe array
    genvar  i, j, k1, k2;

//    (*DONT_TOUCH = "yes"*)
    generate 
        for (i = 0; i < NUM_PE_COL; i = i + 1) begin: array_out
            for (j = 0; j < NUM_PE_ROW; j = j + 1) begin: array_in
//                (*DONT_TOUCH = "yes"*)
                pe u_pe (.clk(clk_p), .done(), .input_A(data_row_mem_0[j]), .input_B(data_col_mem[i]), .input_D(data_row_mem_1[j]),
                         .reset(rst_n), .resulta(pe_result_l[64*i+j]), .resultb(pe_result_h[64*i+j]));
            end
        end
    endgenerate


    // fifo array
    generate
        for (k1 = 0; k1 < NUM_FIFO; k1 = k1 + 1) begin: fifo_array_l
            fifo_8_48 u_fifo_l (.clk(clk_p), .srst(rst_n), .din(pe_result_l[k1][7:0]), .wr_en(wr_en_l), .rd_en(rd_en_l), .dout(fifo_data_l[k1]), .valid(valid_l[k1]), .full(), .empty(), .wr_rst_busy(), .rd_rst_busy());
        end
    endgenerate

    generate
        for (k2 = 0; k2 < NUM_FIFO; k2 = k2 + 1) begin: fifo_array_h
            fifo_8_48 u_fifo_h (.clk(clk_p), .srst(rst_n), .din(pe_result_h[k2][7:0]), .wr_en(wr_en_h), .rd_en(rd_en_h), .dout(fifo_data_h[k2]), .valid(valid_h[k2]), .full(), .empty(), .wr_rst_busy(), .rd_rst_busy());
        end
    endgenerate


    integer    a;
    always @(posedge clk_p or negedge rst_n) begin
        if (!rst_n) begin
            result_row <= 'd0;
            result_col <= 'd0;
        end
        else if (r_c_sel) begin    // read by col
                for (a = 0; a < NUM_ROW; a = a + 1) begin
                    result_col <= {fifo_data_l[a*64], fifo_data_h[a*64], fifo_data_l[a*64+1], fifo_data_h[a*64+1], fifo_data_l[a*64+2], fifo_data_h[a*64+2], fifo_data_l[a*64+3], fifo_data_h[a*64+3], fifo_data_l[a*64+4], fifo_data_h[a*64+4],
                               fifo_data_l[a*64+5], fifo_data_h[a*64+5], fifo_data_l[a*64+6], fifo_data_h[a*64+6], fifo_data_l[a*64+7], fifo_data_h[a*64+7], fifo_data_l[a*64+8], fifo_data_h[a*64+8], fifo_data_l[a*64+9], fifo_data_h[a*64+9],
                               fifo_data_l[a*64+10], fifo_data_h[a*64+10], fifo_data_l[a*64+11], fifo_data_h[a*64+11], fifo_data_l[a*64+12], fifo_data_h[a*64+12], fifo_data_l[a*64+13], fifo_data_h[a*64+13], fifo_data_l[a*64+14], fifo_data_h[a*64+14],
                               fifo_data_l[a*64+15], fifo_data_h[a*64+15], fifo_data_l[a*64+16], fifo_data_h[a*64+16], fifo_data_l[a*64+17], fifo_data_h[a*64+17], fifo_data_l[a*64+18], fifo_data_h[a*64+18], fifo_data_l[a*64+19], fifo_data_h[a*64+19],
                               fifo_data_l[a*64+20], fifo_data_h[a*64+20], fifo_data_l[a*64+21], fifo_data_h[a*64+21], fifo_data_l[a*64+22], fifo_data_h[a*64+22], fifo_data_l[a*64+23], fifo_data_h[a*64+23], fifo_data_l[a*64+24], fifo_data_h[a*64+24],
                               fifo_data_l[a*64+25], fifo_data_h[a*64+25], fifo_data_l[a*64+26], fifo_data_h[a*64+26], fifo_data_l[a*64+27], fifo_data_h[a*64+27], fifo_data_l[a*64+28], fifo_data_h[a*64+28], fifo_data_l[a*64+29], fifo_data_h[a*64+29],
                               fifo_data_l[a*64+30], fifo_data_h[a*64+30], fifo_data_l[a*64+31], fifo_data_h[a*64+31], fifo_data_l[a*64+32], fifo_data_h[a*64+32], fifo_data_l[a*64+33], fifo_data_h[a*64+33], fifo_data_l[a*64+34], fifo_data_h[a*64+34],
                               fifo_data_l[a*64+35], fifo_data_h[a*64+35], fifo_data_l[a*64+36], fifo_data_h[a*64+36], fifo_data_l[a*64+37], fifo_data_h[a*64+37], fifo_data_l[a*64+38], fifo_data_h[a*64+38], fifo_data_l[a*64+39], fifo_data_h[a*64+39],
                               fifo_data_l[a*64+40], fifo_data_h[a*64+40], fifo_data_l[a*64+41], fifo_data_h[a*64+41], fifo_data_l[a*64+42], fifo_data_h[a*64+42], fifo_data_l[a*64+43], fifo_data_h[a*64+43], fifo_data_l[a*64+44], fifo_data_h[a*64+44],
                               fifo_data_l[a*64+45], fifo_data_h[a*64+45], fifo_data_l[a*64+46], fifo_data_h[a*64+46], fifo_data_l[a*64+47], fifo_data_h[a*64+47], fifo_data_l[a*64+48], fifo_data_h[a*64+48], fifo_data_l[a*64+49], fifo_data_h[a*64+49],
                               fifo_data_l[a*64+50], fifo_data_h[a*64+50], fifo_data_l[a*64+51], fifo_data_h[a*64+51], fifo_data_l[a*64+52], fifo_data_h[a*64+52], fifo_data_l[a*64+53], fifo_data_h[a*64+53], fifo_data_l[a*64+54], fifo_data_h[a*64+54],
                               fifo_data_l[a*64+55], fifo_data_h[a*64+55], fifo_data_l[a*64+56], fifo_data_h[a*64+56], fifo_data_l[a*64+57], fifo_data_h[a*64+57], fifo_data_l[a*64+58], fifo_data_h[a*64+58], fifo_data_l[a*64+59], fifo_data_h[a*64+59],
                               fifo_data_l[a*64+60], fifo_data_h[a*64+60], fifo_data_l[a*64+61], fifo_data_h[a*64+61], fifo_data_l[a*64+62], fifo_data_h[a*64+62], fifo_data_l[a*64+63], fifo_data_h[a*64+63]};
                end
                result_row <= 'd0;
            end
            else begin    // read by row
                for (a = 0; a < NUM_COL; a = a + 1) begin
                    if (a % 2) begin    // odd number
                        result_row <= {fifo_data_h[a/2], fifo_data_h[a/2+64], fifo_data_h[a/2+64*2], fifo_data_h[a/2+64*3], fifo_data_h[a/2+64*4], fifo_data_h[a/2+64*5], fifo_data_h[a/2+64*6], fifo_data_h[a/2+64*7], 
                                   fifo_data_h[a/2+64*8], fifo_data_h[a/2+64*9], fifo_data_h[a/2+64*10], fifo_data_h[a/2+64*11], fifo_data_h[a/2+64*12], fifo_data_h[a/2+64*13], fifo_data_h[a/2+64*14], fifo_data_h[a/2+64*15], 
                                   fifo_data_h[a/2+64*16], fifo_data_h[a/2+64*17], fifo_data_h[a/2+64*18], fifo_data_h[a/2+64*19], fifo_data_h[a/2+64*20], fifo_data_h[a/2+64*21], fifo_data_h[a/2+64*22], fifo_data_h[a/2+64*23], 
                                   fifo_data_h[a/2+64*24], fifo_data_h[a/2+64*25], fifo_data_h[a/2+64*26], fifo_data_h[a/2+64*27], fifo_data_h[a/2+64*28], fifo_data_h[a/2+64*29], fifo_data_h[a/2+64*30], fifo_data_h[a/2+64*31], 
                                   fifo_data_h[a/2+64*32], fifo_data_h[a/2+64*33], fifo_data_h[a/2+64*34], fifo_data_h[a/2+64*35], fifo_data_h[a/2+64*36], fifo_data_h[a/2+64*37], fifo_data_h[a/2+64*38], fifo_data_h[a/2+64*39], 
                                   fifo_data_h[a/2+64*40], fifo_data_h[a/2+64*41], fifo_data_h[a/2+64*42], fifo_data_h[a/2+64*43], fifo_data_h[a/2+64*44], fifo_data_h[a/2+64*45], fifo_data_h[a/2+64*46], fifo_data_h[a/2+64*47], 
                                   fifo_data_h[a/2+64*48], fifo_data_h[a/2+64*49], fifo_data_h[a/2+64*50], fifo_data_h[a/2+64*51], fifo_data_h[a/2+64*52], fifo_data_h[a/2+64*53], fifo_data_h[a/2+64*54], fifo_data_h[a/2+64*55], 
                                   fifo_data_h[a/2+64*56], fifo_data_h[a/2+64*57], fifo_data_h[a/2+64*58], fifo_data_h[a/2+64*59], fifo_data_h[a/2+64*60], fifo_data_h[a/2+64*61], fifo_data_h[a/2+64*62], fifo_data_h[a/2+64*63]};
                    end
                    else begin
                    result_row <= {fifo_data_l[a/2], fifo_data_l[a/2+64], fifo_data_l[a/2+64*2], fifo_data_l[a/2+64*3], fifo_data_l[a/2+64*4], fifo_data_l[a/2+64*5], fifo_data_l[a/2+64*6], fifo_data_l[a/2+64*7], 
                                   fifo_data_l[a/2+64*8], fifo_data_l[a/2+64*9], fifo_data_l[a/2+64*10], fifo_data_l[a/2+64*11], fifo_data_l[a/2+64*12], fifo_data_l[a/2+64*13], fifo_data_l[a/2+64*14], fifo_data_l[a/2+64*15], 
                                   fifo_data_l[a/2+64*16], fifo_data_l[a/2+64*17], fifo_data_l[a/2+64*18], fifo_data_l[a/2+64*19], fifo_data_l[a/2+64*20], fifo_data_l[a/2+64*21], fifo_data_l[a/2+64*22], fifo_data_l[a/2+64*23], 
                                   fifo_data_l[a/2+64*24], fifo_data_l[a/2+64*25], fifo_data_l[a/2+64*26], fifo_data_l[a/2+64*27], fifo_data_l[a/2+64*28], fifo_data_l[a/2+64*29], fifo_data_l[a/2+64*30], fifo_data_l[a/2+64*31], 
                                   fifo_data_l[a/2+64*32], fifo_data_l[a/2+64*33], fifo_data_l[a/2+64*34], fifo_data_l[a/2+64*35], fifo_data_l[a/2+64*36], fifo_data_l[a/2+64*37], fifo_data_l[a/2+64*38], fifo_data_l[a/2+64*39], 
                                   fifo_data_l[a/2+64*40], fifo_data_l[a/2+64*41], fifo_data_l[a/2+64*42], fifo_data_l[a/2+64*43], fifo_data_l[a/2+64*44], fifo_data_l[a/2+64*45], fifo_data_l[a/2+64*46], fifo_data_l[a/2+64*47], 
                                   fifo_data_l[a/2+64*48], fifo_data_l[a/2+64*49], fifo_data_l[a/2+64*50], fifo_data_l[a/2+64*51], fifo_data_l[a/2+64*52], fifo_data_l[a/2+64*53], fifo_data_l[a/2+64*54], fifo_data_l[a/2+64*55], 
                                   fifo_data_l[a/2+64*56], fifo_data_l[a/2+64*57], fifo_data_l[a/2+64*58], fifo_data_l[a/2+64*59], fifo_data_l[a/2+64*60], fifo_data_l[a/2+64*61], fifo_data_l[a/2+64*62], fifo_data_l[a/2+64*63]};
                    end
                end
                result_col <= 'd0;
            end
    end


endmodule




(*DONT_TOUCH = "yes"*)
module pe
#(
    parameter INPUT_WIDTH   =   'd8,
    parameter OUTPUT_WIDTH  =   INPUT_WIDTH + 'd14
   
)
 (input                                                      clk,
 input                                                      done,
 input                      [INPUT_WIDTH - 1 : 0]           input_A,
 input                      [INPUT_WIDTH - 1 : 0]           input_B,
 input                      [INPUT_WIDTH - 1 : 0]           input_D,
 input                                                      reset,
 output      reg            [OUTPUT_WIDTH - 1 : 0]          resulta,
 output      reg            [OUTPUT_WIDTH - 1 : 0]          resultb);
 /*
 output      wire           [7 : 0]                         dout,
 output      wire                                           full,
 output      wire                                           empty,
 output      wire                                           rd_rst_busy,
 output      wire                                           wr_rst_busy,
 output      wire           [7 : 0]                         dout2,
 output      wire                                           full2,
 output      wire                                           empty2,
 output      wire                                           rd_rst_busy2,
 output      wire                                           wr_rst_busy2);
*/
reg            [16 : 0]                        P_change_sign_1;
reg            [16 : 0]                        P_change_sign_2;
wire           [47 : 0]                        P;
wire           [47 : 0]                        C_in;
wire           [6 : 0]                        result_h_1;
wire           [6 : 0]                        result_h_2;

 
reg                     [2 : 0]                         input_sign_1;
reg                     [2 : 0]                         input_sign_2;
reg                     [2 : 0]                         input_sign_3;
reg                     [26 : 0]                        abs_A;
reg                     [17 : 0]                        abs_B;
reg                     [7 : 0]                         abs_D;
reg                     [26 : 0]                        shift_D;
reg                     [6 : 0]                        P_high_change_sign_1;
reg                     [6 : 0]                        P_high_change_sign_2;
//wire                    [6 : 0]                        result_h_1;
//wire                    [6 : 0]                        result_h_2;
wire                    [6 : 0]                        P_change_sign_extend_1;
wire                    [6 : 0]                        P_change_sign_extend_2;





 
 reg                        [16 : 0]                        P_left_1;
 reg                        [16 : 0]                        P_left_2;
 reg                        [11 : 0]                        P_cut_1;
 reg                        [11 : 0]                        P_cut_2;

 reg                        [11 : 0]                        P_high_1;
 reg                        [11 : 0]                        P_high_2;


 

 always @(*) begin
    if(input_A[INPUT_WIDTH - 1] == 1'b1)
    begin
        abs_A[7 : 0] = ~input_A + 1;
        abs_A[26 : 8] = 19'b0;
    end
    else
    begin
        abs_A = input_A;
    end

    if(input_B[INPUT_WIDTH - 1] == 1'b1)
    begin
        abs_B[7 : 0] = ~input_B + 1;
        abs_B[17 : 8] = 10'b0;
    end
    else
    begin
        abs_B = input_B;
    end

    if(input_D[INPUT_WIDTH - 1] == 1'b1)
    begin
        abs_D = ~input_D + 1;
    end
    else
    begin
        abs_D = input_D;
    end
 end        


 always @(*) begin
    shift_D = {abs_D ,18'b0};
     end

 xbip_dsp48_macro_0 dsp48_1 (
    .CLK(clk),  // input wire CLK
    .A(abs_A),      // input wire [26 : 0] A
    .B(abs_B),      // input wire [17 : 0] B
    .C(C_in),      // input wire [47 : 0] C
    .D(shift_D),      // input wire [26 : 0] D
    .P(P)      // output wire [47 : 0] P
  );



 always @(posedge clk ) begin
    if(reset == 1'b1)
    begin
      input_sign_1 <= 0;
      input_sign_2 <= 0;
      input_sign_3 <= 0;
    end
    else
    begin
    input_sign_3 <= input_sign_2;
    input_sign_2 <= input_sign_1;
    input_sign_1 <= {input_A [INPUT_WIDTH - 1], input_B[INPUT_WIDTH-1], input_D[INPUT_WIDTH-1]};   
    end
 end

 always @(posedge clk or posedge reset) begin
    
    if(reset == 1'b1)
    begin
      P_change_sign_1 <= 0;
      P_change_sign_2 <= 0;
    end
    else
    begin
    if (input_sign_3[2]^input_sign_3[1]^input_sign_2[2]^input_sign_2[1] == 0) begin
      P_change_sign_1 <= P[16 : 0];
    end else begin
      P_change_sign_1 <= ~P[16 : 0] + 1'b1;
    end

    if (input_sign_3[0]^input_sign_3[1]^input_sign_2[0]^input_sign_2[1] == 0) begin
      P_change_sign_2 <= P[34 : 18];
    end else begin
      P_change_sign_2 <= ~P[34 : 18] + 1'b1;
    end
 end
 end
  
 always @(*) begin
    if (P_change_sign_1[16] == P_change_sign_1[15]) begin
      P_cut_1 = 0;
    end else begin
      P_cut_1 = {{6{P_change_sign_1[16]}}, 1'b1};
    end
    if (P_change_sign_2[16] == P_change_sign_2[15]) begin
      P_cut_2 = 0;
    end else begin
      P_cut_2 = {{6{P_change_sign_2[16]}}, 1'b1};
    end
    P_left_1 = {P_change_sign_1[16], P_change_sign_1[16], P_change_sign_1[14:0]};
    P_left_2 = {P_change_sign_2[16], P_change_sign_2[16], P_change_sign_2[14:0]};
    
 end
 
 assign C_in[16 : 0] = P_left_1;
 assign C_in[17] = 0;
 assign C_in[34 : 18] = P_left_2;
 assign C_in[47 : 35] = 0;

 always @(* ) begin
    P_high_1 = P_high_change_sign_1 + P_cut_1;
    P_high_2 = P_high_change_sign_2 + P_cut_2;
 end

 always @(posedge clk or posedge reset) begin
    if(reset == 1'b1)
    begin
      P_high_change_sign_1 = 0;
      P_high_change_sign_2 = 0;
    end
    else
    begin
    if (input_sign_3[0]^input_sign_3[1]^input_sign_2[0]^input_sign_2[1] == 0) begin
      P_high_change_sign_2 <= P_high_2;
    end else begin
      P_high_change_sign_2 <= ~P_high_2 + 1'b1;
    end
    if (input_sign_3[2]^input_sign_3[1]^input_sign_2[2]^input_sign_2[1] == 0) begin
      P_high_change_sign_1 <= P_high_1;
    end else begin
      P_high_change_sign_1 <= ~P_high_1 + 1'b1;
    end
    end
 end


assign P_change_sign_extend_1 = {7{P_change_sign_1[16]}};
assign P_change_sign_extend_2 = {7{P_change_sign_2[16]}};
assign result_h_1 = P_high_change_sign_1 + P_change_sign_extend_1;
assign result_h_2 = P_high_change_sign_2 + P_change_sign_extend_2;
 //always @(*) begin
     
     //result_high_1 = {12{P_change_sign_1[16]}};
     //result_high_2 = {12{P_change_sign_2[16]}};
    // end
 always @(posedge clk ) begin
  
      resulta <= {result_h_1 , P_change_sign_1[14 : 0]};
      resultb <= {result_h_2 , P_change_sign_2[14 : 0]};
  
 end
 
/*
 fifo_generator_0 v0 (
  .clk(clk),                  // input wire clk
  .srst(reset),                // input wire srst
  .din(result01),                  // input wire [7 : 0] din
  .wr_en(reset),              // input wire wr_en
  .rd_en(reset),              // input wire rd_en
  .dout(dout),                // output wire [7 : 0] dout
  .full(full),                // output wire full
  .empty(empty),              // output wire empty
  .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy)  // output wire rd_rst_busy
);
 
 fifo_generator_0 v1 (
  .clk(clk),                  // input wire clk
  .srst(reset),                // input wire srst
  .din(result02),                  // input wire [7 : 0] din
  .wr_en(reset),              // input wire wr_en
  .rd_en(reset),              // input wire rd_en
  .dout(dout2),                // output wire [7 : 0] dout
  .full(full2),                // output wire full
  .empty(empty2),              // output wire empty
  .wr_rst_busy(wr_rst_busy2),  // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy2)  // output wire rd_rst_busy
);*/
 endmodule
 

