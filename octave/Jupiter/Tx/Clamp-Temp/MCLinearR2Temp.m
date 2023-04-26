## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-04-26

function [a0,a1] = MCLinearR2Temp (P,P0,T,R2)
  # model: a0*1/R2 + a1*T = P-P0
  Z =[];
  DP=[];
  for r=1:numel(R2)-1
    Z    = [Z;[ones(numel(T),1)*1/R2(r) T]];
    DP   = [DP;[P(:,r)-P0]];
  endfor
  ZTZ  = Z'*Z;
  ZTDP = Z'*DP;
  iZTZ = pinv(ZTZ);
  a    = iZTZ * ZTDP;
  a0   = a(1);
  a1   = a(2);
endfunction
