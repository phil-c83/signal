import numpy as np
import matplotlib.pyplot as plt
import time
import csv


# fa = sig_set_lst[set][clamp_set[clamp][0]]
# fb = sig_set_lst[set][clamp_set[clamp][1]]
sig_set_lst = [[410, 440, 470],[520, 560, 590],[610, 640, 670],[710, 740, 770]]
freq_test   = 480
clamp_set   = [[0,1],[1,2],[2,0]]


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


def sig_E1(R,I,m):
    return R*I/m

def gen_sin(Fe,A,f1,phi,nsamples):
    Te  = np.arange(0,nsamples/Fe,1/Fe)
    sig = A*np.sin(2*np.pi*f1*Te+phi) 
    return (sig,Te)

def gen_voltage_signal(Fe,D,Vmax,fa,fb,nsamples):
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

def gen_normed_current(Fe,D,Irms,f1,f2,nsamples):
    Te  = np.arange(0,nsamples/Fe,1/Fe)
    A1  = sig_An(1,D)    
    K   = sig_K(D)
    K2  = K*K
    P1  = sig_Pn(1,D)
    P2  = sig_Pn(2,D)
    print('A1=%.3f A2=%.3f P1=%.3f P2=%.3f' % (A1,K*A1,P1,P2))
    sig =   Irms * 1/(np.sqrt(1+K2)) * (
               np.sin(2*np.pi*f1*Te+P1) - np.sin(2*np.pi*f2*Te+P1) + 
               K * (np.sin(4*np.pi*f1*Te+P2) - np.sin(4*np.pi*f2*Te+P2)))
    return (sig,Te)                                        

#eval_Z(f,I2,R1,R2,m,Rf_coefs,Lm_coefs)
def gen_voltage_for_normed_I2(Fe,D,I2rms,f1,f2,R1,R2,m,Rf_coefs,Lm_coefs,Av,nsamples):
    # Z = (R2/m^2 // Rf // jXm), Y = 1/Z
    # V1 = E1*(1+R1*Y), E1 = R2*I2/m, V1 = I2*R2/m*(1+R1*Y)    
    # V1 = V11-V21+V12-V22
    # Vij = 1/Yij*Iij 
    # Yij = Yij(j*fi,e1(j*fi)) = Yij(j*fi,R2*I2(j*fi)/m)
    # Iij = I2rms*1/sqrt(1+K^2)*K^(j-1)*sin(2*pi*j*fi*t+Pi+theta_ij)
    Te  = np.arange(0,nsamples/Fe,1/Fe)
    A1  = sig_An(1,D)    
    K   = sig_K(D)
    K2  = K*K
    P1  = sig_Pn(1,D)
    P2  = sig_Pn(2,D)
    
    # f1 component
    I11 = I2rms*1/(np.sqrt(1+K2))/Av     
    Y11,rho11,theta11 = eval_Y(f1,I11,R2,m,Rf_coefs,Lm_coefs)
    V11 = I11*np.sin(2*np.pi*f1*Te+P1-theta11)*abs(R2/m*(1+R1*Y11))

    # 2*f1 component
    I12 = K*I11     
    Y12,rho12,theta12 = eval_Y(2*f1,I12,R2,m,Rf_coefs,Lm_coefs)
    V12 = I12*np.sin(4*np.pi*f1*Te+P2+theta12)*abs(R2/m*(1+R1*Y12))

    # f2 component
    I21 = I11     
    Y21,rho21,theta21 = eval_Y(f2,I21,R2,m,Rf_coefs,Lm_coefs)
    V21 = I21*np.sin(2*np.pi*f2*Te+P1+theta21)*abs(R2/m*(1+R1*Y21))

    # 2*f2 component
    I22 = K*I21     
    Y22,rho22,theta22 = eval_Y(2*f2,I22,R2,m,Rf_coefs,Lm_coefs)
    V22 = I21*np.sin(4*np.pi*f2*Te+P2+theta22)*abs(R2/m*(1+R1*Y22))
    return (V11-V21+V12-V22,Te)


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
    cos_mc  = np.cos(P)
    cos_ui  = P1/(U1rms*I1rms)
    return (U1rms,I1rms,P1,S1,I2rms,phi1,phi2,phi12,cos_mc,cos_ui)
    

