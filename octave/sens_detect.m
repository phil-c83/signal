pkg load signal
clear all;
nT  = 0.1;
N   = 1024;
nTe = nT/N;
Fe  = 1/nTe;

function [nTe,y]=zero_mean_rect(A,Fe,T1,T)
  nTe = 0:1/Fe:T-1/Fe;
  y = A*rectpuls(nTe-T1/2,T1) - T1/(T-T1)*A*rectpuls(nTe-(T1+(T-T1)/2),T-T1);
endfunction

function [nTe,y]=zero_mean_rect_train(A,Fe,T1,T,nT)
  nTe = ((0:1/Fe:nT-1/Fe))';
  %delay and amplitude of each signal period
  dT  = ((0:T:nT-T))';
  d1  = [dT+T1/2,A*ones(nT/T,1)];
  d2  = [dT+(T+T1)/2,(A*T1)/(T-T1)*ones(nT/T,1)];
  y   =  pulstran(nTe,d1,"rectpuls",T1) - pulstran(nTe,d2,"rectpuls",T-T1);
endfunction
%{
T=linspace(-1,1,20);
T=-1:0.099:1-0.1;
y=rectpuls(T,0.4);
plot(T,y,"-*k;pulse;");
%[nTe,y]=zero_mean_rect(3,1024/0.1,2/410/5,1/410);
%}

[nTe,y]=zero_mean_rect_train(1,Fe,2/410/5,1/410,nT);
plot(nTe,y,"-*k;pulse;");


