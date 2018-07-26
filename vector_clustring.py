import scipy
import numpy as np
import scipy.spatial.distance as distance
import sys,re
from matplotlib.pyplot import show
from scipy.cluster.hierarchy import linkage, dendrogram
from sklearn.cluster import KMeans
import pqkmeans
import pandas as pd

def array_add(l1,l2,c):
    length = len(l1)
    for i in range(length):
        if(l2[i] != -1):
            l1[i] = l1[i] + l2[i]
            c[i]+=1

argvs = sys.argv
filename = argvs[1]
data = []
header = []
flag = 0
f = open(filename)
dlength = 0
###mkdataset
for line in f.readlines():
    dlength+=1
    line = line.strip()
    data_list = [float(s) for s in line.split()[5:]]
    if(flag==0):
        length = len(data_list)
        data.append(np.array(data_list))
        header.append(line)
        print(length)
        flag = 1
    if(len(data_list)!=length):
        print(dlength)
        print(len(line.split()))
        dlength-=1
    else:
        data.append(np.array(data_list))
        header.append(line)
f.close()
print(length)
clu0 = np.array([0.]*length)
clu1 = np.array([0.]*length)
clu2 = np.array([0.]*length)
clu3 = np.array([0.]*length)

count0 = np.array([0.]*length)
count1 = np.array([0.]*length)
count2 = np.array([0.]*length)
count3 = np.array([0.]*length)
###
###clustering
encoder = pqkmeans.encoder.PQEncoder(num_subdim=4, Ks=256)
encoder.fit(np.array(data[:1000]))
X_pqcode = encoder.transform(np.array(data))
kmeans = pqkmeans.clustering.PQKMeans(encoder=encoder, k=4)
pred = kmeans.fit_predict(X_pqcode)


for (i,j) in zip(pred,data):
    if i == 0:
        array_add(clu0,j,count0)
    elif i == 1:
        array_add(clu1,j,count1)
    elif i == 2:
        array_add(clu2,j,count2)
    elif i == 3:
        array_add(clu3,j,count3)

num = 0
f = open('clu0.txt','w')
for i in range(length):
    string = str(num) + " " + str(clu0[i]/count0[i]) + " " + str(int(count0[i])) + "\n"
    f.write(string)
    num += 1
f.close()

num=0
f = open('clu1.txt','w')
for i in range(length):
    string = str(num) + " " + str(clu1[i]/count1[i]) + " " + str(int(count1[i])) + "\n"
    f.write(string)
    num += 1
f.close()

num = 0
f = open('clu2.txt','w')
for i in range(length):
    string = str(str(num) + " " + clu2[i]/count2[i]) + " " + str(int(count2[i])) + "\n"
    f.write(string)
    num += 1
f.close()

num = 0
f = open('clu3.txt','w')
for i in range(length):
    string = str(str(num) + " " + clu3[i]/count3[i]) + " " + str(int(count3[i])) + "\n"
    f.write(string)
    num += 1
f.close()
for (i,j)in zip(pred,header):
    string = j + "\n"
    if i == 0:
        f.write(string)
    elif i == 1:
        g.write(string)
    elif i == 2:
        h.write(string)
    elif i == 3:
        l.write(string)
f.close()
g.close()
h.close()
l.close()
