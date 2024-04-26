## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-02-15

# Signal generator for jupE
# just fundamental and 1st harmonic of
# A*Rect(x/(D*T)) - A*D/(1-D)*Rect((x-D*T)/((1-D)*T))
#
# VGrms : generator rms value to compute signal for
# D     : duty cycle for reference signal
# w     : angular frequency
# dP    : phase correction to apply
# Te    : samples time vector
# S = VGrms/(sqrt(K1^2+K2^2)) * (K1*sin(w*t+p1-dP1) + K2*sin(2*w*t+p2-dP2))
function S = Sig_gen(VGrms,D,w,dP,Te)
  [K1,P1,S1] = Eval_Sn(Te,1,D,w,dP(1));
  [K2,P2,S2] = Eval_Sn(Te,2,D,w,dP(2));
  A          = VGrms/sqrt(K1^2 + K2^2);
  S          = A * (S1 + S2) ;
endfunction


function Kn = Eval_Kn(n,D)
  Kn = sqrt(2)/(pi*n*(1-D))*sqrt(1-cos(2*pi*n*D));
endfunction

function Pn = Eval_Pn(n,D)
  Pn = atan(sin(2*pi*n*D)/(1-cos(2*pi*n*D)));
endfunction

# S_n = A_n * sin(n*w*t+Pn-dPn)
function [Kn,Pn,Sn] = Eval_Sn(Te,n,D,w,dP)
  Kn = Eval_Kn(n,D);
  Pn = Eval_Pn(n,D);
  Sn = Kn*sin(n*w*Te+Pn-dP);
endfunction
