
regex='(?:START_JSON)' + '(?:\n|\r\n?)*' + '((.*(?:\n|\r\n?))*?)' + '(?:STOP_JSON)'
if __name__ == '__main__':
    import sys    

    if len(sys.argv) != 2:
        print('usage: ' + str(sys.argv[0]) + " <file> <regex>")
    else:
        import re
        with open(sys.argv[1],'r') as file:
            file_txt = file.read()
            match = re.finditer(regex,file_txt)
            for v in match:
                print(v)
                print(v.group(0))
                print(v.group(1))

