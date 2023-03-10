## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-03-08

function [fname,fpath,Fs,U1,I1,P1,cos_ui,I2,R2] = read_csv_measures()

  [fqname,fpath,fname] = choose_csv();
  [Fs,U1,I1,P1,cos_ui,I2,R2] = csv2vectors(fqname);
endfunction

