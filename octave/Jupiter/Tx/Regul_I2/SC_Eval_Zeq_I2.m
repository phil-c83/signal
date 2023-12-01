
clear all;

#ModZm=0.81 ArgZm=0.4
#ModZs=0.035 ArgZs=1.2
m = 1.0/7;
Z1 = 0.38;
Zm = 0.81*exp(i*0.4);
Zs = 0.035*exp(i*1.2);

Zeq_I2 = Eval_Zeq_I2(Z1,Zs,Zm,m)
abs(Zeq_I2)
ModZeq = ModZeq_I2(Z1,Zs,Zm,m)

