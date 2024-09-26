## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-04-26

function [R2,T,Pa] = csv2mat(fqname)

  m=dlmread(fqname,",",0,0);% skip 1st line

  R2  = m(1,2:end)';
  T   = m(2:end,1);
  Pa  = m(2:end,2:end);

endfunction
