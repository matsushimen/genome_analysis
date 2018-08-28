import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import sys,re,copy


args = sys.argv
outname = args[1]
seqfile = args[2:]
file_num = 0
x = np.array([])
sc = np.array([])
for files in seqfile:
    f = open(files)
    x_tmp = np.array([])
    score_tmp = np.array([])
    for line in f.readlines():
        line = line.strip()
        x_tmp = np.append(x_tmp, [int(line.split()[0])])
        #print(float(line.split()[1]))
        score_tmp = np.append(score_tmp, [float(line.split()[1])])
    
    f.close()
    x = np.append(x,copy.copy(x_tmp),axis=0)
    sc = np.append(sc, copy.copy(score_tmp),axis=0)

score_max = int(sc.max()+1)
lgt = (x.max()+1)/2

number = x.reshape((len(seqfile),lgt*2))
score = sc.reshape((len(seqfile),lgt*2))

fig = plt.figure()
leftside = fig.add_subplot(1,2,1)
plt.axis(xmin=-lgt,xmax=0,ymin=0,ymax=score_max)
for i in range(len(seqfile)):
    labelname = "cluster" + str(i)
    leftside.plot(number[i]-lgt,score[i],label=labelname)
   

rightside = fig.add_subplot(1,2,2)
rightside.tick_params(labelleft="off")
plt.axis(xmin=0,xmax=lgt,ymin=0,ymax=score_max)
for i in range(len(seqfile)):
    labelname = "cluster" + str(i)
    rightside.plot(number[i]-lgt,score[i],label=labelname)

rightside.legend()
plt.savefig(outname, transparent=True)