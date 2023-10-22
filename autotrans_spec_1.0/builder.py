import os
import json
from configparser import ConfigParser
import re

class myconf(ConfigParser): # ensure uppercase
    def __init__(self, defaults=None):
        ConfigParser.__init__(self, defaults=defaults)

    def optionxform(self, optionstr):
        return optionstr

class builder_a(object):
    def read_libinfo(libinfo_file): 
        # for example: lib_dict = {'code': {'Gelu_method1': ['WIDTH_ADDEND-input_shape[0][0]', 'ADDER_NUM-input_shape[0][1]']}}
        conf = myconf()
        conf.read(libinfo_file)

        lib_dict = {}
        for sec in conf.sections():
            lib_dict.update({sec:{}})
            for opt in conf.options(sec):
                value = conf.get(sec, opt) # for example: value = 'input_shape, output_shape'
                value_list = value.split(',') # for example: value = ['input_shape', ' output_shape']
                value_list = [string.replace("\n", "").replace(" ", "") for string in value_list]
                # remove any whitespace and enterspace at the beginning of the string
                lib_dict[sec].update({opt:value_list})

        return lib_dict

    # use "class builder" includes some methods
    def builder(mode, network_file, lib_dict,head_num):
        # find operator in lib_dict
        with open(network_file, "r") as file:
            content_list = json.load(file)
            split_merge_couple=[]
            for index,j in enumerate(content_list):#获取split和merge的op_id对
                    assist=[]
                    if j["op_type"]=='Split':
                        assist.append(j['op_id'])
                        for index_sub,j in enumerate(content_list[index+1:],start=index+1):
                            if j['op_type']=='Merge':
                                assist.append(j['op_id'])
                                split_merge_couple.append(assist)
                                break
            print(split_merge_couple)

            for i in range(len(content_list)): # content_list[i] represents an operator
                optype = content_list[i]["op_type"]
                # optypes in high_level: 'MAC', 'Split', 'Transpose', 'MatMul', 'Softmax', 'Merge', 'Add', 'Layernorm', 'Gelu'
                input_shape= content_list[i]["input_shape"] # list
                output_shape = content_list[i]["output_shape"] # list
                op_name=content_list[i]["op_name"] # string
                op_id=content_list[i]['op_id']
                op_type=content_list[i]["op_type"]
                flag_whether_inSM=0
                #id在split_merge之间,那么
                for id_couple in split_merge_couple:
                    if op_id>=id_couple[0] and op_id<=id_couple[1]:
                        flag_whether_inSM=1

                found = 0
                method_dict = {}
                for method in lib_dict[mode].items(): # for example: method = ('Gelu_method1', ['input_shape', 'output_shape'])
                    method_name = method[0]
                    method_params = method[1]
                    if optype in method_name.split('_'):
                        found = 1
                        method_dict[method_name] = method_params 
                        # for example: if optype is 'Add',
                        # method_dict = {'Add_method1': ['WIDTH_ADDEND-input_shape[0][0]', 'ADDER_NUM-input_shape[0][1]'],
                        #                'Add_method2': ['WIDTH_ADDEND-input_shape[0][0]', 'ADDER_NUM-input_shape[0][1]']}

                # print(method_dict)

                if found == 0:
                    print("Generation failed: Cannot find optype \"" + optype + "\" in libinfo.")

                else:
                    modified_file = open("./modified_verilog/" + op_name + "_modified.v", "w+") # name of modified operator
                    if len(method_dict) == 1:
                        name="{}_method1".format(optype) # name is the generator method (operator + '_' + tag)
                        address = "./autotrans_spec_1.0/op_trans/{}.v".format(name) # address is the operator file to be modified
                    else:
                        print('''Multiple methods for operator \"" + optype +"\" was found.
                            ''') # 
                        
                        method = "method1"#input("which method to use?") #  method应该是用户输入的字符串

                        name="{}_{}".format(optype, method)
                        address = "./autotrans_spec_1.0/op_trans/{}.v".format(name)

                    with open(address) as file_to_be_modified: 
                        print(op_name)
                        content=file_to_be_modified.read()
                        
                        search_name=re.compile("module\s+(.*)(?:\n)?#\s*\(")
                        for parameter in method_dict[name]: # (In libinfo.ini) "parameter" looks like 'WIDTH_ADDEND-input_shape[0][0]'
                            source_file_parameter = parameter.split('-')[0] # 'WIDTH_ADDEND'
                            test_info_parameter = parameter.split('-')[1] # 'input_shape[0][0]'
                            print(source_file_parameter)
                            search=re.compile("parameter\s*"+source_file_parameter+"\s*=\s*(.*)?(?:\s*)(?:\n)") # Regular expression finds "input_shape[index][index]" in the comments
                            search_for_headNum=re.compile("parameter\s*"+"HEAD_NUM"+"\s*=\s*(.*)?(?:\s*)(?:\n)")
                            search_result=search.findall(content)[0]
                            if op_type=='Split' or op_type=="Merge":
                                #head_num替换
                                head_num_string=search_for_headNum.findall(content)[0]
                                if ',' in head_num_string:
                                    content=re.sub(search_for_headNum, rf'parameter HEAD_NUM = {head_num},\n',content) 
                                else:
                                    content=re.sub(search_for_headNum, rf'parameter HEAD_NUM = {head_num}\n',content) 
                                print(content)
                            for index1,one_input_shape in enumerate(input_shape):#input部分的参数替换
                                for index2,everyParameter in enumerate(one_input_shape):
                                    if ("input_shape"+"[{}]".format(index1)+"[{}]".format(index2))== test_info_parameter:
                                        if input_shape[index1][index2]==12 and flag_whether_inSM==1:
                                            replacement="{}".format(head_num)
                                        else:
                                            replacement="{}".format(input_shape[index1][index2])

                                        if ',' in search_result:
                                            content=re.sub(search, rf'parameter {source_file_parameter} = {replacement},\n',content) # find all "//input_shape[index][index]"
                                        else:
                                            content=re.sub(search, rf'parameter {source_file_parameter} = {replacement}\n',content) 

                            for index1,one_output_shape in enumerate(output_shape):#output部分的参数替换
                                for index2,everyParameter in enumerate(one_output_shape):
                                    if ("output_shape"+"[{}]".format(index1)+"[{}]".format(index2))== test_info_parameter:
                                        if output_shape[index1][index2]==12 and flag_whether_inSM==1:
                                            replacement="{}".format(head_num)
                                        else:
                                            replacement="{}".format(output_shape[index1][index2])
                                        if ',' in search_result:
                                            content=re.sub(search, rf'parameter {source_file_parameter} = {replacement},\n',content) # find all "//input_shape[index][index]"
                                        else:
                                            content=re.sub(search, rf'parameter {source_file_parameter} = {replacement}\n',content)     
                        content=re.sub(search_name,'module '+op_name+"_opID_"+'{}'.format(content_list[i]["op_id"])+" #( \n",content)
                        print(content) 
                        # for index1,one_input_shape in enumerate(input_shape):
                        #     for index2,everyParameter in enumerate(one_input_shape):
                        #         print("input_shape"+"[{}]".format(index1)+"[{}]".format(index2))
                        #         if ("input_shape"+"[{}]".format(index1)+"[{}]".format(index2)) in input_shape_list:#如果input_shape给了的话,此时去匹配对应的行进行参数修改
                        #                 # 构建新的行内容
                        #                 keyword_to_match = re.escape("input_shape[{index1}][{index2}]".format(index1=index1,index2=index2))  
                        #                 print(keyword_to_match)    
                        #                 print(input_shape[index1][index2])
                        #                 a = "=(.*)(?=(?:,)\s*\/\/" + keyword_to_match + ')'
                        #                 #(?= ... ) 是正则表达式中的正向预查（Positive Lookahead）构造，它用于匹配一个字符串后面的内容，但不包括这个内容在匹配的结果中。
                        #                 pattern_a = re.compile(a)  
                        #                 content = re.sub(pattern_a,"={}".format(input_shape[index1][index2]),content)
                                            # change content

                        # if "output_shape" in method_dict[name]:
                        #     matching_lines = []
                        #     for index1,one_output_shape in enumerate(output_shape):
                        #         for index2,everyParameter in enumerate(one_output_shape):
                        #             print("output_shape"+"[{}]".format(index1)+"[{}]".format(index2))
                        #             if ("output_shape"+"[{}]".format(index1)+"[{}]".format(index2)) in output_shape_list:
                        #                     keyword_to_match = re.escape("output_shape[{index1}][{index2}]".format(index1=index1,index2=index2))  
                        #                     print(keyword_to_match)    
                        #                     print(output_shape[index1][index2])
                        #                     a = "=(.*)(?=(?:,)\s*\/\/" + keyword_to_match + ')'
                        #                     pattern_a = re.compile(a)  
                        #                     content = re.sub(pattern_a,"={}".format(output_shape[index1][index2]),content)
                                        
                        modified_file.write(content) # write comment into modified file


def main():
    test=builder_a
    lib_dict = test.read_libinfo("autotrans_spec_1.0/libinfo.ini")
    test.builder("code","autotrans_spec_1.0/test_info.json",lib_dict,4)  
    print(lib_dict)



if __name__ == "__main__":
    main()