def compute_fft(fe,f1,f2,buf,show_fft):
    df = 10
    sfft=np.fft.fft(buf,round(fe/df),-1,"forward")
    #print('fft on %d pts' % round(fe/df))
    if1   = round(f1/df)
    i2f1  = round(2*f1/df)    
    if2   = round(f2/df)
    i2f2  = round(2*f2/df)  

    if show_fft :
        fig,(ax1,ax2)  = plt.subplots(2,1)
        Te = [float(k)/fe for k in range(0,len(buf))]
        ax1.plot(Te,buf)   
        Ne = round(len(sfft)/2)   
        Fe = [float(k)*df for k in range(0,Ne)]
        ax2.plot(Fe,2*abs(sfft[0:Ne]))      
        plt.show()    

    return (sfft[if1],sfft[i2f1],sfft[if2],sfft[i2f2])

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

def print_sig_values(label,fa,fb,D,fft_fa,fft_2fa,fft_fb,fft_2fb):
    plag_fa,tlag_fa = sig_lag(1/fa,D,fa,np.angle(fft_fa))
    plag_fb,tlag_fb = sig_lag(1/fb,D,fb,np.angle(fft_fb))
    CFT_p_2fa       = np.angle(CFT_sig_ref(1,tlag_fa,1/fa,D,2*fa))
    CFT_p_2fb       = np.angle(CFT_sig_ref(1,tlag_fb,1/fb,D,2*fb))    
    mod_sig         = np.sqrt( 2*(abs(fft_fa)**2 + abs(fft_2fa)**2 + abs(fft_fb)**2 + abs(fft_2fb)**2) )    

    print('FFT %s: |fa|=%.3f arg(fa)=%.3f |2fa|=%.3f arg(2fa)=%.3f |fb|=%.3f arg(fb)=%.3f |2fb|=%.3f arg(2fb)=%.3f |sig|=%1.3f' % 
            (label,2*abs(fft_fa),np.angle(fft_fa),2*abs(fft_2fa),np.angle(fft_2fa),
                   2*abs(fft_fb),np.angle(fft_fb),2*abs(fft_2fb),np.angle(fft_2fb), mod_sig) )
    print('plag_fa=%1.3f tlag_fa=%.6f arg(cft(2fa))=%1.3f arg(fft(2fa))-arg(cft(2fa)=%1.3f plag_fb=%1.3f tlag_fb=%.6f arg(cft(2fb))=%1.3f arg(fft(2fb))-arg(cft(2fb)=%1.3f' % 
            (plag_fa,tlag_fa,CFT_p_2fa,np.angle(fft_2fa)-CFT_p_2fa,plag_fb,tlag_fb,CFT_p_2fb,np.angle(fft_2fb)-CFT_p_2fb))


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

def eval_I2c(I1,U1,cos_mc,R1,Zm,m):   
    I1c    = I1*(cos_mc - 1j*(np.sqrt(1-cos_mc*cos_mc)))
    I2c    = (U1 - I1c*(Zm+R1))/(m*Zm)
    #print('I2=%.3f+%.3fi'% (np.real(I2c),np.imag(I2c)))
    #print('I1=%.3f+%.3fi'% (np.real(I1c),np.imag(I1c)))
    return I2c    

def eval_E1c(I1,U1,cos_mc,R1):    
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

