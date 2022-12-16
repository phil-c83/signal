## Copyright (C) 2022

## Author:  <phil@archlinux>
## Created: 2022-12-15

function [f,e1,Lm,Rf] = read_csv_Lm_Rf (no_clamp)

  [fname, fpath, fltidx]=uigetfile ("/home/phil/Made/git-prj/signal/data/*.csv","Lm Rf measures");
  file = [fpath "/" fname];

  %Freq,dac_lsb,e1,Lm,Rf

  m=dlmread(file,",",1,0);% skip 1st line
  % index for each clamp
  ix  = find(m(:,1)==no_clamp);
  clx = m(ix,[2 4 5 6]);

  % data for each clamp ie Freq,e1,Lm,Rf
  clx = m(ix,[2 4 5 6]);
  f   = clx(:,1);
  e1  = clx(:,2);
  Lm  = clx(:,3);
  Rf  = clx(:,4);
endfunction
