`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/12 15:34:53
// Design Name: 
// Module Name: divide768
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


module divide768
#(
    parameter   INPUT_WIDTH = 18,
    parameter   OUTPUT_WIDTH = 9
)
(
//*************************************** System signal ***************************************//
    input                                                                           clk_p,
    input                                                                           rst_n,
//*************************************** Input signal ***************************************//
    input                   signed          [INPUT_WIDTH - 1 : 0]                   dividend,
    input                                                                           dividend_valid_n,
//*************************************** Output signal ***************************************//
    output                  signed          [OUTPUT_WIDTH - 1 : 0]                  quotient,
    output                                                                          quotient_valid_n
);
wire                                                aclk;
wire                                                aresetn;
wire                                                s_axis_dividend_tvalid;
wire                                                s_axis_divisor_tvalid;
wire    signed      [23 :   0]                      s_axis_dividend_tdata;
wire    signed      [7  :   0]                      s_axis_divisor_tdata;
wire                                                m_axis_dout_tvalid;
wire                [31 :   0]                      m_axis_dout_tdata;

divider_24_8 u_divider_24_8 (
  .aclk(aclk),                                      // input wire aclk
  .aresetn(aresetn),                                // input wire aresetn
  .s_axis_divisor_tvalid(s_axis_divisor_tvalid),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(s_axis_divisor_tdata),      // input wire [7 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(s_axis_dividend_tvalid),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(s_axis_dividend_tdata),    // input wire [23 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(m_axis_dout_tvalid),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(m_axis_dout_tdata)            // output wire [31 : 0] m_axis_dout_tdata
);

assign  aclk = clk_p;
assign  aresetn = rst_n;
assign  s_axis_dividend_tvalid = ~dividend_valid_n;
assign  s_axis_divisor_tvalid = ~dividend_valid_n;

// devidend width: INPUT_WIDTH -> 32 --(/2**8)--> 24
//INPUT_WIDTH = 18, 30
wire    signed      [31 :   0]                      dividend_l;
short2long#(
    .INPUT_WIDTH ( INPUT_WIDTH ),
    .OUTPUT_WIDTH ( 32 )
)u_short2long(
    .datain      ( dividend      ),
    .dataout     ( dividend_l     )
);
assign  s_axis_dividend_tdata = dividend_l[31:8];   // dividend_l/2**8

assign  s_axis_divisor_tdata = 8'h03;   //  divisor = 3
assign  quotient_valid_n = ~m_axis_dout_tvalid;
assign  quotient = m_axis_dout_tdata[31:8];

endmodule
