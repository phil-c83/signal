## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-03-02

function [s1,s2,Te]=dephased_sin(Fe,Fs,T,phi,var_n)
  Ns   = round(Fe*T);
  Te   = ((0:Ns-1)*1/Fe)';
  n_s1 = randn(Ns,1)*var_n;
  n_s2 = randn(Ns,1)*var_n;
  s1   = sin(2*pi*Fs*Te) + n_s1;
  s2   = sin(2*pi*Fs*Te+phi) + n_s2;
endfunction

