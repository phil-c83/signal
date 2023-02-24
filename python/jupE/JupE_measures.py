import numpy as np
import matplotlib.pyplot as plt
import csv
import MCsinus as mc

def gen_sinus(Fe,A,f1,phi,nsamples):
    Te  = np.arange(0,nsamples/Fe,1/Fe)
    sig = A*np.sin(2*np.pi*f1*Te+phi) 
    return (sig,Te)

# ********************************************************************** #
# An*sin(2*n*pi*f + Pn) = an*cos(2*n*pi*f) + bn*sin(2*n*pi*f)
# an = An*sin(Pn), bn = An*cos(Pn)
# An=sqrt(an^2+bn^2) , Pn = atan(an/bn)
# D = T1/T duty cycle
# an = M/(pi*n*(1-D)*sin(2*pi*n*D)), bn=M/(pi*n*(1-D)*(1-cos(2*pi*n*D))
# An = M/(pi*n*(1-D))*sqrt(2*(1-cos(2*pi*n*D)))
# Pn = atan(sin(2*pi*n*D)/(1-cos(2*pi*n*D)))

def sig_An(n,D):
    Xn = np.pi*n*(1-D)
    return 1/(Xn)*np.sqrt(2*(1-np.cos(2*np.pi*n*D)))

# Phase for base signal ie Pn=atan2(an/bn)
def sig_Pn(n,D):
    Xn = 2*np.pi*n*D
    return np.arctan2(np.sin(Xn),(1-np.cos(Xn)))

# ratio amplitude factor between fundamental and harmonic 1
# A2/A1 = 1/2*sqrt((1-cos(4*pi*D))/(1-cos(2*pi*D)))
def sig_K(D):
    Xn = 2*np.pi*D
    return 1/2*np.sqrt((1-np.cos(2*Xn))/(1-np.cos(Xn)))

def gen_signal(Fe,D,Vmax,fa,fb,nsamples):
    Te  = np.arange(0,nsamples/Fe,1/Fe)
    V1  = sig_An(1,D)
    V2  = sig_An(2,D)
    P1  = sig_Pn(1,D)
    P2  = sig_Pn(2,D)
    sig = Vmax*(V1*np.sin(2*np.pi*fa*Te+P1) + V2*np.sin(4*np.pi*fa*Te+P2)
                - V1*np.sin(2*np.pi*fb*Te+P1) - V2*np.sin(4*np.pi*fb*Te+P2))
    rms = np.std(sig)
    print('sig: Vmax=%1.3f rms=%1.3f A1=%1.3f P1=%1.3f A12=%1.3f P2=%1.3f' % 
            (Vmax,rms,Vmax*V1,P1,Vmax*V2,P2))
    return(sig,Te)   
# ********************************************************************** #    

def measures_signal(U1buf,I1buf,I2buf,G1,G2):   
    #compute all measures from buffers
    cov_ui = np.cov([U1buf,I1buf], bias=True)    
    # Compute I1 RMS
    I1rms = G1*np.sqrt(cov_ui[1][1])
    # Compute U1 RMS
    U1rms = np.sqrt(cov_ui[0][0])
    # Compute I2 RMS
    I2rms = G2*np.std(I2buf)
    # Compute P
    P1 = G1*cov_ui[0][1]
    # Compute S
    S1 = U1rms * I1rms      
    return (U1rms,I1rms,P1,S1,I2rms) 

def measures_sinus(f,Te,U1buf,I1buf,I2buf,G1,G2):
    U1rms,I1rms,P1,S1,I2rms = measures_signal(U1buf,I1buf,I2buf,G1,G2)
    phi1,phi2,phi12 = mc.phase_diff(f,Te,I1buf,U1buf)
    cos_mc  = np.cos(phi12)
    cos_ui  = P1/(U1rms*I1rms)
    return (U1rms,I1rms,P1,S1,I2rms,phi1,phi2,phi12,cos_mc,cos_ui)

def CFT_sig_ref(A,a,T,D,f):
    # compute CFT{sig_ref(t-a)}(f)
    z = A*D*T*np.exp(-1j*2*np.pi*a*f) * (
        np.exp(-1j*np.pi*D*T*f)*np.sinc(D*T*f) - 
        np.exp(-1j*np.pi*(1+D)*T*f)*np.sinc((1-D)*T*f) )
    return z

def sig_lag(T,D,f,FFT_arg):  
    # phi = 2*pi*f*a      
    phi = FFT_arg - np.angle(CFT_sig_ref(1,0,T,D,f)) 
    # -2*pi < phi <= 2*pi
    # normalize ie -pi < phi <= pi
    phi_n = mc.phase_normalise(phi)
    a   = phi_n/(2*np.pi*f)
    if a < 0 : # a is a lag ie must be >=0
        a = T + a
    return (phi,a)    

def read_coefs_model(file):
    with open(file, newline='') as csvfile:
        csv_line = csv.reader(csvfile, delimiter=',').__next__()          
        return [float(x) for x in csv_line]

def eval_poly_model(f,v,coefs):
    f2 = f*f
    v2 = v*v
    p  = coefs[0] 
    p += coefs[1]*f + coefs[2]*v
    p += coefs[3]*f2 + coefs[4]*f*v + coefs[5]*v2
    p += coefs[6]*f2*v + coefs[7]*f*v2 
    p += coefs[8]*f2*v2
    return p

def eval_I2(I1,U1,cos_mc,R1,Zm,m):   
    I1c    = I1*(cos_mc - 1j*(np.sqrt(1-cos_mc*cos_mc)))
    I2c    = (I1c*(Zm+R1) - U1)/(m*Zm)
    #print('I2=%.3f+%.3fi'% (np.real(I2c),np.imag(I2c)))
    #print('I1=%.3f+%.3fi'% (np.real(I1c),np.imag(I1c)))
    return I2c    

def eval_E1(I1,U1,cos_mc,R1):    
    E1c    = U1 - R1*I1*(cos_mc - 1j*np.sqrt(1 - cos_mc*cos_mc))
    #print('E1=%.3f+%.3fi'% (np.real(E1c),np.imag(E1c)))   
    return E1c 

def eval_Zm(f,Rf,Lm):
    # Zm = Rf//i*Lm*w
    Xm = 2*np.pi*f*Lm
    Zm = (Rf*Xm*Xm + 1j*Rf*Rf*Xm) / (Rf*Rf + Xm*Xm)
    #print('Zm=%.3f+%.3fi'% (np.real(Zm),np.imag(Zm)))
    return Zm    

def eval_Rf(f,v,coefs):
    return eval_poly_model(f,v,coefs)    

def eval_Lm(f,v,coefs):
    return eval_poly_model(f,v,coefs) 