## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-04-24
# t   : 1xn time vector
# dom : 1x2 domain to transpose to
# a,b,c : weighting coefficients
function S = Sig(t,dom,a,b,c)
  S = a*Transpose(@Triangle,t,dom(1),dom(2)) - Transpose(@DTriangle,t,dom(1),dom(2))*(b+c);
endfunction
