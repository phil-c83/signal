## Copyright (C) 2022


## Author:  <phil@archlinux>
## Created: 2022-12-16

function [fname,fpath,f,U1,I1,P1,I2] = read_csv_measures()

  [fname, fpath, fltidx]=uigetfile ("/home/phil/Made/git-prj/signal/data/*.csv","U I.. measures");
  file = [fpath "/" fname];
  %freq,Vdac,I1,U1,cos_ui,P1,I2
  m=dlmread(file,",",1,0);% skip 1st line

  f   = m(:,1);
  I1  = m(:,3);
  U1  = m(:,4);
  P1  = m(:,6);
  I2  = m(:,7);
endfunction



