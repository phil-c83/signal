## Copyright (C) 2022

## Author:  <phil@archlinux>
## Created: 2022-12-13


## Lm(f,v) = a0 + a1*f + a2*v + a3*f*v + a4*f^2 + a5*v^2
## pvalues = Z*a => a = inv(Z'*Z)*Z'*pvalues = (Z'*Z) \ (Z'*pvalues)
## a = [a0 a1 a2 a3 a4 a5]'

function [a0, a1, a2, a3, a4, a5] = clamp_Lm_estimate (f, v, Lmvalues)
  N = length (f);
  Z = [ones(N, 1), f, v, f.*v, f .^ 2, v .^ 2];
  ## design matrix
  ZTZ = Z' * Z;
  ZTv = Z' * Lmvalues;
  ## iZTZ = inv(ZTZ);
  ## a    = iZTZ*ZTpa;
  a = ZTZ \ ZTv;
  a0 = a(1);
  a1 = a(2);
  a2 = a(3);
  a3 = a(4);
  a4 = a(5);
  a5 = a(6);
endfunction

