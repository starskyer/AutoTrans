//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2022/10/21 14:01:37
// Module Name: adder_64
// Description: 64 add operation
// default dimension: 64
// comb logic
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

module adder_64
#(
    parameter DIMENTION = 'd64, 
    parameter WIDTH_ADDEND = 'd8, 
    parameter WIDTH_SUM = WIDTH_ADDEND + 1   
)
(
//********************************* Input Signal *********************************
    input signed  [WIDTH_ADDEND * DIMENTION - 1   :   0]  addend1,
    input signed  [WIDTH_ADDEND * DIMENTION - 1   :   0]  addend2,

//********************************* Output Signal *********************************
    output signed [WIDTH_SUM * DIMENTION - 1      :   0]  sum
);

//********************************* Loop Integer **********************************
    genvar                                               i;



    wire  signed  [WIDTH_ADDEND - 1 : 0]                  addend1_mem    [DIMENTION - 1 : 0];
    wire  signed  [WIDTH_ADDEND - 1 : 0]                  addend2_mem    [DIMENTION - 1 : 0];
    wire  signed  [WIDTH_SUM - 1    : 0]                  sum_mem        [DIMENTION - 1 : 0];

    assign {addend1_mem[0], addend1_mem[1], addend1_mem[2], addend1_mem[3], addend1_mem[4], addend1_mem[5], addend1_mem[6], addend1_mem[7], 
            addend1_mem[8], addend1_mem[9], addend1_mem[10], addend1_mem[11], addend1_mem[12], addend1_mem[13], addend1_mem[14], addend1_mem[15], 
            addend1_mem[16], addend1_mem[17], addend1_mem[18], addend1_mem[19], addend1_mem[20], addend1_mem[21], addend1_mem[22], addend1_mem[23], 
            addend1_mem[24], addend1_mem[25], addend1_mem[26], addend1_mem[27], addend1_mem[28], addend1_mem[29], addend1_mem[30], addend1_mem[31], 
            addend1_mem[32], addend1_mem[33], addend1_mem[34], addend1_mem[35], addend1_mem[36], addend1_mem[37], addend1_mem[38], addend1_mem[39], 
            addend1_mem[40], addend1_mem[41], addend1_mem[42], addend1_mem[43], addend1_mem[44], addend1_mem[45], addend1_mem[46], addend1_mem[47], 
            addend1_mem[48], addend1_mem[49], addend1_mem[50], addend1_mem[51], addend1_mem[52], addend1_mem[53], addend1_mem[54], addend1_mem[55], 
            addend1_mem[56], addend1_mem[57], addend1_mem[58], addend1_mem[59], addend1_mem[60], addend1_mem[61], addend1_mem[62], addend1_mem[63]
           } = addend1; 
    assign {addend2_mem[0], addend2_mem[1], addend2_mem[2], addend2_mem[3], addend2_mem[4], addend2_mem[5], addend2_mem[6], addend2_mem[7], 
            addend2_mem[8], addend2_mem[9], addend2_mem[10], addend2_mem[11], addend2_mem[12], addend2_mem[13], addend2_mem[14], addend2_mem[15], 
            addend2_mem[16], addend2_mem[17], addend2_mem[18], addend2_mem[19], addend2_mem[20], addend2_mem[21], addend2_mem[22], addend2_mem[23], 
            addend2_mem[24], addend2_mem[25], addend2_mem[26], addend2_mem[27], addend2_mem[28], addend2_mem[29], addend2_mem[30], addend2_mem[31], 
            addend2_mem[32], addend2_mem[33], addend2_mem[34], addend2_mem[35], addend2_mem[36], addend2_mem[37], addend2_mem[38], addend2_mem[39], 
            addend2_mem[40], addend2_mem[41], addend2_mem[42], addend2_mem[43], addend2_mem[44], addend2_mem[45], addend2_mem[46], addend2_mem[47], 
            addend2_mem[48], addend2_mem[49], addend2_mem[50], addend2_mem[51], addend2_mem[52], addend2_mem[53], addend2_mem[54], addend2_mem[55], 
            addend2_mem[56], addend2_mem[57], addend2_mem[58], addend2_mem[59], addend2_mem[60], addend2_mem[61], addend2_mem[62], addend2_mem[63]
           } = addend2; 
    assign  sum = {sum_mem[0], sum_mem[1], sum_mem[2], sum_mem[3], sum_mem[4], sum_mem[5], sum_mem[6], sum_mem[7], 
            sum_mem[8], sum_mem[9], sum_mem[10], sum_mem[11], sum_mem[12], sum_mem[13], sum_mem[14], sum_mem[15], 
            sum_mem[16], sum_mem[17], sum_mem[18], sum_mem[19], sum_mem[20], sum_mem[21], sum_mem[22], sum_mem[23], 
            sum_mem[24], sum_mem[25], sum_mem[26], sum_mem[27], sum_mem[28], sum_mem[29], sum_mem[30], sum_mem[31], 
            sum_mem[32], sum_mem[33], sum_mem[34], sum_mem[35], sum_mem[36], sum_mem[37], sum_mem[38], sum_mem[39], 
            sum_mem[40], sum_mem[41], sum_mem[42], sum_mem[43], sum_mem[44], sum_mem[45], sum_mem[46], sum_mem[47], 
            sum_mem[48], sum_mem[49], sum_mem[50], sum_mem[51], sum_mem[52], sum_mem[53], sum_mem[54], sum_mem[55], 
            sum_mem[56], sum_mem[57], sum_mem[58], sum_mem[59], sum_mem[60], sum_mem[61], sum_mem[62], sum_mem[63]}; 

    generate
        for(i = 0; i < DIMENTION; i = i + 1) begin: inst_adder64
            adder #(.WIDTH_ADDEND(WIDTH_ADDEND), .WIDTH_SUM(WIDTH_SUM)) u_inst_adder64 
            (.addend1(addend1_mem[i]), .addend2(addend2_mem[i]), .sum(sum_mem[i]));
        end
    endgenerate
    
endmodule