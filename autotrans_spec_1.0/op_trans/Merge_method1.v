module Merge_method1 #(
    parameter DATA_WIDTH = 'd8, //input_shape[0][0]
    parameter INPUT_SHAPE_1 = 'd128, //input_shape[0][1]
    parameter INPUT_SHAPE_2 = 'd4, //input_shape[0][2]
    parameter INPUT_SHAPE_3 = 'd64, //input_shape[0][3]
    parameter OUTPUT_SHAPE_1 = 'd128, //output_shape[0][1]
    parameter OUTPUT_SHAPE_2 = 'd768, //output_shape[0][2]
    parameter HEAD_NUM='d12,
    parameter NUM_WIDTH = 'd3 //input_shape[1]
)
(
    //********************************* System Signal *********************************
    input                                                           clk_p,
    input                                                           rst_n,
    //********************************* Input Signal *********************************
    input signed  [DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2 * INPUT_SHAPE_3 - 1   :   0]          matrix,
    input signed  [NUM_WIDTH   :   0]                                                               num,
    input                                                                                           input_valid_n,
    //********************************* Output Signal *********************************
    output signed [DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2- 1     :   0]                       merge_matrix,
    output                                                                                          output_valid_n
);

localparam COUNT_MAX = HEAD_NUM / INPUT_SHAPE_2; //DSE algorithm modifies INPUT_SHAPE_2

reg [COUNT_MAX - 1 : 0] count;
reg merge_complete;

reg [DATA_WIDTH * OUTPUT_SHAPE_1 * OUTPUT_SHAPE_2] matrix_mem;

always @ (posedge clk_p or negedge rst_n) begin
    if(!rst_n) begin
        count <= 'd0;
        merge_complete <= 'd0;
    end
    else begin
        if(merge_complete) begin
            count <= 'd0;
            if(!input_valid_n) begin
                merge_complete <= 'd0;
                matrix_mem[(count + 1) * DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2 * INPUT_SHAPE_3 - 1 :
                        count * DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2 * INPUT_SHAPE_3] <= matrix;
            end
            else begin
                merge_complete <= 'd1;
                matrix_mem <= matrix_mem;
            end
        end
        else begin
            if(count == COUNT_MAX - 1) begin
                count <= 'd0;
                merge_complete <= 'd1;
                matrix_mem <= matrix_mem;
            end
            else begin                
                count <= count + 'd1;  
                matrix_mem[(count + 1) * DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2 * INPUT_SHAPE_3 - 1 :
                        count * DATA_WIDTH * INPUT_SHAPE_1 * INPUT_SHAPE_2 * INPUT_SHAPE_3] <= matrix;
            end
        end
    end
end

assign merge_matrix = matrix_mem;
assign output_valid_n = ~merge_complete;


endmodule