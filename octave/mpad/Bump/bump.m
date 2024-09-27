## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-09-26

function s = bump(Te,a,b)

  if (Te >= a && Te<= b)
    s= exp(-1/(a*b)) * exp(1 ./ ((Te-a).*(Te-b)));
  else
    s =0;
  end

endfunction


