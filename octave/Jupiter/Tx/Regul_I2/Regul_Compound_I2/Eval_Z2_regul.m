## Copyright (C) 2024
## Author:  <phil@archlinux>
## Created: 2024-02-07

# ZL = Z1 + Z2//(Z0-Z1)
function Z2 = Eval_Z2_regul (Z0,ZL,Z1)
  Z2 = (Z1-ZL)*(Z0-Z1)/(ZL-Z0)
endfunction
