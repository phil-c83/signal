## Copyright (C) 2023
##


## Author:  <phil@archlinux>
## Created: 2023-01-13

% Zm = Rf//(i*Lm*w)
function Zm = Eval_Zm(Rf,Lm,f)
  Xm = 2*pi*f.*Lm;
  Zm = (Rf.*Xm.^2+i*Rf.^2.*Xm)./(Rf.^2+Xm.^2);
endfunction


