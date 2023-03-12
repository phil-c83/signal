## Copyright (C) 2023
##

## Author:  <phil@archlinux>
## Created: 2023-03-07

function [Bs1,Bs2,Bs3] = fields_v(z1,z2,z3,z)

  BI1 = proj(invsq(z-z1),z);
  BI2 = proj(invsq(z-z2),z);
  BI3 = proj(invsq(z-z3),z);
  #{

  BI1  = (1./abs(z1-z)) .* cos(arg(z./(z-z1)));
  BI2  = (1./abs(z2-z)) .* cos(arg(z./(z-z2)));
  BI3  = (1./abs(z3-z)) .* cos(arg(z./(z-z3)));
  #}

  Bs1 = BI1-BI3;
  Bs2 = BI2-BI1;
  Bs3 = BI3-BI2;
endfunction

function z=invsq(z1)
  z=z1./(conj(z1).*z1);
endfunction

function z=proj(z1,z2)
  #z = <z1,z2>*z2/|z2|^2
  z=(real(z1).*real(z2)+imag(z1).*imag(z2)).*z2./abs(z2);
endfunction
