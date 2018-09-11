import numpy as np
import sys,re

args = sys.argv
infile = args[1]

with open(infile) as f:
    for line in f.readlines():
        line.strip()
        data = line.split()
        score = np.mean(float(data[11:]))
        print(data[0] + " " + data[1] + " " + data[2] + " " + data[3] + " " + str(score))
