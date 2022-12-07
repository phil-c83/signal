## Copyright (C) 2022

## Author:  <phil@archlinux>
## Created: 2022-12-05
% S = a0 + a1*x
function [a0,a1] = MClinear(x,S)
  Z    = [ones(length(x),1),x];
  ZTZ  = Z'*Z;
  iZTZ = inv(ZTZ);
  ZTS = Z'*S;
  sol = iZTZ * ZTS;
  a0 = sol(1);
  a1 = sol(2);
endfunction

