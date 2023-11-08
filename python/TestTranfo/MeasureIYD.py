import NI_sample as nis

class MesureIYD(nis.NI_sample):
    """ current measure for Y mode """
    def __init__(self,dev,chans,fadc,nsamples):
        super().__init__(dev,chans,fadc,nsamples)                
        self._Vg_mod      = [0 for k in range(self._nchans//2)]
        self._VgVm_mod    = [0 for k in range(self._nchans//2)]
        self._VgVm_arg    = [0 for k in range(self._nchans//2)]
        self._Vg_mod_avg      = [0 for k in range(self._nchans//2)]
        self._VgVm_mod_avg    = [0 for k in range(self._nchans//2)]
        self._VgVm_arg_avg    = [0 for k in range(self._nchans//2)]
        self._count = 0

    
    def start(self):
        super().start()

    def stop(self):
        super().stop()
        vg_mod_avg = [v/self._count for v in self._Vg_mod_avg]
        vgvm_mod_avg = [v/self._count for v in self._VgVm_mod_avg]
        vgvm_arg_avg = [v/self._count for v in self._VgVm_arg_avg]
        print(self._measure_str(vg_mod_avg,vgvm_mod_avg,vgvm_arg_avg))
        self.plot_measures()


    def _measure_str(self,Vg_mod,VgVm_mod,VgVm_arg):
        v_mod = Vg_mod
        v_mod.extend(VgVm_mod)
        data_g = ' '.join('{}={:06.3f}'.format(c,m) 
                    for (c,m) in zip(self._chans[0:self._nchans//2],v_mod[0:self._nchans//2]))
        data_v = ' '.join('{}={:06.3f}/{:04.3f}'.format(c,m,a) 
                    for (c,m,a) in zip(self._chans[self._nchans//2:self._nchans],
                                        v_mod[self._nchans//2:self._nchans],
                                        self._VgVm_arg[0:self._nchans//2]) )    
        return(data_g + " " + data_v)

    def _process_measures(self,samples):
        import numpy as np

        super()._process_measures(samples) 

        # 1st half channels for generator voltage
        Vg = [np.array(l) for l in self._measures[0:self._nchans//2]]    
        self._Vg_mod = [np.sqrt(np.cov([x,x],bias=True)[0,0]) for x in Vg]

        # voltage drop 
        Vi = [np.array(l) for l in self._measures[self._nchans//2:self._nchans]] 
        Vg_Vm = [Vg[k]-Vi[k] for k in range(0,3)]     
        self._VgVm_mod = [np.sqrt(np.cov([x,x],bias=True)[0,0]) for x in Vg_Vm]

        # relative phase between generator and voltage drop    
        self._VgVm_arg = [np.arccos(np.cov([Vg[k],Vg_Vm[k]])[0][1]/(self._Vg_mod[k]*self._VgVm_mod[k]))
                    for k in range(0,3)]

        # sum all rms values for average at the end
        for i,v in enumerate(self._Vg_mod):
            self._Vg_mod_avg[i] += v

        for i,v in enumerate(self._VgVm_mod):
            self._VgVm_mod_avg[i] += v 

        self._count += 1 
        print(self._measure_str(self._Vg_mod,self._VgVm_mod,self._VgVm_arg))
        return 0 # for conforming with callback signature

    