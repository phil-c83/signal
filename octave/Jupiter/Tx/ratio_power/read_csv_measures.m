## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-03-08

function [fname,fpath,Fs,U1,I1,P1,cos_ui,I2,R2] = read_csv_measures()

  [fname, fpath, fltidx]=uigetfile ("/home/phil/MADE-SERVER/transfert/P_Coste/Jupiter22/","U I.. measures");
  file = [fpath "/" fname];
  printf("file=%s\n",file);

  # get R2 value
  fid = fopen (file);
  header = fgetl(fid);
  fclose(fid);
  pos    = strfind(header,"#R2=");
  R2     = str2num(header(37:end));

  %Fs,U1,I1,P1,cos_ui,I2
  m=dlmread(file,",",1,0);

  Fs      = m(:,1);
  U1      = m(:,2);
  I1      = m(:,3);
  P1      = m(:,4);
  cos_ui  = m(:,5);
  I2      = m(:,6);
endfunction

