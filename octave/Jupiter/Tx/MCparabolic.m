## Copyright (C) 2022


## Author:  <phil@archlinux>
## Created: 2022-12-05

% y = a0+a1*x+a2*x^2
function [a0,a1,a2] = MCparabolic (x,S)
  Z    = [ones(length(x),1),x,x.^2];
  ZTZ  = Z'*Z;
  iZTZ = inv(ZTZ);
  ZTS  = Z'*S;
  sol  = iZTZ * ZTS;
  a0   = sol(1);
  a1   = sol(2);
  a2   = sol(3);
endfunction
