import json
import numpy
import re
def corresponding_operators_function(data_information_dict,RESULT_STRING,WIDTH_IN,WIDTH_OUT,VALID_IN,VALID_OUT):
    address="./op_trans/{}_modified.v".format(data_information_dict["op_name"])
    with open("./op_trans/top module.v",'a+') as file:
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
            
            count_for_input=0
            count_for_output=0
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

                pattern_io_output_1=re.compile(r'output\s+\w+.*?\);')#分割出output那一块
                pattern_io_output_2=re.compile(r'([^,]+)(?:,\s*|\s*$)')#分割出几个字符串
                pattern_io_output_getname=re.compile(r'output\s*(?:wire\s*)?(?:reg\s*)?(?:signed\s*)?(?:\[[^\]]+\]\s*)?(\w+)')#能够直接复用
                pattern_io_output_getwidth=re.compile(r'(?:signed\s*)?\[[^\]]+\]')

                io=pattern_io.findall(content)[0]
                parameterTXT=pattern_parameter.findall(content)[0]
                parameterList=pattern_parameter_getlist.findall(parameterTXT)
                print(parameterList)#拉出所有参数名和对应的值并替换后面可能用于表示和运算的此参数名,如parameter result_WIDTH = x_WIDTH + k_WIDTH + 1, 
                for index_this,this_sentence in enumerate(parameterList):
                    name=pattern_parameter_nameToReplace.findall(this_sentence)[0]
                    value=pattern_parameter_valueToReplace.findall(this_sentence)[0]
                    value=value.replace(',','').replace(')','')
                    parameter_dict[name]=value
                
                for key_this,value_in_dict_this in parameter_dict.items():
                    for key_other,value_in_dict_other in parameter_dict.items():
                        if key_this in value_in_dict_other:
                            pattern_d="{}(?=\s+|$)".format(key_this)#动态生成单独的单词进行匹配,(?=\s|$) 表示零宽度正预测先行断言,它要求匹配项后面要么没有字符（$ 表示字符串的结尾）,要么有一个空格字符
                            parameter_dict[key_other]=re.sub(pattern_d,value_in_dict_this,value_in_dict_other)


                    
                for index_others,other_sentences in enumerate(parameterList[index_this+1:],start=index_this+1):
                    if name in other_sentences:
                        parameterList[index_others].replace("{}".format(name),"{}".format(value))
                        #print(parameterList[index_others].replace("{}".format(name),"{}".format(value)))


                #in部分
                in_tmp=pattern_io_input.findall(   pattern_io_input_tmp.findall(io)[0]   )[0]
                in_name=pattern_io_input_final.findall(in_tmp)

                for item in (in_name):#取得in部分的位宽
                    if '[' in item  or "signed" in item:
                        width_input.append(pattern_io_input_getwidth.findall(item)[0])
                for i in range(len(width_input)):#把位宽换为全数字的
                    for keys,values in parameter_dict.items(): 
                        pattern_wire_width="{}(?=\s+|$)".format(keys)
                        width_input[i]=re.sub(pattern_wire_width,'('+values+')',width_input[i])
                #print(width_input)
                for i in range(len(width_input)):
                    WIDTH_IN.append(width_input[i] )#加入到所有in位宽组成的大列表里


                for index,item in enumerate(in_name):#取得in部分的名字
                    in_name[index]=pattern_io_input_getname.findall(item)[0]



                #out部分
                out_name=pattern_io_output_1.findall(io)[0]
                out_name=pattern_io_output_2.findall(out_name)

                for item in (out_name):#取得out部分的位宽
                    if '[' in item  or "signed" in item:
                        width_output.append(pattern_io_output_getwidth.findall(item)[0])    
                for i in range(len(width_output)):
                    for keys,values in parameter_dict.items(): 
                        pattern_wire_width="{}(?=\s+|$)".format(keys)
                        width_output[i]=re.sub(pattern_wire_width,'('+values+')',width_output[i])  

                for i in range(len(width_output)):  
                    WIDTH_OUT.append(width_output[i])#加入到所有in位宽组成的列表里


                for index,item in enumerate(out_name):#取得out部分的名字
                    out_name[index]=pattern_io_output_getname.findall(item)[0]
                
                
                
                code_string=standard_module_name+"  "+data_information_dict["op_name"]+"\n"#第一行
                code_string=code_string+"("+"\n"
                for i in range(len(in_name)):#输入
                    if('enable'not in in_name[i] and 'valid' not in in_name[i]  and 'clk' not in in_name[i]  and 'rst_n' not in in_name[i]):
                        code_string=code_string+"\t"+"."+in_name[i]+"({contents1})".format(contents1=data_information_dict["input"][count_for_input].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"))+","+"\n"
                        count_for_input+=1
                    else:
                        code_string=code_string+"\t"+'.'+in_name[i]+"({})".format(in_name[i])+","+"\n"
                        if('en' in in_name[i] or 'valid'  in in_name[i] ):#将所有输入使能信号加入valid_in里
                            valid_in.append(in_name[i])

                      
                print(out_name)
                for i in range(len(out_name)):#输出
                    if(i!=len(out_name)-1):#如果输出不是最后一行,那么要加逗号, 比如'.softmax_quant(input_16),',最后一行则不用加
                        if('enable'not in out_name[i] and 'valid' not in out_name[i] and 'clk' not in out_name[i] and 'rst_n' not in out_name[i]):
                            code_string=code_string+'\t'+"."+out_name[i]+"({contents2})".format(contents2=data_information_dict["output"][count_for_output].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"))+","+"\n"
                            count_for_output+=1
                        else:
                            code_string=code_string+"\t"+'.'+out_name[i]+"({})".format(out_name[i])+","+"\n"
                            if('en' in out_name[i] or 'valid'  in out_name[i] ):#将所有输出使能信号加入valid_out里
                                valid_out.append(out_name[i])
                    else:
                        if('enable'not in out_name[i] and 'valid' not in out_name[i] and 'clk' not in out_name[i] and 'rst_n' not in out_name[i]):
                            code_string=code_string+'\t'+"."+out_name[i]+"({contents2})".format(contents2=data_information_dict["output"][count_for_output].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"))+"\n"
                            count_for_output+=1
                        else:
                            code_string=code_string+"\t"+'.'+out_name[i]+"({})".format(out_name[i])+"\n"
                            if('en' in out_name[i] or 'valid'  in out_name[i] ):#将所有输出使能信号加入valid_out里
                                valid_out.append(out_name[i])
                print(valid_out)
                VALID_IN.append(valid_in)
                VALID_OUT.append(valid_out)
                code_string=code_string+");"+"\n"
                RESULT_STRING.append(code_string)
            
                







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

                pattern_io_output_1=re.compile(r'output\s+\w+.*?\);')#分割出output那一块
                pattern_io_output_2=re.compile(r'([^,]+)(?:,\s*|\s*$)')#分割出几个字符串
                pattern_io_output_getname=re.compile(r'output\s*(?:wire\s*)?(?:reg\s*)?(?:signed\s*)?(?:\[[^\]]+\]\s*)?(\w+)')#能够直接复用
                pattern_io_output_getwidth=re.compile(r'(?:signed\s*)?\[[^\]]+\]')

                io=pattern_io.findall(content)[0]
                parameterTXT=pattern_parameter.findall(content)[0]
                parameterList=pattern_parameter_getlist.findall(parameterTXT)
                print(parameterList)#拉出所有参数名和对应的值并替换后面可能用于表示和运算的此参数名,如parameter result_WIDTH = x_WIDTH + k_WIDTH + 1, 
                for index_this,this_sentence in enumerate(parameterList):
                    name=pattern_parameter_nameToReplace.findall(this_sentence)[0]
                    value=pattern_parameter_valueToReplace.findall(this_sentence)[0]
                    value=value.replace(',','').replace(')','')
                    parameter_dict[name]=value
                
                for key_this,value_in_dict_this in parameter_dict.items():
                    for key_other,value_in_dict_other in parameter_dict.items():
                        if key_this in value_in_dict_other:
                            pattern_d="{}(?=\s+|$)".format(key_this)#动态生成单独的单词进行匹配,(?=\s|$) 表示零宽度正预测先行断言,它要求匹配项后面要么没有字符（$ 表示字符串的结尾）,要么有一个空格字符
                            parameter_dict[key_other]=re.sub(pattern_d,value_in_dict_this,value_in_dict_other)


                    
                for index_others,other_sentences in enumerate(parameterList[index_this+1:],start=index_this+1):
                    if name in other_sentences:
                        parameterList[index_others].replace("{}".format(name),"{}".format(value))
                        #print(parameterList[index_others].replace("{}".format(name),"{}".format(value)))


                #in部分
                in_tmp=pattern_io_input.findall(   pattern_io_input_tmp.findall(io)[0]   )[0]
                in_name=pattern_io_input_final.findall(in_tmp)

                for item in (in_name):#取得in部分的位宽
                    if '[' in item  or "signed" in item:
                        width_input.append(pattern_io_input_getwidth.findall(item)[0])
                for i in range(len(width_input)):#把位宽换为全数字的
                    for keys,values in parameter_dict.items(): 
                        pattern_wire_width="{}(?=\s+|$)".format(keys)
                        width_input[i]=re.sub(pattern_wire_width,'('+values+')',width_input[i])
                #print(width_input)
                for i in range(len(width_input)):
                    WIDTH_IN.append(width_input[i] )#加入到所有in位宽组成的大列表里


                for index,item in enumerate(in_name):#取得in部分的名字
                    in_name[index]=pattern_io_input_getname.findall(item)[0]



                #out部分
                out_name=pattern_io_output_1.findall(io)[0]
                out_name=pattern_io_output_2.findall(out_name)

                for item in (out_name):#取得out部分的位宽
                    if '[' in item  or "signed" in item:
                        width_output.append(pattern_io_output_getwidth.findall(item)[0])    
                for i in range(len(width_output)):
                    for keys,values in parameter_dict.items(): 
                        pattern_wire_width="{}(?=\s+|$)".format(keys)
                        width_output[i]=re.sub(pattern_wire_width,'('+values+')',width_output[i])  

                for i in range(len(width_output)):  
                    WIDTH_OUT.append(width_output[i])#加入到所有in位宽组成的列表里


                for index,item in enumerate(out_name):#取得out部分的名字
                    out_name[index]=pattern_io_output_getname.findall(item)[0]
                
                
                
                code_string=standard_module_name+"  "+data_information_dict["topo"]["name"]+"\n"#第一行
                code_string=code_string+"("+"\n"
                for i in range(len(in_name)):#输入
                    if('enable'not in in_name[i] and 'valid' not in in_name[i]  and 'clk' not in in_name[i]  and 'rst_n' not in in_name[i]):
                        code_string=code_string+"\t"+"."+in_name[i]+"({contents1})".format(contents1=data_information_dict["topo"]["input"][count_for_input].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"))+","+"\n"
                        count_for_input+=1
                    else:
                        code_string=code_string+"\t"+'.'+in_name[i]+"({})".format(in_name[i])+","+"\n"
                        if('en' in in_name[i] or 'valid'  in in_name[i] ):#将所有输入使能信号加入valid_in里
                            valid_in.append(in_name[i])

                      
                print(out_name)
                for i in range(len(out_name)):#输出
                    if(i!=len(out_name)-1):#如果输出不是最后一行,那么要加逗号, 比如'.softmax_quant(input_16),',最后一行则不用加
                        if('enable'not in out_name[i] and 'valid' not in out_name[i] and 'clk' not in out_name[i] and 'rst_n' not in out_name[i]):
                            code_string=code_string+'\t'+"."+out_name[i]+"({contents2})".format(contents2=data_information_dict["topo"]["output"][count_for_output].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"))+","+"\n"
                            count_for_output+=1
                        else:
                            code_string=code_string+"\t"+'.'+out_name[i]+"({})".format(out_name[i])+","+"\n"
                            if('en' in out_name[i] or 'valid'  in out_name[i] ):#将所有输出使能信号加入valid_out里
                                valid_out.append(out_name[i])
                    else:
                        if('enable'not in out_name[i] and 'valid' not in out_name[i] and 'clk' not in out_name[i] and 'rst_n' not in out_name[i]):
                            code_string=code_string+'\t'+"."+out_name[i]+"({contents2})".format(contents2=data_information_dict["topo"]["output"][count_for_output].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"))+"\n"
                            count_for_output+=1
                        else:
                            code_string=code_string+"\t"+'.'+out_name[i]+"({})".format(out_name[i])+"\n"
                            if('en' in out_name[i] or 'valid'  in out_name[i] ):#将所有输出使能信号加入valid_out里
                                valid_out.append(out_name[i])
                print(valid_out)
                VALID_IN.append(valid_in)
                VALID_OUT.append(valid_out)
                code_string=code_string+");"+"\n"
                RESULT_STRING.append(code_string)




#     elif(data_information_dict["op_type"]=="Add"):    
#         with open("./op_trans/top module.v",'a+') as file:
#             code_string="""
#     Madder_128_768 {module_name}
#     (
#     //********************************* Input Signal *********************************
#         .addend1({addend1}),
#         .addend2({addend2}),

#     //********************************* Output Signal *********************************
#         .sum({sum})
#     );
#     """.format(module_name=data_information_dict["topo"]["name"],\
#                        addend1=data_information_dict["topo"]["input"][0].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"),\
#                         addend2=data_information_dict["topo"]["input"][1].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"),\
#                         sum=data_information_dict["topo"]["output"][0].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"))
#             file.write(code_string)



#     elif(data_information_dict["op_type"]=="MatMul"):    
#         with open("./op_trans/top module.v",'a+') as file:
#             code_string="""
#     multiplier_group {module_name}
#     (
#     //*************************************** System signal ***************************************//
#         .clk_p(clk),
#         .rst_n(rst_n),
#     //*************************************** Input signal ***************************************//
#         .factor1({factor1}),
#         .factor2({factor2}),
#         .factor_valid_n(factor_valid_n),
#     //*************************************** Output signal ***************************************//
#         .product({product}),
#         .product_valid_n(product_valid_n)
#     );
#     """.format(module_name=data_information_dict["topo"]["name"],\
#                        factor1=data_information_dict["topo"]["input"][0].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"),\
#                         factor2=data_information_dict["topo"]["input"][1].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"),\
#                         product=data_information_dict["topo"]["output"][0].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_"))
#   #使能信号问题很大!!!
#             file.write(code_string)
    
            
#     #if(data_information_dict["op_type"]=="Add"):
#         #if((data_information_dict["topo"])["name"].split('_')[-1]=='84'):