pkg load signal
clear all;
close all;
%graphics_toolkit("qt"); set in .octaverc
nT  = 0.1;
N   = 1024;
Te = nT/N;
Fe  = 1/Te;

function [nTe,y]=zero_mean_rect(A,Fe,T1,T)
  nTe = 0:1/Fe:T-1/Fe;
  y = A*rectpuls(nTe-T1/2,T1) - T1/(T-T1)*A*rectpuls(nTe-(T1+(T-T1)/2),T-T1);
endfunction

function [nTe,y]=zero_mean_rect_train(A,Fe,T1,T,nT)
  nTe = ((0:1/Fe:nT-1/Fe))';
  %delay and amplitude of each signal period
  dT  = ((0:T:nT-T))';
  d1  = [dT+T1/2,A*ones(floor(nT/T),1)];
  d2  = [dT+(T+T1)/2,(A*T1)/(T-T1)*ones(floor(nT/T),1)];
  y   =  pulstran(nTe,d1,"rectpuls",T1) - pulstran(nTe,d2,"rectpuls",T-T1);
endfunction

function yfft=plot_fft_signal(nTe,y,T,draw)
  N = length(nTe);
  Fe = 1/(nTe(2)-nTe(1));
  dF = Fe/N;
  ndF = -Fe/2:dF:Fe/2-dF;
  yfft=fft(y(1:1024));
  yffts=fftshift(yfft);
  if (draw) 
    figure;
    subplot(3,1,1);
    plot(nTe,y,"--.k;sig;");
    subplot(3,1,2);
    plot(ndF,abs(yffts)/N,"--.b;mods;");
    subplot(3,1,3);
    plot(ndF,arg(yffts)*180/pi,"--.g;args;");  
    figure;
    plot3(ndF,yffts);
  endif
  % attention au calcul des indices: si floor au lieu de round
  idx0 = round(1/T/dF+1);  % fondamental index ie +1/T
  idx1 = round(2/T/dF+1);  % 1st hamonic index ie +2/T
  idx2 = round(N-(1/T/dF-1));  % fondamental index ie -1/T
  idx3 = round(N-(2/T/dF-1));  % 1st hamonic index ie -2/T
  printf("1/T=%f abs(fft(1/T))=%f arg(fft(1/T))=%f abs(fft(2/T))=%f arg(fft(2/T))=%f\n",
          1/T,abs(yfft(idx0))/N,arg(yfft(idx0))*180/pi,abs(yfft(idx1))/N,arg(yfft(idx1))*180/pi);
  printf("1/T=%f abs(fft(-1/T))=%f arg(fft(-1/T))=%f abs(fft(-2/T))=%f arg(fft(-2/T))=%f\n",
          1/T,abs(yfft(idx2))/N,arg(yfft(idx2))*180/pi,abs(yfft(idx3))/N,arg(yfft(idx3))*180/pi); 
  printf("idx0=%d idx1=%d idx2=%d idx3=%d 2/T=%f\n",idx0,idx1,idx3,idx4,2/T); 
          
  %printf("T=%f abs(fft(1/T))=%f arg(fft(1/T))=%f abs(fft(1/(2*T)))=%f arg(fft(1/(2*T)))=%f\n",
  %        T,abs(yfft(idx0)),arg(yfft(idx0))*180/pi,abs(yfft(idx1)),arg(yfft(idx1))*180/pi);
endfunction



% signal 410Hz
F=410;
printf("\nF=%f\n",F);
[nTe,y]=zero_mean_rect_train(1,Fe,3/F/5,1/F,2*nT);
% f(t)
yfft=plot_fft_signal(nTe(1:1024),y(1:1024),1/F,1);
%f(t-5*Te)
yfft=plot_fft_signal(nTe(6:1029),y(6:1029),1/F,1);
% -f(t)
yfft=plot_fft_signal(nTe(1:1024),-y(1:1024),1/F,0);
% -f(t-5*Te)
yfft=plot_fft_signal(nTe(6:1029),-y(6:1029),1/F,0);

% signal 440Hz
F=440;
printf("\nF=%f\n",F);
[nTe,y]=zero_mean_rect_train(1,Fe,3/F/5,1/F,2*nT,0);
% f(t)
yfft=plot_fft_signal(nTe(1:1024),y(1:1024),1/F,0);
%f(t-5*Te)
yfft=plot_fft_signal(nTe(6:1029),y(6:1029),1/F,0);
% -f(t)
yfft=plot_fft_signal(nTe(1:1024),-y(1:1024),1/F,0);
% -f(t-5*Te)
yfft=plot_fft_signal(nTe(6:1029),-y(6:1029),1/F,0);


% signal 470Hz
F=470;
printf("\nF=%f\n",F);
[nTe,y]=zero_mean_rect_train(1,Fe,3/F/5,1/F,2*nT,0);
% f(t)
yfft=plot_fft_signal(nTe(1:1024),y(1:1024),1/F,0);
%f(t-5*Te)
yfft=plot_fft_signal(nTe(6:1029),y(6:1029),1/F,0);
% -f(t)
yfft=plot_fft_signal(nTe(1:1024),-y(1:1024),1/F,0);
% -f(t-5*Te)
yfft=plot_fft_signal(nTe(6:1029),-y(6:1029),1/F,0);

% signal 520Hz
F=520;
printf("\nF=%f\n",F);
[nTe,y]=zero_mean_rect_train(1,Fe,3/F/5,1/F,2*nT,0);
% f(t)
yfft=plot_fft_signal(nTe(1:1024),y(1:1024),1/F,0);
%f(t-5*Te)
yfft=plot_fft_signal(nTe(6:1029),y(6:1029),1/F,0);
% -f(t)
yfft=plot_fft_signal(nTe(1:1024),-y(1:1024),1/F,0);
% -f(t-5*Te)
yfft=plot_fft_signal(nTe(6:1029),-y(6:1029),1/F,0);



%{
yfft=fft(y(1:1024));
yfft=fftshift(yfft);

%plot(-Fe/2:Fe/N:Fe/2-Fe/N,abs(yfft));
figure;
subplot(3,1,1);
plot(nTe(1:1024),y(1:1024),"--.k;pulses;");
subplot(3,1,2);
plot(-Fe/2:Fe/N:Fe/2-Fe/N,abs(yfft),"--.b;mods;");
subplot(3,1,3);
plot(-Fe/2:Fe/N:Fe/2-Fe/N,arg(yfft),"--.g;args;");


yfft=fft(-y(1:1024));
yfft=fftshift(yfft);
figure;
%plot(-Fe/2:Fe/N:Fe/2-Fe/N,abs(yfft));
subplot(3,1,1);
plot(nTe(1:1024),-y(1:1024),"--.k;pulses;");
subplot(3,1,2);
plot(-Fe/2:Fe/N:Fe/2-Fe/N,abs(yfft),"--.b;mods;");
subplot(3,1,3);
plot(-Fe/2:Fe/N:Fe/2-Fe/N,arg(yfft),"--.g;args;");
%}

