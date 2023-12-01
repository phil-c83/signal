m = 1/7
R0 = 370e-3
# clamp model : Z1 + (Zs/m^2 // Zm)
# Z1 : wire + measure resistor + other things (typically R1) supposed known
# Zm : self + loss clamp impedance  
# Zs : impedance connected to secondary

# Z0 : impedance without load
# Z  : impedance with load ie Zs != Inf


# Zm computed without load
def compute_Zm0(Z0,Z1):
    return Z0-Z1

def Compute_Zs(Z,Z0,Z1,m):    
    Zs = m*m*(Z1-Z)/(Z-Z0)
    return Zs

if __name__ == '__main__':    
    import sys   
    import os  
    import cmath as cx 
    import avg_Z

    #print(sys.argv)
    nargs = len(sys.argv)-1
    if nargs != 2:
        print("usage: " + sys.argv[0] + " " + "<dir/file for Z0> <dir/file for Z>") 
    
    EZ0 = avg_Z.EvalZ()
    EZ  = avg_Z.EvalZ()
    for n,pname in enumerate(sys.argv[1:]):        
        if os.path.isfile(pname):  
            
            if n == 0:
                EZ0.process_file(pname)
                Z0 = EZ0.stat()
            else:
                EZ.process_file(pname)
                Z =  EZ.stat()          

        elif os.path.isdir(pname):
                                
            if n == 0:
                EZ0.process_dir(pname)
                Z0 = EZ0.stat()
            else:
                EZ.process_dir(pname)
                Z =  EZ.stat()    

    Zs=Compute_Zs(EZ0.avg_Z,EZ.avg_Z,m) 
    str_Zs = ' '.join('{}:{:02.3f}'.format(s,v) 
            for (s,v) in zip(["Zs"],[abs(Zs)]))     
    print(str_Zs)
            
    
    
