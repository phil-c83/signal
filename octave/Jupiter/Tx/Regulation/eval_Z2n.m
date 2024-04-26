## Copyright (C) 2024
## Author:  <phil@archlinux>
## Created: 2024-02-07

# ZL = Z1 + Z2//(Z0-Z1)
function Z2n = eval_Z2n(Z0n,Z1n,ZLn)
  Z2n = (Z1n-ZLn)*(Z0n-Z1n)/(ZLn-Z0n);
endfunction
