
def CausalFun(f,t): #ie f(t)*heaviside(t)
    if t>0:
        return f(t)
    else:
        return 0

def gen_polyphased_sin(fs,fe,A,Ns,N,phase):       
    # f = sin(2*pi*fs/fe*k - 2*pi/N*n + phase) n=0..N-1
    Fn  = 2*np.pi*fs/fe # Numeric frequency       
    Te  = [1/fe*k for k in range(Ns)] # time vector
    sig = np.ndarray([N,Ns]) # a matrix NxNs of sin
    for i in range(N):
        sig[i,:] = [A*np.sin(Fn*k - 2*np.pi/N*i) for k in range(Ns)]       
    return Te,sig     


def plot_signal(Te,sig):
    N = sig.shape[0] #number of row
    if N == 1: #subplot() return 1 axes
        fig,ax  = plt.subplots(1,1)
        ax.plot(Te,sig[0,:])
    else: #subplot() return an array of axes
        fig,ax  = plt.subplots(N,1)
        for i in range(len(ax)):    
            ax[i].plot(Te,sig[i,:])                   
    plt.show()


def NI_3Phases_gen(dev,fs,fe,A,Ns):    
    import nidaqmx
    from nidaqmx.stream_writers import AnalogMultiChannelWriter
    from nidaqmx.constants import AcquisitionType

    blk_cpt = 0 
    global ostream   

    with nidaqmx.Task() as task_ao:
        task_ao.ao_channels.add_ao_voltage_chan(dev + "/" + "ao0")
        task_ao.ao_channels.add_ao_voltage_chan(dev + "/" + "ao1")
        task_ao.ao_channels.add_ao_voltage_chan(dev + "/" + "ao2")

        # set initial state to 0V
        sa0 = [0 for k in range(1000)]
        sig=[sa0,sa0,sa0]
        task_ao.timing.cfg_samp_clk_timing(fe,
            sample_mode=AcquisitionType.FINITE,
            samps_per_chan=Ns)
        
        task_ao.write(sig)
        task_ao.start() 
        task_ao.wait_until_done( nidaqmx.constants.WAIT_INFINITELY)
        task_ao.stop()

        # Generate signal for indefinite time
        task_ao.timing.cfg_samp_clk_timing(fe,
            sample_mode=AcquisitionType.CONTINUOUS,
            samps_per_chan=Ns)
        Te,sig = gen_polyphased_sin(fs,fe,A,Ns,3,0)                         
        
        task_ao.write(sig)
        task_ao.start()  

        #task.wait_until_done( nidaqmx.constants.WAIT_INFINITELY)
        input("press Enter to stop...")

        task_ao.stop()

def NI_sample(dev_adc,fe_adc,chans,Ns):
    # dev_adc : str for device
    # fe_adc  : samples by channel frequency
    # chans   : string list of channels (ie ["ai0","ai3"])
    # Ns      : number of samples to read by channel    
    import nidaqmx
    import nidaqmx.constants as nc   

    with nidaqmx.Task() as task:
        #register all channels
        for c in range(len(chans)):
            inputname = '{dev}/{input}'.format(dev=dev_adc,input=chans[c])
            print(inputname)
            task.ai_channels.add_ai_voltage_chan(inputname)

        task.timing.cfg_samp_clk_timing(fe_adc, sample_mode=nc.AcquisitionType.CONTINUOUS)        

        def callback(task_handle, every_n_samples_event_type, number_of_samples, callback_data):
            """Callback function for reading singals."""
            #print("Every N Samples callback invoked.")

            samples = task.read(number_of_samples_per_channel=Ns)

            #compute rms value for each channel
            if len(chans) >= 1:
                rms = [np.sqrt(np.cov([x,x])[0,0]) for x in samples]                    
            else:
                rms = [np.sqrt(np.cov([samples,samples])[0,0])]           

            print(rms)

            return 0

        task.register_every_n_samples_acquired_into_buffer_event(Ns,callback)
        task.start()

        input("Running task. Press Enter to stop\n")
        task.stop()
        return task


