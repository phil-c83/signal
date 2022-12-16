## Copyright (C) 2022


## Author:  <phil@archlinux>
## Created: 2022-12-14

## m(f,v) = a0 + a1*f + a2*v + a3*f^2 + a4*f*v + a5*v^2 + a6*f^2*v + a7*f*v^2 + a8*f^2*v^2
## values = Z*a => a = inv(Z'*Z)*Z'*values = (Z'*Z) \ (Z'*values)
## a = [a0 a1 a2 a3 a4 a5 a6 a7 a8]'

% f: frequency,
% v: tension
% values: m(f,v) measures
% select: what coef to evaluate ie [1 1 0 1 1 0 1 0 1]
% return :
%  a     : polynomial coefs
%  etype : standard deviation
%  emax  : max error
function [etype,emax,a] = MCDeg4(f, v, values, select)
  N = length (f);
  T = [ones(N, 1), f, v, f.^2, f.*v, v.^2, (f.^2).*v, f.*(v.^2), (f.^2).*(v.^2)];
  Z = T * diag(select); % select only chosen coefs/cols from T
  ## design matrix
  ZTZ = Z' * Z;
  ZTv = Z' * values;
  % iZTZ = inv(ZTZ);
  % a    = iZTZ*ZTv;
  % a = ZTZ \ ZTv;
  iZTZ = pinv(ZTZ);
  a    = iZTZ*ZTv;
  err  = Z * a - values;
  emax = max(abs(err));
  etype= abs(sum(err.^2)/length(values));
endfunction


