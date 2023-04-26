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
                            help='csv filename stored data',                            
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
    parser.add_argument('--R2',
                            help='R2 comma separated values list',
                            metavar='<R2 list>',
                            type=str,
                            required=True)    

                             

    args = parser.parse_args()
    #Retrieve arguments    
    fadc = args.fadc    
    fdac = args.fdac  
    fs   = args.fs
    vdac = args.vdac
    Av   = args.Av   
    G1   = args.G1
    fname = args.fname
    R2_list = [float(item) for item in args.R2.split(',')]

    # print args
    print('devdac=%s devadc=%s fadc=%d fdac=%d fs=%d vdac=%1.1f Av=%.3f fname=%s G1=%.3f R2=%s' % 
            (args.devdac,args.devadc,fadc,fdac,fs,vdac,Av,fname,G1,' '.join(str(r) for r in R2_list)))  

    import sys 
    import os     
    import matplotlib.pyplot as plt

    cwd = os.getcwd() 
    libpath = cwd + "/../python_lib"
    #print(libpath)
    sys.path.append(libpath)  
    import JupE_measures as jm  
    import NI_device as nid
    import JupE_csv as jcsv
        
    #gen_sinus(Fe,A,f1,phi,nsamples)
    sig,Te = jm.gen_sinus(fdac,vdac,fs,0,0.5*fdac) 
    # fig,ax = plt.subplots()           
    # ax.plot(Te,sig)
    # plt.show()  

    Fsl = []
    U1l = []
    I1l = []
    P1l = []
    S1l = []
    R2l = []
    for r in R2_list:
        print('Put R2=%f and press enter to start' % r)
        a = input()        
        I1buf,U1buf,I2buf = nid.generate_and_sample(sig,fdac,fadc,fadc*(0.5-0.2),args.devdac,args.devadc)
        Te_adc =  [t*1/fadc for t in range(0,len(I1buf))]
        U1rms,I1rms,P1,S1,I2rms,phi1,phi2,phi12,cos_mc,cos_ui = jm.measures_sinus(fs,Te_adc,U1buf,I1buf,I2buf,G1,1.0)
        Fsl.append(fs)
        U1l.append(U1rms)
        I1l.append(I1rms)
        P1l.append(P1)
        S1l.append(S1)
        R2l.append(r)
        print('fs=%d U1=%1.3f I1=%1.3f P1=%1.3f S1=%1.3f R2=%1.3f' % (fs,U1rms,I1rms,P1,S1,r))
    
    jcsv.save_clamp_power_refs(fadc,Fsl,U1l,I1l,P1l,S1l,R2l,fname) 

    
    exit(0)
    

    
