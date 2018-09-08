import numpy as np
import matplotlib.pyplot as plt
import sys,re

args = sys.argv
outname = args[1]
graph1 = args[2]
graph2 = args[3]

def read_graph(path):
    label = []
    mean = []
    variance = []
    number = []
    with open(path) as f:
        for line in f.readlines():
            line.strip()
            data = line.split()
            label.append(data[0])
            mean.append(float(data[1]))
            variance.append(float(data[2]))
            number.append(float(data[3]))
    
    return [np.array(label),np.array(mean),np.array(variance),np.array(number)]

def plot_bargraphs(graph_list1,graph_list2):
    plt.figure()
    #plot graph1
    plt.bar(range(len(graph_list1[0]))*0.5, graph_list1[1], yerr=np.sqrt(graph_list1[2]/graph_list1[3]), ecolor="black")
    #plot graph2
    plt.bar(range(len(graph_list2[0])), graph_list2[1], yerr=np.sqrt(graph_list2[2]/graph_list2[3]), ecolor="black")
    plt.savefig(outname,transparent=True)

plot_bargraphs(read_graph(graph1),read_graph(graph2))