## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-04-09

function y = Sigref(x,A,D,T)
  y = A*Rect(x/(D*T)) - A*D/(1-D)*Rect((x-D*T)/((1-D)*T));
endfunction
