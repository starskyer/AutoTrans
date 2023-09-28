import json

def main():
    with open("./dag_match.json", "r") as file:
        content_list = json.load(file)
        optype_list = []
        for i in range(len(content_list)):
            optype = content_list[i]["op_type"]
            if optype not in optype_list:
                optype_list.append(optype)
        print(optype_list)
        file.close()

if __name__ == '__main__':
    main()