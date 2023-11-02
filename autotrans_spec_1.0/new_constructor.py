#automatic generation of the whole verilog code 

#read from the .json config to get the  link connnection
import onnx
import json
import utils
import string
from corresponding_operators import corresponding_operators_function
import re
# model=onnx.load("./test.onnx")
class constructor(object):
    output_dict=[]
    input_dict=[]#全部都是input,是列表
    input_diff=[]#删除重复元素的input list
    wire_dict=[]
    only_output_dict=[]
    
    WIDTH_IN=[]
    WIDTH_OUT=[]#存放了所有的in位宽,与输入信号对应
    RESULT_STRING=[]#存放了所有的out位宽,与输出信号对应
    VALID_IN={}#存放所有的输入信号,是列表的字典
    VALID_OUT={}
    unique_list=[]
    top_module_address="./autotrans_spec_1.0/top module.v"

    def __init__(self) -> None:
        pass
    def simpleDiff(self,input_dict,unique_list):
        '''简单对input去重,因为可能有同个输入输入给多个模块'''
        record=[]
        unique_list_firstStep=[]

        for x in input_dict:
            if x not in unique_list_firstStep:
                unique_list_firstStep.append(x)
        print(unique_list_firstStep)
        #改变去重方式为直接查看变量名,一样的话不管位宽在表示上是32 * 128 * 768和32 * 768 * 128都是同一个变量
        for  index_unique_list,y in enumerate(unique_list_firstStep):
            for index_z,z in enumerate(unique_list_firstStep[index_unique_list+1:],start=index_unique_list+1):
                if y.split("]")  [-1]==z.split("]")  [-1]:
                    record.append(index_z)
        #record记录下所有重复的序号,不在这个序号列表里的才append进unique_list
  
        for index,x in enumerate(unique_list_firstStep):
            if index not in record:
                unique_list.append(x)
    
    def diff_To_Find_Input_Output_Wire_Signal(self,input_diff,wire_dict,only_output_dict,output_dict,unique_list):
        '''筛查去掉input和output重复的信号,并作为wire,unique list为简单去重后的input列表'''
        
        for item_out in output_dict:
            flag=0
            for item_in in unique_list:
                if(item_in.split("]")   [-1]     ==    item_out.split("]")  [-1] ):
                    flag=1
            if flag ==1:
                wire_dict.append('wire'+"\t"+item_out)
            else:
                only_output_dict.append('output'+"\t"+item_out)


        for index,element_in in enumerate(unique_list):
            flag=0#flag等于0表示没有和他一样的
            for element_out in output_dict:
                if(element_in.split("]")   [-1]     ==    element_out.split("]")  [-1] ):
                    flag=1
            if(flag==0):
                input_diff.append(unique_list[index])

    def generateInputAndOutputAndWire(self,data,output_dict,input_dict,WIDTH_IN,WIDTH_OUT):#wire_dict,only_output_dict直接作为成员变量操作,不加到参数列表里
        '''将所有输入输出信号加上wire/input/output和对应的位宽,修改建议是把id是最后的使能信号的输出读出来作为output,其余作为wire'''
        for data_information_dict in data:#顺序遍历输出字典
            for i in range(len(data_information_dict["output"])):
                output_dict.append(data_information_dict["output"][i])
        for index_1,item_out in enumerate(output_dict):
                output_dict[index_1]="{}".format(WIDTH_OUT[index_1])+item_out.translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_")

        


        for data_information_dict in data:#顺序遍历输入字典
            for i in range(len(data_information_dict["input"])):
                input_dict.append(data_information_dict["input"][i])
        for index,item_in in enumerate(input_dict):
            input_dict[index]="input"+"\t"+"{}".format(WIDTH_IN[index])+item_in.translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_")
        #注意一定要加完width之后才能去去除相同元素的操作                  


        self.simpleDiff(self.input_dict,self.unique_list)#简单去除相同元素
        
        self.diff_To_Find_Input_Output_Wire_Signal(self.input_diff,self.wire_dict,self.only_output_dict,self.output_dict,self.unique_list)

    def state_valid_signal_is_wire(self,file,key_VALID_IN_wire,key_VALID_OUT_wire):
            '''写入所有是线网的使能信号'''
            for i in key_VALID_IN_wire:
                for valid_signal in self.VALID_IN[i]:#输出其他输入使能信号,全部为wire信号
                        file.write('wire'+'\t'+valid_signal+";"+'\n')
            for i in key_VALID_OUT_wire:            
                for valid_signal in self.VALID_OUT[i]:#输出其他output使能信号,全部为wire信号
                        file.write('wire'+'\t'+valid_signal+";"+'\n')
        
    def create_middle_signal_connection(self,file,data,VALID_IN,VALID_OUT,key_VALID_IN_list,key_VALID_OUT_list,Opid_Valid_Input_List):
        '''使能信号连线,还有问题'''
        for data_information_dict in data:
                for topo_next_number in range(len(data_information_dict['topo']['next'])):
                    print(data_information_dict['topo']['next'][topo_next_number][0])
                    if(data_information_dict['topo']['next'][topo_next_number][0]) in key_VALID_IN_list:#对应json中算子有pre的情况
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
                                      
                if data_information_dict['topo']['pre'][0][0] not in key_VALID_OUT_list: #对应json中前几个算子的pre是没有,那要分是否是输入模块情况讨论,理论上都是输入模块无需写,实际还需要调整
                    if data_information_dict['op_id'] not in Opid_Valid_Input_List:
                        for index,thisModuleInputV in enumerate(VALID_IN[data_information_dict['op_id']]):
                                file.write("assign "+thisModuleInputV+" = 'b1 ;"+'\n') 
                      
    def getOpid_Valid_IO_List(self,Opid_Valid_Input_List,Opid_Valid_Output_List,input_diff,only_output_dict,data):
        '''拿到所有数据输入都是输入的模块(它的valid_in是input)的op_id/拿到所有数据输出都是输出的模块(它的valid_out是output)的op_id,
            通过Opid_Valid_Input_List,Opid_Valid_Output_List传出'''
        input_name=[]
        output_name=[]
        for input_diff_item in input_diff:#拿到所有输入输出的名字,存在input_name和output_name里
            input_name.append(input_diff_item.split("]")  [-1] )
        for output_diff_item in only_output_dict:
            output_name.append(output_diff_item.split("]")  [-1] )


        for data_information_dict in data:
            flag=1
            for i in range(len(data_information_dict["input"])):
                if data_information_dict["input"][i].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_") not in input_name :
                    flag=0#flag=0表示该算子有输入不在input_diff,只有算子的输入全部在input_diff里该算子的valid才是input
            if flag==1:
                Opid_Valid_Input_List.append(data_information_dict['op_id'])


        for data_information_dict in data:
            flag=1
            for i in range(len(data_information_dict["output"])):
                if data_information_dict["output"][i].translate(str.maketrans({'.': '_'})).replace("onnx::","onnx_") not in output_name:
                    flag=0#flag=0表示该算子有输入不在only_output_dict,只有算子的输入全部在only_output_dict里该算子的valid才是output
            if flag==1:
                Opid_Valid_Output_List.append(data_information_dict['op_id'])   

    def open_and_write(self,top_module_address,input_diff,wire_dict,only_output_dict,RESULT_STRING,VALID_IN,VALID_OUT,data):
        '''打开文件写入输入(使能)信号,输出(使能)信号和wire信号'''
        with open(top_module_address,'a+') as file:
            print(only_output_dict)
            print(wire_dict)
            file.write('module top_module(\n')
            file.write('input clk_p,\n')
            file.write('input rst_n,\n')
            #input,output,wire变量定义
            Opid_Valid_Input_List=[]
            Opid_Valid_Output_List=[]
            

            key_VALID_IN_list=VALID_IN.keys()
            key_VALID_OUT_list=VALID_OUT.keys()
          
     
            self.getOpid_Valid_IO_List(Opid_Valid_Input_List,Opid_Valid_Output_List,input_diff,only_output_dict,data)
          



            for opid in Opid_Valid_Input_List:
                for valid_signal_as_input in VALID_IN[opid]:#写入input_valid信号
                    file.write('input'+'\t'+valid_signal_as_input+","+'\n')


            for str_in in input_diff: #写入所有数据输入信号
                file.write(str_in+','+"\n")


            for opid in Opid_Valid_Output_List:
                for valid_signal_as_output in VALID_OUT[opid]:#写入output_valid信号
                    file.write('output'+'\t'+valid_signal_as_output+","+'\n')


            for str_output in only_output_dict:#写入所有数据输出信号
                if(str_output==only_output_dict[len(only_output_dict)-1]):
                    file.write(str_output+'\n'+');'+'\n')
                else:
                    file.write(str_output+','+'\n')


            for str_out in wire_dict:
                file.write(str_out+";"+"\n")

            #分输入/输出获得所有其他的opid(输入id刨掉Opid_Valid_Input_List,输出id刨掉Opid_Valid_Output_List),他们的输入/输出valid均为wire
            key_VALID_IN_wire=[]
            key_VALID_OUT_wire=[]
            for id in key_VALID_IN_list:
                if id not in Opid_Valid_Input_List:
                    key_VALID_IN_wire.append(id)
            for id in key_VALID_OUT_list:
                if id not in Opid_Valid_Output_List:
                    key_VALID_OUT_wire.append(id)

            self.state_valid_signal_is_wire(file,key_VALID_IN_wire,key_VALID_OUT_wire)


            file.write("\n")#接下来生成具体电路了

            #使能连线
            self.create_middle_signal_connection(file,data,self.VALID_IN,self.VALID_OUT,key_VALID_IN_list,key_VALID_OUT_list,Opid_Valid_Input_List)
            #模块调用
            for content in RESULT_STRING:
                file.write(content)     
            file.write("\n")
            file.write('endmodule')
                      


    def generateTopModule(self):
        ''' 生成顶层模块 '''
        with open('autotrans_spec_1.0/test.json') as f:
            data=json.load(f)

        for  index,data_information_dict in enumerate(data):
            corresponding_operators_function(data_information_dict,self.RESULT_STRING,
                                             self.WIDTH_IN,self.WIDTH_OUT,
                                             self.VALID_IN,self.VALID_OUT)

        self.generateInputAndOutputAndWire(data,self.output_dict,self.input_dict,
                                                  self.WIDTH_IN,self.WIDTH_OUT)
        # #automation    

        self.open_and_write(self.top_module_address,
                            self.input_diff,self.wire_dict,self.only_output_dict,self.RESULT_STRING,
                            self.VALID_IN,self.VALID_OUT,
                            data)
       
test=constructor()
test.generateTopModule()