

def check_vdac(x):
    try:
        v = float(x)
    except ValueError:    
        raise argparse.ArgumentTypeError("must be a floating point number")
    if v <= 0.0 or v > 10.0:
        raise argparse.ArgumentTypeError("must be in ]0,10]")
    return v  

def check_mode(m):
    if m not in mode:
       raise argparse.ArgumentTypeError("Must be a good mode, see help!") 
    else:
        return m   



if __name__ == '__main__':    
    import argparse  

    global mode 
    mode =  ["mYD","mDY","IYD","None"] 
    mode_str = '|'.join(mode) 
    
    
    # Initialize command line parser
    parser = argparse.ArgumentParser(description='PyTestTranfo')
    
    # devices name

    parser.add_argument('--devdac',
                            help='dac devname',                            
                            metavar='<devname>',
                            default="Dev2")

    parser.add_argument('--devadc',
                            help='adc devname',                            
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
                            default=5000)

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
                            
    parser.add_argument('--mode',                         
                        help=mode_str,
                        type=check_mode,
                        metavar='<type>',
                        default=mode[-1])   

    parser.add_argument('--info', 
                        action='store_const', 
                        help='Devices info',
                        const=True,
                        default=False)                                                           

    #Retrieve arguments 
    args = parser.parse_args()       
         

    
    # print args
    print('Devdac=%s Devadc=%s fs=%d fdac=%d fadc=%d vdac=%.1f mode=%s' % 
            (args.devdac,args.devadc,args.fs,args.fdac,args.fadc,args.vdac,args.mode))  

    
        
    if args.info == True:
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
            
    elif args.mode == mode[-1]:  
        import NI_generator as ni_gen

        gen = ni_gen.NI_generator(args.devdac,["ao0","ao1","ao2"],args.fdac,args.vdac,args.fs)
        gen.plot_sig()

        # Te,sig = gen_polyphased_sin(fsig,fdac,vdac,950,3,np.pi/3)  
        # plot_signal(Te,sig)
        # S = LongestPeriodicSubsequence(sig[0])      
        # nTe = Te[0:len(S)]
        # nSig=sig[:,0:len(S)]
        # plot_signal(nTe,nSig)
                
    else:
        if args.mode == mode[2]: # IYD
            import NI_generator as ni_gen
            gen = ni_gen.NI_generator(args.devdac,["ao0","ao1","ao2"],args.fdac,args.vdac,args.fs)
            gen.start()

            import MeasureIYD as mYD
            miyd = mYD.MesureIYD(args.devadc,["ai0","ai1","ai2","ai3","ai4","ai5"],
                                args.fadc,args.fadc)
            miyd.start()
            input("Running task. Press Enter to stop\n") 
            gen.stop()
            miyd.stop()

        elif args.mode == mode[1]: # mDY
            import NI_generator as ni_gen
            gen = ni_gen.NI_generator(args.devdac,["ao0","ao1","ao2"],args.fdac,args.vdac,args.fs)
            gen.start()

            import ratio_mDY as rdy
            mdy = rdy.ratio_mDY(args.devadc,["ai0","ai1","ai2","ai3","ai4","ai5"],
                                args.fadc,args.fadc)
            mdy.start()
            input("Running task. Press Enter to stop\n") 
            gen.stop()
            mdy.stop()

        elif args.mode == mode[0]: # mYD
            import NI_generator as ni_gen
            gen = ni_gen.NI_generator(args.devdac,["ao0","ao1","ao2"],args.fdac,args.vdac,args.fs)
            gen.start()

            import ratio_mYD as ryd
            myd = ryd.ratio_mYD(args.devadc,["ai0","ai1","ai2","ai3","ai4","ai5"],
                                args.fadc,args.fadc,(10.0+1.0)/1.0)
            myd.start()
            input("Running task. Press Enter to stop\n") 
            gen.stop()
            myd.stop()

        else:    
            pass
        