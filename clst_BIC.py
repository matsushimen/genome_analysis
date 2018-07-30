import scipy
import numpy as np
import sys,re
from scipy.cluster.hierarchy import linkage, dendrogram
import pqkmeans

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
clu = [ np.array([0.]*length) for i in range(clst_num)]
count = [ np.array([0.]*length) for i in range(clst_num)]
###clustering
encoder = pqkmeans.encoder.PQEncoder(num_subdim=4, Ks=256)
encoder.fit(np.array(data[:1000]))
X_pqcode = encoder.transform(np.array(data))
for clst_num in range(2,10)
    kmeans = pqkmeans.clustering.PQKMeans(encoder=encoder, k=clst_num)
    pred = kmeans.fit_predict(X_pqcode)
    sse = kmeans.inertia_#誤差平方和
    n = dlength
    BIC = n*np.log(sse/n)+length*np.log(n)
    print("k = %d BIC = %.3f"%(clst_num, BIC))