def LongestPeriodicSubsequence(s):
    # seek the longuest subsequence into wich there is entire sinuoide period
    # for this we seek index k for which abs(s[k]-s[0]) < tol and
    # the sign slope is the same as sign slope at s[0]
    ds = s[1]-s[0] 
    tol= np.abs(ds) # tol is increment from initial value
    # seek from end 
    for i,v in enumerate(s[-2:0:-1]):
        err = np.abs(v-s[0]) # v == s[-2-i]
        if  err <= tol and np.sign(ds) == np.sign(s[-2-i+1]-v):
            if np.abs(s[-2-i-1]-s[0]) < err:
                return s[0:-2-i-1]
            else:
                return s[0:-2-i]

def cb_measures(fe,fsig,measures,chan_ai):
    # fe      : sample freq
    # fsig    : signal freq
    # measure : list of list of samples for each channel
    # chan_ai : list of input channels str    

    t = [1/fe*k for k in range(len(measures[0]))]
    
    rms = [np.sqrt(np.cov([x,x])[0,0]) for x in measures] 
    angleCov = [0]   
    angleCov.extend([np.arccos(np.cov([measures[0],measures[k]])[0][1]/(rms[0]*rms[k]))
                    for k in range(1,len(measures))])
                        
    data_f = ' '.join('{}={:05.2f}/{:04.2f}'.format(i,j,k) for (i,j,k) in zip(chan_ai,rms,angleCov))
    print(data_f)        
    print("")

def cb_Gen_Y_Meas_D(fe,fsig,measures,chan_ai,rms_Vg,rms_Vm,count):
    # Y Generator (LV side) , D Measures (HV side)
    # first three channels for generator voltage on LV side ie chan_ai[0:2]
    # last three channels for voltage on HV side with voltage divisor ie chan_ai[3:]
    # fe      : sample freq
    # fsig    : signal freq
    # measure : list of list of samples for each channel
    # chan_ai : list of input channels str 

    HV_div = 10.85
    LV_voltage = [np.array(l) for l in measures[0:3]]   
    LV_rms = [np.sqrt(np.cov([x,x],bias=True)[0,0]) for x in LV_voltage]

    #print(LV_rms)
    HV_voltage = [np.array(l) for l in measures[3:6]]
    delta_voltage = [HV_voltage[0]-HV_voltage[1],
                     HV_voltage[1]-HV_voltage[2],
                     HV_voltage[2]-HV_voltage[0]]
    HV_rms = [np.sqrt(np.cov([x,x],bias=True)[0,0])*HV_div for x in delta_voltage]

    # sum all rms values for average at the end
    for i,v in enumerate(LV_rms):
        rms_Vg[i] += v

    for i,v in enumerate(HV_rms):
        rms_Vm[i] += v 

    count[0] += 1
    
    LHV_rms=LV_rms
    LHV_rms.extend(HV_rms)
    data_v = ' '.join('{}={:06.3f}'.format(c,m) for(c,m) in zip(chan_ai,LHV_rms))
    
    print(data_v)
    print("")
    
    
def cb_Gen_D_Meas_Y(fe,fsig,measures,chan_ai,rms_Vg,rms_Vm,count):
# D Generator (HV side) , Y Measures (LV side)
# first three channels for generator voltage on HV side ie chan_ai[0:2]
# last three channels for voltage on LV side ie chan_ai[3:]
# fe      : sample freq
# fsig    : signal freq
# measure : list of list of samples for each channel
# chan_ai : list of input channels str 
    
    HV_voltage = [np.array(l) for l in measures[0:3]]   
    HV_rms = [np.sqrt(np.cov([x,x],bias=True)[0,0]) for x in HV_voltage]
    #print(LV_rms)
    LV_voltage = [np.array(l) for l in measures[3:6]]        
    LV_rms = [np.sqrt(np.cov([x,x],bias=True)[0,0]) for x in LV_voltage]   

    # sum all rms values for average at the end
    for i,v in enumerate(HV_rms):
        rms_Vg[i] += v

    for i,v in enumerate(LV_rms):
        rms_Vm[i] += v 

    count[0] += 1     
    
    HVL_rms = HV_rms
    HVL_rms.extend(LV_rms)
    data_v = ' '.join('{}={:06.3f}'.format(c,m) for(c,m) in zip(chan_ai,HVL_rms))    
    print(data_v)
    print("")


