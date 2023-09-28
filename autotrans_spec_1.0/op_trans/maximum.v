//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2022/10/13 16:57:35
// Module Name: maximum
// Description: 
// max module with adjustable dimension and width
// default dimension: 64, default width: 8
// comb logic
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////
module maximum
#(
    parameter NUM = 'd64,
    parameter WIDTH_MAX_INPUT = 'd8,
    parameter WIDTH_MAX_OUTPUT = 'd8
)
(
input signed    [NUM * WIDTH_MAX_INPUT  - 1   :   0]     inputend,
output signed   [WIDTH_MAX_OUTPUT - 1   :   0]    max
);

wire signed [WIDTH_MAX_INPUT - 1   :   0]  inputend_mem     [NUM - 1  :   0]; 
assign {inputend_mem[0], inputend_mem[1], inputend_mem[2], inputend_mem[3], 
        inputend_mem[4], inputend_mem[5], inputend_mem[6], inputend_mem[7], 
        inputend_mem[8], inputend_mem[9], inputend_mem[10], inputend_mem[11], 
        inputend_mem[12], inputend_mem[13], inputend_mem[14], inputend_mem[15], 
        inputend_mem[16], inputend_mem[17], inputend_mem[18], inputend_mem[19], 
        inputend_mem[20], inputend_mem[21], inputend_mem[22], inputend_mem[23], 
        inputend_mem[24], inputend_mem[25], inputend_mem[26], inputend_mem[27], 
        inputend_mem[28], inputend_mem[29], inputend_mem[30], inputend_mem[31], 
        inputend_mem[32], inputend_mem[33], inputend_mem[34], inputend_mem[35], 
        inputend_mem[36], inputend_mem[37], inputend_mem[38], inputend_mem[39], 
        inputend_mem[40], inputend_mem[41], inputend_mem[42], inputend_mem[43], 
        inputend_mem[44], inputend_mem[45], inputend_mem[46], inputend_mem[47], 
        inputend_mem[48], inputend_mem[49], inputend_mem[50], inputend_mem[51], 
        inputend_mem[52], inputend_mem[53], inputend_mem[54], inputend_mem[55], 
        inputend_mem[56], inputend_mem[57], inputend_mem[58], inputend_mem[59], 
        inputend_mem[60], inputend_mem[61], inputend_mem[62], inputend_mem[63]
        } = inputend;


wire signed [WIDTH_MAX_INPUT - 1   :   0]  max_middle       [NUM - 2  :   0];  // middle comp results

