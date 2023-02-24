## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-02-24

function [phi1,phi2,phi12] = MCangle(s1,s2,f,Te)
  [A1,phi1,k1] = MCsinus(s1,f,Te);
  [A2,phi2,k2] = MCsinus(s2,f,Te);
  phi12        = phi1-phi2;
endfunction
