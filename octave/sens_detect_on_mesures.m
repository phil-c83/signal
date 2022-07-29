pkg load signal
clear all;
close all;

function plot_fft_signal(nTe,y,yfft)
  N = length(nTe);
  Fe = 1/(nTe(2)-nTe(1));
  dF = Fe/N;
  ndF = -Fe/2:dF:Fe/2-dF;
  yffts = fftshift(yfft);
  figure;
  subplot(3,1,1);
  plot(nTe,y,"--.k;sig;");
  subplot(3,1,2);
  plot(ndF,abs(yffts)/N,"--.b;mods;");
  subplot(3,1,3);
  plot(ndF,arg(yffts)*180/pi,"--.g;args;");  
  figure;
  plot3(ndF,yffts);  
endfunction  

m1=dlmread("../data/L1.csv",",",0,0);
figure;
%plot(m1(:,1),m1(:,2),"--.b;L1;");
idx0=find(m1(:,1)==0.2); % on se place ds le signal a t=0.2s
idx=(0:999)*100+idx0; % 1 point sur 100 a partir de t=0.2s pendant 0.1s
s1=m1(idx,:);
plot(s1(:,1),s1(:,2));
ffts1=fft(s1);
plot_fft_signal(s1(:,1),s1(:,2),ffts1);

%{
m2=dlmread("../data/L2.csv",",",0,0);
figure;
plot(m2(:,1),m2(:,2),"--.b;L2;");

m3=dlmread("../data/L3.csv",",",0,0);
figure;
plot(m3(:,1),m3(:,2),"--.b;L3;");
%}