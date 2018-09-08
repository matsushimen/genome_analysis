import numpy as np
import matplotlib.pyplot as plt
import sys,re

args = sys.argv
savename = args[1]
hists = args[2:]
open_f = 0
labels = []
means = {}
meansquare = {}
number = {}
#make dictionary
for hist in hists:
    f = open(hist)
    for line in f.readlines():
        line.strip()
        if(not re.match("[0-9]",line)):
            continue
        data = line.split()
        
        if(open_f == 0):
            labels.append(data[0])
            print (data[0])
            means[data[0]] = float(data[1])*int(data[3])
            meansquare[data[0]] = (float(data[2])+means[data[0]]*means[data[0]])*int(data[3])
            number[data[0]] = int(data[3])
            
        else:
            means[data[0]] += float(data[1])*int(data[3])
            meansquare[data[0]] += (float(data[2])+means[data[0]]*means[data[0]])*int(data[3])
            number[data[0]] += int(data[3])

    open_f = 1
    f.close()

mean_values = []
variance_values = []
number_values = []

#append to lists
for name in labels:
    mean_values.append(means[name]/number[name])
    variance_values.append((meansquare[name]-means[name]*means[name])/(number[name]-1))
    number_values.append(number[name])

mean_values = np.array(mean_values)
variance_values = np.array(variance_values)
number_values = np.array(number_values)

plt.figure()
plt.bar(range(len(labels)), mean_values)
plt.savefig(savename,transparent=True,yerr=np.sqrt(variance_values/number_values))