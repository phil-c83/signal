class NI_generator:
    def __init__(self,dev,chans,fdac,vdac,fsig):
        import numpy as np
        import matplotlib.pyplot as plt
        import math 
        # number of Samples for complete signal periods ie N * 1/fdac = K * 1/fsig
        self._nsamples = math.lcm(fdac,fsig)//fsig - 1 
        self._chans = chans
        self._dev   = dev
        self._nphases  = len(chans)
        self._fdac = fdac
        self._vdac = vdac
        self._fsig = fsig  
        self._task = None      
        self._Te,self._sig = self._polyphased_gen()
    
    def stop(self):
        self._task.stop() 
        self._task.close()

    def start(self):          
        import nidaqmx
        import nidaqmx.constants as nc        
        
        self._task =  nidaqmx.task.Task()          
        #register all ao channels
        for c in range(len(self._chans)):
            ao_name = '{dev}/{output}'.format(dev=self._dev,output=self._chans[c])
            #print(ao_name)
            self._task.ao_channels.add_ao_voltage_chan(ao_name)
        
        # Configure sample clock DAC and generate signal for indefinite time
        self._task.timing.cfg_samp_clk_timing(self._fdac,
            sample_mode=nc.AcquisitionType.CONTINUOUS,
            samps_per_chan=self._nsamples)
        self._task.write(self._sig)
        self._task.start() 

    def plot_sig(self):
        import matplotlib.pyplot as plt        
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

        plot_signal(self._Te,self._sig)    


    # generator can be surcharged to define another polyphased periodic signal
    def _polyphased_gen(self):
        import numpy as np
        def gen_polyphased_sin(fs,fe,A,Ns,N,phase):       
        # f = sin(2*pi*fs/fe*k - 2*pi/N*n + phase) n=0..N-1
            Fn  = 2*np.pi*fs/fe # Numeric frequency       
            Te  = [1/fe*k for k in range(Ns)] # time vector
            sig = np.ndarray([N,Ns]) # a matrix NxNs of sin
            for i in range(N):
                sig[i,:] = [A*np.sin(Fn*k - 2*np.pi/N*i + phase) for k in range(Ns)]       
            return Te,sig 
        return gen_polyphased_sin(self._fsig,self._fdac,self._vdac,
                            self._nsamples,self._nphases,0) 