def NI_generate_and_sample(dev_dac,dev_adc,fe_dac,fs,fe_adc,
                           chans_ao,chans_ai,A,Ns,cb_meas):
    # dev_dac : str for dac device
    # dev_adc : str for adc device
    # fe_dac  : samples/channel frequency
    # fe_adc  : samples/channel frequency
    # fs      : sinuoidal signal frequency
    # chans_ao: string list of output channels (ie ["a00","a03"])
    # chans_ai: string list of input channels (ie ["ai0","ai4"])
    # A       : Amplitude for dac 
    # Ns      : number of samples to write/read by channel
    # cb_meas : callback called with a list of list of samples
    import nidaqmx
    import nidaqmx.constants as nc

    measures = []
    
    with nidaqmx.Task() as task_dac, nidaqmx.Task() as task_adc:             
        
        #register all ao channels
        for c in range(len(chans_ao)):
            ao_name = '{dev}/{output}'.format(dev=dev_dac,output=chans_ao[c])
            #print(ao_name)
            task_dac.ao_channels.add_ao_voltage_chan(ao_name)
        
        # Configure sample clock DAC and generate signal for indefinite time
        task_dac.timing.cfg_samp_clk_timing(fe_dac,
            sample_mode=nc.AcquisitionType.CONTINUOUS,
            samps_per_chan=Ns)
        Te,sig = gen_polyphased_sin(fs,fe_dac,A,Ns,len(chans_ao),0) 
        task_dac.write(sig)
        task_dac.start() 

        #register all ai channels
        for c in range(len(chans_ai)):
            ai_name = '{dev}/{input}'.format(dev=dev_adc,input=chans_ai[c])
            #print(ai_name)
            task_adc.ai_channels.add_ai_voltage_chan(ai_name)
        
        # Configure sample clock ADC
        task_adc.timing.cfg_samp_clk_timing(fe_adc,sample_mode=nc.AcquisitionType.CONTINUOUS)
        
        
        measures = []
        Rms_Vg   = [0.0,0.0,0.0]
        Rms_Vm   = [0.0,0.0,0.0]
        count    = [0] # for passing by ref to callback
        # define callback for continuous sampling task
        def callback(task_handle, every_n_samples_event_type, number_of_samples, callback_data):                    
            nonlocal measures,Rms_Vg,Rms_Vm,count
            #print("Every N Samples callback invoked.")
            samples = task_adc.read(number_of_samples_per_channel=fe_adc)

            # make the return list of list
            if len(chans_ai) >= 1:                
                s = LongestPeriodicSubsequence(samples[0])
                measures = [l[0:len(s)] for l in samples]                                   
            else:
                s = LongestPeriodicSubsequence(samples)
                measures = [samples[0:len(s)]]                                         
            
            # pass measures to callback
            cb_meas(fe_adc,fs,measures,chans_ai,Rms_Vg,Rms_Vm,count)            
            return 0
        
        task_adc.register_every_n_samples_acquired_into_buffer_event(fe_adc,callback)
        task_adc.start()
        
        input("Running task. Press Enter to stop\n")           
        task_dac.stop()
        task_adc.stop()

        avg_Rms_Vg = [v/count[0] for v in Rms_Vg]
        avg_Rms_Vm = [v/count[0] for v in Rms_Vm]

        Ratio_Vg_Vm = [max(vg/vm,vm/vg) for (vg,vm) in zip(avg_Rms_Vg,avg_Rms_Vm)]

        avg_rms = avg_Rms_Vg
        avg_rms.extend(avg_Rms_Vm)
        
        data_v = ' '.join('{}={:06.3f}'.format(c,m) for(c,m) in zip(chans_ai,avg_rms)) 
        data_r = ' '.join('{}={:05.2f}'.format(r,v) for (r,v) in zip(["R1","R2","R3"],Ratio_Vg_Vm))
        print(data_v + " " + data_r)

        # plot the last acquisition
        plot_signal([1/fe_adc*k for k in range(len(measures[0]))],np.array(measures))             
        return


def check_fe(x):
    try:
        i = int(x)
    except ValueError:    
        raise argparse.ArgumentTypeError("must be a number")
    if i<10 or i>100:
        raise argparse.ArgumentTypeError("must be [10..100]")
    return i  

