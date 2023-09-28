`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/10 14:10:38
// Design Name: 
// Module Name: short2long
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


module short2long
#(
	parameter	INPUT_WIDTH = 10,
	parameter	OUTPUT_WIDTH = 14
)
(
	input 					signed 				[INPUT_WIDTH-1	:	0]		datain,
	output      wire		signed      	 	[OUTPUT_WIDTH-1	:	0]		dataout
);
assign  dataout = {{(OUTPUT_WIDTH-INPUT_WIDTH){datain[INPUT_WIDTH-1]}}, datain[INPUT_WIDTH-1:0]};
endmodule
