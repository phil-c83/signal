close all;


# get recorded phase fix for signal generators
source("DATA_Phase_fix.m");

# get recorded Z0 @ -10°C <= Temp <= +50°C
source("DATA_Temp_Z0.m");
#plot(temp,abs(Z0_0),";clamp1;",temp,abs(Z0_1),";clamp2;",temp,abs(Z0_2),";clamp3;");
#figure;
#plot(real(Z0_0),imag(Z0_0),";clamp1;",
#     real(Z0_1),imag(Z0_1),";clamp2;",
#     real(Z0_2),imag(Z0_2),";clamp3;");


# constant values for the problem
m = 1/7; Z2 = 50e-3; Z1 = 0.11+0.27; I2 = m*0.5;
T = 0.1; Fe = 8e3; Te = 0:1/Fe:T-1/Fe;

printf("Z0_0_min=%f Z0_0_max=%f @500Hz\n",abs(Z0_0(1)),abs(Z0_0(end)));
printf("Z0_1_min=%f Z0_1_max=%f @500Hz\n",abs(Z0_1(1)),abs(Z0_1(end)));
printf("Z0_2_min=%f Z0_2_max=%f @500Hz\n\n",abs(Z0_2(1)),abs(Z0_2(end)));

Z0n_0_min = normalize_Z(Z0_0(1),2*pi*500);
Z0n_0_max = normalize_Z(Z0_0(end),2*pi*500);
Z0n_1_min = normalize_Z(Z0_1(1),2*pi*500);
Z0n_1_max = normalize_Z(Z0_1(end),2*pi*500);
Z0n_2_min = normalize_Z(Z0_2(1),2*pi*500);
Z0n_2_max = normalize_Z(Z0_2(end),2*pi*500);

ZLn_0_min  = eval_ZLn(Z0n_0_min,Z1,Z2);
ZLn_0_max  = eval_ZLn(Z0n_0_max,Z1,Z2);
printf("ZLn_0_min=%f ZLn_0_max=%f @%1.2fHz\n",abs(ZLn_0_min),abs(ZLn_0_max),1/(2*pi));

ZLn_1_min  = eval_ZLn(Z0n_1_min,Z1,Z2);
ZLn_1_max  = eval_ZLn(Z0n_1_max,Z1,Z2);
printf("ZLn_1_min=%f ZLn_1_max=%f @%1.2fHz\n",abs(ZLn_1_min),abs(ZLn_1_max),1/(2*pi));

ZLn_2_min  = eval_ZLn(Z0n_1_min,Z1,Z2);
ZLn_2_max  = eval_ZLn(Z0n_1_max,Z1,Z2);
printf("ZLn_2_min=%f ZLn_2_max=%f @%1.2fHz\n\n",abs(ZLn_2_min),abs(ZLn_2_max),1/(2*pi));

# ZT ~= k/(Z0-Z1)
ZTn_0_max = eval_ZTn(Z0n_0_min,Z1,Z2/m^2);
ZTn_0_min = eval_ZTn(Z0n_0_max,Z1,Z2/m^2);
printf("ZTn_0_min=%f ZTn_0_max=%f @%1.2fHz\n",abs(ZTn_0_min),abs(ZTn_0_max),1/(2*pi));

ZTn_1_max = eval_ZTn(Z0n_1_min,Z1,Z2/m^2);
ZTn_1_min = eval_ZTn(Z0n_1_max,Z1,Z2/m^2);
printf("ZTn_1_min=%f ZTn_1_max=%f @%1.2fHz\n",abs(ZTn_1_min),abs(ZTn_1_max),1/(2*pi));

ZTn_2_max = eval_ZTn(Z0n_2_min,Z1,Z2/m^2);
ZTn_2_min = eval_ZTn(Z0n_2_max,Z1,Z2/m^2);
printf("ZTn_2_min=%f ZTn_2_max=%f @%1.2fHz\n\n",abs(ZTn_2_min),abs(ZTn_2_max),1/(2*pi));


Z2n_0_min = eval_Z2n(Z0n_0_min,Z1,ZLn_0_min);
Z2n_0_max = eval_Z2n(Z0n_0_max,Z1,ZLn_0_max);
printf("Z2n_0_min=%f Z2n_0_max=%f @%1.2fHz\n\n",abs(Z2n_0_min),abs(Z2n_0_max),1/(2*pi));

V1_0_max = eval_Vg(I2,ZTn_0_max,2/5,2*pi*410,2*pi*440)
V1_0_min = eval_Vg(I2,ZTn_0_min,2/5,2*pi*410,2*pi*440)
I2_0_min = eval_I2(V1_0_max,ZTn_0_min,2/5,2*pi*410,2*pi*440)/m
I2_0_max = eval_I2(V1_0_min,ZTn_0_max,2/5,2*pi*410,2*pi*440)/m

s = Sig_gen_jupE(V1_0_max,410,440,470,Te,dP_S0);
figure;
plot(Te,s(:,1),"g",Te,s(:,2),"y",Te,s(:,3),"r");

