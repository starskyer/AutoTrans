`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/10 19:50:58
// Design Name: 
// Module Name: adder_768
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Use add_tree_64 to build
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adder_768_zh
#(
    parameter   NUM_ADDERTREE       = 'd12,
    parameter   ADDEND_WIDTH        = 'd8,
    parameter   TREE_DIMENTION      = 'd64,
    parameter   SUM_WIDTH           = 'd18,
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

assign  {addend_tree[11], addend_tree[10], addend_tree[9], addend_tree[8],
         addend_tree[7],  addend_tree[6],  addend_tree[5], addend_tree[4],
         addend_tree[3],  addend_tree[2],  addend_tree[1], addend_tree[0]
} = addend;

add_tree_64#(
    .DIMENTION      ( TREE_DIMENTION ),
    .WIDTH_ADDEND   ( ADDEND_WIDTH ),
    .NUM_LEVEL      ( ADD_TREE_LEVEL )
)u_add_tree_64_11(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( addend_tree[11]         ),
    .addend_valid_n ( addend_valid_n ),
    .sum            ( sum_tree[11]            ),
    .sum_valid_n    ( sum_tree_valid_n[11]    )
);

add_tree_64#(
    .DIMENTION      ( TREE_DIMENTION ),
    .WIDTH_ADDEND   ( ADDEND_WIDTH ),
    .NUM_LEVEL      ( ADD_TREE_LEVEL )
)u_add_tree_64_10(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( addend_tree[10]         ),
    .addend_valid_n ( addend_valid_n ),
    .sum            ( sum_tree[10]            ),
    .sum_valid_n    ( sum_tree_valid_n[10]    )
);

add_tree_64#(
    .DIMENTION      ( TREE_DIMENTION ),
    .WIDTH_ADDEND   ( ADDEND_WIDTH ),
    .NUM_LEVEL      ( ADD_TREE_LEVEL )
)u_add_tree_64_9(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( addend_tree[9]         ),
    .addend_valid_n ( addend_valid_n ),
    .sum            ( sum_tree[9]            ),
    .sum_valid_n    ( sum_tree_valid_n[9]    )
);

add_tree_64#(
    .DIMENTION      ( TREE_DIMENTION ),
    .WIDTH_ADDEND   ( ADDEND_WIDTH ),
    .NUM_LEVEL      ( ADD_TREE_LEVEL )
)u_add_tree_64_8(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( addend_tree[8]         ),
    .addend_valid_n ( addend_valid_n ),
    .sum            ( sum_tree[8]            ),
    .sum_valid_n    ( sum_tree_valid_n[8]    )
);

add_tree_64#(
    .DIMENTION      ( TREE_DIMENTION ),
    .WIDTH_ADDEND   ( ADDEND_WIDTH ),
    .NUM_LEVEL      ( ADD_TREE_LEVEL )
)u_add_tree_64_7(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( addend_tree[7]         ),
    .addend_valid_n ( addend_valid_n ),
    .sum            ( sum_tree[7]            ),
    .sum_valid_n    ( sum_tree_valid_n[7]    )
);

add_tree_64#(
    .DIMENTION      ( TREE_DIMENTION ),
    .WIDTH_ADDEND   ( ADDEND_WIDTH ),
    .NUM_LEVEL      ( ADD_TREE_LEVEL )
)u_add_tree_64_6(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( addend_tree[6]         ),
    .addend_valid_n ( addend_valid_n ),
    .sum            ( sum_tree[6]            ),
    .sum_valid_n    ( sum_tree_valid_n[6]    )
);

add_tree_64#(
    .DIMENTION      ( TREE_DIMENTION ),
    .WIDTH_ADDEND   ( ADDEND_WIDTH ),
    .NUM_LEVEL      ( ADD_TREE_LEVEL )
)u_add_tree_64_5(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( addend_tree[5]         ),
    .addend_valid_n ( addend_valid_n ),
    .sum            ( sum_tree[5]            ),
    .sum_valid_n    ( sum_tree_valid_n[5]    )
);

add_tree_64#(
    .DIMENTION      ( TREE_DIMENTION ),
    .WIDTH_ADDEND   ( ADDEND_WIDTH ),
    .NUM_LEVEL      ( ADD_TREE_LEVEL )
)u_add_tree_64_4(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( addend_tree[4]         ),
    .addend_valid_n ( addend_valid_n ),
    .sum            ( sum_tree[4]            ),
    .sum_valid_n    ( sum_tree_valid_n[4]    )
);

add_tree_64#(
    .DIMENTION      ( TREE_DIMENTION ),
    .WIDTH_ADDEND   ( ADDEND_WIDTH ),
    .NUM_LEVEL      ( ADD_TREE_LEVEL )
)u_add_tree_64_3(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( addend_tree[3]         ),
    .addend_valid_n ( addend_valid_n ),
    .sum            ( sum_tree[3]            ),
    .sum_valid_n    ( sum_tree_valid_n[3]    )
);

add_tree_64#(
    .DIMENTION      ( TREE_DIMENTION ),
    .WIDTH_ADDEND   ( ADDEND_WIDTH ),
    .NUM_LEVEL      ( ADD_TREE_LEVEL )
)u_add_tree_64_2(
    .clk_p          ( clk_p          ),
    .rst_n          ( rst_n          ),
    .addend         ( addend_tree[2]         ),
    .addend_valid_n ( addend_valid_n ),
    .sum            ( sum_tree[2]            ),
    .sum_valid_n    ( sum_tree_valid_n[2]    )
);

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
wire    signed          [(ADDEND_WIDTH + 7) - 1 :   0]      l7_sum      [7   :   0];
reg     signed          [(ADDEND_WIDTH + 7) - 1 :   0]      l7_sum_r    [7   :   0];
reg                                                         l7_valid_n;

adder#(
    .WIDTH_ADDEND ( ADDEND_WIDTH + 6 )
)u_adder_l7_1(
    .addend1      ( sum_tree[11]      ),
    .addend2      ( sum_tree[10]      ),
    .sum          ( l7_sum[7]          )
);

adder#(
    .WIDTH_ADDEND ( ADDEND_WIDTH + 6 )
)u_adder_l7_2(
    .addend1      ( sum_tree[9]      ),
    .addend2      ( sum_tree[8]      ),
    .sum          ( l7_sum[6]          )
);

adder#(
    .WIDTH_ADDEND ( ADDEND_WIDTH + 6 )
)u_adder_l7_3(
    .addend1      ( sum_tree[7]      ),
    .addend2      ( sum_tree[6]      ),
    .sum          ( l7_sum[5]          )
);

adder#(
    .WIDTH_ADDEND ( ADDEND_WIDTH + 6 )
)u_adder_l7_4(
    .addend1      ( sum_tree[5]      ),
    .addend2      ( sum_tree[4]      ),
    .sum          ( l7_sum[4]          )
);

assign  l7_sum[3] = {sum_tree[3][ADDEND_WIDTH + ADD_TREE_LEVEL - 1] ,sum_tree[3]};
assign  l7_sum[2] = {sum_tree[2][ADDEND_WIDTH + ADD_TREE_LEVEL - 1] ,sum_tree[2]};
assign  l7_sum[1] = {sum_tree[1][ADDEND_WIDTH + ADD_TREE_LEVEL - 1] ,sum_tree[1]};
assign  l7_sum[0] = {sum_tree[0][ADDEND_WIDTH + ADD_TREE_LEVEL - 1] ,sum_tree[0]};

always @(posedge clk_p or negedge rst_n) begin
    if(~rst_n)  begin
        l7_sum_r[0] <= 0;
        l7_sum_r[1] <= 0;
        l7_sum_r[2] <= 0;
        l7_sum_r[3] <= 0;
        l7_sum_r[4] <= 0;
        l7_sum_r[5] <= 0;
        l7_sum_r[6] <= 0;
        l7_sum_r[7] <= 0;
    end
    else    begin
        l7_sum_r[0] <= l6_valid_n ? l7_sum_r[0] : l7_sum[0];
        l7_sum_r[1] <= l6_valid_n ? l7_sum_r[1] : l7_sum[1];
        l7_sum_r[2] <= l6_valid_n ? l7_sum_r[2] : l7_sum[2];
        l7_sum_r[3] <= l6_valid_n ? l7_sum_r[3] : l7_sum[3];
        l7_sum_r[4] <= l6_valid_n ? l7_sum_r[4] : l7_sum[4];
        l7_sum_r[5] <= l6_valid_n ? l7_sum_r[5] : l7_sum[5];
        l7_sum_r[6] <= l6_valid_n ? l7_sum_r[6] : l7_sum[6];
        l7_sum_r[7] <= l6_valid_n ? l7_sum_r[7] : l7_sum[7];
    end
end

always @(posedge clk_p or negedge rst_n) begin
    if(~rst_n)  begin
        l7_valid_n <= 1; 
    end
    else    begin
        l7_valid_n <= l6_valid_n ? 1 : 0;
    end
end

//*************************************** level 8 ***************************************//
wire    signed          [(ADDEND_WIDTH + 8) - 1 :   0]      l8_sum      [3   :   0];
reg     signed          [(ADDEND_WIDTH + 8) - 1 :   0]      l8_sum_r    [3   :   0];
reg                                                         l8_valid_n;

adder#(
    .WIDTH_ADDEND ( ADDEND_WIDTH + 7 )
)u_adder_l8_1(
    .addend1      ( l7_sum_r[7]      ),
    .addend2      ( l7_sum_r[6]      ),
    .sum          ( l8_sum[3]          )
);

adder#(
    .WIDTH_ADDEND ( ADDEND_WIDTH + 7 )
)u_adder_l8_2(
    .addend1      ( l7_sum_r[5]      ),
    .addend2      ( l7_sum_r[4]      ),
    .sum          ( l8_sum[2]          )
);

adder#(
    .WIDTH_ADDEND ( ADDEND_WIDTH + 7 )
)u_adder_l8_3(
    .addend1      ( l7_sum_r[3]      ),
    .addend2      ( l7_sum_r[2]      ),
    .sum          ( l8_sum[1]          )
);

adder#(
    .WIDTH_ADDEND ( ADDEND_WIDTH + 7 )
)u_adder_l8_4(
    .addend1      ( l7_sum_r[1]      ),
    .addend2      ( l7_sum_r[0]      ),
    .sum          ( l8_sum[0]          )
);

always @(posedge clk_p or negedge rst_n) begin
    if(~rst_n)  begin
        l8_sum_r[0] <= 0;
        l8_sum_r[1] <= 0;
        l8_sum_r[2] <= 0;
        l8_sum_r[3] <= 0;
    end
    else    begin
        l8_sum_r[0] <= l7_valid_n ? l8_sum_r[0] : l8_sum[0];
        l8_sum_r[1] <= l7_valid_n ? l8_sum_r[1] : l8_sum[1];
        l8_sum_r[2] <= l7_valid_n ? l8_sum_r[2] : l8_sum[2];
        l8_sum_r[3] <= l7_valid_n ? l8_sum_r[3] : l8_sum[3];
    end
end

always @(posedge clk_p or negedge rst_n) begin
    if(~rst_n)  begin
        l8_valid_n <= 1; 
    end
    else    begin
        l8_valid_n <= l7_valid_n ? 1 : 0;
    end
end

//*************************************** level 9 ***************************************//
wire    signed          [(ADDEND_WIDTH + 9) - 1 :   0]      l9_sum      [1   :   0];
reg     signed          [(ADDEND_WIDTH + 9) - 1 :   0]      l9_sum_r    [1   :   0];
reg                                                         l9_valid_n;

adder#(
    .WIDTH_ADDEND ( ADDEND_WIDTH + 8 )
)u_adder_l9_1(
    .addend1      ( l8_sum_r[3]      ),
    .addend2      ( l8_sum_r[2]      ),
    .sum          ( l9_sum[1]          )
);

adder#(
    .WIDTH_ADDEND ( ADDEND_WIDTH + 8 )
)u_adder_l9_2(
    .addend1      ( l8_sum_r[1]      ),
    .addend2      ( l8_sum_r[0]      ),
    .sum          ( l9_sum[0]          )
);

always @(posedge clk_p or negedge rst_n) begin
    if(~rst_n)  begin
        l9_sum_r[0] <= 0;
        l9_sum_r[1] <= 0;
    end
    else    begin
        l9_sum_r[0] <= l8_valid_n ? l9_sum_r[0] : l9_sum[0];
        l9_sum_r[1] <= l8_valid_n ? l9_sum_r[1] : l9_sum[1];
    end
end

always @(posedge clk_p or negedge rst_n) begin
    if(~rst_n)  begin
        l9_valid_n <= 1; 
    end
    else    begin
        l9_valid_n <= l8_valid_n ? 1 : 0;
    end
end

//*************************************** level 10 ***************************************//
wire                  signed          [SUM_WIDTH - 1  :   0]                      sum_w;

adder#(
    .WIDTH_ADDEND ( ADDEND_WIDTH + 9 )
)u_adder_sum(
    .addend1      ( l9_sum_r[1]      ),
    .addend2      ( l9_sum_r[0]      ),
    .sum          ( sum_w          )
);

always @(posedge clk_p or negedge rst_n) begin
    if(~rst_n)  begin
        sum <= 0;
    end
    else    begin
        sum <= l9_valid_n ? sum : sum_w;
    end
end

always @(posedge clk_p or negedge rst_n) begin
    if(~rst_n)  begin
        sum_valid_n <= 1; 
    end
    else    begin
        sum_valid_n <= l9_valid_n ? 1 : 0;
    end
end

endmodule
