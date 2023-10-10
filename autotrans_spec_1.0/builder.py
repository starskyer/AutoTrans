import os
import json
from configparser import ConfigParser
import re


def read_libinfo(libinfo_file): # for example: lib_dict = {'code': {'gelu_method1': ['input_size', 'output_size']}}
    conf = ConfigParser()
    conf.read(libinfo_file)

    lib_dict = {}
    for sec in conf.sections():
        lib_dict.update({sec:{}})
        for opt in conf.options(sec):
            value = conf.get(sec, opt) # for example: value = 'input_size, output_size'
            value_list = value.split(', ')
            lib_dict[sec].update({opt:value_list})

    return lib_dict


def builder(mode, network_file, lib_dict):
    # find operator in lib_dict
    with open(network_file, "r") as file:
        content_list = json.load(file)
        for i in range(len(content_list)): # content_list[i] represents an operator
            optype = content_list[i]["optype"]
            # optypes in high_level: MM, split, transpose, softmax, merge, MADD, layernorm, gelu.
            # optypes in dag_match:  Identity, Constant, Shape, Expand, Gather, Add, Layernorm, Mul, MatMul, 
            #                        Reshape, Transpose, Div, Softmax, Gelu, Gemm, Tanh, Relu
            input_size = content_list[i]["input_size"]
            output_size = content_list[i]["output_size"]

            found = 0
            param_list = []
            for method in lib_dict[mode].keys():
                if optype in method.split('_'):
                    found = 1
                    param_list = lib_dict[mode][method]
                    break

            if found == 0:
                print("Generation failed: Cannot find optype \"" + optype + "\" in libinfo.")

            else:
                modified_file = open("./modified_verilog/" + optype + "_modified.v", "r+")
                address="./op_trans/{}.v".format(optype)
                with open(address)as file_to_be_modified:
                    content=file_to_be_modified.read().replace('\n', ' ')
                    modified_content = content  # 创建一个副本用于修改
                    search=re.compile('#(input_size\[.*?\])')#正则表达式匹配人工要求输入的input_size
                    input_size_list=search.findall(content)#匹配注释里的input_size
                    if param_list[0]=="input_size":#知道接下来要改input_size
                        matching_lines = []  # 用于存储匹配的行
                        modified_content = content  # 创建一个副本用于修改
                        for index1,one_input_size in enumerate(input_size):
                            for index2,everyParameter in enumerate(one_input_size):
                                if ("input"+"[{}]".format(index1)+"[{}]".format(index2)) in input_size_list:#如果input_size给了的话,此时去匹配对应的行进行参数修改
                                        # 构建新的行内容
                                        keyword_to_match = f"input_size[{index1}][{index2}]"            
                                        modified_content = modified_content.replace(f"'=.*,//{keyword_to_match}'", f"{input_size[index1][index2]}")
                                        #替换行内容
                        modified_file.write(modified_content)#写入
                                
                            
                    

            # if(optype == 'gelu'):
            #     modified_gelu=open("./modified_verilog/nnlut_gelu.v","r+")
            #     with open("./autotrans_spec_1.0/op_trans/nnlut_gelu_64.v","r+") as gelufile:
            #         data_lines=gelufile.readlines()
            #         for line in data_lines:
            #             if 'parameter DIMENTION = 64' in line:
            #                 modified_gelu.write(line.replace('parameter DIMENTION = 64', 'parameter DIMENTION = {num}'.format(num=dimension_1)))
            #             else:
            #                 modified_gelu.write(line)

            # # elif(optype == 'split'):

            # # elif(optype == 'transpose'):

            # # elif(optype == 'softmax'):
            # #     modified_softmax=open("./modified_verilog/nnlut_softmax_modified.v","r+")
            # #     with open("./autotrans_spec_1.0/op_trans/nnlut_softmax_128_quant.v","r+") as softmaxfile:
            # #         data_lines=softmaxfile.readlines()
            # #         for line in data_lines:
            # #             if 'parameter DIMENTION = 64' in line:
            # #                 modified_softmax.write(line.replace('parameter DIMENTION = 64', 'parameter DIMENTION = {num}'.format(num=dimension)))
            # #             else:
            # #                 modified_softmax.write(line)
                
            # # elif(optype == 'merge'):

            # elif(optype == 'MADD'):
            #     modified_MADD=open("./modified_verilog/Madder.v","r+")
            #     with open("./autotrans_spec_1.0/op_trans/Madder_128_768.v","r+") as MADDfile:
            #         data_lines=MADDfile.readlines()
            #         for line in data_lines:
            #             if "parameter ADDER_NUM = 'd128" in line:
            #                 modified_MADD.write(line.replace("parameter ADDER_NUM = 'd128", "parameter ADDER_NUM = 'd{num}".format(num=dimension_1)))
            #             else:
            #                 modified_MADD.write(line)

            # elif(optype == 'layernorm'):
            #     modified_layernorm=open("./modified_verilog/nnlut_layernorm.v","r+")
            #     with open("./autotrans_spec_1.0/op_trans/layernorm_nnlut_128_768.v","r+") as layernormfile:
            #         data_lines=layernormfile.readlines()
            #         for line in data_lines:
            #             if 'parameter   SENTENCE_NUM=128' in line:
            #                 modified_layernorm.write(line.replace('parameter   SENTENCE_NUM=128,', 'parameter SENTENCE_NUM = {num}'.format(num=dimension_1)))
            #             else:
            #                 modified_layernorm.write(line)

            
            # # elif(optype == 'MM'):




def main():
    lib_dict = read_libinfo("./autotrans_spec_1.0/libinfo.ini")





if __name__ == "__main__":
    main()