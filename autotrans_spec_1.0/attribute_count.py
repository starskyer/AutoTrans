import json

def optype_count():
    with open("./autotrans_spec_1.0/high_level_IR_wi_comment.json", "r") as file:
        content_list = json.load(file)
        optype_list = []
        for i in range(len(content_list)):
            optype = content_list[i]["op_type"]
            if optype not in optype_list:
                optype_list.append(optype)
        print(optype_list)
        file.close()

def data_format_count():
    with open("./autotrans_spec_1.0/high_level_IR_wi_comment.json", "r") as file:
        content_list = json.load(file)
        data_list = []
        for i in range(len(content_list)):
            data_format = content_list[i]["data_format"]
            for data in data_format:
                if data not in data_list:
                    data_list.append(data)
        print(data_list)
        file.close()

def main():
    data_format_count()

if __name__ == '__main__':
    main()