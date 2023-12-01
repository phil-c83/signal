import sys   
import os  
import extract_json as ej 
import numpy as np
import cmath as cx

class EvalZ():
    def __init__(self):
        self.avg_Z=0
        self.count=0
        self.list_Z=[]        

    # nomalize to normal unit ie volt or ampere
    def I_pt_to_A(self,Ipt):
        return(((Ipt*((3.3)/(4096)))/(30/10))/(0.11))

    def U_pt_to_V(self,Upt):
        return((Upt*((3.3)/(4096)))/(15/33))

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

    def Compute_Z(self,R0,Urms,Irms,Phi):
        Ic=Irms*cx.exp(1j*Phi)
        #Z = Urms/Ic - R0
        Z = Urms/Ic
        return Z  

    def trace(self,U,I,phi,Z):
        str_trace = ' '.join('{}:{:02.3f}'.format(s,v) 
            for (s,v) in zip(["\tUrms","Irms","Phi","|Z|"],[U,I,phi,abs(Z)]))            
        print(str_trace)  

    def process_dir(self,dir):        
        #print('enter: ' + dir)
        for folderName, subfolders, filenames in os.walk(dir):                          
            for filename in filenames:
                fname = os.path.join(folderName,filename)
                #print('file: ' + fname)
                self.process_file(fname)                       
    
    def process_file(self,file):
        (s,ext)=os.path.splitext(file)        
        if ext == ".json":
            mes = ej.extract_json(file)
            Ibuf  = mes[0][0]
            Ubuf  = mes[0][1]
            ln=len(Ibuf)//32*32 # integral number of periods
            Ibuf  = Ibuf[:ln]
            Ubuf  = Ubuf[:ln]
            # normalize measures
            Ibuf_n = [self.I_pt_to_A(i) for i in Ibuf]
            Ubuf_n = [self.U_pt_to_V(u) for u in Ubuf] 
            (Urms,Irms,Phi)=self.rms_U_I_Phi(Ubuf_n,Ibuf_n) 
            Z = self.Compute_Z(self.R0,Urms,Irms,Phi)
            self.list_Z.append(Z)
            self.count += 1
            self.trace(Urms,Irms,Phi,Z)

    def stat(self):
        if self.count:
            for i,v in enumerate(self.list_Z):
                self.avg_Z += v
            self.avg_Z /= self.count
            print('{}:{:02.3f}'.format("avg_Z",abs(self.avg_Z)))


if __name__ == '__main__':    
    
    #print(sys.argv)
    nargs = len(sys.argv)-1
    
    EZ = EvalZ()
    
    for name in sys.argv[1:]:
        if os.path.isfile(name):            
            EZ.process_file(name)
        elif os.path.isdir(name):
            EZ.process_dir(name)                    
            
    EZ.stat()
    






