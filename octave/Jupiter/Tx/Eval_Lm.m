## Copyright (C) 2023
##

## Author:  <phil@archlinux>
## Created: 2023-01-10

%{
Z = R1+(Rf//Lm) => Z = (R1*Rf^2+Lm^2*w^2*(R1+Rf) + i*(Lm*w*Rf^2))/(Rf^2+Lm^2*w^2)
S = U*conj(I) = Z*I*conj(I) = Z*I^2 = I^2*(R+i*X)
S = I^2*R+i*I^2*X  => P = I^2*R  Q = I^2*X
Q/I^2 = Lm*w*Rf^2/(Rf^2+Lm^2*w^2)
P/I^2 = ((R1*Rf^2+Lm^2*w^2*(R1+Rf))/(Rf^2+Lm^2*w^2)

Lm  = (I1^4*R1^2 - 2*I1^2*P*R1 + S^2) / (I^2*Q*w)
Lm  = (I1^2*R1^2 - 2*P*R1 + U1^2) / (sqrt(U1^2*I1^2 - P^2)*w)

%}
function Lm = Eval_Lm (I1,U1,P1,R1,f)
  Lm = (I1.^2*R1^2 - 2*P1*R1 + U1.^2) ./ (sqrt(U1.^2.*I1.^2 - P1.^2).*(2*pi*f));
endfunction
