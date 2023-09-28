import onnx
import json

from utils import read_pattern_conf
from utils import make_target_DAG, region_analyze

class Optimizer:
    ''' Onnx Model Optimizer'''

    def __init__(self, model_parsed, config):
        self.network = None
        with open(model_parsed, 'r') as f:
            self.network = json.load(f)
        self.config = config
        self.dag = self.construct_DAG()
        return
    
    def remove_const(self):
        op_list = self.network
        op_list_clear = []
        for op in op_list:
            if op['op_type'] != 'Constant':
                op_list_clear.append(op)
        return op_list_clear

    def construct_DAG(self, dag_base=None, Dump=False, dag_path='optimizer/dag.json'):
        ''' Construct Directed Acyclic Graph with topology information. '''
        
        if dag_base: # custom
            dag = dag_base
        else:  # default
            dag = self.network
        
        for op in dag:
            op['topo'].update({'pre':[], 'next':[]})
        
        for ind, op1 in enumerate(dag): # Forward Traversal
            op1_ins = op1['topo']['input']
            for op1_in in op1_ins:
                for search_ind in range(ind, -1, -1): # Backward Search
                    if op1_in in dag[search_ind]['topo']['output']:
                        dag[ind]['topo']['pre'].append((dag[search_ind]['op_id'], dag[search_ind]['op_type']))
                        dag[search_ind]['topo']['next'].append((dag[ind]['op_id'], dag[ind]['op_type']))
                        break

        if Dump:   
            with open(dag_path, 'w') as f:
                json.dump(dag, f, indent=4)

        return dag



    def node_expand(self, node):
        neighbors = [node]
        for op_n in [*node['topo']['pre'], *node['topo']['next']]:
            neighbors.append(self.dag[op_n[0]-1])
        return neighbors

    def graph_expand(self, node, stepnum):
        node_list = [node]
        for _ in range(stepnum):
            node_expand = []
            for n in node_list:
                for nb in self.node_expand(n):
                    if nb not in node_expand:
                        node_expand.append(nb)
            # print(self.node_expand(n))
            node_list = node_expand
        return node_list
    
    def extract_subdomain(self, pattern):
        region_size = region_analyze(pattern)
        key_type = pattern['sign'].split('_')[0]
        subdomains = []

        for vert in self.dag:
            if vert['op_type'] == key_type: # Key Match
                subdomains.append(self.graph_expand(vert, region_size))
        
        return subdomains



    def check_equal_once(self, node, node_target):
        ''' Check equalilty by in-out nodes (type & quantity) '''

        equal = True

        # Compare pre nodes
        if node_target['pre']:
            pre_tar = {}
            for pnode in node_target['pre']:
                ty = pnode.split('_')[0]
                if ty in pre_tar.keys():
                    pre_tar[ty] = pre_tar[ty] + 1
                else:
                    pre_tar.update({ty:1})
            
            pre = {}
            for pnode in node['topo']['pre']:
                ty = pnode[1]
                if ty in pre.keys():
                    pre[ty] = pre[ty] + 1
                else:
                    pre.update({ty:1})
            
            # Constant Unawareness
            pre.pop('Constant', None)

            if pre != pre_tar:
                dif = 0
                for key in pre.keys():
                    if key not in pre_tar.keys():
                        dif = dif + pre[key]
                    else:
                        dif = dif + (pre[key]-pre_tar[key])
                
                uni = 0
                for key_tar in pre_tar.keys():
                    if 'Uni' in key_tar:
                        uni = uni + pre_tar[key_tar]

                if dif != uni:
                    equal = False
                
        
        # Compare post nodes
        if node_target['next']:
            next_tar = {}
            for pnode in node_target['next']:
                ty = pnode.split('_')[0]
                if ty in next_tar.keys():
                    next_tar[ty] = next_tar[ty] + 1
                else:
                    next_tar.update({ty:1})
            
            next = {}
            for pnode in node['topo']['next']:
                ty = pnode[1]
                if ty in next.keys():
                    next[ty] = next[ty] + 1
                else:
                    next.update({ty:1})
            
            # Constant Unawareness
            next.pop('Constant', None)

            if next != next_tar:
                dif = 0
                for key in next.keys():
                    if key not in next_tar.keys():
                        dif = dif + next[key]
                    else:
                        dif = dif + (next[key]-next_tar[key])
                
                uni = 0
                for key_tar in next_tar.keys():
                    if 'Uni' in key_tar:
                        uni = uni + next_tar[key_tar]

                if dif != uni:
                    equal = False
        

        if equal:
            node['topo'].update({'match':node_target['name']})


        return equal


    def check_equal_backward(self, subdomain, dag_tar, node_st, node_st_tar):
        ''' Check if target pattern is in subdomain. (NOT USED ANYMORE) '''

        if self.check_equal_once(node_st, node_st_tar):
                # node expand backward
                pre_itr = []
                for op_n in node_st['topo']['pre']:
                    for s_n in subdomain:
                        if s_n['op_id'] == op_n[0] and s_n['op_type'] != 'Constant':
                            pre_itr.append(s_n)
                            break
                
                pre_itr_tar = []
                for op_n in node_st_tar['pre']:
                    for s_n in dag_tar:
                        if s_n['name'] == op_n:
                            pre_itr_tar.append(s_n)
                            break
                
                # print(pre_itr)
                # print(pre_itr_tar)

                # Recursive Traversal
                # if pre_itr_tar:
                #     if len(pre_itr_tar) != len(pre_itr):
                #         return False

                match_list_pre = []
                for nd_tar in pre_itr_tar:
                    
                    cand_list = []
                    for nd_pre in pre_itr:
                        if nd_tar['type'] == nd_pre['op_type']:
                            if nd_pre not in match_list_pre:
                                cand_list.append(nd_pre)
                    
                    for nd_cd in cand_list:
                        if self.check_equal_backward(subdomain, dag_tar, nd_cd, nd_tar):
                            match_list_pre.append(nd_cd)
                            break
                
                if len(match_list_pre) != len(pre_itr_tar):
                    return False
                
        else:
            return False

        return True


    def check_equal_forward(self, subdomain, dag_tar, node_st, node_st_tar):
        ''' Check if target pattern is in subdomain. (NOT USED ANYMORE) '''

        if self.check_equal_once(node_st, node_st_tar):
                # node expand forward
                next_itr = []
                for op_n in node_st['topo']['next']:
                    for s_n in subdomain:
                        if s_n['op_id'] == op_n[0] and s_n['op_type'] != 'Constant':
                            next_itr.append(s_n)
                            break
                
                next_itr_tar = []
                for op_n in node_st_tar['next']:
                    for s_n in dag_tar:
                        if s_n['name'] == op_n:
                            next_itr_tar.append(s_n)
                            break
                
                # print(next_itr)
                # print(next_itr_tar)

                # Recursive Traversal
                # if next_itr_tar:
                #     if len(next_itr_tar) != len(next_itr):
                #         return False

                match_list_next = []
                for nd_tar in next_itr_tar:
                    
                    cand_list = []
                    for nd_next in next_itr:
                        if nd_tar['type'] == nd_next['op_type']:
                            if nd_next not in match_list_next:
                                cand_list.append(nd_next)
                    
                    for nd_cd in cand_list:
                        if self.check_equal_forward(subdomain, dag_tar, nd_cd, nd_tar):
                            match_list_next.append(nd_cd)
                            break
                
                if len(match_list_next) != len(next_itr_tar):
                    return False

        else:
            return False

        return True


    def check_equal_pattern(self, subdomain, dag_tar, node_st, node_st_tar):
        ''' Check if target pattern is in subdomain. '''
        
        # Prevent repeated traversal
        if 'match' in node_st['topo'].keys():
            if node_st['topo']['match'] == node_st_tar['name']:
                return True

        if self.check_equal_once(node_st, node_st_tar):
                # node expand backward
                pre_itr = []
                for op_n in node_st['topo']['pre']:
                    for s_n in subdomain:
                        if s_n['op_id'] == op_n[0] and s_n['op_type'] != 'Constant':
                            pre_itr.append(s_n)
                            break
                
                pre_itr_tar = []
                for op_n in node_st_tar['pre']:
                    for s_n in dag_tar:
                        if s_n['name'] == op_n:
                            pre_itr_tar.append(s_n)
                            break
                
                # print(pre_itr)
                # print(pre_itr_tar)

                # Recursive Traversal
                # if pre_itr_tar:
                #     if len(pre_itr_tar) != len(pre_itr):
                #         return False

                match_list_pre = []
                for nd_tar in pre_itr_tar:
                    
                    cand_list = []
                    for nd_pre in pre_itr:
                        if nd_tar['type'] == nd_pre['op_type'] or 'Uni' in nd_tar['type']:
                            if nd_pre not in match_list_pre:
                                cand_list.append(nd_pre)
                    
                    for nd_cd in cand_list:
                        if self.check_equal_pattern(subdomain, dag_tar, nd_cd, nd_tar):
                            match_list_pre.append(nd_cd)
                            break
                

                if len(match_list_pre) != len(pre_itr_tar):
                    # Remove 'Match' flag
                    node_st['topo'].pop('match', None)
                    return False
                
                # node expand forward
                next_itr = []
                for op_n in node_st['topo']['next']:
                    for s_n in subdomain:
                        if s_n['op_id'] == op_n[0] and s_n['op_type'] != 'Constant':
                            next_itr.append(s_n)
                            break
                
                next_itr_tar = []
                for op_n in node_st_tar['next']:
                    for s_n in dag_tar:
                        if s_n['name'] == op_n:
                            next_itr_tar.append(s_n)
                            break
                
                # print(next_itr)
                # print(next_itr_tar)

                # Recursive Traversal
                # if next_itr_tar:
                #     if len(next_itr_tar) != len(next_itr):
                #         return False

                match_list_next = []
                for nd_tar in next_itr_tar:
                    
                    cand_list = []
                    for nd_next in next_itr:
                        if nd_tar['type'] == nd_next['op_type'] or 'Uni' in nd_tar['type']:
                            if nd_next not in match_list_next:
                                cand_list.append(nd_next)
                    
                    for nd_cd in cand_list:
                        if self.check_equal_pattern(subdomain, dag_tar, nd_cd, nd_tar):
                            match_list_next.append(nd_cd)
                            break
                
                if len(match_list_next) != len(next_itr_tar):
                    # Remove 'Match' flag
                    node_st['topo'].pop('match', None)
                    return False

        else:
            return False

        return True


    def pattern_mining(self, pattern):
        ''' Detect matched pattern and return corresponding dictionary. '''
        
        matching_dic = {}

        # Detect subdomains with 'key_op'
        subdomains = self.extract_subdomain(pattern)

        # Make DAG of target pattern
        dag_tar = make_target_DAG(pattern)

        # Compare target pattern with every subdomain
        for subdomain in subdomains:
            # Determine the Starting node
            node_st_list = []
            for node in subdomain:
                if node['op_type'] == pattern['sign'].split('_')[0]:
                    node_st_list.append(node)
            
            for node in dag_tar:
                if node['name'] == pattern['sign']:
                    node_tar = node
            
            # check pattern
            for node_st in node_st_list:
                    if self.check_equal_pattern(subdomain, dag_tar, node_st, node_tar):
                        if node_st['op_id'] not in matching_dic.keys():
                            matching_dic.update({node_st['op_id']:subdomain})
                        break
                        

        return matching_dic


    def remove_mislabel(self, opname, opid_list, pattern):
        ''' Remove the mislabel node. (future work) '''
        # print(opname, opid_list)
        opid_list = [max(opid_list)]
        return opid_list


    def matchGranu(self, Dump=False, dump_path='optimizer/dag_match.json'):
        ''' Replace matched subgraph with self-granularity. '''
        dag_opt = self.dag

        pat_dic = read_pattern_conf(self.config)

        del_list = []
        newop_list = []
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
        for pname, pattern in pat_dic.items():
            # Detect matched pattern
            matching_dic = self.pattern_mining(pattern)

            for _, subdomain in enumerate(matching_dic.values()):
                # Construct to-be-deleted dic (name:op_id)
                del_dic = {}
                for node in subdomain:
                    if 'match' in node['topo'].keys():
                        if node['topo']['match'] in pattern['opset']:
                            if node['topo']['match'] not in del_dic.keys():
                                del_dic.update({node['topo']['match']:[node['op_id']]})
                            else:
                                del_dic[node['topo']['match']].append(node['op_id'])

                # Mislabeling Detection
                for opname, opid in del_dic.items():
                    if len(opid) > 1:
                       del_dic[opname] = self.remove_mislabel(opname, opid, pattern)
                
                # to-delete list
                del_list_tmp = []
                for opname, opid in del_dic.items():
                    if 'Uni' not in opname:
                        del_list_tmp.append(opid[0])
                del_list.extend(del_list_tmp)

                # Get boundary information
                # Generate self-granularity nodes
                new_op = {"op_id":None,
                          "op_type":pname,
                          "topo":{
                            'name':None,
                            'input':None,
                            'output':None,
                            'pre':None,
                            'next':None
                          }}
                
                op_id = min(del_list_tmp)
                op_name = pname + '_' + str(_)

                op_input = []
                op_output = []
                op_pre = []
                op_next = []
                for opname, [opid] in del_dic.items():
                    if 'UniB' in opname:
                        next_messes = []
                        for next_nd in dag_opt[opid-1]['topo']['next']:
                            if [next_nd[0]] in del_dic.values():
                                next_messes.append(next_nd)
                                if dag_opt[opid-1]['topo']['output'][0] not in op_input:
                                    op_input.append(dag_opt[opid-1]['topo']['output'][0]) # for everynode: just one output wire                                
                        op_pre.append((opid, dag_opt[opid-1]['op_type']))
                    
                        # clean up interface mess
                        id_insert = dag_opt[opid-1]['topo']['next'].index(next_messes[0])
                        dag_opt[opid-1]['topo']['next'].insert(id_insert, (op_id, pname))
                        for next_mess in next_messes:
                            dag_opt[opid-1]['topo']['next'].remove(next_mess)
                        # print(dag_opt[opid-1]['topo']['next'])


                    if 'UniE' in opname:
                        pre_messes = []
                        for poi, pre_nd in enumerate(dag_opt[opid-1]['topo']['pre']):
                            if [pre_nd[0]] in del_dic.values():
                                pre_messes.append(pre_nd)
                                if dag_opt[opid-1]['topo']['input'][poi] not in op_output:
                                    op_output.append(dag_opt[opid-1]['topo']['input'][poi]) # for everynode: multiple input wire 
                        op_next.append((opid, dag_opt[opid-1]['op_type']))

                        # clean up interface mess
                        id_insert = dag_opt[opid-1]['topo']['pre'].index(pre_messes[0])
                        dag_opt[opid-1]['topo']['pre'].insert(id_insert, (op_id, pname))
                        for pre_mess in pre_messes:
                            dag_opt[opid-1]['topo']['pre'].remove(pre_mess)
                        # print(dag_opt[opid-1]['topo']['pre'])


                new_op['op_id'] = op_id
                new_op['topo']['name'] = op_name
                new_op['topo']['input'] = op_input
                new_op['topo']['output'] = op_output
                new_op['topo']['pre'] = op_pre
                new_op['topo']['next'] = op_next
                newop_list.append(new_op)
        
        
        # Delete old nodes
        del_list.sort()
        # print(del_list)

        for i in range(len(del_list)):
            del dag_opt[del_list[i]-1 -i]
            # print('Done {}/{}'.format(i+1, len(del_list)))


        # New nodes add-in
        insert_list = []
        newop_list.sort(key=lambda x: x['op_id'])
    
        index_newop = 0
        for i in range(len(dag_opt)-1):
            if dag_opt[i]['op_id'] > newop_list[index_newop]['op_id']:
                insert_list.append(i)
                index_newop = index_newop + 1
                if index_newop == len(newop_list):
                    break
        if index_newop < len(newop_list):
            for i in range(len(newop_list) - index_newop):
                insert_list.append(len(dag_opt)+i)
        # print(insert_list)

        for i in range(len(newop_list)):
            dag_opt.insert(insert_list[i]+i, newop_list[i])

        # Resort DAG


        if Dump:   
            with open(dump_path, 'w') as f:
                json.dump(dag_opt, f, indent=4)

        return dag_opt



