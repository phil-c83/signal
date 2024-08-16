## Copyright (C) 2024

## Author:  <phil@dell-arch>
## Created: 2024-08-13

function r = CausalSin(t,f,p)

  theta = 2*pi*f*t+p;
  idx   = find(theta >= 0);

  if(length(idx) == 0)
    r = zeros(1,length(t));
  elseif(length(idx) == length(t))
    r = sin(theta);
  else
    r(1:idx(1)-1) = 0;
    r(idx) = sin(theta(idx));
  end

endfunction
