## Copyright (C) 2022


## Author:  <phil@archlinux>
## Created: 2022-12-16

function [f,U1,E1,I1,cos_ui,R1,I2] = read_csv_U_I_Cos(no_clamp)

  [fname, fpath, fltidx]=uigetfile ("/home/phil/Made/git-prj/signal/data/*.csv","U I.. measures");
  file = [fpath "/" fname];
  %clamp,freq,U1,E1,I1,cos_ui,R1,I2
  m=dlmread(file,",",1,0);% skip 1st line
  % index for each clamp
  ix  = find(m(:,1)==no_clamp);
  clx = m(ix,2:end);

  f   = clx(:,1);
  U1  = clx(:,2);
  E1  = clx(:,3);
  I1  = clx(:,4);
  cos_ui = clx(:,5);
  R1  = clx(:,6);
  I2  = clx(:,7);


endfunction



