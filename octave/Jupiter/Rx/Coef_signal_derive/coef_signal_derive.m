## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-11-09

function r = coef_signal_derive (f1,f2,f3,D)
  r=(f1^2+f2^2+f3^2)*4*pi^2*(1+(1-cos(4*pi*D))/(1-cos(2*pi*D)))
endfunction
