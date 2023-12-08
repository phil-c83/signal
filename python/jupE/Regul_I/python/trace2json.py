import sys
import re
import extract_json as ej
import avg_Z
class Txt2Json:
    def __init__(self,fname,start_pattern,stop_pattern):
        self.start_pat = start_pattern
        self.stop_pat  = stop_pattern
        self.fname     = fname
        self.text      = self.open(self.fname)        
        self.text = self.text.replace("\n","")
        self.pattern = self.start_pat + r'(.*?)' + self.stop_pat        
        self.jsons = re.findall(self.pattern,
                                self.text, flags=0)
        self.count = 0
        
        # self.iter      = re.finditer(self.start_pat + '(.*?)' + self.stop_pat,
        #                              self.text, flags=0).__iter__()                             
    
    def open(self,txtfilepath):
        with open(txtfilepath, 'r') as file:
            return file.read()

    def next(self):
        if self.count < len(self.jsons):
            json_str = self.jsons[self.count]           
            self.count += 1 
            return True,json_str
        else:
            return False,""   
        # try:
        # # Retrieve the next item
        #    json = self.iter.__next__()             
        # except StopIteration:            
        #     print(self.text)            
        # else:        
        #     print(json.string)


if __name__ == '__main__':        
    #print(sys.argv)
    nargs = len(sys.argv)-1    
    if nargs != 1:
        print("Usage: " + str(sys.argv[0] + " <fname>"))
        exit(1)
    else:
        tj = Txt2Json(sys.argv[1],"START_JSON","STOP_JSON")
        # one object EvalZ by channel for Z0 eval
        avgZ01 = avg_Z.EvalZ()
        avgZ02 = avg_Z.EvalZ()
        avgZ03 = avg_Z.EvalZ()
        computed_avgZ = False
        
        while True:
            err,json_str = tj.next()
            if err == False:               
                exit(0)
            else:
                # process json string
                # print(json_str + "\n")
                dataZ=ej.extract_json(json_str)
                if type(dataZ) == ej.mesure_U_I_Z: # measures for computing Z and Zs
                    # one object EvalZ for each channel for each measure
                    if computed_avgZ == False:
                        avg_Z01 = avgZ01.avg_z()
                        avg_Z02 = avgZ02.avg_z()
                        avg_Z03 = avgZ03.avg_z()
                        print(avgZ01.avgZ2str("avg_Z01") + "  " +
                              avgZ02.avgZ2str("avg_Z02") + "  " +
                              avgZ03.avgZ2str("avg_Z03"))
                        print("\n")
                        computed_avgZ = True

                    ZClamp1 = avg_Z.EvalZ()
                    ZClamp2 = avg_Z.EvalZ()
                    ZClamp3 = avg_Z.EvalZ() 
                    # compute Z for this measure
                    Urms1,Irms1,Phi1,Zc1=ZClamp1.process_measure(dataZ.C1,dataZ.Coef_u,dataZ.Coef_i)
                    Urms2,Irms2,Phi2,Zc2=ZClamp2.process_measure(dataZ.C2,dataZ.Coef_u,dataZ.Coef_i)
                    Urms3,Irms3,Phi3,Zc3=ZClamp3.process_measure(dataZ.C3,dataZ.Coef_u,dataZ.Coef_i)
                    
                    # compute Zs for this Zci (i=1,2,3), Z0,Z1,m
                    Z21=ZClamp1.Compute_Z2(Zc1,avg_Z01,dataZ.Z1)
                    print(ZClamp1.str_trace_Z2(Urms1,Irms1,Phi1,Zc1,avg_Z01,Z21))

                    Z22=ZClamp2.Compute_Z2(Zc2,avg_Z02,dataZ.Z1)
                    print(ZClamp1.str_trace_Z2(Urms2,Irms2,Phi2,Zc2,avg_Z02,Z22))

                    Z23=ZClamp3.Compute_Z2(Zc3,avg_Z03,dataZ.Z1)
                    print(ZClamp1.str_trace_Z2(Urms3,Irms3,Phi3,Zc3,avg_Z03,Z23))

                    print("\n")
                                        

                elif type(dataZ) == ej.mesure_U_I_Z0: # measures for computing Z0 

                    Urms,Irms,Phi,Z=avgZ01.process_measure(dataZ.C1,dataZ.Coef_u,dataZ.Coef_i) 
                    print(avgZ01.str_trace_Z(Urms,Irms,Phi,Z))                   
                    Urms,Irms,Phi,Z=avgZ02.process_measure(dataZ.C2,dataZ.Coef_u,dataZ.Coef_i)
                    print(avgZ02.str_trace_Z(Urms,Irms,Phi,Z))                   
                    Urms,Irms,Phi,Z=avgZ03.process_measure(dataZ.C3,dataZ.Coef_u,dataZ.Coef_i)
                    print(avgZ03.str_trace_Z(Urms,Irms,Phi,Z))                   

                    # print(avgZ02.str_trace_Z(Urms,Irms,Phi,Z))
                    # print(avgZ01.str_trace_Z(Urms,Irms,Phi,Z))
                    # print(avgZ03.str_trace_Z(Urms,Irms,Phi,Z))
                    # print("\n")

        

                
        


    


    