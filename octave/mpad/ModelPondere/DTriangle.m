## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-04-24

function Cr = DTriangle(t)
  Cr = Rect(2*(t+1/4))-Rect(2*(t-1/4));
endfunction
