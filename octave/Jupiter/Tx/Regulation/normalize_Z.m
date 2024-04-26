## Copyright (C) 2024


## Author:  <phil@archlinux>
## Created: 2024-04-04

function Zn = normalize_Z(Z,w)
  if (imag(Z) >=0)
    Zn = real(Z) + i*imag(Z)/w;
  else
    Zn = real(Z) + i*imag(Z)*w;
  endif
endfunction
