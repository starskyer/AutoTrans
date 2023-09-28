`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/16 18:46:01
// Design Name: 
// Module Name: fifo_8kb_512
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


module fifo_8kb_32
#(
    parameter   INPUT_WIDTH = 8,
    parameter   INPUT_NUM = 768,
    parameter   FIFO_WIDTH = 1024,
    parameter   FIFO_NUM = 8,
    parameter   FIFO_GROUP_WIDTH = FIFO_WIDTH * FIFO_NUM
)
(
//*************************************** System signal ***************************************//
    input                                                                           clk_p,
    input                                                                           rst_n,
//*************************************** Input signal ***************************************//
    input                                   [INPUT_WIDTH * INPUT_NUM - 1 : 0]       data,
    input                                                                           data_valid_n,
    input                                                                           read_en_n,
//*************************************** Output signal ***************************************//
    output                                  [INPUT_WIDTH * INPUT_NUM - 1 : 0]       result,
    output                                                                          result_valid_n
    );
wire        [FIFO_WIDTH - 1 : 0]            fifo_input      [FIFO_NUM - 1 : 0];

// 输入位宽小于FIFO位宽，高位补0
assign  {fifo_input[7], fifo_input[6], fifo_input[5], fifo_input[4],
         fifo_input[3], fifo_input[2], fifo_input[1], fifo_input[0]} = {
            {(FIFO_GROUP_WIDTH - INPUT_WIDTH * INPUT_NUM){1'b0}}, data
         };

//*************************************** FIFO ***************************************//
wire                                        rd_en;
wire        [FIFO_WIDTH - 1 : 0]            fifo_output     [FIFO_NUM - 1 : 0];
wire                                        wr_en;
wire                                        rst;
wire        [FIFO_NUM - 1 : 0]              valid;

assign  rd_en = ~read_en_n;
assign  wr_en = ~data_valid_n;
assign  rst = ~rst_n;


fifo_1024_32 u_fifo_1024_32_1 (
  .clk(clk_p),                  // input wire clk
  .srst(rst),                  // input wire rst
  .din(fifo_input[0]),                  // input wire [1023 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(fifo_output[0]),    // output wire [1023 : 0] dout
  .valid(valid[0])                
);

fifo_1024_32 u_fifo_1024_32_2 (
  .clk(clk_p),                  // input wire clk
  .srst(rst),                  // input wire rst
  .din(fifo_input[1]),                  // input wire [1023 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(fifo_output[1]),                // output wire [1023 : 0] dout
  .valid(valid[1])
);

fifo_1024_32 u_fifo_1024_32_3 (
  .clk(clk_p),                  // input wire clk
  .srst(rst),                  // input wire rst
  .din(fifo_input[2]),                  // input wire [1023 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(fifo_output[2]),                // output wire [1023 : 0] dout
  .valid(valid[2])
);

fifo_1024_32 u_fifo_1024_32_4 (
  .clk(clk_p),                  // input wire clk
  .srst(rst),                  // input wire rst
  .din(fifo_input[3]),                  // input wire [1023 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(fifo_output[3]) ,               // output wire [1023 : 0] dout
  .valid(valid[3])
);

fifo_1024_32 u_fifo_1024_32_5 (
  .clk(clk_p),                  // input wire clk
  .srst(rst),                  // input wire rst
  .din(fifo_input[4]),                  // input wire [1023 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(fifo_output[4]) ,               // output wire [1023 : 0] dout
  .valid(valid[4])
);

fifo_1024_32 u_fifo_1024_32_6 (
  .clk(clk_p),                  // input wire clk
  .srst(rst),                  // input wire rst
  .din(fifo_input[5]),                  // input wire [1023 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(fifo_output[5]) ,               // output wire [1023 : 0] dout
  .valid(valid[5])
);

fifo_1024_32 u_fifo_1024_32_7 (
  .clk(clk_p),                  // input wire clk
  .srst(rst),                  // input wire rst
  .din(fifo_input[6]),                  // input wire [1023 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(fifo_output[6]) ,               // output wire [1023 : 0] dout
  .valid(valid[6])
);

fifo_1024_32 u_fifo_1024_32_8 (
  .clk(clk_p),                  // input wire clk
  .srst(rst),                  // input wire rst
  .din(fifo_input[7]),                  // input wire [1023 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(fifo_output[7]),                // output wire [1023 : 0] dout
  .valid(valid[7])
);

// 输出位宽小于FIFO位宽，高位截断
wire        [FIFO_WIDTH * FIFO_NUM - 1 : 0]            fifo_outputs;       
assign  fifo_outputs = {fifo_output[7], fifo_output[6], fifo_output[5], fifo_output[4],
                        fifo_output[3], fifo_output[2], fifo_output[1], fifo_output[0]};
assign  result = fifo_outputs[INPUT_WIDTH * INPUT_NUM - 1 : 0];
assign  result_valid_n = ~(&valid);


endmodule