CONFIG_FILE = 'optimizer/pattern.ini'


if __name__ == '__main__':
    optimizer = Optimizer(
        model_parsed='optimizer/test.json',
        config=CONFIG_FILE
    )

    # dag = optimizer.construct_DAG()
    # dag = optimizer.construct_DAG(Dump=True)
    # print([x['op_id'] for x in optimizer.node_expand(dag[547])])
    # print([x['op_id'] for x in optimizer.graph_expand(dag[547], 2)])


    # pat_dic = read_pattern_conf(CONFIG_FILE)
    # pattern = pat_dic['gelu']
    # pattern = pat_dic['layernorm']
    # print(pattern)
    # print(len(optimizer.extract_subdomain(pattern)))
    
    # subdomain = optimizer.extract_subdomain(pattern)[0]
    # node1 = optimizer.extract_subdomain(pattern)[0][4]
    # print(node1)

    # dag_tar = make_target_DAG(pattern)
    # node2 = make_target_DAG(pattern)[0]
    # print(node2)

    # print(optimizer.check_equal_once(node1, node2))

    # print(optimizer.check_equal_backward(subdomain, dag_tar, node1, node2))
    # print(optimizer.check_equal_forward(subdomain, dag_tar, node1, node2))
    # print(optimizer.check_equal_pattern(subdomain, dag_tar, node1, node2))

    # print(optimizer.pattern_mining(pattern)[59])
    # print(len(optimizer.pattern_mining(pattern)))

    optimizer.matchGranu(Dump=True)