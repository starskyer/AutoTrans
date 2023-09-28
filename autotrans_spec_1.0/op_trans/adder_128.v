`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/10 19:50:58
// Design Name: 
// Module Name: adder_128
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      adder tree for 128 input, formed by several 64 adder tree. For default dimension of 128, it is formed by 2 64 adder trees
// timing logic:
//      pipeline 1: two 64 adder trees 
//          clk 1: 64 --> 32 (2 in parallel)
//          clk 2: 32 --> 16 (2 in parallel)
//          clk 3: 16 --> 8 (2 in parallel)
//          clk 4: 8 --> 4 (2 in parallel)
//          clk 5: 4 --> 2 (2 in parallel)
//          clk 6: 2 --> 1 (2 in parallel)
//      pipeline 2:
//          clk 7: add for 2 adder tree output z
// Dependencies: 
//      2 add_tree_64,  1 adder
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adder_128
#(
    parameter   NUM_ADDERTREE       = 'd2,
    parameter   ADDEND_WIDTH        = 'd8,
    parameter   TREE_DIMENTION      = 'd64,
    parameter   SUM_WIDTH           = 'd15,
    parameter   ADD_TREE_LEVEL      = 'd6
)
(
//*************************************** System signal ***************************************//
    input                                                                                               clk_p,
    input                                                                                               rst_n,
//*************************************** Input signal ***************************************//
    input                      signed          [ADDEND_WIDTH * TREE_DIMENTION * NUM_ADDERTREE - 1 : 0]  addend,
    input                                                                                               addend_valid_n,
//*************************************** Output signal ***************************************//
    output         reg         signed          [SUM_WIDTH - 1  :   0]                                   sum,
    output         reg                                                                                  sum_valid_n    
);
//*************************************** level 1 - 6 adder tree ***************************************//
wire        signed      [ADDEND_WIDTH + ADD_TREE_LEVEL - 1   :   0]      sum_tree           [NUM_ADDERTREE - 1 : 0];
wire                    [NUM_ADDERTREE - 1 : 0]                          sum_tree_valid_n;
wire                                                                     l6_valid_n;
wire        signed      [ADDEND_WIDTH * TREE_DIMENTION - 1  :   0]       addend_tree        [NUM_ADDERTREE - 1   : 0];

// 只有所有的有效信号同时有效，当前级才有效
assign  l6_valid_n = |sum_tree_valid_n;

assign  {addend_tree[1], addend_tree[0]
} = addend;

add_tree_64#(
    .DIMENTION      ( TREE_DIMENTION ),
    .WIDTH_ADDEND   ( ADDEND_WIDTH ),
    .NUM_LEVEL      ( ADD_TREE_LEVEL )
)u_add_tree_64_1(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( addend_tree[1]         ),
    .addend_valid_n ( addend_valid_n ),
    .sum            ( sum_tree[1]            ),
    .sum_valid_n    ( sum_tree_valid_n[1]    )
);

add_tree_64#(
    .DIMENTION      ( TREE_DIMENTION ),
    .WIDTH_ADDEND   ( ADDEND_WIDTH ),
    .NUM_LEVEL      ( ADD_TREE_LEVEL )
)u_add_tree_64_0(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( addend_tree[0]         ),
    .addend_valid_n ( addend_valid_n ),
    .sum            ( sum_tree[0]            ),
    .sum_valid_n    ( sum_tree_valid_n[0]    )
);


//*************************************** level 7 ***************************************//
wire                  signed          [SUM_WIDTH - 1  :   0]                      sum_w;

adder#(
    .WIDTH_ADDEND ( ADDEND_WIDTH + 6 ),
    .WIDTH_SUM (SUM_WIDTH)
)u_adder_l7_1(
    .addend1      ( sum_tree[1]      ),
    .addend2      ( sum_tree[0]      ),
    .sum          ( sum_w         )
);

always @(posedge clk_p or negedge rst_n) begin
    if(~rst_n)  begin
        sum <= 0;
    end
    else    begin
        sum <= l6_valid_n ? sum : sum_w;
    end
end

always @(posedge clk_p or negedge rst_n) begin
    if(~rst_n)  begin
        sum_valid_n <= 1; 
    end
    else    begin
        sum_valid_n <= l6_valid_n ? 1 : 0;
    end
end

endmodule
