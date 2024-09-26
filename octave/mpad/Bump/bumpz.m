## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-09-26

function s = bumpz(Te)

  s = bumpz_ab(Te,-1,1);

endfunction

function s = bumpz_ab(Te,a,b)
  s = exp(-1/(a*b)) * exp(1 ./ ((Te-a).*(Te-b)));
endfunction