def eval_Y(f,I2,R2,m,Rf_coefs,Lm_coefs):
    # Y = 1/(R2//Rf//i*Lm*w)
    G1 = 1/R1
    G2 = 1/R2
    Rf = eval_Rf(f,R2*I2/m,Rf_coefs)
    Gf = 1/Rf
    Lm = eval_Lm(f,R2*I2/m,Lm_coefs)
    Ym = 1/(2*np.pi*f*Lm)
    Y  = m*m*G2+Gf-1j*Ym
    rho   = abs(Y)
    theta = np.arctan2(np.imag(Y),np.real(Y))
    return (Y,rho,theta)



def check_sig_set(x):
    try:
        i = int(x)
    except ValueError:    
        raise argparse.ArgumentTypeError("must be a number")
    if i<1 or i>4:
        raise argparse.ArgumentTypeError("must be 1|2|3|4")
    return i

def check_clamp(x):
    try:
        i = int(x)
    except ValueError:    
        raise argparse.ArgumentTypeError("must be a number")
    if i<1 or i>3:
        raise argparse.ArgumentTypeError("must be 1|2|3")
    return i    

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



def get_freqs(sig_set,clamp):
    return (sig_set_lst[sig_set][clamp_set[clamp][0]],sig_set_lst[sig_set][clamp_set[clamp][1]])          

