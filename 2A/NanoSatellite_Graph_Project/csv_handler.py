from numpy import genfromtxt

### On récupère les points
avg = genfromtxt('topologies/topology_avg.csv', delimiter=',')[1:, 1:]
high = genfromtxt('topologies/topology_high.csv', delimiter=',')[1:, 1:]
low = genfromtxt('topologies/topology_low.csv', delimiter=',')[1:, 1:]