## Copyright (C) 2023
##

## Author:  <phil@archlinux>
## Created: 2023-03-07

function [Bs1,Bs2,Bs3] = fields_v(z1,z2,z3,z)
  K1  = (1./abs(z1-z)) .* cos(arg(z./(z-z1)));
  K2  = (1./abs(z2-z)) .* cos(arg(z./(z-z2)));
  K3  = (1./abs(z3-z)) .* cos(arg(z./(z-z3)));
  Bs1 = K1-K3;
  Bs2 = K2-K1;
  Bs3 = K3-K2;
endfunction
