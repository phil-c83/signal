## Author:  <phil@archlinux>
## Created: 2023-11-30

#Zeq = (Z1*Zs/(m*Zm) + m*Z1 + Zs/m)
function ModZeq = ModZeq_I2(Z1,Zs,Zm,m)
  ModZeq = sqrt(abs(Z1*Zs/(m*Zm))^2 + abs(m*Z1)^2 + abs(Zs/m)^2 + ...
                2*real(Z1*Zs/Zm*conj(Z1)) + ...
                2*real(Z1*Zs/(m*Zm)*conj(Zs/m)) + ...
                2*real(Z1*conj(Zs))) ;
endfunction

