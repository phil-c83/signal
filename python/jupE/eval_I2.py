import numpy as np
import matplotlib.pyplot as plt
import NI_device as nid
import JupE_measures as jm 

freqs_f   = [410,440,470,480,520,560,590,610,640,670,710,740,770]
freqs_2f  = [2*f for f in freqs_f]
freqs_lst = freqs_f + freqs_2f
freqs_str = str(freqs_lst).strip('[]')

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

def check_freq(x):
    
    if x in freqs_lst == False :
        raise argparse.ArgumentTypeError("must be in frequency list")
    
    return x


if __name__ == '__main__':    
    import argparse
    # Initialize command line parser
    parser = argparse.ArgumentParser(description='I2 evaluation')
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
                            help='sinus frequency %s' % freqs_str,
                            type=check_freq,
                            metavar='<frequency>',
                            default=480)      
    parser.add_argument('--vdac',
                            help='vdac [0.1..1]',
                            type=check_vdac,
                            metavar='<dac_level>',
                            default=0.1)     
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
    parser.add_argument('--m',
                            help='transform ratio',
                            type=check_positive,
                            metavar='<m=N2/N1>',
                            default=1.0/7.0) 
    parser.add_argument('--dir',
                            help='directory for model',                            
                            metavar='<dirname>',
                            default='.') 
    args = parser.parse_args()
    #Retrieve arguments    
    fe_adc=args.fadc    
    fe_dac=args.fdac    
    fsig  =  int(args.fs)
    vdac  = args.vdac
    G1    = args.G1
    G2    = args.G2    
    Av    = args.Av
    m     = args.m     
    D     = 2/5 
    dname = args.dir 


    # print args
    print('fadc=%d fdac=%d fsig=%d vdac=%.1f G1=%.3f G2=%.3f Av=%.3f m=%.3f dir=%s' % 
            (fe_adc,fe_dac,fsig,vdac,G1,G2,Av,m,dname))  

    sig,Te = jm.gen_sinus(fe_dac,vdac,fsig,0,round(fe_dac*0.5))

    # rng    = np.random.default_rng(round(fe_dac*0.5))
    # noise  = rng.random(round(fe_dac*0.5))*0.8
    # sig_noise = sig+noise

    I1buf,U1buf,I2buf = nid.generate_and_sample(sig,fe_dac,fe_adc,fe_adc*(0.5-0.2)) 
    Te_adc =  [t*1/fe_adc for t in range(0,len(I1buf))]
    U1rms,I1rms,P1,S1,I2rms,phi1,phi2,phi12,cos_mc,cos_ui = jm.measures_sinus(fsig,Te_adc,U1buf,I1buf,I2buf,G1,G2)

    """ fig,(ax1,ax2)  = plt.subplots(2,1)        
    ax1.plot(Te,sig)       
    ax2.plot(Te_adc,U1buf)      
    plt.show() """  

    print('U1rms=%1.3f I1rms=%1.3f I2rms=%1.3f P1=%1.3f S1=%1.3f phi_U1=%1.3f phi_I1=%1.3f phi_UI=%1.3f cos_mc=%1.3f cos_ui=%1.3f' % 
            (U1rms,I1rms,I2rms,P1,S1,phi1,phi2,phi12,cos_mc,cos_ui))


    lm_coefs = jm.read_coefs_model(dname+'/Lm_model.csv')
    #print(lm_coefs)
    rf_coefs = jm.read_coefs_model(dname+'/Rf_model.csv')
    #print(rf_coefs)
    R1 = jm.read_coefs_model(dname+'/R1.csv')[0]
    #print(R1)
    E1c = jm.eval_E1(I1rms,U1rms,cos_mc,R1)
    E1  = abs(E1c)
    Lm  = jm.eval_Lm(fsig,E1,lm_coefs)
    Rf  = jm.eval_Rf(fsig,E1,rf_coefs)
    Zm  = jm.eval_Zm(fsig,Rf,Lm)
    I2c = jm.eval_I2(I1rms,U1rms,cos_mc,R1,Zm,m)    
    R2  = abs(m*E1c/I2c)

    print('E1=%.3f I2m=%.3f R2=%.3f R1=%.3f Lm=%.6f Rf=%.3f Zm=%.3f' % 
            (E1,abs(I2c),R2,R1,Lm,Rf,abs(Zm)))  

