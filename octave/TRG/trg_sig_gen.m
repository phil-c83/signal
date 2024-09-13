## Copyright (C) 2024
##

## Author:  <phil@archlinux>
## Created: 2024-05-29

# signal generator for TRG
# Ts    : signal time period
# Tb    : quiet  time period
# Fe    : sample frequency
# Fs    : signal sinus frequency
# A     : magitude
# P     : phase at origin
function [Te,sig] = trg_sig_gen (Ts,Tb,Fe,Fs,A,P)
  N   = round(Ts*Fe);
  Te  = (0:N-1)*1/Fe;
  sig = A*sin(2*pi*Fs*Te + P);
  sig = [sig,zeros(1,N)];
  Te  = [Te,Te+N/Fe];
endfunction
