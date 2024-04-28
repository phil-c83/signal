## Copyright (C) 2024

## Author:  <phil@dell-arch>
## Created: 2024-04-28

function s = Transpose(fn,t,a,b)
  s = fn(1/(b-a)*(t-(a+b)/2));
endfunction
