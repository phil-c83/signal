## Copyright (C) 2024


## Author:  <phil@archlinux>
## Created: 2024-04-24

function S = Sig (t,a,b,c)

  S = a*Triangle(t) - b*DTriangle(t) - c*DTriangle(t);

endfunction
