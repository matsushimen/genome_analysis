
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import sys,re

args = sys.argv
matrix_file1 = args[1]
matrix_file2 = args[2]
savename = args[3]
def matrix_calc(file1,file2):
    mat_f1 = open(file1)
    mat_f2 = open(file2)
    mat1 = []
    mat2 = []
    for line in mat_f1.readlines():
        line = line.strip()
        line_s = [float(x) for x in line.split(" ")]
        mat1.append(line_s)
    mat1 = np.array(mat1)
    mat_f1.close()

    for line in mat_f2.readlines():
        line = line.strip()
        line_s = [float(x) for x in line.split(" ")]
        mat2.append(line_s)
    mat2 = np.array(mat2)
    mat_f2.close()

    size = mat1.shape[0]
    outmat = []
    for i in range(size):
        line = []
        for j in range(size):
            if(mat2[i,j]==0):
                line.append(-1)
            else:
                line.append(mat1[i,j]/mat2[i,j])
        outmat.append(line)
    outmat = np.array(outmat)

    return outmat

def draw_heatmap(data,savename):
    fig,ax = plt.subplots()
    heatmap = ax.pcolor(data, cmap=plt.cm.Reds)

    ax.invert_yaxis()
    ax.xaxis.tick_top()

    plt.show()
    plt.savefig(savename)

    return heatmap

draw_heatmap(matrix_calc(matrix_file1,matrix_file2),savename)
