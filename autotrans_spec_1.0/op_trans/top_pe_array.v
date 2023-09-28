`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2023 01:06:36 PM
// Design Name: 
// Module Name: top_pe_array
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_pe_array(
    input    clk_p,
    input    rst_n, 
    output   vd
);


    localparam    NUM_ROW = 'd128;
    localparam    NUM_COL = 'd64;
    localparam    WIDTH_DATA = 'd8;
    localparam    NUM_PE_ROW = 'd64;
    localparam    NUM_PE_COL = 'd64;    // 128/2=64


    wire                                                                 clk_p;
    wire                                                                 rst_n;
    wire           [NUM_ROW * WIDTH_DATA - 1 : 0]                        data_row;
    wire           [NUM_COL * WIDTH_DATA - 1 : 0]                        data_col;
    wire                                                                 r_c_sel;    // read data from fifo by row or col, 0 by row, 1 by col
    wire           [0 : NUM_COL * WIDTH_DATA - 1]                        result_row;
    wire           [0 : NUM_ROW * WIDTH_DATA - 1]                        result_col;


    dsp_pe_array #(.NUM_ROW(NUM_ROW), .NUM_COL(NUM_COL), .WIDTH_DATA(WIDTH_DATA), .NUM_PE_ROW(NUM_PE_ROW), .NUM_PE_COL(NUM_PE_COL)) 
                   (clk_p, rst_n, data_row, data_col, r_c_sel, result);

    assign  vd = (|result);
    

endmodule
