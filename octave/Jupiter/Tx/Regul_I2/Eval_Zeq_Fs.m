## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-01-16

function [mod,z] = Eval_Zeq_Fs (r2,l2,rp,lp,r1,l1,fs)
  z1=r1+i*2*pi*l1*fs;
  z2=r2+i*2*pi*l2*fs;
  zp=rp+i*2*pi*lp*fs;
  z= Eval_Zeq(z1,z2,zp);
  mod=abs(z);

endfunction
