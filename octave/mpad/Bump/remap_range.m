## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-09-27

#{
  map ir=[u1,u2] -> or=[v1,v2]
  v1 = a*u1 + b
  v2 = a*u2 + b

  a  = (v2-v1) / (u2-u1)
  b  = (v1*u2 - v2*u1) / (u2-u1)
#}
function or = remap_range(ir)

  a = (i_range(2) - irange(1)) /

endfunction
