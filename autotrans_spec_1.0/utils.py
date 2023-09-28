import json
from configparser import ConfigParser


def opset_analyze(opset):
    # Opset Mode Example : ['Add_1', 'Pow', 'Add_2'] 
    op_list = {}
    for op in opset:
        op_type = None
        if '_' in op:
            op_type = op.split('_')[0]
        else:
            op_type = op
        
        if op_type in op_list.keys():
            op_list[op_type] = op_list[op_type] + 1
        else:
            op_list.update({op_type : 1})
        
        op_sort = sorted(op_list.items(), key=lambda x: x[1])
    return op_sort


def flowset_make(flowset):
    # Flowset Mode Example : ['Add_1-Mul', 'Add_1-Erf']
    flow_list = []
    for edge in flowset:
        flow_list.append((edge.split('-')[0],edge.split('-')[1]))
    return flow_list


def read_pattern_conf(conf_file):
    conf = ConfigParser()
    conf.read(conf_file)

    pat_dic = {}
    # secs = conf.sections()
    for sec in conf.sections():
        pat_dic.update({sec:{}})
        for option in conf.options(sec):
            elestr = conf.get(sec, option)
            elelist = elestr.split(', ')
            
            # Flowset make Only
            if option == 'flowset':
                elelist = flowset_make(elelist)
            
            # Sign with only ONE element
            if option == 'sign':
                elelist = elelist[0]

            pat_dic[sec].update({option:elelist})

    return pat_dic


def make_target_DAG(target):

    pat_dag = []
    for op in target['opset']:
        op_type = op.split('_')[0]
        op_info = { 'name':op, 
                    'type':op_type, 
                    'pre':[], 
                    'next':[]}
        for flow in target['flowset']:
            if op == flow[0]:
                op_info['next'].append(flow[1])
            if op == flow[1]:
                op_info['pre'].append(flow[0])
        pat_dag.append(op_info)

    return pat_dag


def step_contract(graph, uni_sign='UNI'):
    ''' Stepwise Contraction Algorithm for Graph Analysis. '''
    verts = set(graph['opset'])
    edges = set(graph['flowset'])
    keyop = graph['sign']

    if keyop not in verts:
        return
    
    edges_del = edges.copy()
    uni_set = set()
    for edge in edges:
        if keyop == edge[0]:
            edges_del.remove(edge)
            uni_set.add(edge[1])
            continue
        if keyop == edge[1]:
            edges_del.remove(edge)
            uni_set.add(edge[0])
    # print('Uni_set:', uni_set)

    verts_cont = verts
    verts_cont.remove(keyop)
    for vt in uni_set:
        verts_cont.remove(vt)
    verts_cont.add(uni_sign)
    
    edges_cont = set()
    for edge in edges_del:
        if edge[0] in uni_set and edge[1] not in uni_set:
            edges_cont.add((uni_sign, edge[1]))
            continue
        if edge[0] not in uni_set and edge[1] in uni_set:
            edges_cont.add((edge[0], uni_sign))
            continue
        if edge[0] not in uni_set and edge[1] not in uni_set:
            edges_cont.add(edge)
    
    return {'opset':verts_cont, 'flowset':edges_cont, 'sign':uni_sign}


def region_analyze(pattern):
    ''' Analyze Graph Region of Pattern from 'KeyOp'. '''
    count = 0
    graph = pattern
    while graph['flowset']:
        # print(graph)
        graph = step_contract(graph)
        count = count + 1
    return count


if __name__ == '__main__':
    # json_path = 'optimizer/test.json'
    # json_path_new = 'optimizer/test_rc.json'
    # op_clear = remove_const(json_path)
    # with open(json_path_new, 'w') as f:
    #     json.dump(op_clear, f, indent=4)

    
    
    
    config_file = 'optimizer/pattern.ini'
    print(read_pattern_conf(config_file))
    pat_dic = read_pattern_conf(config_file)

    # print(step_contract(pat_dic['gelu']))
    # print(region_analyze(pat_dic['gelu']))

    # opset = pat_dic['gelu']['opset']
    # print(opset)
    # opsta = opset_analyze(opset)
    # print(opsta)

    # flowset = pat_dic['gelu']['flowset']
    # print(flowset)
    # flowsort = flowset_make(flowset)
    # print(flowsort)
