## Copyright (C) 2023
## Author:  <phil@archlinux>
## Created: 2023-04-26

function [fqname,fpath,fname] = choose_file(ext)
  [fname, fpath, fltidx]=uigetfile (ext,[ext " files..."]);
  fqname = [fpath fname];
  #printf("file=%s\n",fqname);
endfunction
