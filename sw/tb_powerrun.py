import numpy as np
import matplotlib.pyplot as plt
from doFFT import *

ts  = 8e-9
X   = np.load('results/sweep_23aug2023/sweep_30aug2023.npz',allow_pickle=True)['a']
print(X[0])
Xs = [X[i] for i in range(len(X)) if (X[i]['Vdd'] == 32.0) and (X[i]['Vgg1']==2.2) and (X[i]['Vgg2']== 1.8)]  
X = Xs

fft = doFFTClass(ts)
pd = []
ad = []
re = np.zeros((201,3))
for i in range(len(X)):
    #fft.plotFFT(inputsignal)
    inputsignal = X[i]['data'][2]
    outputsignal = X[i]['data'][1]
    mfreq, ia, ip = fft.getAP(inputsignal)
    mfreq, oa, op = fft.getAP(outputsignal)
    ad.append(oa-ia)
    pd1 =  op-ip
    if pd1<0:
        pd1 +=360 # 2*np.pi
    pd.append(pd1)
    print(i, "power:", X[i]['Powerlevel'],"Amp.diff:", oa-ia, "Pha.diff:", pd1)
    re[i,0] = X[i]['Powerlevel']
    re[i,1] = oa-ia
    re[i,2] = pd1 

print("Average amplitude difference:", np.mean(ad))
print("STD     amplitude difference:", np.std(ad))
print("Average phase     difference:", np.mean(pd))
print("STD     phase     difference:", np.std(pd))



## plot result ###
import matplotlib.pyplot as plt

fig = plt.figure()
plt.plot(re[:,0], re[:,1],'r-')
plt.plot(re[:,0], re[:,2],'b-')
plt.grid()
plt.tight_layout()
plt.show()
