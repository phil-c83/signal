import json
class channel:
    def __init__(self,buff_U,buff_I,Urms=0,Irms=0,phi=0):
        self.buff_U=buff_U
        self.buff_I=buff_I
        self.Urms=Urms
        self.Irms=Irms
        self.phi=phi

class mesure_U_I:
    def __init__(self,U1,I1,U2,I2,U3,I3,coef_u,coef_i,Z1):
        self.C1=channel(U1,I1)
        self.C2=channel(U2,I2)
        self.C3=channel(U3,I3)
        self.Coef_u=coef_u
        self.Coef_i=coef_i
        self.Z1=Z1
    


class mesure_U_I_Z (mesure_U_I):
     def __init__(self,U1,I1,U2,I2,U3,I3,coef_u,coef_i,Z1):
         super().__init__(U1,I1,U2,I2,U3,I3,coef_u,coef_i,Z1)

class mesure_U_I_Z0 (mesure_U_I):
     def __init__(self,U1,I1,U2,I2,U3,I3,coef_u,coef_i,Z1):
         super().__init__(U1,I1,U2,I2,U3,I3,coef_u,coef_i,Z1)

def complete_chan(voie,z_chan):
    z_chan.Irms=voie['I1rms']
    z_chan.Urms=voie['U1rms']
    z_chan.phi=voie['phi']


def extract_json(obj_json_str):
    data =json.loads(obj_json_str)
    coeff_u= data['coeff_u']
    coeff_i=data['coeff_i']
    Z1=data['Z1']
    try :
        data_Z=data['Z']
    except Exception :
       pass
    else :
        ICH0= data_Z['I_ch0']
        UCH0= data_Z['U_ch0']
        ICH1= data_Z['I_ch1']
        UCH1= data_Z['U_ch1']
        ICH2= data_Z['I_ch2']
        UCH2= data_Z['U_ch2']
        Z=mesure_U_I_Z(UCH0,ICH0,UCH1,ICH1,UCH2,ICH2,coeff_u,coeff_i,Z1)
        voie=data['Voie_1']
        complete_chan(voie,Z.C1)
        voie=data['Voie_2']
        complete_chan(voie,Z.C2)
        voie=data['Voie_3']
        complete_chan(voie,Z.C3)

        return Z

    try :
        data_Z=data['Z0']
        
    except Exception :
        exit(1)
    else :
        ICH0= data_Z['I_ch0']
        UCH0= data_Z['U_ch0']
        ICH1= data_Z['I_ch1']
        UCH1= data_Z['U_ch1']
        ICH2= data_Z['I_ch2']
        UCH2= data_Z['U_ch2']
        Z=mesure_U_I_Z0(UCH0,ICH0,UCH1,ICH1,UCH2,ICH2,coeff_u,coeff_i,Z1)
        voie=data['Voie_1']
        complete_chan(voie,Z.C1)
        voie=data['Voie_2']
        complete_chan(voie,Z.C2)
        voie=data['Voie_3']
        complete_chan(voie,Z.C3)
        return Z