assign max_middle[0] = (inputend_mem[0] > inputend_mem[1]) ? inputend_mem[0] : inputend_mem[1];
assign max_middle[1] = (max_middle[0] > inputend_mem[2]) ? max_middle[0] : inputend_mem[2];
assign max_middle[2] = (max_middle[1] > inputend_mem[3]) ? max_middle[1] : inputend_mem[3];
assign max_middle[3] = (max_middle[2] > inputend_mem[4]) ? max_middle[2] : inputend_mem[4];
assign max_middle[4] = (max_middle[3] > inputend_mem[5]) ? max_middle[3] : inputend_mem[5];
assign max_middle[5] = (max_middle[4] > inputend_mem[6]) ? max_middle[4] : inputend_mem[6];
assign max_middle[6] = (max_middle[5] > inputend_mem[7]) ? max_middle[5] : inputend_mem[7];
assign max_middle[7] = (max_middle[6] > inputend_mem[8]) ? max_middle[6] : inputend_mem[8];
assign max_middle[8] = (max_middle[7] > inputend_mem[9]) ? max_middle[7] : inputend_mem[9];
assign max_middle[9] = (max_middle[8] > inputend_mem[10]) ? max_middle[8] : inputend_mem[10];
assign max_middle[10] = (max_middle[9] > inputend_mem[11]) ? max_middle[9] : inputend_mem[11];
assign max_middle[11] = (max_middle[10] > inputend_mem[12]) ? max_middle[10] : inputend_mem[12];
assign max_middle[12] = (max_middle[11] > inputend_mem[13]) ? max_middle[11] : inputend_mem[13];
assign max_middle[13] = (max_middle[12] > inputend_mem[14]) ? max_middle[12] : inputend_mem[14];
assign max_middle[14] = (max_middle[13] > inputend_mem[15]) ? max_middle[13] : inputend_mem[15];
assign max_middle[15] = (max_middle[14] > inputend_mem[16]) ? max_middle[14] : inputend_mem[16];
assign max_middle[16] = (max_middle[15] > inputend_mem[17]) ? max_middle[15] : inputend_mem[17];
assign max_middle[17] = (max_middle[16] > inputend_mem[18]) ? max_middle[16] : inputend_mem[18];
assign max_middle[18] = (max_middle[17] > inputend_mem[19]) ? max_middle[17] : inputend_mem[19];
assign max_middle[19] = (max_middle[18] > inputend_mem[20]) ? max_middle[18] : inputend_mem[20];
assign max_middle[20] = (max_middle[19] > inputend_mem[21]) ? max_middle[19] : inputend_mem[21];
assign max_middle[21] = (max_middle[20] > inputend_mem[22]) ? max_middle[20] : inputend_mem[22];
assign max_middle[22] = (max_middle[21] > inputend_mem[23]) ? max_middle[21] : inputend_mem[23];
assign max_middle[23] = (max_middle[22] > inputend_mem[24]) ? max_middle[22] : inputend_mem[24];
assign max_middle[24] = (max_middle[23] > inputend_mem[25]) ? max_middle[23] : inputend_mem[25];
assign max_middle[25] = (max_middle[24] > inputend_mem[26]) ? max_middle[24] : inputend_mem[26];
assign max_middle[26] = (max_middle[25] > inputend_mem[27]) ? max_middle[25] : inputend_mem[27];
assign max_middle[27] = (max_middle[26] > inputend_mem[28]) ? max_middle[26] : inputend_mem[28];
assign max_middle[28] = (max_middle[27] > inputend_mem[29]) ? max_middle[27] : inputend_mem[29];
assign max_middle[29] = (max_middle[28] > inputend_mem[30]) ? max_middle[28] : inputend_mem[30];
assign max_middle[30] = (max_middle[29] > inputend_mem[31]) ? max_middle[29] : inputend_mem[31];
assign max_middle[31] = (max_middle[30] > inputend_mem[32]) ? max_middle[30] : inputend_mem[32];
assign max_middle[32] = (max_middle[31] > inputend_mem[33]) ? max_middle[31] : inputend_mem[33];
assign max_middle[33] = (max_middle[32] > inputend_mem[34]) ? max_middle[32] : inputend_mem[34];
assign max_middle[34] = (max_middle[33] > inputend_mem[35]) ? max_middle[33] : inputend_mem[35];
assign max_middle[35] = (max_middle[34] > inputend_mem[36]) ? max_middle[34] : inputend_mem[36];
assign max_middle[36] = (max_middle[35] > inputend_mem[37]) ? max_middle[35] : inputend_mem[37];
assign max_middle[37] = (max_middle[36] > inputend_mem[38]) ? max_middle[36] : inputend_mem[38];
assign max_middle[38] = (max_middle[37] > inputend_mem[39]) ? max_middle[37] : inputend_mem[39];
assign max_middle[39] = (max_middle[38] > inputend_mem[40]) ? max_middle[38] : inputend_mem[40];
assign max_middle[40] = (max_middle[39] > inputend_mem[41]) ? max_middle[39] : inputend_mem[41];
assign max_middle[41] = (max_middle[40] > inputend_mem[42]) ? max_middle[40] : inputend_mem[42];
assign max_middle[42] = (max_middle[41] > inputend_mem[43]) ? max_middle[41] : inputend_mem[43];
assign max_middle[43] = (max_middle[42] > inputend_mem[44]) ? max_middle[42] : inputend_mem[44];
assign max_middle[44] = (max_middle[43] > inputend_mem[45]) ? max_middle[43] : inputend_mem[45];
assign max_middle[45] = (max_middle[44] > inputend_mem[46]) ? max_middle[44] : inputend_mem[46];
assign max_middle[46] = (max_middle[45] > inputend_mem[47]) ? max_middle[45] : inputend_mem[47];
assign max_middle[47] = (max_middle[46] > inputend_mem[48]) ? max_middle[46] : inputend_mem[48];
assign max_middle[48] = (max_middle[47] > inputend_mem[49]) ? max_middle[47] : inputend_mem[49];
assign max_middle[49] = (max_middle[48] > inputend_mem[50]) ? max_middle[48] : inputend_mem[50];
assign max_middle[50] = (max_middle[49] > inputend_mem[51]) ? max_middle[49] : inputend_mem[51];
assign max_middle[51] = (max_middle[50] > inputend_mem[52]) ? max_middle[50] : inputend_mem[52];
assign max_middle[52] = (max_middle[51] > inputend_mem[53]) ? max_middle[51] : inputend_mem[53];
assign max_middle[53] = (max_middle[52] > inputend_mem[54]) ? max_middle[52] : inputend_mem[54];
assign max_middle[54] = (max_middle[53] > inputend_mem[55]) ? max_middle[53] : inputend_mem[55];
assign max_middle[55] = (max_middle[54] > inputend_mem[56]) ? max_middle[54] : inputend_mem[56];
assign max_middle[56] = (max_middle[55] > inputend_mem[57]) ? max_middle[55] : inputend_mem[57];
assign max_middle[57] = (max_middle[56] > inputend_mem[58]) ? max_middle[56] : inputend_mem[58];
assign max_middle[58] = (max_middle[57] > inputend_mem[59]) ? max_middle[57] : inputend_mem[59];
assign max_middle[59] = (max_middle[58] > inputend_mem[60]) ? max_middle[58] : inputend_mem[60];
assign max_middle[60] = (max_middle[59] > inputend_mem[61]) ? max_middle[59] : inputend_mem[61];
assign max_middle[61] = (max_middle[60] > inputend_mem[62]) ? max_middle[60] : inputend_mem[62];
assign max_middle[62] = (max_middle[61] > inputend_mem[63]) ? max_middle[61] : inputend_mem[63];

assign max = max_middle[62];

endmodule



