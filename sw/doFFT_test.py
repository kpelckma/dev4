import numpy as np
import doFFT

ts = 8e-9  # sampling constant: a sample every 8ns
X = np.load('results/sweep_23aug2023/sweep.npz', allow_pickle='True')['a']
f = doFFT.doFFTClass(ts)

phase_diff = np.zeros(len(X))
amp_diff  = np.zeros(len(X))
for i in range(len(X)):
    o_signal = X[i]['data'][0]
    i_signal = X[i]['data'][3]
    i_freq,i_amplitude,i_phase = f.getAP(i_signal)
    o_freq,o_amplitude,o_phase = f.getAP(o_signal)
    amp_diff[i]   = (o_amplitude - i_amplitude)/i_amplitude
    phase_diff[i] = o_phase - i_phase
    if phase_diff[i]<0:
        phase_diff[i] += 2*np.pi
    print(i, "Phase difference", phase_diff)
print("STD phase diff:    ", np.std(phase_diff))
print("STD amplitude diff:", np.std(amp_diff))

#
# plot pulse repetions
#
import matplotlib.pyplot as plt

npu = len(X)
n  = len(X[i]['data'][0])
Zi = np.zeros((npu,n))
Zo = np.zeros((npu,n))
for i in range(npu):
    for j in range(n):
        Zi[i,j] = X[i]['data'][3][j]
        Zo[i,j] = X[i]['data'][0][j]

t1 = np.arange(npu)
t2 = np.arange(n)
T1 = np.outer(t1, np.ones(n))
T2 = np.outer(np.ones(npu), t2)

### plot result ###
fig = plt.figure()
ax = plt.axes(projection='3d')
ax.plot_surface(T2, T1, Zi)
ax.set_xlabel('Pulse time')
ax.set_ylabel('Pulse number')
plt.tight_layout()
plt.show()
