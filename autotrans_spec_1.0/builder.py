import os
import json
from configparser import ConfigParser
import re

class myconf(ConfigParser): 
    # ensure uppercase for .ini file read
    def __init__(self, defaults = None):
        ConfigParser.__init__(self, defaults=defaults)

    def optionxform(self, optionstr):
        return optionstr

class builder(object):
    # basic information & hyper parameters
    mode = '' # 'code', 'gen', 'gen_hls'
    network_file = ''
    libinfo_file = ''
    head_num = 1
    data_width = 8

    def __init__(self, mode, network_file, libinfo_file, head_num, data_width):
        self.mode = mode
        self.network_file = network_file
        self.libinfo_file = libinfo_file
        self.head_num = head_num
        self.data_width = data_width

    def read_libinfo(self, libinfo_file): 
        '''read libinfo.ini and return a dictionary as follows:
        for example: lib_dict = {'code': {'Gelu_method1': ['WIDTH_ADDEND-input_shape[0][0]', 'ADDER_NUM-input_shape[0][1]']}}'''
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
    
    def find_split_merge(self, content_list):
        '''for the contents of a network, find all the split-merge pairs in it
        return a list of lists containing the op_ids of every split-merge pair'''
        split_merge_pairs = []
        for index_split, op in enumerate(content_list): # get the op_id of a split-merge pair
            pair = []
            if op["op_type"] == 'Split':
                pair.append(op['op_id'])
                for index_merge, op in enumerate(content_list[index_split + 1:], start = index_split + 1):
                    if op['op_type'] == 'Merge':
                        pair.append(op['op_id'])
                        split_merge_pairs.append(pair)
                        break
        return split_merge_pairs
    
    def find_method(self, mode_methods, optype):
        '''find available methods for specified optype
        return a dictionary of all available methods'''
        method_dict = {}
        for method in mode_methods.items(): # for example: method = ('Gelu_method1', ['input_shape', 'output_shape'])
            method_name = method[0]
            method_params = method[1]
            if optype in method_name.split('_'):
                method_dict[method_name] = method_params 
                # for example: if optype is 'Add',
                # method_dict = {'Add_method1': ['WIDTH_ADDEND-input_shape[0][0]', 'ADDER_NUM-input_shape[0][1]'],
                #                'Add_method2': ['WIDTH_ADDEND-input_shape[0][0]', 'ADDER_NUM-input_shape[0][1]']}
        return method_dict

    def file_modify(self, modified_file, source_file, op, params, in_split_merge):
        '''modify the specified operator with given information
        generate the modified file under modified_file address'''
        input_shape = op["input_shape"] # list
        output_shape = op["output_shape"] # list
        op_name = op["op_name"] # string
        op_id = op['op_id']
        op_type = op["op_type"]

        with open(source_file) as file_to_be_modified: 
            content = file_to_be_modified.read()
            
            search_name = re.compile("module\s+(.*)(?:\n)?#\s*\(")
            for parameter in params: # (In libinfo.ini) "parameter" looks like 'WIDTH_ADDEND-input_shape[0][0]'
                source_file_parameter = parameter.split('-')[0] # 'WIDTH_ADDEND'
                test_info_parameter = parameter.split('-')[1] # 'input_shape[0][0]'

                search = re.compile("parameter\s*" + source_file_parameter + "\s*=\s*(.*)?(?:\s*)(?:\n)") # Regular expression finds "input_shape[index][index]" in the comments
                search_for_headNum = re.compile("parameter\s*" + "HEAD_NUM" + "\s*=\s*(.*)?(?:\s*)(?:\n)")
                search_result = search.findall(content)[0]
                if op_type == 'Split':
                    # head_num replace
                    head_num_string = search_for_headNum.findall(content)[0]
                    if ',' in head_num_string:
                        content = re.sub(search_for_headNum, rf'parameter HEAD_NUM = {output_shape[0][2]},\n',content) 
                    else:
                        content = re.sub(search_for_headNum, rf'parameter HEAD_NUM = {output_shape[0][2]}\n',content) 
                if op_type == 'Merge':
                    # head_num replace
                    head_num_string = search_for_headNum.findall(content)[0]
                    if ',' in head_num_string:
                        content = re.sub(search_for_headNum, rf'parameter HEAD_NUM = {input_shape[0][2]},\n',content) 
                    else:
                        content = re.sub(search_for_headNum, rf'parameter HEAD_NUM = {input_shape[0][2]}\n',content) 
                
                for index1, one_input_shape in enumerate(input_shape): # input parameter replace
                    for index2, everyParameter in enumerate(one_input_shape):
                        if ("input_shape" + "[{}]".format(index1) + "[{}]".format(index2)) == test_info_parameter:
                            if input_shape[index1][index2] == 12 and in_split_merge == 1: # TODO: 12 is the split/merge num
                                replacement = "{}".format(self.head_num)
                            else:
                                replacement = "{}".format(input_shape[index1][index2])

                            if ',' in search_result:
                                content = re.sub(search, rf'parameter {source_file_parameter} = {replacement},\n',content) # find all "//input_shape[index][index]"
                            else:
                                content = re.sub(search, rf'parameter {source_file_parameter} = {replacement}\n',content) 

                for index1, one_output_shape in enumerate(output_shape): # output parameter replace
                    for index2, everyParameter in enumerate(one_output_shape):
                        if ("output_shape" + "[{}]".format(index1) + "[{}]".format(index2)) == test_info_parameter:
                            if output_shape[index1][index2] == 12 and in_split_merge == 1: # TODO: 12 is the split/merge num
                                replacement = "{}".format(self.head_num)
                            else:
                                replacement = "{}".format(output_shape[index1][index2])
                            if ',' in search_result:
                                content = re.sub(search, rf'parameter {source_file_parameter} = {replacement},\n',content) # find all "//input_shape[index][index]"
                            else:
                                content = re.sub(search, rf'parameter {source_file_parameter} = {replacement}\n',content)

            content = re.sub(search_name,'module ' + op_name + "_opID_" + '{}'.format(op_id) + " #( \n",content)
            modified_file.write(content) # write content into modified file


    def build(self):
        '''main process of the builder'''

        # read libinfo file into lib_dict
        lib_dict = self.read_libinfo(self.libinfo_file)

        # read network file into content_list
        with open(self.network_file, "r") as file:
            content_list = json.load(file) # content_list[index] is all the information of an operator

            # get all split-merge pairs in content_list 
            split_merge_pairs = self.find_split_merge(content_list)

            for i in range(len(content_list)): # content_list[i] represents an operator
                # optypes in high_level: 'MAC', 'Split', 'Transpose', 'MatMul', 'Softmax', 'Merge', 'Add', 'Layernorm', 'Gelu'

                # TODO: Not flexible for extra attributes
                op_name = content_list[i]["op_name"] # string
                op_id = content_list[i]['op_id']
                op_type = content_list[i]["op_type"]

                # whether operator is in split-merge pair
                in_split_merge = 0
                for id_couple in split_merge_pairs:
                    if op_id >= id_couple[0] and op_id <= id_couple[1]:
                        in_split_merge = 1

                # find available methods in libinfo
                mode_methods = lib_dict[self.mode]
                method_dict = self.find_method(mode_methods, op_type)

                if len(method_dict) == 0:
                    print("Generation failed: Cannot find optype \"" + op_type + "\" in libinfo.")

                else:
                    modified_file = open("./modified_verilog/" + op_name + "_modified.v", "w+") # name of modified operator
                    if len(method_dict) == 1:
                        name = "{}_method1".format(op_type) # name is the generator method (operator + '_' + tag)
                        source_file = "./autotrans_spec_1.0/op_trans/{}.v".format(name) # source_file is the source operator file
                    else:
                        print("Multiple methods for operator \"" + op_type +"\" was found.") # 
                        
                        method = "method1" # input ("which method to use?") #  method must be the string user input

                        name = "{}_{}".format(op_type, method)
                        source_file = "./autotrans_spec_1.0/op_trans/{}.v".format(name)

                    params = method_dict[name] # list of strings containing corresponding parameters
                    self.file_modify(modified_file, source_file, content_list[i], params, in_split_merge)


def main():
    test = builder(mode = "code", network_file = "./autotrans_spec_1.0/test.json",
                   libinfo_file = "autotrans_spec_1.0/libinfo.ini", head_num = 4, data_width = 8)
    test.build()  



if __name__ == "__main__":
    main()