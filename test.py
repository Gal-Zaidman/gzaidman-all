import os

def main():
    base = "/home/gzaidman/workspace/personal/gzaidman-all"
    #files = os.listdir(base)
    for folder, sub, files in os.walk(base):
        to_remove = []
        for s in sub:
            if s.startswith('.'):
                to_remove.append(s)
        for r in to_remove:
            sub.remove(r)
        
        for f in files:
            if f.startswith('.') == False and ' ' in f:
                newName = f.replace(' ', '-')
                os.replace(folder + '/' + f, folder + '/' + newName)

main()