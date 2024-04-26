## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-01-16

function [mod,z] = Eval_Zeq(R2,L2,Rp,Lp,R1,L1,fs)
  Z1=R1+i*2*pi*L1*fs;
  Z2=R2+i*2*pi*L2*fs;
  Zp=Eval_Zp_Cart(Rp,Lp,Fs);
  z = Z1*Z2/Zp + Z1 + Z2;
  mod=abs(z);
endfunction
