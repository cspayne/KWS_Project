import os
import os.path
from os import path
import re
import glob
import shutil

def movetofolder(list, root):
        regex = re.compile(r'(?<=\/)(.*?)(?=\/)')
        f = open(list, 'r')
        line = f.readline()
        line = line.strip('\n')
        if (path.exists(line)):
            print(line)
            subset = regex.findall(line)
            newfilepath = root + "/" + subset[0]
            shutil.move(line, newfilepath)
        for line in f:
            line = f.readline()
            line = line.strip('\n')
            if (os.path.exists(line)):
                print(line)
                subset = regex.findall(line)
                newfilepath = root + "/" + subset[0]
                shutil.move(line, newfilepath)


movetofolder("testing_set.txt", "./Project1_DS/Testing")
movetofolder("validation_set.txt", "./Project1_DS/Validation")
