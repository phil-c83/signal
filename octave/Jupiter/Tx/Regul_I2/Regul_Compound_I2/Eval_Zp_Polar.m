## Copyright (C) 2024


## Author:  <phil@archlinux>
## Created: 2024-01-16

function [Zp,Rp,Lp] = Eval_Zp_Polar(ModZ0,ArgZ0,R1,Fs)
  Rs=ModZ0*cos(ArgZ0)-R1;
  Xs=ModZ0*sin(ArgZ0);
  Zs=Rs+i*Xs;
  Rp=abs(Zs)^2/Rs;
  Xp=abs(Zs)^2/Xs;
  Lp=Xp/(2*pi*Fs);
endfunction
