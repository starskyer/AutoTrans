`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/20 10:52:27
// Design Name: 
// Module Name: clip
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: f(x) = clip(x, min=-2**n, max=2**n-1)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// f(x) = clip(x, min=-2**n, max=2**n-1)
// n = OUTPUT_WIDTH
module clip
#(
    parameter   INPUT_WIDTH = 21,
    parameter   OUTPUT_WIDTH = 8
)
(
input   [INPUT_WIDTH - 1 : 0]   x,
output  [OUTPUT_WIDTH - 1 : 0]  y
    );
assign  y = x[INPUT_WIDTH - 1] ? 
            ((&(x[INPUT_WIDTH - 1 : OUTPUT_WIDTH - 1])) ? (x[OUTPUT_WIDTH - 1 : 0]) : ({1'b1,{(OUTPUT_WIDTH-1){1'b0}}})) : 
            ((|(x[INPUT_WIDTH - 1 : OUTPUT_WIDTH - 1])) ? ({1'b0,{(OUTPUT_WIDTH-1){1'b1}}}) : (x[OUTPUT_WIDTH - 1 : 0])) ;
endmodule
