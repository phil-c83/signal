import sys   
import os  
import extract_json as ej 
import numpy as np
import cmath as cx

class EvalZ():
    # clamp model : Z1 + (Zs/m^2 // Zm)
    # Z1 : wire + measure resistor + other things (typically R1) supposed known
    # Zm : self + loss clamp impedance  
    # Zs : impedance connected to secondary 
    # Z0 : impedance without load
    # Z  : impedance with load ie Zs != Inf
    
    def __init__(self):
        self.avg_Z=0
        self.count=0
        self.list_Z=[]           

    def rms_U_I_Phi(self,U,I):
        Urms = np.sqrt(np.cov([U,U],bias=True)[0,0])
        Irms = np.sqrt(np.cov([I,I],bias=True)[0,0])
        Phi  = np.arccos(np.cov([U,I],bias=True)[0,1]/(Urms*Irms))
        return (Urms,Irms,Phi) 

    def rms_U_I_Phi(self,U,I):
        Urms = np.sqrt(np.cov([U,U],bias=True)[0,0])
        Irms = np.sqrt(np.cov([I,I],bias=True)[0,0])
        Phi  = np.arccos(np.cov([U,I],bias=True)[0,1]/(Urms*Irms))
        return (Urms,Irms,Phi)  

    def Compute_Z(self,Urms,Irms,Phi):
        Ic=Irms*cx.exp(1j*(-Phi)) # Ic en retard (inductif)        
        Z = Urms/Ic
        return Z  
    
    def Compute_Z2(self,Z,Z0,Z1): 
        # Z =  Z1 + (Z2 // (Z0-Z1)) 
        # --> Z2 = (Z0-Z1)*(Z1-Z)/(Z-Z0)  
        Z2 = (Z0-Z1)*(Z1-Z)/(Z-Z0)
        return Z2

    def str_trace_Z(self,U,I,phi,Z):
        str_trace = ' '.join('{}:{:02.3f}'.format(s,v) 
            for (s,v) in zip(["\tUrms","Irms","Phi"],[U,I,phi]))
        str_trace = str_trace + " " + self.Z2str(Z,"Z") 
        return str_trace       
    
    def str_trace_Z2(self,U,I,phi,Z,Z0,Z2):
        return (self.str_trace_Z(U,I,phi,Z) + " " +
               self.Z2str(Z0,"Z0") + " " + self.Z2str(Z2,"Z2"))

    def avgZ2str(self,name):
        return self.Z2str(self.avg_Z,name)

    def Z2str(self,Z,name):
        Z_pol = cx.polar(Z)
        return '{}:{:02.3f}/{:02.3f}'.format(name,Z_pol[0],Z_pol[1])        

    
    def process_measure(self,channel,coef_u,coef_i):           
        Ibuf  = channel.buff_I
        Ubuf  = channel.buff_U
        ln=len(Ibuf)//32*32 # integral number of periods
        Ibuf  = Ibuf[:ln]
        Ubuf  = Ubuf[:ln]
        # normalize measures
        Ibuf_n = [i*coef_i for i in Ibuf]
        Ubuf_n = [u*coef_u for u in Ubuf] 
        (Urms,Irms,Phi)=self.rms_U_I_Phi(Ubuf_n,Ibuf_n) 
        Z = self.Compute_Z(Urms,Irms,Phi)
        self.list_Z.append(Z)
        self.count += 1        
        return (Urms,Irms,Phi,Z)

    def avg_z(self):
        if self.count:
            for i,v in enumerate(self.list_Z):
                self.avg_Z += v
            self.avg_Z /= self.count
            return self.avg_Z
            








