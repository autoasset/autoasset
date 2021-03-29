import os

def BFS_Dir(path, dirCallback=None, fileCallback=None):
    queue = []
    queue.append(path);
    while len(queue) > 0:
        tmp = queue.pop(0)
        if (os.path.isdir(tmp)):
            for item in os.listdir(tmp):
                if not item.startswith('.'):
                    queue.append(os.path.join(tmp, item))
            if dirCallback:
                dirCallback(tmp)
        elif (os.path.isfile(tmp)):
            if fileCallback:
                fileCallback(tmp)

def dirCallback(path):
    print('dir:' + path)
    return

def license(path: str):
    with open(path, 'rb') as reader:
        return reader.readlines()

def fileCallback(path: str, license: bytearray = license(path=os.getcwd() + '/license')):
    if path.endswith('.DS_Store') or path.endswith('Package.swift'):
        return

    print('file:' + path)

    with open(path, 'rb') as reader:
        lines = reader.readlines()

        index: int = 0
        for i in range(0, len(lines)):
            line = lines[i].decode(encoding='utf-8').replace(' ', '')
            if line.startswith('//'):
                continue
            if line == '\n':
                continue
            index = i   
            break

        lines = license + [b'\n'] + lines[index:]
        with open(path, 'wb') as writer:
            writer.writelines(lines)


BFS_Dir(os.getcwd() + '/autoasset/Sources', dirCallback=dirCallback,fileCallback=fileCallback)
