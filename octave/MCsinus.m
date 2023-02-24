## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-02-24

function [A,phi,k] = MCsinus (s1,f,Te)
  N    = length(s1);
  D    = [sin(2*pi*f*Te),cos(2*pi*f*Te),ones(N,1)];
  DTs1 = D'*s1;
  DTD  = D'*D ;
  iDTD = pinv(DTD);
  x    = iDTD*DTs1;

  #x    = DTD \ DTs1;

  phi  = atan2(x(2),x(1));
  A    = sqrt(x(1)^2+x(2)^2);
  k    = x(3);
endfunction
