def make_pwr_matrix(pwr_data):
    # built a nx2 matrix M 
    # with M(:,1) is R2 values and M(:,2) is power ratios ie P10/P1  
    # sort R2 values in ascending order
    idx_asc = sorted(range(len(pwr_data)),key=lambda k:jcsv.get_R2(pwr_data,k)) 
    pwr_m = []
    P10   = jcsv.get_P1(pwr_data,idx_asc[len(idx_asc)-1]) 
    #build matrix
    for k in range(len(idx_asc)-1):        
        pwr_m.append([jcsv.get_R2(pwr_data,idx_asc[k]), P10/jcsv.get_P1(pwr_data,idx_asc[k])])
    return (pwr_m,P10)

def eval_R2(pwr_m,pwr):     
    p_inf = 0
    p_sup = 0
    r     = 0
    if pwr < pwr_m[0][1]:
        R2 = 0.0 # pwr < min 
    elif pwr > pwr_m[len(pwr_m)-1][1]: # pwr > max
        R2 = float('inf')
    else :        
        for k in range(len(pwr_m)):
            if pwr_m[k][1] == pwr: # exact value found
                R2 = pwr_m[k][0]                
            elif pwr_m[k][1] > pwr: #        inf < pwr < sup
                p_inf =  pwr_m[k-1][1] 
                p_sup =  pwr_m[k][1] 
                r     =  (pwr - p_inf)/(p_sup-p_inf)
                R2    =  pwr_m[k-1][0]*(1-r) + pwr_m[k][0]*r
                break

    print('p_inf={:4.3f} p_sup={:4.3f} r={:4.3f} pwr={:4.3f} R2={:4.3f}'.format(p_inf,p_sup,r,pwr,R2))          
    return R2
    


def check_fe(x):
    try:
        i = int(x)
    except ValueError:    
        raise argparse.ArgumentTypeError("must be a number")
    if i<100 or i>100000:
        raise argparse.ArgumentTypeError("must be [100..100000]")
    return i  

def check_vdac(x):
    try:
        v = float(x)
    except ValueError:    
        raise argparse.ArgumentTypeError("must be a floating point number")
    if v < 0.1 or v > 1.0:
        raise argparse.ArgumentTypeError("must be in [0.1..1.0]")
    return v  

def check_positive(x):
    try:
        v = float(x)
    except ValueError:    
        raise argparse.ArgumentTypeError("must be a floating point number")
    if v <= 0:
        raise argparse.ArgumentTypeError("must be positive!")
    return v 

if __name__ == '__main__':    
    import argparse
    # Initialize command line parser
    parser = argparse.ArgumentParser(description='Make clamp model')
    parser.add_argument('--fadc',
                            help='select the ADC sample frequency',
                            type=check_fe,
                            metavar='<sample_freq>',
                            default=48000)
    parser.add_argument('--fdac',
                            help='select the DAC sample frequency',
                            type=check_fe,
                            metavar='<sample_freq>',
                            default=48000)  
    parser.add_argument('--fs',                        
                            help='select sinus frequency',
                            type=int,                            
                            metavar='<freq>',
                            required=True)                              
    parser.add_argument('--vdac',
                            help='select signal amplitude',
                            type=float,                            
                            metavar='<voltage>',
                            required=True)            
    parser.add_argument('--Av',
                            help='ampli gain',
                            type=check_positive,
                            metavar='<Ampli_Gain>',
                            default=2.5)    
    parser.add_argument('--fname',
                            help='csv filename for power measures',                            
                            metavar='<csv-filename>',
                            required=True) 
    parser.add_argument('--devdac',
                            help='select output NI device',                             
                            metavar='<dev>',
                            required=True)  
    parser.add_argument('--devadc',
                            help='select input NI device',                             
                            metavar='<dev>',
                            required=True)  
    parser.add_argument('--G1',
                            help='I1=G1*V',
                            type=check_positive,
                            metavar='<calibre_I1>',
                            default=1.0/102.4e-3) 
    parser.add_argument('--simul',
                            help='test with ramdom value',                            
                            action='store_true')                            
                            
                            

    args = parser.parse_args()
    #Retrieve arguments    
    fadc = args.fadc    
    fdac = args.fdac      
    vdac = args.vdac
    Av   = args.Av   
    G1   = args.G1
    fname = args.fname    

    # print args
    print('devdac=%s devadc=%s fadc=%d fdac=%d vdac=%1.1f Av=%.3f fname=%s G1=%.3f' % 
            (args.devdac,args.devadc,fadc,fdac,vdac,Av,fname,G1))  

    import sys 
    import os     
    import matplotlib.pyplot as plt
    import random

    cwd = os.getcwd() 
    libpath = cwd + "/../python_lib"
    #print(libpath)
    sys.path.append(libpath)  
    import JupE_measures as jm     
    import JupE_csv as jcsv
    if args.simul == False:
         import NI_device as nid

    # get power ratios ref measures
    pwr_data = jcsv.load_clamp_power_refs(fname);
    #print('data={}'.format(pwr_data))
    (pwr_m,P10) = make_pwr_matrix(pwr_data)
    print('pwr_matrix={}'.format(pwr_m))
    if args.simul == True:
        pwr = random.random()*0.2+0.8 # simulation
    else:        
        sig,Te = jm.gen_sinus(fdac,vdac,args.fs,0,0.5*fdac)
        I1buf,U1buf,I2buf = nid.generate_and_sample(sig,fdac,fadc,fadc*(0.5-0.2),args.devdac,args.devadc)
        Te_adc =  [t*1/fadc for t in range(0,len(I1buf))]
        U1rms,I1rms,P1,S1,I2rms,phi1,phi2,phi12,cos_mc,cos_ui = jm.measures_sinus(args.fs,Te_adc,U1buf,I1buf,I2buf,G1,1.0)
        pwr = P10/P1    
    eval_R2(pwr_m,pwr) 
    
    




