## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-04-09

# Sfx = K1*sin(2*pi*fx/Fe*n+P1) + K2*[sin(4*pi*fx/Fe*n+P2)
function s = Sig_gen_jupE (Vrms,f1,f2,f3,Te,dP)

  # S = Sig_gen(VGrms,D,w,dPn,Te)
  D = 2/5;

  s = zeros(length(Te),3);
  s1 = Sig_gen(Vrms,D,2*pi*f1,dP(1,:),Te);
  s2 = Sig_gen(Vrms,D,2*pi*f2,dP(2,:),Te);
  s3 = Sig_gen(Vrms,D,2*pi*f3,dP(3,:),Te);
  s(:,1) = s1-s2;
  s(:,2) = s2-s3;
  s(:,3) = s3-s1;

endfunction



