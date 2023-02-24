## Copyright (C) 2023
##

## Author:  <phil@archlinux>
## Created: 2023-01-16

function [Zm,Rf,Lm] = Eval_Zm_model (E1,f,a0_anRf,a0_anLm)

 Rf = Eval_poly_model(f,E1,a0_anRf);
 Lm = Eval_poly_model(f,E1,a0_anLm);
 Zm = Eval_Zm(Rf,Lm,f);

endfunction
