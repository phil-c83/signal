## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-04-04

function V1 = eval_Vg(I2,ZTn,D,w1,w2)
  Rp1 = (1-cos(4*pi*D)) / (4*(1-cos(2*pi*D)));
  V1  = I2/sqrt(2*(1+Rp1));
  V1 *= sqrt( unormalize_Zn(ZTn,w1)   * conj(unormalize_Zn(ZTn,w1))   +
              unormalize_Zn(ZTn,w2)   * conj(unormalize_Zn(ZTn,w2))   +
              Rp1 *
             (unormalize_Zn(ZTn,2*w1) * conj(unormalize_Zn(ZTn,2*w1))  +
              unormalize_Zn(ZTn,2*w2) * conj(unormalize_Zn(ZTn,2*w2))));
endfunction
