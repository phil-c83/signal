## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-03-21

function [covxx,covyy,covxy]=covar(x,y)
  sx    = sum(x);
  sy    = sum(y);
  sx2   = sum(x.^2);
  sy2   = sum(y.^2);
  sxy   = sum(x.*y);
  covxx = sx2/length(x) - (sx/length(x))^2;
  covyy = sy2/length(y) - (sy/length(y))^2;
  covxy = sxy/length(x) - (sx*sy/length(x)^2);
endfunction


