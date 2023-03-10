## Copyright (C) 2023


## Author:  <phil@archlinux>
## Created: 2023-03-10

function [fqname,fpath,fname] = choose_csv()
  [fname, fpath, fltidx]=uigetfile ("/home/phil/MADE-SERVER/transfert/P_Coste/Jupiter22/","U I.. measures");
  fqname = [fpath fname];
  printf("file=%s\n",fqname);
endfunction
