## Author:  <phil@archlinux>
## Created: 2023-12-06

function [Z2,L2] = Eval_Z2_w_Zp(M,A,Zp,R1,Fs)
  Z = M*exp(i*A);
  Z2= Zp*(R1-Z)/(Z-(Zp+R1));
  L2=imag(Z2)/(2*pi*Fs);
endfunction
