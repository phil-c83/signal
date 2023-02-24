## Copyright (C) 2023
##

## Author:  <phil@archlinux>
## Created: 2023-01-16

%u(f,v) = a0 + a1*f + a2*v + a3*f^2 + a4*f*v + a5*v^2 + a6*f^2*v + a7*f*v^2 + a8*f^2*v^2
function u=Eval_poly_model(f,v,a)
  N  = length(f);
  u  = [ones(N,1), f, v, f.^2, f.*v, v.^2, f.^2.*v, f.*v.^2, f.^2.*v.^2] * a;
endfunction

