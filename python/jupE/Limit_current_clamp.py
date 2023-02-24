import nidaqmx
import nidaqmx.constants as nc
import numpy as np
import matplotlib.pyplot as plt
import time
import csv


r_meas_i=94.1e-6
cal_i2=5
Coef_I1 = 1.0

# Add all frequencies to frequency list
freq_list = [410, 440, 470, 480, 520, 560, 590, 610, 640, 670, 710, 740, 770]
# Add all harmonic frequencies to frequency list 
freq_list += [f*2 for f in freq_list]

# Add all voltages to voltage list
volt_list = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]

phi_list=[0]

def gen_sig(fe, amp, f, phi, duration):
    return [amp*np.sin(2*np.pi*f*t+phi) for t in np.arange(0, duration, 1/fe)]

# def wait_user_input():
#     key=input()
#     if key == 'q':
#         quit()

# def compute_r1(P, I1rms, R2cc, m_clamp):
#     Rcc = P / (I1rms ** 2)
#     return Rcc - (R2cc / (m_clamp ** 2))
    
def compute_meas(samples):
    # Convert current samples to A
    # cov = np.cov([[s/r_meas_i for s in samples[0]],samples[1]], bias=True)
    cov = np.cov(samples[0],samples[1], bias=True)    
    #plt.plot(samples[0])
    #plt.plot(samples[1])
    #plt.show()
    # dot = np.dot(samples[0], samples[1]) / (r_meas_i*len(samples[0]))
    #print(cov)
    # print(dot)
    # Compute I1 RMS
    I1rms=np.sqrt(cov[0][0]/(r_meas_i*r_meas_i))*Coef_I1
    # Compute U1 RMS
    U1rms=np.sqrt(cov[1][1])
    # Compute I2 RMS
    I2rms=np.std(samples[2])
    # Compute P
    P = cov[0][1]/r_meas_i*Coef_I1
    # Compute S
    S = U1rms * I1rms
    # Compute cos(phi)
    cosPhi = P / S
    return (I1rms, U1rms, I2rms*cal_i2, P, S, cosPhi)

def print_results(params, results):
    print('Freq=%sHz Voltage=%sV Rep=%s' % (params[0],params[1], params[2]))
    print('I1rms=%.3fA U1rms=%.3fV cos(phi)=%.3f P=%.3fW S=%.3fVA I2rms=%.3fA' % (results[0],results[1],results[5],results[3],results[4],results[2]))
    

def test_clamp(fe_dac, fe_adc, freqs, volts, acq_duration, reps, save_on,quiet):
    file_content=[]
    # Create ADC/DAC handling tasks
    with nidaqmx.Task() as task_dac, nidaqmx.Task() as task_adc:
        # Select ADC/DAC channels
        task_dac.ao_channels.add_ao_voltage_chan("Dev1/ao0") # Clamp output
        task_adc.ai_channels.add_ai_voltage_chan("Dev2/ai0") # Measure I1
        task_adc.ai_channels.add_ai_voltage_chan("Dev2/ai1") # Measure U1
        task_adc.ai_channels.add_ai_voltage_chan("Dev2/ai2") # Measure I2
        # Configure sample clock DAC
        task_dac.timing.cfg_samp_clk_timing(fe_dac, sample_mode=nc.AcquisitionType.FINITE, samps_per_chan=int(fe_dac*(acq_duration+0.2)))
        # Configure sample clock ADC
        task_adc.timing.cfg_samp_clk_timing(fe_adc, sample_mode=nc.AcquisitionType.FINITE, samps_per_chan=int(fe_adc*acq_duration))
        # Generation and measure for all combinations
        for freq in freqs:
            for volt in volts:
                I1rms=0
                U1rms=0
                I2rms=0
                P=0
                S=0
                cosphi=0
                cnt=0
                # Repetition loop
                while cnt < reps:
                    # Count repetitions
                    cnt+=1
                    # Generate signal
                    sig = gen_sig(fe_dac, volt, freq, phi_list[0], (acq_duration+0.2))
                    # Play signal
                    task_dac.write(sig, auto_start=True, timeout=0)
                    # Start data acquisition
                    raw_data = task_adc.read(int(fe_adc*acq_duration))
                    task_dac.wait_until_done(nc.WAIT_INFINITELY)
                    # Stop both DAC & ADC
                    task_dac.stop()
                    # Make computations
                    results=compute_meas(raw_data)
                    #return (I1rms, U1rms, I2rms, P, S, cosPhi)
                    I1rms+=results[0]
                    U1rms+=results[1]
                    I2rms+=results[2]
                    P+=results[3]
                    S+=results[4]
                    cosphi+=results[5]
                    time.sleep(0.5)
                # Compute average values
                I1rms/=cnt
                U1rms/=cnt
                I2rms/=cnt
                P/=cnt
                S/=cnt
                cosphi/=cnt
                # Print results
                if quiet == False:
                    print_results((freq,volt,cnt),(I1rms, U1rms, I2rms, P, S, cosphi))
                if save_on:
                    # Add results to file
                    file_content.append((freq, volt, I1rms, U1rms, cosphi, P, I2rms))
        # Save file
        if save_on:
            import csv
            with open('clamp_{}.csv'.format(time.time()), 'w', newline='') as f:
                writer = csv.writer(f)
                writer.writerow(('frequency', 'voltage', 'I1rms', 'U1rms', 'cos(phi)', 'P', 'I2rms'))
                writer.writerows(file_content)
    return (freq,volt,I1rms,U1rms,P,I2rms)

