import numpy as np
import matplotlib.pyplot as plt
import measure_regul_i as meas
import cmath as cm
R0=0.5
m=1/7
f_sig=500
fe=16000
t=np.arange(0,0.1,1/fe)
w=2*np.pi*f_sig
U0rms=3.57768
I0rms=6.14213 
P0=21.6699 
U1rms=3.57188
I1rms=6.15282
P1=21.6744
phi0_meas=np.arccos(P0/(U0rms*I0rms))
phi1_meas=np.arccos(P1/(U1rms*I1rms))
noise1 = np.random.normal(0,1,len(t))
noise2 = np.random.normal(0,1,len(t))
noise3 = np.random.normal(0,1,len(t))
noise4 = np.random.normal(0,1,len(t))
U0=0.5+np.sqrt(2)*U0rms*np.sin(w*t)+0.0*noise1
I0=0.3+np.sqrt(2)*I0rms*np.sin(w*t-phi0_meas)+0.0*noise2
U1=1.2+np.sqrt(2)*U1rms*np.sin(w*t)+0.0*noise3
I1=0.8+np.sqrt(2)*I1rms*np.sin(w*t-phi1_meas)+0.0*noise4

plt.plot(t,U0)
plt.plot(t,I0)
plt.show()
Urms0,Irms0,Phi0=meas.rms_U_I_Phi(U0,I0)
print("Urms0= "+str(Urms0))
print("Irms0= "+str(Irms0))
print("Phi0= "+str(Phi0))
#-phi car circuit inductif
Z0=meas.Compute_Z(R0,Urms0,Irms0,-Phi0)
print("Z0 "+str(Z0))
mod_z0=cm.sqrt(Z0.real**2+Z0.imag**2)
print("mod_z0= "+str(mod_z0))
L=mod_z0.real/(2*np.pi*f_sig)
print("L ="+str(L))
Urms1,Irms1,Phi1=meas.rms_U_I_Phi(U1,I1)
#-phi car circuit inductif
Z = meas.Compute_Z(R0,Urms1,Irms1,-Phi1)
print("Z= "+str(Z))
Zs=meas.Compute_Zs(Z,m,Z0)
print("Zs= "+str(Zs))
mod_zs=cm.sqrt(Zs.real**2+Zs.imag**2)
print("mod_zs= "+str(mod_zs))