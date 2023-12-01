import matplotlib.pyplot as plt
import numpy as np
from scipy.fft import fft
samplerate=10240
N=1024
fft_step=samplerate/N
gain_integrated=2E5
y = np.arange(10, samplerate/2, 10)

def plot_sig_and_fft(sig_proche,sig_loin,title=''):
    ax = plt.subplot(311)
    ax2 = plt.subplot(312)
    ax3 = plt.subplot(313)
    
    ax.plot(sig_proche, "r")
    fft1 = fft(sig_proche, N)
    mag1 = 2/(N*N) * np.power(np.abs(fft1[0:N//2]),2)
    ax2.plot(y[:149], mag1[1:150], "ro", label="bobine proche")
    ax2.plot(y[:149], mag1[1:150], "k", label="bobine proche")

    for i in range(1,150) :
        mag1[i]=gain_integrated*mag1[i]/((i*fft_step)*(i*fft_step))
    ax3.plot(y[:149], mag1[1:150], "k", label="bobine proche")

    ax.plot(sig_loin, "b")
    fft1 = fft(sig_loin, N)
    mag1 = 2/(N*N) * np.power(np.abs(fft1[0:N//2]),2)
    ax2.plot(y[:149], mag1[1:150], "b", label="bobine loin")

    
    
    plt.legend()
    ax.set_title(title)
    plt.show()