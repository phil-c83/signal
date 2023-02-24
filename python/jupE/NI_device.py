

def generate_and_sample(sig,fe_dac,fe_adc,adc_buf_size):
    import nidaqmx
    import nidaqmx.constants as nc
    
    with nidaqmx.Task() as task_dac, nidaqmx.Task() as task_adc:             
        # Select ADC/DAC channels
        task_dac.ao_channels.add_ao_voltage_chan("Dev1/ao0") # Clamp output
        task_adc.ai_channels.add_ai_voltage_chan("Dev2/ai0") # Measure I1
        task_adc.ai_channels.add_ai_voltage_chan("Dev2/ai1") # Measure U1
        task_adc.ai_channels.add_ai_voltage_chan("Dev2/ai2") # Measure I2
        # Configure sample clock DAC
        task_dac.timing.cfg_samp_clk_timing(fe_dac, sample_mode=nc.AcquisitionType.FINITE, samps_per_chan=int(len(sig)))
        # Configure sample clock ADC
        task_adc.timing.cfg_samp_clk_timing(fe_adc, sample_mode=nc.AcquisitionType.FINITE, samps_per_chan=int(adc_buf_size))
        task_dac.write(sig, auto_start=True, timeout=0)
        # Start data acquisition
        raw_data = task_adc.read(int(adc_buf_size))
        task_dac.wait_until_done(nc.WAIT_INFINITELY)
        # Stop both DAC & ADC
        task_dac.stop()
        I1 = raw_data[0]
        U1 = raw_data[1]
        I2 = raw_data[2]
        return (I1,U1,I2)

def gen_sin(Fe,A,f1,phi,nsamples):
    Te  = np.arange(0,nsamples/Fe,1/Fe)
    sig = A*np.sin(2*np.pi*f1*Te+phi) 
    return (sig,Te)        

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


if __name__ == '__main__':
    import argparse
    import numpy as np
    import matplotlib.pyplot as plt
    
    parser = argparse.ArgumentParser(description='NI DAC and ADC')
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
    
    parser.add_argument('--vdac',
                            help='vdac [0.1..1]',
                            type=check_vdac,
                            metavar='<dac_level>',
                            default=0.1)                                                                                        


    args = parser.parse_args()
    #Retrieve arguments
    # Retrieve ADC sample frequency
    fe_adc=args.fadc
    # Retrieve DAC sample frequency
    fe_dac=args.fdac    
    vdac  = args.vdac    

    print('fadc=%d fdac=%d vdac=%.1f' % 
            (fe_adc,fe_dac,vdac)) 
    sig,Te = gen_sin(fe_dac,vdac,480,0,0.5*fe_dac)

    #fig,ax  = plt.subplots()
    #ax.plot(Te,sig)       
    #plt.show()       

    I1,U1,I2 = generate_and_sample(sig,fe_dac,fe_adc,len(sig)-fe_adc*0.2)      

    fig,(axI1,axU1,axI2)  = plt.subplots(3,1)
    Te = [float(k)/fe_adc for k in range(0,len(I1))]
    axI1.plot(Te,I1)
    axU1.plot(Te,U1)
    axI2.plot(Te,I2)               
    plt.show()       

