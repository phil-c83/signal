## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-01-16

function [Z2,R2,L2] = Eval_Z2 (ModZ,ArgZ,Rp,Lp,R1,Fs)
  Z=ModZ*exp(-i*ArgZ);
  #Zp=Rp//Xp
  Xp=2*pi*Lp*Fs;
  Zp=Eval_Zp_Cart(Rp,Lp,Fs);
  Z2=Zp*(R1-Z)/(Z-(Zp+R1));
  R2=real(Z2);
  L2=imag(Z2)/(2*pi*Fs);

endfunction
