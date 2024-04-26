## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-04-04

function Z = unormalize_Zn(Zn,w)
  if (imag(Zn)>=0)
    Z = real(Zn) + i*imag(Zn)*w;
  else
    Z = real(Zn) + i*imag(Zn)/w;
  endif
endfunction
