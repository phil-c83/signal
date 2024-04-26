## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-02-15

function S = Sig_gen (VGrms,D,f1,f2,Te)
  K1 = Eval_Kn(1,D);
  K2 = Eval_Kn(2,D);
  P1 = Eval_Pn(1,D);
  P2 = Eval_Pn(2,D);
  A  = VGrms/sqrt(K1^2+K2^2)
  S  = A*(K1*(sin(2*pi*f1*Te+P1)-sin(2*pi*f2*Te+P1))+K2*(sin(4*pi*f1*Te+P2)-sin(4*pi*f2*Te+P2)));
endfunction


function Kn = Eval_Kn(n,D)
  Kn = sqrt(2)/(pi*n*(1-D))*sqrt(1-cos(2*pi*n*D));
endfunction

function Pn = Eval_Pn(n,D)
  Pn = atan(sin(2*pi*n*D)/(1-cos(2*pi*n*D)));
endfunction
