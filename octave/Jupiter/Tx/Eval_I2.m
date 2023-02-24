## Copyright (C) 2023
##
##

## Author:  <phil@archlinux>
## Created: 2023-01-16

%
function I2c = Eval_I2(I1,U1,P1,R1,Zm,m)
  cos_ui = P1 ./ (U1 .* I1);
  I1c = I1.*(cos_ui - i*(sqrt(1-cos_ui.^2)));
  I2c = (U1-I1c.*(Zm+R1))./(m*Zm);
endfunction