def check_positive_float(x):
    try:
        f = float(x)
    except ValueError:    
        raise argparse.ArgumentTypeError("must be a floating point number")
    if f <= 0:
        raise argparse.ArgumentTypeError("must be a positive number")
    return f

def check_positive_int(x):
    try:
        i = int(x)
    except ValueError:    
        raise argparse.ArgumentTypeError("must be a number")
    if i <= 0:
        raise argparse.ArgumentTypeError("must be a positive number")
    return i

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

def eval_I2c(I1,U1,P1,R1,Zm,m):
    # I2 = I1*(R1+Zm)-U1 /(m*Zm)
    cos_ui = P1 / (U1*I1)
   # print('cos_ui=%.3f' % cos_ui) 
    I1c    = I1*(cos_ui - 1j*(np.sqrt(1-cos_ui*cos_ui)))
    I2c    = (U1 - I1c*(Zm+R1))/(m*Zm)
    #print('I2=%.3f+%.3fi'% (np.real(I2c),np.imag(I2c)))
    #print('I1=%.3f+%.3fi'% (np.real(I1c),np.imag(I1c)))
    return I2c    

def eval_E1c(I1,U1,P1,R1):
    # E1 = U1-R1*I1
    cos_ui = P1 / (U1*I1)
    E1c    = U1 - R1*I1*(cos_ui - 1j*np.sqrt(1 - cos_ui*cos_ui))
    #print('E1=%.3f+%.3fi'% (np.real(E1c),np.imag(E1c)))   
    return E1c 

def eval_Zm(Rf,Lm,f):
    Xm = 2*np.pi*f*Lm
    Zm = (Rf*Xm*Xm + 1j*Rf*Rf*Xm) / (Rf*Rf + Xm*Xm)
    #print('Zm=%.3f+%.3fi'% (np.real(Zm),np.imag(Zm)))
    return Zm

def eval_Rf(f,v,coefs):
    return eval_poly_model(f,v,coefs)    

def eval_Lm(f,v,coefs):
    return eval_poly_model(f,v,coefs)   



def eval_U1_for_I2(I2,f,R1,R2,m,lm_coefs,rf_coefs):
    G1 = 1/R1
    G2 = 1/R2
    E1 = R2*I2 / m
    Rf = eval_Rf(f,E1,rf_coefs)
    Gf = 1/Rf
    Lm = eval_Lm(f,E1,lm_coefs)
    Xm = 2*np.pi*Lm*f
    Ym = 1 / Xm
    U1 = 1/m * (R2*R1*I2) * np.sqrt(pow((G1 + m*m*G2 + Gf),2) + pow(Ym,2))
    return (U1,E1,Rf,Lm)
    


