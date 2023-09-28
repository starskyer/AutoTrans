import os
import json
from configparser import ConfigParser

#def builder(mode, content):

def main():
    conf = ConfigParser()
    conf.read("./libinfo.ini")
    lib_dict = {}
    for sec in conf.sections():
        lib_dict.update({sec:{}})
        for opt in conf.options(sec):
            value = conf.get(sec, opt)
            #


    with open("./high_level_IR_wi_comment.json", "r") as file:
        content_list = json.load(file)
        for i in range(len(content_list)):
            optype = content_list[i]['optype']
            # optypes in high_level: MM, split, transpose, softmax, merge, MADD, layernorm, gelu.
            # optypes in dag_match:  Identity, Constant, Shape, Expand, Gather, Add, Layernorm, Mul, MatMul, 
            #                        Reshape, Transpose, Div, Softmax, Gelu, Gemm, Tanh, Relu
            if(optype == 'MM'):# seemingly not found

            elif(optype == 'split'):

            elif(optype == 'transpose'):

            elif(optype == 'softmax'):
                
            elif(optype == 'merge'):

            elif(optype == 'MADD'):

            elif(optype == 'layernorm'):

            elif(optype == 'gelu'):
            



if __name__ == "__main__":
    main()