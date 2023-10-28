import json
import numpy
import re
def getParameterDict(parameterList,parameter_dict,pattern_parameter_nameToReplace,pattern_parameter_valueToReplace):
    '''拉出所有参数名和对应的值成为字典并替换后面可能用于表示和运算的此参数名,如parameter result_WIDTH = x_WIDTH + k_WIDTH + 1, '''
    for index_this,this_sentence in enumerate(parameterList):
            name=pattern_parameter_nameToReplace.findall(this_sentence)[0]
            value=pattern_parameter_valueToReplace.findall(this_sentence)[0]
            value=value.replace(',','').replace(')','')
            for index_others,other_sentences in enumerate(parameterList[index_this+1:],start=index_this+1):#替换后面用于运算的此参数名,如parameter result_WIDTH = x_WIDTH + k_WIDTH + 1中的x_WIDTH和k_WIDTH
                if name in other_sentences:
                    parameterList[index_others].replace("{}".format(name),"{}".format(value))
            parameter_dict[name]=value
                
    for key_this,value_in_dict_this in parameter_dict.items():
        for key_other,value_in_dict_other in parameter_dict.items():
            if key_this in value_in_dict_other:
                pattern_d="{}(?=\s+|$)".format(key_this)#动态生成单独的单词进行匹配,(?=\s|$) 表示零宽度正预测先行断言,它要求匹配项后面要么没有字符（$ 表示字符串的结尾）,要么有一个空格字符
                parameter_dict[key_other]=re.sub(pattern_d,value_in_dict_this,value_in_dict_other)
                #print(parameterList[index_others].replace("{}".format(name),"{}".format(value)))


def getInWidthAndPortname(pattern_io_input_getwidth,pattern_io_input_getname,parameter_dict,width_input,in_name,WIDTH_IN):
    '''得到输入的位宽和端口名,位宽压入WIDTH_IN,端口名通过in_name传出'''
    for item in (in_name):#取得in部分的位宽
        if '[' in item  or "signed" in item:
            width_input.append(pattern_io_input_getwidth.findall(item)[0])
    #print(parameter_dict)
    for i in range(len(width_input)):#把位宽换为全数字的
        for keys,values in parameter_dict.items(): 
            pattern_wire_width=r"\b{}\b(?=\s*|$)".format(keys)
            width_input[i]=re.sub(pattern_wire_width,'('+values+')',width_input[i])
                    
    for i in range(len(width_input)):
        WIDTH_IN.append(width_input[i] )#加入到所有in位宽组成的大列表里


    for index,item in enumerate(in_name):#取得in部分的名字
        in_name[index]=pattern_io_input_getname.findall(item)[0]


def getOutWidthAndPortname(pattern_io_output_getwidth,pattern_io_output_getname,parameter_dict,width_output,out_name,WIDTH_OUT):
    '''得到输出的位宽和端口名,位宽压入WIDTH_OUT,端口名通过out_name传出'''
    for item in (out_name):#取得out部分的位宽
        if '[' in item  or "signed" in item:
            width_output.append(pattern_io_output_getwidth.findall(item)[0])    
    for i in range(len(width_output)):
        for keys,values in parameter_dict.items(): 
            pattern_wire_width=r"\b{}\b(?=\s*|$)".format(keys)
            width_output[i]=re.sub(pattern_wire_width,'('+values+')',width_output[i])  
    #
    for i in range(len(width_output)):  
        WIDTH_OUT.append(width_output[i])#加入到所有in位宽组成的列表里


    for index,item in enumerate(out_name):#取得out部分的名字
        out_name[index]=pattern_io_output_getname.findall(item)[0]


