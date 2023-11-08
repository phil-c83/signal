import NI_sample as nis

class ratio_mYD(nis.NI_sample):
    def __init__(self,dev,chans,fadc,nsamples,ratio_measure):
        super().__init__(dev,chans,fadc,nsamples)        
        self._LV_rms   = []
        self._HV_rms   = []        
        self._HV_LV_ratio = []
        self._HV_rms_avg   = [0 for k in range(self._nchans//2)] 
        self._LV_rms_avg   = [0 for k in range(self._nchans//2)]        
        self._count = 0
        self._ratio_meas = ratio_measure

    def start(self):
        super().start()

    
    def stop(self):        
        super().stop()
        HV_avg = [v/self._count for v in self._HV_rms_avg]
        LV_avg = [v/self._count for v in self._LV_rms_avg]
        ratio_avg = [vlv for (vhv,vlv) in zip(self._HV_rms_avg,self._LV_rms_avg)]
        print(self._measure_str(LV_avg,HV_avg,ratio_avg))
        self.plot_measures()

    def _process_measures(self,samples):
        import numpy as np

        super()._process_measures(samples)
        
        # 1st half channels LV side generator 
        Vg = [np.array(l) for l in self._measures[0:self._nchans//2]]    
        self._LV_rms = [np.sqrt(np.cov([x,x],bias=True)[0,0]) for x in Vg] 

        # 2nd half channels HV side voltage  
        Vh = [np.array(l) for l in self._measures[self._nchans//2:self._nchans]]             
        self._HV_rms = [self._ratio_meas*np.sqrt(np.cov([x,x],bias=True)[0,0]) for x in Vh]

        # ratio HV LV voltage
        self._HV_LV_ratio = [vhv/vlv for (vhv,vlv) in zip(self._HV_rms,self._LV_rms)]

        # sum all rms values for average at the end
        for i,v in enumerate(self._HV_rms):
            self._HV_rms_avg[i] += v
        
        for i,v in enumerate(self._LV_rms):
            self._LV_rms_avg[i] += v
        
        self._count += 1

        print(self._measure_str(self._LV_rms,self._HV_rms,self._HV_LV_ratio))
        return 0

    def _measure_str(self,LV,HV,HV_LV_ratio):
        v_rms = LV
        v_rms.extend(HV)        

        str_v = ' '.join('{}:{:06.3f}'.format(c,m) for(c,m) in zip(self._chans[:],v_rms[:]) )
        str_r = ' '.join('{}:{:06.3f}'.format(c,m) for (c,m) in zip(["R1","R2","R3"],self._HV_LV_ratio[:]))
        
        return(str_v + " " + str_r)
