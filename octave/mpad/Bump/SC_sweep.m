close all;
clearvars;
close all;
addpath("../../fun");

Fe = 50e3;
f1 = 1e3;
f2 = 5e3;
[s1,t1]=linear_sin_sweep(f1,f2,1e-3,0.001,0,Fe);

plot(t1,s1);

