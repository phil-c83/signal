import nidaqmx
import nidaqmx.constants as nc
import numpy as np
import matplotlib.pyplot as plt
import time

r_meas_i=106.5e-3
cal_i2=10

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
    cov = np.cov([[s/r_meas_i for s in samples[0]],samples[1]], bias=True)
    # dot = np.dot(samples[0], samples[1]) / (r_meas_i*len(samples[0]))
    # print(cov)
    # print(dot)
    # Compute I1 RMS
    I1rms=np.sqrt(cov[0][0])
    # Compute U1 RMS
    U1rms=np.sqrt(cov[1][1])
    # Compute I2 RMS
    I2rms=np.std(samples[2])
    # Compute P
    P = cov[0][1]
    # Compute S
    S = U1rms * I1rms
    # Compute cos(phi)
    cosPhi = P / S
    return (I1rms, U1rms, I2rms*cal_i2, P, S, cosPhi)

def print_results(params, results):
    print('Freq=%sHz Voltage=%sV Rep=%s' % (params[0],params[1], params[2]))
    print('I1rms=%.3fA U1rms=%.3fV cos(phi)=%.3f' % (results[0], results[1], results[5]))
    print('P=%.3fW S=%.3fVA' % (results[3],results[4]))
    print('I2rms=%.3fA P1/I1^2=%1.3f' % (results[2],results[3]/(results[0]**2)))
 
def test_clamp(fe_dac, fe_adc, freqs, volts, acq_duration, reps, save_on):
    file_content=[]
    # Create ADC/DAC handling =
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

if __name__ == '__main__':
    import argparse
    # Make sure the lists are all sorted
    freq_list.sort()
    volt_list.sort()
    phi_list.sort()
    # Initialize command line parser
    parser = argparse.ArgumentParser(description='Clamp testing tool for Jupiter.')
    parser.add_argument('--fadc',
                            help='select the ADC sample frequency',
                            type=check_positive_int,
                            metavar='<sample_freq>',
                            default=8000)
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
    test_clamp(fe_dac, fe_adc, sel_freqs, sel_volts, acq_duration, reps, save_on)