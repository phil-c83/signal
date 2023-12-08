## Author:  <phil@archlinux>
## Created: 2023-12-06

# Z=M/A , Zp=Rp//i*Xp
function [Z2,L2] = Eval_Z2 (M,A,Rp,Xp,R1,Fs)
  Z = M*exp(i*A);
  Yp=Rp - i*Xp;
  Zp=1/Yp;
  Z2= Zp*(R1-Z)/(Z-(Zp+R1));
  L2= imag(Z2)/(2*pi*Fs);
endfunction
