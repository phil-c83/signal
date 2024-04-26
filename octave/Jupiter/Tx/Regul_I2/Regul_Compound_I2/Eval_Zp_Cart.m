## Copyright (C) 2024
##

## Author:  <phil@archlinux>
## Created: 2024-01-16

function Zp = Eval_Zp_Cart(Rp,Lp,Fs)
  Xp=2*pi*Fs*Lp;
  Zp=(Xp^2*Rp+i*Xp*Rp^2)/(Rp^2+Xp^2);
endfunction
