import numpy as np
from scipy.fft import fft, fftfreq
import matplotlib.pyplot as plt

class SignalClass:
  def __init__(self, s, pulse):
    self.I=np.zeros(len(s))
    self.Q=np.zeros(len(s))
    self.N=len(s)
    self.T=1/125_000_000
    self.s = s
    self.pulse=pulse

  def process(self,level):
    iff = 5_000_000
    self.fft = fft(self.s)
    self.fftfreq = fftfreq(self.N, d=self.T)

    _in   = np.where(self.fftfreq==iff)[0][0]
    _fft  = self.fft[_in]
    __fft = fft(self.pulse)[_in]
    #_fft1 = "{:e}".format(np.abs(_fft))
    _fft1 = "{:e}".format(np.max(self.s))
    _fft2 = "{:e}".format(np.angle(_fft))
    #_fft3 = "{:e}".format(np.abs(__fft))
    _fft3 = "{:e}".format(np.max(self.pulse))
    _fft4 = "{:e}".format(np.angle(__fft))
    _pd = np.angle(__fft) - np.angle(_fft)
    if _pd>0: _pd -= 2*np.pi
    _fft5 = "{:e}".format(np.min([_pd, _pd]))
    #_fft6 = "{:e}".format(np.abs(__fft) - np.abs(_fft))
    _fft6 = "{:e}".format(np.max(self.s) - np.max(self.pulse))
    print("Ch.3 (a, ph):",_fft3,_fft4 , " Ch.2 (a,ph): "+_fft1+" , "+_fft2, ", a diff:",_fft6,", ph diff: "+_fft5)
    res.append([level, np.max(self.pulse), np.angle(__fft), np.max(self.s), np.angle(_fft), np.max(self.s)-np.max(self.pulse), _pd])

    #plt.plot(self.fftfreq, (2.0/self.N)*np.abs(self.fft),'-x')
    #plt.grid()
    #plt.xlabel('Frequency')
    #plt.ylabel('|.|')
    #plt.title("Signal " + str(i) + ", length: " + str(self.N))
    #plt.show()

  def getIQ(self):
    return self.I, self.Q

############# main ##########################
#data = np.loadtxt('results/sweep_4july2023d.csv', delimiter=',')
data = np.load('results/sweep_7juli2023__powerlevel_sspa.csv.npz')['a']
nmax = data.shape[0]
#print("Nmax: ", nmax)
sc = []
res = []
for i in range(nmax):
  #print("Length:", len(data[i,:800,1]))
  sc.append(SignalClass(data[i,:800,1], data[i,:800,2]))
  level = 10000+i*1000
  print("Level:", level)
  sc[i].process(level)
np.savetxt('results/sweep_powerlevel_sspa.csv', res, delimiter=',')
