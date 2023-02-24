## Copyright (C) 2022

## Author:  <phil@archlinux>
## Created: 2022-12-13

function m = csv_Clamps_measures (file)
  %freq,Vdac,I1,U1,cos_ui,P,I2
  m=dlmread(file,",",1,0);% skip 1st line

endfunction
