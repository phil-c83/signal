import numpy as np
import matplotlib.pyplot as plt

def sinMC(f,t,s):
# A*sin(wt+p)+c = A*cos(p)*sin(wt)+A*sin(p)*cos(wt)+c = a*sin(wt)+b*cos(wt)+c
# we seek a,b,c 
# D = [sin(wt),cos(wt),ones()] , S = D*X, X=[a,b,c]'
# X = (D'*D)^(-1)*D*S
    Te     = np.array(t)
    sin_v  = np.sin(2*np.pi*f*Te)
    cos_v  = np.cos(2*np.pi*f*Te)
    one_v  = np.ones(Te.size)
    DT     = np.array([sin_v,cos_v,one_v]) # transpose disign matrix
    D      = DT.T                          # disign matrix
    S      = np.array(s).T
    DTD_i  = np.linalg.inv(np.matmul(DT,D))
    DTS    = np.matmul(DT,S)
    X      = np.matmul(DTD_i,DTS)    
    A      = np.sqrt(X[0]**2+X[1]**2)
    p      = np.arctan2(X[1],X[0])
    c      = X[2]
    return (A,p,c) 

def phase_diff(f,t,s1,s2):
    A1,P1,C1 = sinMC(f,t,s1)
    A2,P2,C2 = sinMC(f,t,s2)
    P = phase_normalise (P1-P2)
    return (P1,P2,P)   

def phase_normalise (p):
    #-pi < P <= pi
    Pn = np.fmod(p,2*np.pi)
    if Pn < -np.pi:
        Pn = Pn + 2*np.pi
    elif Pn > np.pi:
        Pn = Pn - 2*np.pi
    return Pn         
                           




