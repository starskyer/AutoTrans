//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2022/09/28 10:40:17
// Module Name: multiplier
// Description: 
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2022/09/28 10:40:17
// Module Name: multiplier
// Description: 
// basic module of a multiplier, with adjustable width
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////
module multiplier
#(
    parameter WIDTH_MUL_INPUT1    =   'd8,
    parameter WIDTH_MUL_INPUT2    =   'd8,
    parameter WIDTH_MUL    =   WIDTH_MUL_INPUT1 + WIDTH_MUL_INPUT2
)
(
    input signed [WIDTH_MUL_INPUT1 - 1 : 0]  mul_input1,
    input signed [WIDTH_MUL_INPUT2 - 1 : 0]  mul_input2,

    output signed [WIDTH_MUL - 1 : 0]   mul
);


assign  mul = mul_input1 * mul_input2;
    // mul_8_8 u_mul_8_8 (
    // .A(mul_input1),  // input wire [7 : 0] A
    // .B(mul_input2),  // input wire [7 : 0] B
    // .P(mul)  // output wire [15 : 0] P
    // );

endmodule