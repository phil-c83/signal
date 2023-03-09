## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-03-03

function [cosMC,cosCOV] = Test_UI_cos(Te,Fs,U1,I1)

  [phi1,phi2,phiMC] = MCangle(I1,U1,Fs,Te);
   cosMC   = cos(phiMC);

   cosCOV  = cov(U1,I1,1)/sqrt(cov(U1,U1,1)*cov(I1,I1,1));
endfunction
