pkg load signal
clear all;

function [nTe,y]=zero_mean_rect(A,Fe,T1,T)
  nTe = 0:1/Fe:T-1/Fe;
  y = A*rectpuls(nTe-T1/2,T1) - T1/(T-T1)*A*rectpuls(nTe-(T1+(T-T1)/2),T-T1);
endfunction

[nTe,y]=zero_mean_rect(3,1024/0.1,2/410/5,1/410);
plot(nTe,y);
