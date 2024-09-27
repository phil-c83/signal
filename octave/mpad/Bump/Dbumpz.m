## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-09-26

function s = Dbumpz(Te)
  s = Dbumpz_ab(Te,-1/2,1/2);
endfunction

function s = Dbumpz_ab(Te,a,b)
  s = -((Te-b) + (Te-a)) ./ ((Te-a).*(Te-b)) .* bumpz(Te);
endfunction
