clear all;

#Urms:1.783 Irms:2.726 Phi:0.438 Z:0.654/0.438 Z0:0.786/0.451 Zs:0.026/1.211
#Urms:1.790 Irms:2.649 Phi:0.386 Z:0.676/0.386 Z0:0.815/0.399 Zs:0.025/1.049
#Urms:1.774 Irms:2.787 Phi:0.400 Z:0.637/0.400 Z0:0.751/0.411 Zs:0.025/1.174

#Urms:1.796 Irms:2.641 Phi:0.447 Z:0.680/0.447 Z0:0.791/0.450 Zs:0.033/1.236
#Urms:1.805 Irms:2.559 Phi:0.390 Z:0.705/0.390 Z0:0.816/0.398 Zs:0.034/1.030
#Urms:1.787 Irms:2.703 Phi:0.404 Z:0.661/0.404 Z0:0.753/0.415 Zs:0.033/1.129

#Z0=0.81/0.4
#Z =0.7/0.4
m  = 1.0/7;
Fs = 500;
R1 = 0.38;
I2 = m*0.5;

M0 = 0.820;
A0 = 0.384;
M  = 0.716;
A  = 0.4;


[Zs,Zp,Ls,Lp] = Eval_Zs_Zp_P2C(M0,A0,R1,Fs)
#[Z2,L2] = Eval_Z2_w_Zp(M,A,Zp,R1,Fs)
[Z2,L2] = Eval_Z2(M,A,real(Zp),imag(Zp),R1,Fs)
printf("|Z2p|= %2.3f |Z2|= %2.3f\n",abs(Z2),abs(Z2)*m^2);
Zeq     = Eval_Zeq_I2(R1,Z2,Zp)
Mod_Zeq = abs(Zeq)
V1      = Eval_V1(Zeq,I2)
V1_max  = V1*sqrt(2)
I2 = V1*Zp/(Z2*Zp+R1*Zp+R1*Z2)
Mod_I2 = abs(I2)/m


