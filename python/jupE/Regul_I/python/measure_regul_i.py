import numpy as np
import cmath as cx

def rms_U_I_Phi(U,I):
    Urms = np.sqrt(np.cov([U,U],bias=True)[0,0])
    Irms = np.sqrt(np.cov([I,I],bias=True)[0,0])
    Phi  = np.arccos(np.cov([U,I],bias=True)[0,1]/(Urms*Irms))
    return (Urms,Irms,Phi)


def Compute_Z(R0,Urms,Irms,Phi):
    Ic=Irms*cx.exp(1j*Phi)
    Z0 = Urms/Ic - R0
    return Z0

def Compute_Zs(Z,m,Z0):
    Zs = m*m*(-Z*Z0)/(Z-Z0)
    return Zs


