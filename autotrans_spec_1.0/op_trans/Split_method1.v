module Split_method1 #(
    parameter DATA_WIDTH = 'd8, //input_shape[0][0]
    parameter INPUT_SHAPE_1 = 'd128, //input_shape[0][1]
    parameter INPUT_SHAPE_2 = 'd768, //input_shape[0][2]
    parameter OUTPUT_SHAPE_1 = 'd128, //output_shape[0][1]
    parameter OUTPUT_SHAPE_2 = 'd4, //output_shape[0][2]
    parameter OUTPUT_SHAPE_3 = 'd64, //output_shape[0][3]
    parameter HEAD_NUM = 'd12,
    parameter NUM_WIDTH = 'd4 //input_shape[1]
)
(
    //********************************* System Signal *********************************
    input                                                           clk_p,
    input                                                           rst_n,
    //********************************* Input Signal *********************************
    input signed  [DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2 - 1   :   0]                          matrix,
    input signed  [NUM_WIDTH   :   0]                                                               num,
    input                                                                                           input_valid_n,
    //********************************* Output Signal *********************************
    output signed [DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 * OUTPUT_SHAPE_3 - 1     :   0]     split_matrix,
    output                                                                                          output_valid_n
);

localparam COUNT_MAX = HEAD_NUM / OUTPUT_SHAPE_2; //DSE algorithm modifies OUTPUT_SHAPE_2

reg [COUNT_MAX - 1 : 0] count;
reg split_complete;

reg [DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2] matrix_mem;

always @ (posedge clk_p or negedge rst_n) begin
    if(!rst_n) begin
        count <= 'd0;
        split_complete <= 'd0;
    end
    else begin
        if(split_complete) begin
            count <= 'd0;
            if(!input_valid_n) begin
                matrix_mem <= matrix;
                split_complete <= 'd0;
            end
            else begin
                matrix_mem <= matrix_mem;
                split_complete <= 'd1;
            end
        end
        else begin
            matrix_mem <= matrix_mem;
            if(count == COUNT_MAX - 1) begin
                count <= 'd0;
                split_complete <= 'd1;
            end
            else begin
                count <= count + 'd1;  
            end
        end
    end
end

assign split_matrix = matrix_mem [(count + 1) * DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 * OUTPUT_SHAPE_3 - 1 :
                                   count * DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2 * OUTPUT_SHAPE_3];
assign output_valid_n = split_complete;

endmodule