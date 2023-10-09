module adder_768
#(
    parameter DIMENTION = 'd768, 
    parameter WIDTH_ADDEND = 'd8, 
    parameter WIDTH_SUM = WIDTH_ADDEND   
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

    generate
        for(i = 0; i < DIMENTION; i = i + 1) begin: inst_adder768
            assign addend1_mem[i] = addend1[(i + 1) * WIDTH_ADDEND - 1 : i * WIDTH_ADDEND];
            assign addend2_mem[i] = addend2[(i + 1) * WIDTH_ADDEND - 1 : i * WIDTH_ADDEND];
            assign sum[(i + 1) * WIDTH_ADDEND - 1 : i * WIDTH_ADDEND] = sum_mem[i];
            adder #(.WIDTH_ADDEND(WIDTH_ADDEND), .WIDTH_SUM(WIDTH_SUM)) u_inst_adder768 
            (.addend1(addend1_mem[i]), .addend2(addend2_mem[i]), .sum(sum_mem[i]));
        end
    endgenerate
    
endmodule