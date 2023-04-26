import csv  
import time

def save_clamp_power_refs(Fe,Fs,U1rms,I1rms,P1,S1,R2,fname):  
    fname = '{}_{}.csv'.format(fname,time.time()) 
    Fe_str = '#Fe={}'.format(Fe)    
    with open(fname, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(('Fs','U1','I1','P1','S1','R2',Fe_str))
        for i in range(0,len(Fs)):
            row = (Fs[i],U1rms[i],I1rms[i],P1[i],S1[i],R2[i])
            writer.writerow(row)

def load_clamp_power_refs(fname):
    fdata = []
    with open(fname, newline='') as csvfile:        
        csvrd = csv.reader(csvfile, delimiter=',')
        csvline =csvrd.__next__() 
        for csvline in csvrd:
            #print('csvlines=%s' % (csvline))            
            values = [float(field) for field in csvline]
            #print('values={}'.format(values) )
            fdata.append(values)         
        return fdata

def get_fs(fdata,nrow):
    return fdata[nrow][0]

def get_U1(fdata,nrow):
    return fdata[nrow][1]

def get_I1(fdata,nrow):
    return fdata[nrow][2]

def get_P1(fdata,nrow):
    return fdata[nrow][3]

def get_S1(fdata,nrow):
    return fdata[nrow][4]

def get_R2(fdata,nrow):
    return fdata[nrow][5]

