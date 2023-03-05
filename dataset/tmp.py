import matplotlib.pyplot as plt
import os

counts = [len(os.listdir('./cells/'+str(i))) for i in range(10)]

plt.bar([*range(10)],counts)
plt.xlabel('classes')
plt.ylabel('count')
plt.show()
