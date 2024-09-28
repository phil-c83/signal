## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-09-26

# bump(t,a,b) = exp(-1/(ab)) * exp(1/((t-a)*(t-b)))
# bump(t) = bump(t,a=-1/2,b=+1/2);
function s = bump(t)
    s = exp(4) * exp(1 ./ ((t+1/2).*(t-1/2))) .* Rect(t);
endfunction


