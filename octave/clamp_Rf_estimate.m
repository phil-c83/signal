## Copyright (C) 2022

## Author:  <phil@archlinux>
## Created: 2022-12-13


## Rf(f,v) = a0+a1*f+a2*v+a3*v^2
## pvalues = Z*a => a = inv(Z'*Z)*Z'*pvalues = (Z'*Z) \ (Z'*pvalues)
## a = [a0 a1 a2 a3]'

function [a0, a1, a2, a3] = clamp_Rf_estimate (fq, vg, Rfvalues)
  N = length (fq);
  Z = [ones(N, 1), fq, vg, vg .^ 2];
  ## design matrix
  ZTZ = Z' * Z;
  ZTv = Z' * Rfvalues;
  ## iZTZ = inv(ZTZ);
  ## a    = iZTZ*ZTpa;
  a = ZTZ \ ZTv;
  a0 = a (1);
  a1 = a (2);
  a2 = a (3);
  a3 = a (4);
endfunction

