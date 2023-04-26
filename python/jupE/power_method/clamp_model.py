import numpy as np
import matplotlib.pyplot as plt
import NI_device as nid
import JupE_measures as jm 
import csv
import time

# Add all frequencies to frequency list
freq_list = [410, 440, 470, 480, 520, 560, 590, 610, 640, 670, 710, 740, 770]
# Add all harmonic frequencies to frequency list 
freq_list += [f*2 for f in freq_list]

# Add all voltages to voltage list
volt_list = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]

# Save buffer in file
def save_buffer(Fe,Fs,U1rms,I1rms,P1,cos_UI,label,dname):  
    fname = '{}/{}_{}.csv'.format(dname,label,time.time()) 
    Fe_str = '#Fe={}'.format(Fe)    
    with open(fname, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(('Fs','U1','I1','P1','cos_UI',Fe_str))
        for i in range(0,len(Fs)):
            row = (Fs[i],U1rms[i],I1rms[i],P1[i],cos_UI[i])
            writer.writerow(row)

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

def check_positive_or_null(x):
    try:
        v = float(x)
    except ValueError:    
        raise argparse.ArgumentTypeError("must be a floating point number")
    if v < 0:
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
                            help='select the frequency range to use. freqs=['+' '.join(map(str,freq_list))+']',
                            type=int,
                            nargs=2,
                            choices=freq_list,
                            metavar='<freq_start freq_stop>',
                            required=True) 
    parser.add_argument('--vdac',
                            help='select the voltage range to use. voltages=['+' '.join(map(str,volt_list))+']',
                            type=float,
                            nargs=2,
                            choices=volt_list,
                            metavar='<voltage>',
                            required=True)        
    parser.add_argument('--G1',
                            help='I1=G1*V',
                            type=check_positive,
                            metavar='<calibre_I1>',
                            default=1.0/102.4e-3)
    parser.add_argument('--G2',
                            help='I2=G2*V',
                            type=check_positive,
                            metavar='<calibre_I2>',
                            default=5.0)
    parser.add_argument('--Av',
                            help='ampli gain',
                            type=check_positive,
                            metavar='<Ampli_Gain>',
                            default=2.5)    
    parser.add_argument('--dir',
                            help='directory for model',                            
                            metavar='<dirname>',
                            default='.') 
    parser.add_argument('--devdac',
                            help='select output NI device',                             
                            metavar='<dev>',
                            required=True)  
    parser.add_argument('--devadc',
                            help='select input NI device',                             
                            metavar='<dev>',
                            required=True)  

    parser.add_argument('-s',
                            help='Save measures on csv file',
                            action="store_true")                            
                            

    args = parser.parse_args()
    #Retrieve arguments    
    fadc = args.fadc    
    fdac = args.fdac  
    args.fs.sort()
    freqs = freq_list[freq_list.index(args.fs[0]):freq_list.index(args.fs[1])+1]
    # Retrieve selected voltages list
    args.vdac.sort()
    volts = volt_list[volt_list.index(args.vdac[0]):volt_list.index(args.vdac[1])+1]      
    G1    = args.G1   
    G2    = args.G2 
    Av    = args.Av   
    dname = args.dir 

    # print args
    print('devdac=%s devadc=%s fadc=%d fdac=%d fstart=%d fstop=%d vstart=%1.1f vstop=%1.1f G1=%.3f G2=%.3f Av=%.3f dir=%s' % 
            (args.devdac,args.devadc,fadc,fdac,freqs[0],freqs[len(freqs)-1],volts[0],volts[len(volts)-1],G1,G2,Av,dname))     

    Fs = []
    U1 = []
    I1 = []
    P  = []
    cos_UI = []
    for f in freqs:
        for v in volts:
            sig,Te = jm.gen_sinus(fdac,v,f,0,round(fdac*0.5))
            I1buf,U1buf,I2buf = nid.generate_and_sample(sig,fdac,fadc,fadc*(0.5-0.2),args.devdac,args.devadc) 
            Te_adc =  [t*1/fadc for t in range(0,len(I1buf))]
            U1rms,I1rms,P1,S1,I2rms,phi1,phi2,phi12,cos_mc,cos_ui = jm.measures_sinus(f,Te_adc,U1buf,I1buf,I2buf,G1,G2)
            Fs.append(f)
            U1.append(U1rms)
            I1.append(I1rms)
            P.append(P1)
            cos_UI.append(cos_mc)

    if args.s:
        save_buffer(fadc,Fs,U1,I1,P,cos_UI,"clamp",dname)         
