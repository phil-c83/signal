clear all
close all
clc
pkg load signal;

% signal params
Fsig=500;
Fe=Fsig*20;
N=10e-3*Fe;
t=(0:N-1)/Fe;
t=t';


s=sin(2*pi*Fsig*t);
%figure;plot(t,s,"marker",'+',"color",'k');
%title('Signal s');

s2=sin(2*pi*Fsig*t-pi);
%figure;plot(t,s2,"marker",'+',"color",'b');
%title('Signal s2');

% barker 13 code +1 +1 +1 +1 +1 −1 −1 +1 +1 −1 +1 −1 +1  vector with s & s2
s_Barker13=[s ; s ; s; s; s ; s2 ; s2 ; s ; s ; s2 ; s ; s2 ; s];


%tB=(1:length(s_Barker13))/Fe;
%tB=tB';
%figure;plot(tB,s_Barker13);
%title('Barker13'); 

% Barker13 derivative
ds_Barker13=[diff(s_Barker13)*Fe;0];
%figure;plot(tB,ds_Barker);
%title('Barker13 derivative');


%{
 zeros_padding() : adding n zeros to vector v
 v: columns vector, 
 n: number of zeros to insert in front (if n>0) or 
    on back (if n<0) of v
 return vs: vector of the same length of v 
%}
function vs=zeros_padding(v,n)  
  if n > 0     
    vs=[zeros(n,1);v(1:end-n)];
  elseif n < 0
    vs=[v(-n+1:end);zeros(-n,1)];
  else
    vs=v;
  end
end

function [c_corr,ratio]=test_corr(v,v_ref,npad,nfft)
  global Fe;
  m_v=zeros_padding(v,npad);
  [C,lag]=xcorr(m_v,v_ref);
  imax=length(v_ref);
  
  c_corr=C(imax-nfft/2:imax+nfft/2-1);
  df=2*Fe/nfft;
  fftC=fft(c_corr);
  Ereal=sum(real(fftC).^2);
  Eimag=sum(imag(fftC).^2);
  E=sum(abs(fftC).^2);
  ratio=Ereal/Eimag;  
  printf("E=%e Er=%e Ei=%e Er/Ei=%e\n",E,Ereal,Eimag,ratio);
  
end

function plot_xcorr_center(c_corr)
  c=length(c_corr);
  figure;plot(-c/2:c/2-1,c_corr,"marker",'x');
end  
% auto with shifted barker version
[c_corr,r]=test_corr(s_Barker13,s_Barker13,0,64);
printf("Auto Barker13 lag=0 Ratio=%e\n",r);
plot_xcorr_center(c_corr);

[c_corr,r]=test_corr(s_Barker13,s_Barker13,1,64);
printf("Auto Barker13 lag=1 Ratio=%e\n",r);
plot_xcorr_center(c_corr);
[c_corr,r]=test_corr(s_Barker13,s_Barker13,2,64);
printf("Auto Barker13 lag=2 Ratio=%e\n",r);
plot_xcorr_center(c_corr);

[c_corr,r]=test_corr(s_Barker13,s_Barker13,-1,64);
printf("Auto Barker13 lag=-1 Ratio=%e\n",r);
plot_xcorr_center(c_corr);

[c_corr,r]=test_corr(s_Barker13,s_Barker13,-2,64);
printf("Auto Barker13 lag=-2 Ratio=%e\n",r);
plot_xcorr_center(c_corr);


printf("\n");

% inter with shifted derived barker version
[c_corr,r]=test_corr(ds_Barker13,s_Barker13,0,64);
printf("inter dBarker13 Barker13 lag=0 Ratio=%e\n",r);
plot_xcorr_center(c_corr);

[c_corr,r]=test_corr(ds_Barker13,s_Barker13,1,64);
printf("inter dBarker13 Barker13 lag=1 Ratio=%e\n",r);
plot_xcorr_center(c_corr);

[c_corr,r]=test_corr(ds_Barker13,s_Barker13,2,64);
printf("inter dBarker13 Barker13 lag=2 Ratio=%e\n",r);
plot_xcorr_center(c_corr);

[c_corr,r]=test_corr(ds_Barker13,s_Barker13,-1,64);
printf("inter dBarker13 Barker13 lag=-1 Ratio=%e\n",r);
plot_xcorr_center(c_corr);

[c_corr,r]=test_corr(ds_Barker13,s_Barker13,-2,64);
printf("inter dBarker13 Barker13 lag=-2 Ratio=%e\n",r);
plot_xcorr_center(c_corr);

%{
% intercorrelation Barker13 and measured Barker13
[C1,lag1]=xcorr(s_Barker13,s_Barker13);
%figure;plot(lag1,C1);
%title('inter Barker13 mBarker');

% intercorrelation Barker13 and derived measured Barker13
[C2,lag2]=xcorr(ds_Barker,s_Barker13);
%figure;plot(lag2,C2);
%title('inter Barker13 mdBarker');

% right synchro assumed => Max corr value must be at index length(m_Barker)
% for the original signal s_Barker13
imax=length(s_Barker13);


interC1=C1(imax-33:imax+32);
figure;plot(-33:+32,interC1,"marker",'x');
title('Center auto Barker13');


interC2=C2(imax-33:imax+32);
figure;plot(-33:+32,interC2,"marker",'x');
title('Center inter Barker13 dBarker13');

df=Fe/32;
fftC1=fft(interC1);
figure;plot((0:31)*df,2*abs(fftC1(1:32)));

fftC2=fft(interC2);
figure;plot((0:31)*df,2*abs(fftC2(1:32)));


% ratio real part imag part of intercorr 
% function is pair ratio >> 1 else ratio << 1
real1=sum(real(fftC1).^2);
imag1=sum(imag(fftC1).^2);
ratio1=real1/imag1

real2=sum(real(fftC2).^2);
imag2=sum(imag(fftC2).^2);
ratio2=real2/imag2


%padding with random number of zeros
m_Barker=zeros_padding(s_Barker13,1);
mds_Barker=zeros_padding(ds_Barker,-1);
% intercorrelation Barker13 and measured Barker13
[C3,lag3]=xcorr(m_Barker,s_Barker13);
interC3=C3(imax-33:imax+32);
figure;plot(-33:+32,interC3,"marker",'x');
title('Center inter Barker13 mBarker13');
% intercorrelation Barker13 and measured dBarker13
[C4,lag4]=xcorr(mds_Barker,s_Barker13);
interC4=C4(imax-33:imax+32);
figure;plot(-33:+32,interC4,"marker",'x');
title('Center inter Barker13 mdBarker13');
%}








