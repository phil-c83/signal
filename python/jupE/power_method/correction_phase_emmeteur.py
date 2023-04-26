import numpy as np
import matplotlib.pyplot as plt

def mag_and_phase(freq, N, fe, fft_data):
    step = fe/N
    # Get magnitude and phase
    magnitude = 2/N*np.abs(fft_data[int(freq/step)])
    phase = np.angle(fft_data[int(freq/step)])
    return(magnitude, phase)

def an_coef(a,k,n):
    return a*np.sin(2*np.pi*n*k)/((np.pi*n)*(1-k))

def bn_coef( a, k, n):
    return -a*(np.cos(np.pi*2*n*k)-1)/((np.pi*n)*(1-k))

# on fixe k = 2/5
def compute_amp_phi_coef():
    amp=[]
    phi=[]
    for i in range(2):
        an=an_coef(1.0,2.0/5.0,i+1)
        bn=bn_coef(1.0,2.0/5.0,i+1)
        amp.append(np.sqrt(an*an+bn*bn))
        phi.append(np.arctan2(an,bn))
    return(amp,phi)
   
def compute_phase_corrective_coef(freqs=[410,440,470,520,560,590,610,640,670,710,740,770]):
    # correction aproximé par une droite en faisant des mesure de la phase de la tension en sortie du dac et de la phase du courant sur le câble*/
    a=-0.0007784606548672566
    b=0.5634515184955752
    phi_cor_f=[]
    for i in range(len(freqs)):
        t=(a*freqs[i]+b,a*2*freqs[i]+b)
        phi_cor_f.append(t)
    return phi_cor_f

def arrays_to_c_array(tab):
    print("{",end='')
    for i in range(len(tab)-1):
        print("{",tab[i][0],",",tab[i][1],"},",end='')
    print("{",tab[len(tab)-1][0],",",tab[len(tab)-1][1],"}",end='')
    print("}")

phi_cor=compute_phase_corrective_coef()
amp,phi=compute_amp_phi_coef()
amp_ratio=amp[1]/amp[0]
t=np.arange(0,0.3,1/100000)
sig1=np.sin(2*np.pi*410*t+phi[0]-phi_cor[0][0])+amp_ratio*np.sin(2*np.pi*820*t+phi[1]-phi_cor[0][1])
sig2=np.sin(2*np.pi*440*t+phi[0]-phi_cor[1][0])+amp_ratio*np.sin(2*np.pi*880*t+phi[1]-phi_cor[1][1])
sig1=amp[0]*np.sin(2*np.pi*410*t+phi[0])+amp[1]*np.sin(2*np.pi*820*t+phi[1])
sig2=amp[0]*np.sin(2*np.pi*440*t+phi[0])+amp[1]*np.sin(2*np.pi*880*t+phi[1])
sig=sig1-sig2
plt.plot(2*sig)
plt.show()
print("amp_ratio=",amp_ratio)
print("amp=",amp) 
print("phi=",phi) 
arrays_to_c_array(compute_phase_corrective_coef())

# fe=10000
# t=np.arange(0,0.1,1/fe)
# f=400
# an=np.random.rand()
# bn=np.random.rand()*5
# sig_comp=an*np.cos(2*np.pi*f*t) +bn*np.sin(2*np.pi*f*t)
# sig=np.sqrt(an*an+bn*bn)*np.sin(2*np.pi*f*t+np.arctan(an/bn)+0.3)
# fft_sig = np.fft.fft(sig[0:1024])
# mag_sig,phase_sig=mag_and_phase(410, 2048, fe, fft_sig)
# fft_sig_comp = np.fft.fft(sig_comp[0:2048])
# mag_sig_comp,phase_sig_comp=mag_and_phase(410, 2048, fe, fft_sig_comp)
# print("sig: mag=",mag_sig," phase=",phase_sig)
# print("sig: mag_sig_comp=",mag_sig_comp," phase_sig_comp=",phase_sig_comp)
# plt.plot(t,sig,"b")
# plt.plot(t,sig_comp,"r")
# plt.show()