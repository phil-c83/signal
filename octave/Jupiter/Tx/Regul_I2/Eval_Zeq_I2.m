
## Author:  <phil@archlinux>
## Created: 2023-11-30

#Zeq= Z1*Zs/(m*Zm) + m*Z1 + Zs/m
function Zeq_I2 = Eval_Zeq_I2(Z1,Zs,Zm,m)
  Zeq_I2 = Z1*Zs/(m*Zm) + m*Z1 + Zs/m;
endfunction



