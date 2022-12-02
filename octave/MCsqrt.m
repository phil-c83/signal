## Copyright (C) 2022

## Author:  <phil@archlinux>
## Created: 2022-12-02

% S = a*sqrt(kT)+b
function [a,b] = MCsqrt (x,S)
  Z    = [ones(length(x),1),sqrt(x)];
  ZTZ  = Z'*Z;
  iZTZ = inv(ZTZ);
  ATS = Z'*S;
  sol = iZTZ * ATS;
  b = sol(1);
  a = sol(2);
endfunction
