#automatic generation of the whole verilog code 

#read from the .json config to get the  link connnection
import onnx
import json
import utils
import string
from corresponding_operators import corresponding_operators_function
import re
# model=onnx.load("./test.onnx")
with open('autotrans_spec_1.0/test_info.json') as f:
    data=json.load(f)

in_name=[]
out_name=[]
output_dict=[]#全部都是wire类型
input_dict=[]#全部都是input,是列表
input_diff=[]#删除重复元素的input list


WIDTH_IN=[]
WIDTH_OUT=[]#存放了所有的in位宽,与输入信号对应
RESULT_STRING=[]#存放了所有的out位宽,与输出信号对应
VALID_IN={}#存放所有的输入信号,是列表的字典
VALID_OUT={}

for  index,data_information_dict in enumerate(data):
    corresponding_operators_function(data_information_dict,RESULT_STRING,WIDTH_IN,WIDTH_OUT,VALID_IN,VALID_OUT)
print(VALID_OUT)
print(VALID_IN)

#automation
for data_information_dict in data:#顺序遍历输出字典
    for i in range(len(data_information_dict["output"])):
        output_dict.append(data_information_dict["output"][i])
for index_1,item_out in enumerate(output_dict[len(output_dict)-len(data[len(data)-1]["output"])\
                                              :len(output_dict)],\
                                                start=len(output_dict)-len(data[len(data)-1]["output"])):
        output_dict[index_1]="output"+"\t"+"{}".format(WIDTH_OUT[index_1])+item_out.translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_")

for index,item_out in enumerate(output_dict[0:len(output_dict)-len(data_information_dict["output"])]):
        output_dict[index]="wire"+"\t"+"{}".format(WIDTH_OUT[index])+item_out.translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_")



for data_information_dict in data:#顺序遍历输入字典
    for i in range(len(data_information_dict["input"])):
        input_dict.append(data_information_dict["input"][i])
for index,item_in in enumerate(input_dict):
    input_dict[index]="input"+"\t"+"{}".format(WIDTH_IN[index])+item_in.translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_")
#注意一定要加完width之后才能去去除相同元素的操作
#去除相同元素
unique_list=[]
for x in input_dict:
    if x not in unique_list:
        unique_list.append(x)

for index,element_in in enumerate(unique_list):#再筛查去掉input和output重复的信号
    flag=0#flag等于0表示没有和他一样的
    for element_out in output_dict:
        if(element_in.split("]")   [-1]     ==    element_out.split("]")  [-1] ):
            flag=1
    if(flag==0):
        input_diff.append(unique_list[index])     

            

    



with open("./autotrans_spec_1.0/top module.v",'a+') as file:
    file.write('module top_module(\n')
    file.write('input clk_p,\n')
    file.write('input rst_n,\n')
    #input,output,wire变量定义
    key_VALID_IN_list=VALID_IN.keys()
    key_VALID_OUT_list=VALID_OUT.keys()
    key_VALID_IN_min=min(key_VALID_IN_list)
    key_VALID_OUT_max=max(key_VALID_OUT_list)
    for first_module_valid in VALID_IN[key_VALID_IN_min]:#最开始的使能信号为input
        file.write('input'+'\t'+first_module_valid+","+'\n')
    for str_in in input_diff: 
        file.write(str_in+','+"\n")


    for module_output_valid in VALID_OUT[key_VALID_OUT_max]:   #最后一个算子的output使能为top模块的output信号
        file.write("output"+'\t'+module_output_valid+','+'\n')


    for str_output in output_dict[len(output_dict)-len(data[len(data)-1]["output"])\
                                              :len(output_dict)]:#最后一个算子的output数据信号为output,其他为为wire
        if(str_output==output_dict[len(output_dict)-1]):
            file.write(str_output+'\n'+');'+'\n')
        else:
            file.write(str_output+','+'\n')
   

    for str_out in output_dict[0:len(output_dict)-len(data[len(data)-1]["output"])]:
        file.write(str_out+";"+"\n")
    key_VALID_IN_list_nomin=[x for x in key_VALID_IN_list if x !=key_VALID_IN_min ]#把input使能对应的op_id去掉
    key_VALID_OUT_list_nomax=[x for x in key_VALID_OUT_list if x !=key_VALID_OUT_max ]#把output使能对应的op_id去掉
    for i in key_VALID_IN_list_nomin:
        for valid_signal in VALID_IN[i]:#输出其他输入使能信号,全部为wire信号
                file.write('wire'+'\t'+valid_signal+";"+'\n')
    for i in key_VALID_OUT_list_nomax:            
        for valid_signal in VALID_OUT[i]:#输出其他output使能信号,全部为wire信号
                file.write('wire'+'\t'+valid_signal+";"+'\n')


    file.write("\n")#接下来是具体电路了
    #使能连线  重要!考虑前级使能没有的情况
    for data_information_dict in data:
        for topo_next_number in range(len(data_information_dict['topo']['next'])):
            if(data_information_dict['topo']['next'][topo_next_number][0]) in key_VALID_IN_list:
                for nextModuleInputV in VALID_IN[data_information_dict['topo']['next'][topo_next_number][0]]:
                    file.write('assign '+nextModuleInputV+" = ")
                    if(VALID_OUT[data_information_dict['op_id']]==[]):
                        file.write(" 'b1;\n")
                    else:
                        for index,thisModuleOutputV in enumerate(VALID_OUT[data_information_dict['op_id']]):
                            if(index==len(VALID_OUT[data_information_dict['op_id']])-1):
                                file.write(thisModuleOutputV+" ;"+'\n') 
                            else:             
                                file.write(thisModuleOutputV+" & ")
    # for index,i in enumerate(VALID_IN[1:len(VALID_IN)],start=1):
    #     for i_content in i:
    #         file.write("assign  "+i_content+"=")
    #         num=0
    #         for num in range(len(VALID_OUT[index-1])):
    #             j= VALID_OUT[index-1][num]
    #             if num != len(VALID_OUT[index-1])-1:
    #                 file.write(' '+j+' '+'&'+' ')s
    #             else:
    #                 file.write(j+';'+'\n')
    
    #模块调用
    for content in RESULT_STRING:
        file.write(content)     
    file.write("\n")
    file.write('endmodule')     
        