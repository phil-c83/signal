## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-09-26

function s = Dbump(Te)
  s = Dbump_ab(Te,-1/2,1/2);
endfunction

function s = Dbump_ab(Te,a,b)
  s = -((Te-b) + (Te-a)) ./ ((Te-a).*(Te-b)) .* bump(Te);
endfunction
