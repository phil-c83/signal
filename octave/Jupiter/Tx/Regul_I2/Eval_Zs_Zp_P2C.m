## Author:  <phil@archlinux>
## Created: 2023-12-06

# Z0 = Zs + R1 = Zp + R1 , Zs=Rs+i*Xs,
# Zp = Rp//Xp = (Rp*Xp^2 + i*Xp*Rp^2)/(Rp^2+Xp^2)
# Rp = |Zs|^2/Rs , Xp = |Zs|^2/Xs
function [Zs,Zp,Ls,Lp] = Eval_Zs_Zp_P2C(M0,A0,R1,Fs)
  Rs = M0*cos(A0)-R1;
  Xs = M0*sin(A0);
  Ms2= Rs^2 + Xs^2;
  Rp = Ms2/Rs;
  Xp = Ms2/Xs;
  Zs = Rs + i*Xs;
  Zp = Rp + i*Xp;
  Ls = Xs/(2*pi*Fs);
  Lp = Xp/(2*pi*Fs);
endfunction