def check_vdac(x):
    try:
        v = float(x)
    except ValueError:    
        raise argparse.ArgumentTypeError("must be a floating point number")
    if v <= 0.0 or v > 10.0:
        raise argparse.ArgumentTypeError("must be in ]0,10]")
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
    try:
        v = float(x)
    except ValueError:    
        raise argparse.ArgumentTypeError("must be a number")
    if v < 10.0 or v > 100.0:
        raise argparse.ArgumentTypeError("10 =< fs <= 100")         
    return v


if __name__ == '__main__':    
    import argparse
    import numpy as np
    import matplotlib.pyplot as plt
    import math    
    
    # Initialize command line parser
    parser = argparse.ArgumentParser(description='3 Phases generator')
    
    # devices name

    parser.add_argument('--devdac',
                            help='dac devname',                            
                            metavar='<devname>',
                            default="Dev2")

    parser.add_argument('--devadc',
                            help='adc devname>',                            
                            metavar='<devname>',
                            default="Dev1")
    # sample frequency
    parser.add_argument('--fdac',
                            help='dac sample frequency',
                            type=int,
                            metavar='<freq>',
                            default=10000)

    parser.add_argument('--fadc',
                            help='adc sample frequency',
                            type=int,
                            metavar='<freq>',
                            default=10000)

    parser.add_argument('--fs',
                            help='signal frequency',
                            type=int,
                            metavar='<freq>',
                            default=50)   

    parser.add_argument('--vdac',
                            help='vdac ]0,10]',
                            type=check_vdac,
                            metavar='<VdacMax>',
                            default=1)  
    parser.add_argument('--dry', 
                        action='store_const', 
                        help='Just plot signal',
                        const=True,
                        default=False)   

    parser.add_argument('--info', 
                        action='store_const', 
                        help='Devices info',
                        const=True,
                        default=False)                                                           

    
    args = parser.parse_args()
    #Retrieve arguments       
    fsig  = args.fs
    fdac  = args.fdac 
    fadc  = args.fadc   
    vdac  = args.vdac 
    devdac= args.devdac
    devadc= args.devadc       

    # number of Samples for 1 complete signal period
    Nsamples = math.lcm(fdac,fsig)//fsig - 1

    # print args
    print('Devdac=%s Devadc=%s fsig=%d fdac=%d fadc=%d vdac=%.1f Ns=%d' % 
            (devdac,devadc,fsig,fdac,fadc,vdac,Nsamples))  

    if args.dry == True:        
        Te,sig = gen_polyphased_sin(fsig,fdac,vdac,950,3,np.pi/3)  
        plot_signal(Te,sig)
        S = LongestPeriodicSubsequence(sig[0])      
        nTe = Te[0:len(S)]
        nSig=sig[:,0:len(S)]
        plot_signal(nTe,nSig)
        
        
    elif args.info == True:
        import nidaqmx
        local_system = nidaqmx.system.System.local()
        driver_version = local_system.driver_version
        print(
            "DAQmx {0}.{1}.{2}".format(
                driver_version.major_version,
                driver_version.minor_version,
                driver_version.update_version,
            )
        )  
        for device in local_system.devices:
            print("Device Name: {0}, Product Category: {1}, Product Type: {2}".format(
                device.name, device.product_category, device.product_type)
            ) 
    else:
        NI_generate_and_sample(devdac,devadc,fdac,fsig,fadc,["ao0","ao1","ao2"],
                               ["ai0","ai1","ai2","ai3","ai4","ai5"],
                               vdac,Nsamples,cb_Gen_Y_Meas_D)
        # NI_generate_and_sample(devdac,devadc,fdac,fsig,fadc,["ao0","ao1","ao2"],
        #                        ["ai0","ai1","ai2","ai3","ai4","ai5"],
        #                        vdac,Nsamples,cb_Gen_D_Meas_Y)                               
        
        
        # nsamples = len(samples)
        # print(nsamples)
        # Te = [1/fadc*k for k in range(nsamples)]
        # Sig= np.array([samples])
        # plot_signal(Te,Sig)
        #NI_3Phases_gen(devdac,fsig,fdac,vdac,Nsamples) 


        


