close all;
clear all;

N  = 2*1024;
Fs = 50;
Fe = 10*Fs;
Te = (0:N-1)*1/Fe;

r1 = CausalSin(Te,Fs,4*pi/3);

plot(Te,r1,"-*");
