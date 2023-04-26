## Copyright (C) 2023
## Author:  <phil@archlinux>
## Created: 2023-04-26

function [fqname,fpath,fname] = choose_file()
  [fname, fpath, fltidx]=uigetfile ("/home/phil/Made/git-prj/signal/data/","csv file..");
  fqname = [fpath fname];
  printf("file=%s\n",fqname);
endfunction
