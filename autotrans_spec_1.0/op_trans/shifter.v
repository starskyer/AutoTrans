`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/17 11:08:03
// Design Name: 
// Module Name: shifter
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

// 右移并缩短宽度
module shifter
#(
    parameter   INPUT_WIDTH = 42,
    parameter   OUTPUT_WIDTH = 19
)
(
input       [INPUT_WIDTH - 1 : 0]   a,
output      [OUTPUT_WIDTH - 1 : 0]  b
);
assign      b = a[INPUT_WIDTH - 1 : INPUT_WIDTH - OUTPUT_WIDTH];
endmodule