if __name__ == '__main__':
    import argparse
    # Make sure the lists are all sorted
    freq_list.sort()
    volt_list.sort()
    phi_list.sort()
    # Initialize command line parser
    parser = argparse.ArgumentParser(description='Clamp testing tool for Jupiter.')

    parser.add_argument('--quiet',
                            help='display measures on each iteration',                            
                            default=False)

    parser.add_argument('--fadc',
                            help='select the ADC sample frequency',
                            type=check_positive_int,
                            metavar='<sample_freq>',
                            default=48000)
    parser.add_argument('--fdac',
                            help='select the DAC sample frequency',
                            type=check_positive_int,
                            metavar='<sample_freq>',
                            default=48000)
    parser.add_argument('-f',
                            help='select the frequency range to use. freqs=['+' '.join(map(str,freq_list))+']',
                            type=int,
                            nargs=2,
                            choices=freq_list,
                            metavar='<freq>',
                            required=True)
    parser.add_argument('-v',
                            help='select the voltage range to use. voltages=['+' '.join(map(str,volt_list))+']',
                            type=float,
                            nargs=2,
                            choices=volt_list,
                            metavar='<voltage>',
                            required=True)
    parser.add_argument('-a',
                            help='acquisition duration in seconds',
                            type=check_positive_float,
                            metavar='<acq_duration>',
                            default=0.5)
    parser.add_argument('-r',
                            help='number of repetitions before producting a result',
                            type=check_positive_int,
                            metavar='<n_repeat>',
                            default=1)
    parser.add_argument('-s',
                            help='save results into a CSV file',
                            action='store_true')
    args = parser.parse_args()
    # Retrieve arguments
    # Retrieve ADC sample frequency
    fe_adc=args.fadc
    # Retrieve DAC sample frequency
    fe_dac=args.fdac
    # Retrieve selected frequencies list
    args.f.sort()
    sel_freqs=freq_list[freq_list.index(args.f[0]):freq_list.index(args.f[1])+1]
    # Retrieve selected voltages list
    args.v.sort()
    sel_volts=volt_list[volt_list.index(args.v[0]):volt_list.index(args.v[1])+1]
    # Retrieve acquisition duration
    acq_duration = args.a
    # Retrieve number of repetitions
    reps=args.r
    # Retrieve save mode flag
    save_on=args.s
    # Launch clamp test
    freq,volt,I1rms,U1rms,P1,I2rms = test_clamp(fe_dac, fe_adc, sel_freqs, sel_volts, acq_duration, reps, save_on,args.quiet)

    lm_coefs = read_coefs_model('Lm_model.csv')
    #print(lm_coefs)
    rf_coefs = read_coefs_model('Rf_model.csv')
    #print(rf_coefs)
    R1 = read_coefs_model('R1.csv')[0]
    #print(R1)

    m   = 1/7
    Av  = 1.7 # amplifier gain
    E1c = eval_E1c(I1rms,U1rms,P1,R1)
    E1  = abs(E1c)
    Lm  = eval_Lm(freq,E1,lm_coefs)
    Rf  = eval_Rf(freq,E1,rf_coefs)
    Zm  = eval_Zm(Rf,Lm,freq)
    I2c = eval_I2c(I1rms,U1rms,P1,R1,Zm,m)
    R2p = abs(E1c / (m*I2c)) # secondary R2
    R2  = abs(m*E1c/I2c)
    

    print('I1=%.3f U1=%.3f P1=%.3f cos=%.3f E1=%.3f I2=%.3fA I2m=%.3f R2p=%.3f R2=%.3f R1=%.3f Lm=%.6f Rf=%.3f Zm=%.3f' % 
            (I1rms,U1rms,P1,P1/(I1rms*U1rms),E1,I2rms,abs(I2c),R2p,R2,R1,Lm,Rf,abs(Zm)))     
    
    
    if abs(I2c) > 2.0:
        U1,E1,Rf,Lm=eval_U1_for_I2(2.0,freq,R1,R2,m,lm_coefs,rf_coefs)
        freq,volt,I1rms,U1rms,P1,I2rms = test_clamp(fe_dac, fe_adc, [freq], [U1/Av], acq_duration, reps, save_on,args.quiet)
        print('I1=%.3f U1=%.3f P1=%.3f I2=%.3fA U1m=%.3f E1m=%.3f Lm=%.6f Rf=%.3f' % 
            (I1rms,U1rms,P1,I2rms,U1,E1,Lm,Rf)) 



    