def write_Submodule_IO_into_Top_And_GetValid_signal(data_information_dict,RESULT_STRING,in_name,out_name,valid_in,valid_out,standard_module_name):
    '''把例化模块的字符串的写入RESULT_STRING,把其中的使能信号通过valid_in/out传出'''
    count_for_input=0
    code_string=standard_module_name+"  "+data_information_dict["op_name"]+"\n"#第一行
    code_string=code_string+"("+"\n"
    for i in range(len(in_name)):#输入
        if('enable'not in in_name[i] and 'valid' not in in_name[i]  and 'clk' not in in_name[i]  and 'rst_n' not in in_name[i]):
            code_string=code_string+"\t"+"."+in_name[i]+"({contents1})".format(contents1=data_information_dict["input"][count_for_input].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"))+","+"\n"
            count_for_input+=1
        else:
            if('clk' in in_name[i] or 'rst_n'  in in_name[i] ):#clk and rst_n
                code_string=code_string+"\t"+'.'+in_name[i]+"({})".format(in_name[i])+","+"\n"
            else:#将所有输入使能信号加入valid_in里
                code_string=code_string+"\t"+'.'+in_name[i]+"({})".format(in_name[i]+'_'+data_information_dict['op_name'])+","+"\n"
                valid_in.append(in_name[i]+'_'+data_information_dict['op_name'])
            
    count_for_output=0
    for i in range(len(out_name)):#输出
        if(i!=len(out_name)-1):#如果输出不是最后一行,那么要加逗号, 比如'.softmax_quant(input_16),',最后一行则不用加
            if('enable'not in out_name[i] and 'valid' not in out_name[i] and 'clk' not in out_name[i] and 'rst_n' not in out_name[i]):
                code_string=code_string+'\t'+"."+out_name[i]+"({contents2})".format(contents2=data_information_dict["output"][count_for_output].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"))+","+"\n"
                count_for_output+=1
            else:
                if('clk' in out_name[i] or 'rst_n'  in out_name[i] ):#clk and rst_n
                    code_string=code_string+"\t"+'.'+out_name[i]+"({})".format(out_name[i])+","+"\n"
                else:#将所有输出使能信号加入valid_out里
                    code_string=code_string+"\t"+'.'+out_name[i]+"({})".format(out_name[i]+'_'+data_information_dict['op_name'])+","+"\n"
                    valid_out.append(out_name[i]+'_'+data_information_dict['op_name'])
        else:#以下不用加逗号
            if('enable'not in out_name[i] and 'valid' not in out_name[i] and 'clk' not in out_name[i] and 'rst_n' not in out_name[i]):
                code_string=code_string+'\t'+"."+out_name[i]+"({contents2})".format(contents2=data_information_dict["output"][count_for_output].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"))+"\n"
                count_for_output+=1
            else:
                if('clk' in out_name[i] or 'rst_n'  in out_name[i] ):#clk and rst_n
                    code_string=code_string+"\t"+'.'+out_name[i]+"({})".format(out_name[i])+"\n"
                else:#将所有输出使能信号加入valid_out里
                    code_string=code_string+"\t"+'.'+out_name[i]+"({})".format(out_name[i]+'_'+data_information_dict['op_name'])+"\n"
                    valid_out.append(out_name[i]+'_'+data_information_dict['op_name'])
    code_string=code_string+");"+"\n"
    RESULT_STRING.append(code_string)

                
def corresponding_operators_function(data_information_dict,RESULT_STRING,WIDTH_IN,WIDTH_OUT,VALID_IN,VALID_OUT):
    '''读取json文件获取例化的字符串,输入位宽信息,输出位宽信息,输入输出使能信号'''
    address="./modified_verilog/{}_modified.v".format(data_information_dict["op_name"])
    with open("./autotrans_spec_1.0/top module.v",'a+') as file:
        with open(address)as file2:
            content=file2.read().replace('\n', ' ')
            pattern=re.compile("module.*?\(")
            standard_module_name=pattern.findall(content)[0]
            if '#' in standard_module_name:
                result = 1  # 如果存在,设置结果为1
            else:
                result = 0  # 如果不存在,设置结果为0
            standard_module_name=standard_module_name.replace("module ","")
            standard_module_name=standard_module_name.replace("(","")
            standard_module_name=standard_module_name.replace("#","")
            '''这部分用来读取模块的名字并得知该文件是否有参数'''


           
            
            width_input=[]#得到一个signed[...]表示位宽的列表,然后append给WIDTH_IN
            width_output=[]
            valid_in=[]
            valid_out=[]
            parameter_dict={}


            if result==1:
                pattern_parameter=re.compile("#\(.*?\)(?:\s+)?\(")#先匹配出#(parameter...)(这一部分
                pattern_parameter_getlist=re.compile(r"parameter .*?(?:,|\))")
                pattern_parameter_nameToReplace =re.compile( r"parameter\s+(\w+)\s+=")
                pattern_parameter_valueToReplace = re.compile(r"parameter\s+.*=(.*)?(?:,)?(?:\))?")
                pattern_io=re.compile("\).*\(.*output.*?;")
                

                pattern_io_input=re.compile("(input.*,)")
                pattern_io_input_tmp=re.compile("(input.*?)(?=output)")#分割出所有input项为一个大字符串,非贪婪匹配 (.*?) 以确保匹配到最近的 "output"。 (?=output) 是一个正向先行断言，用于确保匹配结束在下一个 "output" 之前。
                pattern_io_input_final=re.compile(r'([^,]+),\s*')#分割出不同的input行
                pattern_io_input_getname=re.compile(r'input\s*(?:wire\s*)?(?:signed\s*)?(?:\[[^\]]+\]\s*)?(\w+)')#分割出名字,可有可无的用?:    
                pattern_io_input_getwidth=re.compile(r'(?:signed\s*)?\[[^\]]+\]')#分割出位宽


                pattern_io_output_1=re.compile(r'output\s+.*?\);')#分割出output那一块，原表达式为r'output\s+\w+.*?\);'
                pattern_io_output_2=re.compile(r'([^,]+)(?:,\s*|\s*$)')#分割出几个字符串
                pattern_io_output_getname=re.compile(r'output\s*(?:wire\s*)?(?:reg\s*)?(?:signed\s*)?(?:\[[^\]]+\]\s*)?(\w+)')#能够直接复用
                pattern_io_output_getwidth=re.compile(r'(?:signed\s*)?\[[^\]]+\]')


                io=pattern_io.findall(content)[0]
                parameterTXT=pattern_parameter.findall(content)[0]
                parameterList=pattern_parameter_getlist.findall(parameterTXT)
                parameter_dict={}
                

                getParameterDict(parameterList,parameter_dict,pattern_parameter_nameToReplace,pattern_parameter_valueToReplace)


                #in部分
                in_tmp=pattern_io_input.findall(   pattern_io_input_tmp.findall(io)[0]   )[0]
                in_name=pattern_io_input_final.findall(in_tmp)
                getInWidthAndPortname(pattern_io_input_getwidth,pattern_io_input_getname,parameter_dict,width_input,in_name,WIDTH_IN)



                #out部分
                out_name=pattern_io_output_1.findall(io)[0]
                out_name=pattern_io_output_2.findall(out_name)
                getOutWidthAndPortname(pattern_io_output_getwidth,pattern_io_output_getname,parameter_dict,width_output,out_name,WIDTH_OUT)
                

                #print(data_information_dict["op_name"])
                write_Submodule_IO_into_Top_And_GetValid_signal(data_information_dict,RESULT_STRING,in_name,out_name,valid_in,valid_out,standard_module_name)
                #print(RESULT_STRING)
                VALID_IN[data_information_dict['op_id']]=valid_in
                VALID_OUT[data_information_dict['op_id']]=valid_out
                
            
                







            if(result==0):
                pattern_parameter=re.compile("#\(.*?\)(?:\s+)?\(")#先匹配出#(parameter...)(这一部分
                pattern_parameter_getlist=re.compile(r"parameter .*?(?:,|\))")
                pattern_parameter_nameToReplace =re.compile( r"parameter\s+(\w+)\s+=")
                pattern_parameter_valueToReplace = re.compile(r"parameter\s+.*=(.*)?(?:,)?(?:\))?")
                pattern_io=re.compile("\).*\(.*output.*?;")
                

                pattern_io_input=re.compile("(input.*,)")
                pattern_io_input_tmp=re.compile("(input.*?)(?=output)")#分割出所有input项为一个大字符串,非贪婪匹配 (.*?) 以确保匹配到最近的 "output"。 (?=output) 是一个正向先行断言，用于确保匹配结束在下一个 "output" 之前。
                pattern_io_input_final=re.compile(r'([^,]+),\s*')#分割出不同的input行
                pattern_io_input_getname=re.compile(r'input\s*(?:wire\s*)?(?:signed\s*)?(?:\[[^\]]+\]\s*)?(\w+)')#分割出名字,可有可无的用?:    
                pattern_io_input_getwidth=re.compile(r'(?:signed\s*)?\[[^\]]+\]')#分割出位宽


                pattern_io_output_1=re.compile(r'output\s+.*?\);')#分割出output那一块，原表达式为r'output\s+\w+.*?\);'
                pattern_io_output_2=re.compile(r'([^,]+)(?:,\s*|\s*$)')#分割出几个字符串
                pattern_io_output_getname=re.compile(r'output\s*(?:wire\s*)?(?:reg\s*)?(?:signed\s*)?(?:\[[^\]]+\]\s*)?(\w+)')#能够直接复用
                pattern_io_output_getwidth=re.compile(r'(?:signed\s*)?\[[^\]]+\]')


                io=pattern_io.findall(content)[0]
                parameterTXT=pattern_parameter.findall(content)[0]
                parameterList=pattern_parameter_getlist.findall(parameterTXT)
                parameter_dict={}
                

                getParameterDict(parameterList,parameter_dict,pattern_parameter_nameToReplace,pattern_parameter_valueToReplace)


                #in部分
                in_tmp=pattern_io_input.findall(   pattern_io_input_tmp.findall(io)[0]   )[0]
                in_name=pattern_io_input_final.findall(in_tmp)
                getInWidthAndPortname(pattern_io_input_getwidth,pattern_io_input_getname,parameter_dict,width_input,in_name,WIDTH_IN)



                #out部分
                out_name=pattern_io_output_1.findall(io)[0]
                out_name=pattern_io_output_2.findall(out_name)
                getOutWidthAndPortname(pattern_io_output_getwidth,pattern_io_output_getname,parameter_dict,width_output,out_name,WIDTH_OUT)
                

                #print(data_information_dict["op_name"])
                write_Submodule_IO_into_Top_And_GetValid_signal(data_information_dict,RESULT_STRING,in_name,out_name,valid_in,valid_out,standard_module_name)
                #print(RESULT_STRING)
                VALID_IN[data_information_dict['op_id']]=valid_in
                VALID_OUT[data_information_dict['op_id']]=valid_out




