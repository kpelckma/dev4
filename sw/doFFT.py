import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits import mplot3d
from tqdm import tqdm
from scipy.fft import fft, fftfreq, ifft


class doFFTClass:
    def __init__(self, ts):
      self.ts = ts

    def plotFFT(self, s):
      N = len(s)
      X  = fft(s)
      t  = np.arange(N) * self.ts
      freq = fftfreq(N, self.ts)

      plt.figure(figsize = (12, 6))
      plt.subplot(121)
      plt.stem(freq, (2.0/N) *np.abs(X), 'b', \
         markerfmt=" ", basefmt="-b")
      plt.xlabel('Freq (Hz)')
      plt.ylabel('FFT Amplitude |X(freq)|')
      plt.grid()
      # plt.xlim(0, 3)

      plt.subplot(122)
      plt.plot(t, ifft(X), 'r', label='ifft')
      plt.plot(t, s, 'b', label='original')
      plt.xlabel('Time (s)')
      plt.ylabel('Amplitude')
      plt.legend()
      plt.tight_layout()
      plt.show()


    def getAP(self, s):
      s -= np.mean(s) # remove DC component
      N = len(s)
      X  = fft(s)
      t  = np.arange(N) * self.ts
      freq = fftfreq(N, self.ts)

      im = np.argmax(np.abs(X))
      maxfreq = freq[im]
      maxAmp  = (2.0/N) * np.abs(X[im])
      maxPha  = np.angle(X[im], deg=True)
      #print("max freq:", maxfreq, "amplitude:", maxAmp, "Phase:",maxPha)
      return maxfreq, maxAmp, maxPha






# #################################### example of use ######################################
# ts =8e-9 # 8 nano seconds
# doFFT = doFFT(ts)
# mfreq, AmplitudePulse, PhasePulse = doFFT.getAP(inputsignal)
# mfreq, AmplitudeMeasured, PhaseMeasured = doFFT.getAP(outputsignal)
