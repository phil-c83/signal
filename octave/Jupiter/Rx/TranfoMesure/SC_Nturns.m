clear all;
close all;

A  = 15.8e-6;
Bm = 1.5;
Al = 33e-9;
W  = 2*pi*410;
Ve = 3/7;
R  = 10e-3;
N  = 100;

f = Nturns(A,Bm,Al,W,Ve,R,N)
j = find(f>0);


plot(j,f(j));
