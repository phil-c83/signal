class NI_sample:
    def __init__(self,dev,chans,fadc,nsamples):
        self._dev = dev
        self._chans = chans
        self._nchans = len(chans)
        self._fadc = fadc
        self._nsamples = nsamples
        self._task = None
        self._measures = [[]]


    def start(self):
        import nidaqmx
        import nidaqmx.constants as nc 

        self._task = nidaqmx.task.Task()
        #register all channels
        for c in range(len(self._chans)):
            inputname = '{dev}/{input}'.format(dev=self._dev,input=self._chans[c])
            #print(inputname)
            self._task.ai_channels.add_ai_voltage_chan(inputname)

        self._task.timing.cfg_samp_clk_timing(self._fadc, 
                                                sample_mode=nc.AcquisitionType.CONTINUOUS)        
        # callback arg must be callback(task_handle, every_n_samples_event_type, number_of_samples, callback_data)                                        
        self._task.register_every_n_samples_acquired_into_buffer_event(self._nsamples,
                        lambda a1,a2,a3,a4:self._process_measures(self._task.read(number_of_samples_per_channel=self._nsamples)))
        self._task.start()

    def stop(self):
        self._task.stop()
        self._task.close()


    def _process_measures(self,samples):
        # make list of list
        if len(self._chans) >= 1:                
            s = NI_sample.LongestPeriodicSubsequence(samples[0])
            self._measures = [l[0:len(s)] for l in samples]                                   
        else:
            s = NI_sample.LongestPeriodicSubsequence(samples)
            self._measures = [samples[0:len(s)]]
        return 0    
              

    def plot_measures(self):
        import matplotlib.pyplot as plt        
        Te = [k*1/self._fadc for k in range(len(self._measures[0]))]
        def plot_signal(Te,sig):
            N = len(sig) #number of row
            if N == 1: #subplot() return 1 axes
                fig,ax  = plt.subplots(1,1)
                ax.plot(Te,sig[0])
            else: #subplot() return an array of axes
                fig,ax  = plt.subplots(N,1)
                for i in range(len(ax)):    
                    ax[i].plot(Te,sig[i])                   
            plt.show()

        plot_signal(Te,self._measures)  

    @staticmethod
    def LongestPeriodicSubsequence(s):
        # seek the longuest subsequence into wich there is entire sinuoide periods
        # for this we seek index k for which abs(s[k]-s[0]) < tol and
        # the sign slope is the same as sign slope at s[0]
        import numpy as np
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




        

