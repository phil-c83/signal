
clear all;


m  = 1.0/7;
Z1 = 0.38;
Z0 = 0.81*exp(i*0.4);
Z  = 0.7*exp(i*0.4);


Zeq_I2 = Eval_Zeq_I2(Z1,Zs,Zm,m)
abs(Zeq_I2)
ModZeq = ModZeq_I2(Z1,Zs,Zm,m)

