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
            means[data[0]] = float(data[1])*int(data[3])
            meansquare[data[0]] = (float(data[2])+float(data[1])*float(data[1]))*int(data[3])
            number[data[0]] = int(data[3])
            
        else:
            means[data[0]] += float(data[1])*int(data[3])
            meansquare[data[0]] += (float(data[2])+float(data[1])*float(data[1]))*int(data[3])
            number[data[0]] += int(data[3])

    open_f = 1
    f.close()

mean_values = []
variance_values = []
number_values = []

#append to lists
for name in labels:
    mean_values.append(means[name]/number[name])
    variance_values.append((meansquare[name]/number[name]-(means[name]/number[name])*(means[name]/number[name])))
    number_values.append(number[name])

mean_values = np.array(mean_values)
variance_values = np.array(variance_values)
number_values = np.array(number_values)

with open(savename+".txt",mode='write') as f:
    for n,i,j,k in zip(labels,mean_values,variance_values,number_values):
        string = str(n)+" "+str(i)+" "+str(j)+" "+str(k)+"\n"
        f.write(string)


plt.figure()
plt.bar(range(len(labels)), mean_values, yerr=np.sqrt(variance_values/number_values), ecolor="red")
plt.savefig(savename,transparent=True)