## Copyright (C) 2023
##

## Author:  <phil@archlinux>
## Created: 2023-05-25

function f = Nturns(A,Bm,Al,W,Ve,R,N)
  n = 1:N;
  f = n.^4*(A^2*Bm^2*Al^2*W^2) - n.^2*Al^2*Ve^2 + A^2*Bm^2*R^2;
endfunction
