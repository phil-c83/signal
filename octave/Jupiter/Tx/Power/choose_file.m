## Copyright (C) 2023
##


## Author:  <phil@archlinux>
## Created: 2023-04-17

function [fqname,fpath,fname] = choose_file()
  [fname, fpath, fltidx]=uigetfile ("/home/phil/MADE-SERVER/transfert/P_Coste/Jupiter22/","UI..");
  fqname = [fpath fname];
  printf("file=%s\n",fqname);
endfunction

