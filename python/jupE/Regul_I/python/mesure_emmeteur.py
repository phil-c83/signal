import extract_json as ej
import numpy as np
import matplotlib.pyplot as plt
import measure_regul_i as meas
import cmath as cm
R0=370e-3
def I_pt_to_A(Ipt):
    return(((Ipt*((3.3)/(4096)))/(30/10))/(0.11))
def U_pt_to_V(Upt):
    return((Upt*((3.3)/(4096)))/(15/33))

def compute_z(U,I):
    Urms0,Irms0,Phi0=meas.rms_U_I_Phi(U,I)
    print("Urms0= "+str(Urms0))
    print("Irms0= "+str(Irms0))
    print("Phi0= "+str(Phi0*180/np.pi))
    #-phi car circuit inductif
    Z=meas.Compute_Z(R0,Urms0,Irms0,-Phi0)
    print("Z "+str(Z))
    mod_z=cm.sqrt(Z.real**2+Z.imag**2)
    print("mod_z= "+str(mod_z))
    return Z

f_sig=500
m=1/7
mes0=ej.extract_json("Z0/2023-11-14_16_16_18/0.json")
I0=mes0[0][0]
U0=mes0[0][1]
longueur=len(I0)//32*32
U0=U0[:longueur]
I0=I0[:longueur]
for i in range(len(U0)):
    U0[i]=U_pt_to_V(U0[i])
    I0[i]=I_pt_to_A(I0[i])
Z0=compute_z(U0,I0)
plt.plot(U0)
plt.plot(I0)
#plt.show()

mes1=ej.extract_json("100mOhm/2023-11-14_16_26_03/0.json")
I1=mes1[0][0]
U1=mes1[0][1]
longueur=len(I1)//32*32
U1=U1[:longueur]
I1=I1[:longueur]
for i in range(len(U1)):
    U1[i]=U_pt_to_V(U1[i])
    I1[i]=I_pt_to_A(I1[i])
Z1=compute_z(U1,I1)
plt.plot(U1)
plt.plot(I1)
#plt.show()
print("Z= "+str(Z1))
Zs=meas.Compute_Zs(Z1,m,Z0)
print("Zs= "+str(Zs))
mod_zs=cm.sqrt(Zs.real**2+Zs.imag**2)
print("mod_zs= "+str(mod_zs))