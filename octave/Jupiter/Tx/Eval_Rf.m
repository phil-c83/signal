## Copyright (C) 2023
##

## Author:  <phil@archlinux>
## Created: 2023-01-09

%{

Z = R1+(Rf//Lm) => Z = (R1*Rf^2+Lm^2*w^2*(R1+Rf) + i*(Lm*w*Rf^2))/(Rf^2+Lm^2*w^2)
S = U*conj(I) = Z*I*conj(I) = Z*I^2 = I^2*(R+i*X)
S = I^2*R+i*I^2*X  => P = I^2*R  Q = I^2*X
Q/I^2 = Lm*w*Rf^2/(Rf^2+Lm^2*w^2)
P/I^2 = ((R1*Rf^2+Lm^2*w^2*(R1+Rf))/(Rf^2+Lm^2*w^2)

Rf = (I1^4*R1^2 - 2*I1^2*P1*R1 + S^2) / (I^2*P1 - I1^4*R1)
Rf = (I1^2*R1^2 - 2*P1*R1 + U1^2) / (P1 - I1^2*R1)

%}
function Rf = Eval_Rf (I1,U1,P1,R1)
  Rf = (I1.^2*R1^2 - 2*P1*R1 + U1.^2) ./ (P1 - I1.^2*R1);
endfunction
