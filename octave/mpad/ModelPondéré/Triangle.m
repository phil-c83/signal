## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-04-24

# triangle of width 1, height 1, centered to 0
function Tri = Triangle(t)
  Tri = (1 - 2*abs(t)) .* Rect(t);
endfunction
