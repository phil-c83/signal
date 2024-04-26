## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-04-05

function I2 = eval_I2 (Vg,ZTn,D,w1,w2)
  Rp1 = (1-cos(4*pi*D)) / (4*(1-cos(2*pi*D)));
  I2  = Vg*sqrt(2*(1+Rp1)) / sqrt( unormalize_Zn(ZTn,w1)   * conj(unormalize_Zn(ZTn,w1))   +
                                   unormalize_Zn(ZTn,w2)   * conj(unormalize_Zn(ZTn,w2))   +
                                   Rp1 *
                                  (unormalize_Zn(ZTn,2*w1) * conj(unormalize_Zn(ZTn,2*w1))  +
                                   unormalize_Zn(ZTn,2*w2) * conj(unormalize_Zn(ZTn,2*w2))));
endfunction