if __name__ == '__main__':
    import argparse
    import NI_device as nid
    import MCsinus as mc
    
    # Initialize command line parser
    parser = argparse.ArgumentParser(description='Clamp Limit current.')
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

    parser.add_argument('--sig_set',
                            help='signal set ie 1|2|3|4',
                            type=check_sig_set,
                            metavar='<sig_set>',
                            default=1)  
    parser.add_argument('--clamp',
                            help='Clamp ie 1|2|3',
                            type=check_clamp,
                            metavar='<clamp>',
                            default=1)   
    parser.add_argument('--vdac',
                            help='vdac [0.1..1]',
                            type=check_vdac,
                            metavar='<dac_level>',
                            default=0.1) 
    parser.add_argument('--I2rms',
                            help='I2rms>=0: 0 no I2 control',
                            type=check_positive_or_null,
                            metavar='<I2>',
                            default=2.0)                         
    parser.add_argument('--G1',
                            help='I1=G1*V',
                            type=check_positive,
                            metavar='<calibre_I1>',
                            default=1.0/106.5e-3)
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
    args = parser.parse_args()
    #Retrieve arguments    
    fe_adc=args.fadc    
    fe_dac=args.fdac    
    sig_set = args.sig_set-1
    clamp   = args.clamp-1
    vdac    = args.vdac
    G1      = args.G1
    G2      = args.G2
    norm_I2 = args.I2rms
    Av      = args.Av
    m       = args.m 
    fa,fb   = get_freqs(sig_set,clamp) 
    D       = 2/5  

    print('fadc=%d fdac=%d sig_set=%d clamp=%d vdac=%.1f G1=%.3f G2=%.3f nI2=%.3f Av=%.3f m=%.3f fa=%d fb=%d' % 
            (fe_adc,fe_dac,sig_set+1,clamp+1,vdac,G1,G2,norm_I2,Av,m,fa,fb))  

    """ #test MC 
    sin_v1,Te1 = gen_sin(10000,1.3,102,-2*np.pi/3,1024)
    sin_v2,Te2 = gen_sin(10000,1.3,102,np.pi/6,1024)
    import MCsinus as mc
    A,p,c = mc.sinMC(102,Te1,sin_v1)
    print('A=%1.3f p=%1.3f c=%1.3f' % (A,p,c))
    P1,P2,P = mc.mc_phase_diff(102,Te1,sin_v1,sin_v2)
    print('P1=%1.3f P2=%1.3f P=%1.3f' % (P1,P2,P))
    exit(0) """


    if norm_I2 == 0 :
        #gen_voltage_signal(Fe,D,Vmax,f1,f2,nsamples):
        sig_v,Te = gen_voltage_signal(fe_dac,D,vdac,fa,fb,fe_dac*0.5)       
        
        fft_fa,fft_2fa,fft_fb,fft_2fb  = compute_fft(fe_adc,fa,fb,sig_v,True)
        print_sig_values("sig",fa,fb,D,fft_fa,fft_2fa,fft_fb,fft_2fb)
        exit(0)

        I1buf,U1buf,I2buf = nid.generate_and_sample(sig_v,fe_dac,fe_adc,len(sig_v)-fe_adc*0.2) 
        U1rms,I1rms,P1,S1,I2rms = compute_measures(U1buf,I1buf,I2buf,G1,G2)  
        print('U1rms=%.3f I1rms=%.3f P1=%.3f I2rms=%.3f' % 
            (U1rms,I1rms,P1,I2rms)) 
        bin_fa,bin_2fa,bin_fb,bin_2fb  = compute_fft(fe_adc,fa,fb,U1buf,True)  

        compute_fft(fe_adc,fa,fb,I1buf,G1)
        compute_fft(fe_adc,fa,fb,I2buf,G2)
        exit(0)

    
    
    # generate calibration signal
    # gen_sin(Fe,A,f1,phi,nsamples)
    sig_cal,Te1 = gen_sin(fe_dac,vdac,freq_test,0,fe_dac*0.5)      
    I1buf,U1buf,I2buf = nid.generate_and_sample(sig_cal,fe_dac,fe_adc,len(sig_cal)-fe_adc*0.2) 
    U1rms,I1rms,P1,S1,I2rms,cos_ui = compute_measures(U1buf,I1buf,I2buf,G1,G2)  

    """ fig,(ax1,ax2,ax3)  = plt.subplots(3,1)
    Te = [float(k)/fe_adc for k in range(0,len(I1buf))]
    ax1.plot(Te1,sig_cal)   
    ax2.plot(Te,U1buf)  
    ax3.plot(Te,I1buf)  
    plt.show() """   
    
    # read model params
    lm_coefs = read_coefs_model('Lm_model.csv')
    #print(lm_coefs)
    rf_coefs = read_coefs_model('Rf_model.csv')
    #print(rf_coefs)
    R1 = read_coefs_model('R1.csv')[0]

    # compute E1,Lm,Rf,Zm for computing I2 and R2
    E1c = eval_E1c(I1rms,U1rms,P1,R1)
    E1  = abs(E1c)
    Lm  = eval_Lm(freq_test,E1,lm_coefs)
    Rf  = eval_Rf(freq_test,E1,rf_coefs)
    Zm  = eval_Zm(freq_test,Rf,Lm)

    I2c = eval_I2c(I1rms,U1rms,P1,R1,Zm,m)    
    R2  = abs(m*E1c/I2c) 
    print('E1=%.3f I2_e=%.3f R1=%.3f R2=%.3f Lm=%.6f Rf=%.6f Zm=%.3f' % (abs(E1c),abs(I2c),R1,R2,Lm,Rf,abs(Zm)))  

    if abs(I2c) < norm_I2:
        exit(1) 

    #gen_voltage_for_normed_I2(Fe,D,I2rms,f1,f2,R1,R2,m,Rf_coefs,Lm_coefs,Av,nsamples)
    V1,Te = gen_voltage_for_normed_I2(fe_dac,D,norm_I2,fa,fb,R1,R2,m,rf_coefs,lm_coefs,Av,fe_dac*0.5)    
    I1buf,U1buf,I2buf = nid.generate_and_sample(V1,fe_dac,fe_adc,len(V1)-fe_adc*0.2) 
    U1rms,I1rms,P1,S1,I2rms,cos_ui = compute_measures(fe_adc,U1buf,I1buf,I2buf,G1,G2)

    fig,(ax1,ax2,ax3)  = plt.subplots(3,1)
    Te = [float(k)/fe_adc for k in range(0,len(I1buf))]
    ax1.plot(Te,I1buf)   
    ax2.plot(Te,U1buf)  
    ax3.plot(Te,I2buf)  
    plt.show()