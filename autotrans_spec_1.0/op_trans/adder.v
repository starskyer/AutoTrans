`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/29 19:41:17
// Design Name: 
// Module Name: adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 8 bit adder
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adder
#(
parameter WIDTH_ADDEND    =   'd8, 
parameter WIDTH_SUM       =   WIDTH_ADDEND + 1
)
(
input signed  [WIDTH_ADDEND - 1   :   0]  addend1,
input signed  [WIDTH_ADDEND - 1   :   0]  addend2,
output signed [WIDTH_SUM - 1      :   0]  sum
);
assign  sum = addend1 + addend2;
endmodule
