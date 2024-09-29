## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-09-26

# bump(t,a,b) = exp(-1/(ab)) * exp(1/((t-a)*(t-b))) if t in ]a,b[
# bump(t) = bump(t,a=-1/2,b=+1/2);
function s = bump(t)
    s = zeros(1,numel(t));
    v1 = t >-1/2;
    v2 = t < 1/2;
    v  = v1 & v2;# enforce values for open range ]-1/2,1/2[
    s(v) = exp(4) * exp(1 ./ ((t(v)+1/2).*(t(v)-1/2)));
endfunction


