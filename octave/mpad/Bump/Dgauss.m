## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-09-26

function s = Dgauss (Te)
  s = -2*pi .* Te .* gauss(Te);
endfunction
