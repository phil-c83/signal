## Copyright (C) 2023
##

## Author:  <phil@archlinux>
## Created: 2023-01-10

% Rf(f,v) parameters model with measures
function [a0_an Rf] = Make_Rf_model (I1,U1,E1,P1,R1,f)

  Rf = Eval_Rf (I1,U1,P1,R1);

  % MCDeg4(f, v, values, select)
  [etype_Rf,emax_Rf,a0_an] = MCDeg4(f,E1,Rf, [1 1 1 1 0 1 1 1 0]);
  printf("%s(f,v)= %+g %+g*f %+g*v %+g*f^2 %+g*f*v %+g*v^2 %+g*f^2*v %+g*f*v^2 %+g*f^2*v^2 std=%f emax=%f\n",
        "Rf",a0_an(1),a0_an(2),a0_an(3),a0_an(4),a0_an(5),a0_an(6),a0_an(7),a0_an(8),a0_an(9),etype_Rf,emax_Rf);

endfunction
