clear all
close all
clc
pkg load signal;

global Fe = 10000;
global N = 4096;

[b,a]=butter(2,[2*300/Fe,2*1000/Fe]);
t = (0:N-1)/Fe;
df= Fe/N;
input=sin(2*pi*10*t)+sin(2*pi*100*t) + sin(2*pi*300*t) + sin(2*pi*600*t) + sin(2*pi*1000*t) + sin(2*pi*2000*t);


%randn(size(t));
output=filter(b,a,input);
figure; plot(t,input);
title("input signal");
figure; plot(t,output);
title("output signal");
ffti=fft(input);
figure;plot((0:N/2-1)*df,2*abs(ffti(1:N/2))/length(ffti));
ffto=fft(output);
figure;plot((0:N/2-1)*df,2*abs(ffto(1:N/2))/length(ffto));
freqz(b,a);

%plot([abs(fft(input));abs(fft(output))]);

