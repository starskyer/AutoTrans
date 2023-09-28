module pe
#(
    parameter INPUT_WIDTH   =   'd8,
    parameter OUTPUT_WIDTH  =   INPUT_WIDTH + 'd14
   
)
 (input                                                      clk,
 input                                                      done,
 input                      [INPUT_WIDTH - 1 : 0]           input_A,
 input                      [INPUT_WIDTH - 1 : 0]           input_B,
 input                      [INPUT_WIDTH - 1 : 0]           input_D,
 input                                                      reset,
 output      reg            [OUTPUT_WIDTH - 1 : 0]          resulta,
 output      reg            [OUTPUT_WIDTH - 1 : 0]          resultb,

 
 output      reg            [16 : 0]                        P_change_sign_1,
 output      reg            [16 : 0]                        P_change_sign_2,
 output      wire           [47 : 0]                        P,
 output      wire           [47 : 0]                        C_in,
 output      wire           [6 : 0]                        result_h_1,
 output      wire           [6 : 0]                        result_h_2);
 /*
 output      wire           [7 : 0]                         dout,
 output      wire                                           full,
 output      wire                                           empty,
 output      wire                                           rd_rst_busy,
 output      wire                                           wr_rst_busy,
 output      wire           [7 : 0]                         dout2,
 output      wire                                           full2,
 output      wire                                           empty2,
 output      wire                                           rd_rst_busy2,
 output      wire                                           wr_rst_busy2);
*/


 
reg                     [2 : 0]                         input_sign_1;
reg                     [2 : 0]                         input_sign_2;
reg                     [2 : 0]                         input_sign_3;
reg                     [26 : 0]                        abs_A;
reg                     [17 : 0]                        abs_B;
reg                     [7 : 0]                         abs_D;
reg                     [26 : 0]                        shift_D;
reg                     [6 : 0]                        P_high_change_sign_1;
reg                     [6 : 0]                        P_high_change_sign_2;
//wire                    [6 : 0]                        result_h_1;
//wire                    [6 : 0]                        result_h_2;
wire                    [6 : 0]                        P_change_sign_extend_1;
wire                    [6 : 0]                        P_change_sign_extend_2;





 
 reg                        [16 : 0]                        P_left_1;
 reg                        [16 : 0]                        P_left_2;
 reg                        [11 : 0]                        P_cut_1;
 reg                        [11 : 0]                        P_cut_2;

 reg                        [11 : 0]                        P_high_1;
 reg                        [11 : 0]                        P_high_2;


 

 always @(*) begin
    if(input_A[INPUT_WIDTH - 1] == 1'b1)
    begin
        abs_A[7 : 0] = ~input_A + 1;
        abs_A[26 : 8] = 19'b0;
    end
    else
    begin
        abs_A = input_A;
    end

    if(input_B[INPUT_WIDTH - 1] == 1'b1)
    begin
        abs_B[7 : 0] = ~input_B + 1;
        abs_B[17 : 8] = 10'b0;
    end
    else
    begin
        abs_B = input_B;
    end

    if(input_D[INPUT_WIDTH - 1] == 1'b1)
    begin
        abs_D = ~input_D + 1;
    end
    else
    begin
        abs_D = input_D;
    end
 end        


 always @(*) begin
    shift_D = {abs_D ,18'b0};
     end

 xbip_dsp48_macro_0 dsp48_1 (
    .CLK(clk),  // input wire CLK
    .A(abs_A),      // input wire [26 : 0] A
    .B(abs_B),      // input wire [17 : 0] B
    .C(C_in),      // input wire [47 : 0] C
    .D(shift_D),      // input wire [26 : 0] D
    .P(P)      // output wire [47 : 0] P
  );



 always @(posedge clk ) begin
    if(reset == 1'b1)
    begin
      input_sign_1 <= 0;
      input_sign_2 <= 0;
      input_sign_3 <= 0;
    end
    else
    begin
    input_sign_3 <= input_sign_2;
    input_sign_2 <= input_sign_1;
    input_sign_1 <= {input_A [INPUT_WIDTH - 1], input_B[INPUT_WIDTH-1], input_D[INPUT_WIDTH-1]};   
    end
 end

 always @(posedge clk or posedge reset) begin
    
    if(reset == 1'b1)
    begin
      P_change_sign_1 <= 0;
      P_change_sign_2 <= 0;
    end
    else
    begin
    if (input_sign_3[2]^input_sign_3[1]^input_sign_2[2]^input_sign_2[1] == 0) begin
      P_change_sign_1 <= P[16 : 0];
    end else begin
      P_change_sign_1 <= ~P[16 : 0] + 1'b1;
    end

    if (input_sign_3[0]^input_sign_3[1]^input_sign_2[0]^input_sign_2[1] == 0) begin
      P_change_sign_2 <= P[34 : 18];
    end else begin
      P_change_sign_2 <= ~P[34 : 18] + 1'b1;
    end
 end
 end
  
 always @(*) begin
    if (P_change_sign_1[16] == P_change_sign_1[15]) begin
      P_cut_1 = 0;
    end else begin
      P_cut_1 = {{6{P_change_sign_1[16]}}, 1'b1};
    end
    if (P_change_sign_2[16] == P_change_sign_2[15]) begin
      P_cut_2 = 0;
    end else begin
      P_cut_2 = {{6{P_change_sign_2[16]}}, 1'b1};
    end
    P_left_1 = {P_change_sign_1[16], P_change_sign_1[16], P_change_sign_1[14:0]};
    P_left_2 = {P_change_sign_2[16], P_change_sign_2[16], P_change_sign_2[14:0]};
    
 end
 
 assign C_in[16 : 0] = P_left_1;
 assign C_in[17] = 0;
 assign C_in[34 : 18] = P_left_2;
 assign C_in[47 : 35] = 0;

 always @(* ) begin
    P_high_1 = P_high_change_sign_1 + P_cut_1;
    P_high_2 = P_high_change_sign_2 + P_cut_2;
 end

 always @(posedge clk or posedge reset) begin
    if(reset == 1'b1)
    begin
      P_high_change_sign_1 = 0;
      P_high_change_sign_2 = 0;
    end
    else
    begin
    if (input_sign_3[0]^input_sign_3[1]^input_sign_2[0]^input_sign_2[1] == 0) begin
      P_high_change_sign_2 <= P_high_2;
    end else begin
      P_high_change_sign_2 <= ~P_high_2 + 1'b1;
    end
    if (input_sign_3[2]^input_sign_3[1]^input_sign_2[2]^input_sign_2[1] == 0) begin
      P_high_change_sign_1 <= P_high_1;
    end else begin
      P_high_change_sign_1 <= ~P_high_1 + 1'b1;
    end
    end
 end


assign P_change_sign_extend_1 = {7{P_change_sign_1[16]}};
assign P_change_sign_extend_2 = {7{P_change_sign_2[16]}};
assign result_h_1 = P_high_change_sign_1 + P_change_sign_extend_1;
assign result_h_2 = P_high_change_sign_2 + P_change_sign_extend_2;
 //always @(*) begin
     
     //result_high_1 = {12{P_change_sign_1[16]}};
     //result_high_2 = {12{P_change_sign_2[16]}};
    // end
 always @(posedge clk ) begin
  
      resulta <= {result_h_1 , P_change_sign_1[14 : 0]};
      resultb <= {result_h_2 , P_change_sign_2[14 : 0]};
  
 end
 
/*
 fifo_generator_0 v0 (
  .clk(clk),                  // input wire clk
  .srst(reset),                // input wire srst
  .din(result01),                  // input wire [7 : 0] din
  .wr_en(reset),              // input wire wr_en
  .rd_en(reset),              // input wire rd_en
  .dout(dout),                // output wire [7 : 0] dout
  .full(full),                // output wire full
  .empty(empty),              // output wire empty
  .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy)  // output wire rd_rst_busy
);
 
 fifo_generator_0 v1 (
  .clk(clk),                  // input wire clk
  .srst(reset),                // input wire srst
  .din(result02),                  // input wire [7 : 0] din
  .wr_en(reset),              // input wire wr_en
  .rd_en(reset),              // input wire rd_en
  .dout(dout2),                // output wire [7 : 0] dout
  .full(full2),                // output wire full
  .empty(empty2),              // output wire empty
  .wr_rst_busy(wr_rst_busy2),  // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy2)  // output wire rd_rst_busy
);*/
 endmodule
 

