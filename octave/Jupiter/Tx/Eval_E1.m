## Copyright (C) 2023
##

## Author:  <phil@archlinux>
## Created: 2023-01-09

function E1 = Eval_E1 (I1,U1,P1,R1)
  % I1 lag U1
  cos_ui = P1 ./ (U1 .* I1);
  e1 = U1 - R1 * I1.*(cos_ui - i*sqrt(1-cos_ui.^2));
  E1 = abs(e1);

endfunction
