## Copyright (C) 2023
#

## Author:  <phil@archlinux>
## Created: 2023-03-13
function [F,U,I,P,S,R2]= csv_U1fixed(fqname,U1min,U1max)
  [Fs,U1,I1,P1,cos_ui,I2,R2] = csv2vectors(fqname);

  # select indexes for U1min<=U1<=U1max
  idx_inf = find(U1>=U1min);
  idx_sup = find(U1(idx_inf)<=U1max);
  idx     = idx_inf(idx_sup);
  F       = Fs(idx);
  U       = U1(idx);
  I       = I1(idx);
  P       = P1(idx);
  S       = U1(idx).*I1(idx);
endfunction

