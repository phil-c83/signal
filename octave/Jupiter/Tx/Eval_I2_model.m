## Copyright (C) 2023
##

## Author:  <phil@archlinux>
## Created: 2023-01-16

function [I2,E1,Zm,Rf,Lm] = Eval_I2_model (I1,U1,P1,R1,f,m,a0_anRf,a0_anLm)
  E1 = Eval_E1 (I1,U1,P1,R1);
  [Zm,Rf,Lm] = Eval_Zm_model (E1,f,a0_anRf,a0_anLm);
  I2c = Eval_I2(I1,U1,P1,R1,Zm,m);
  I2  = abs(I2c);
endfunction
