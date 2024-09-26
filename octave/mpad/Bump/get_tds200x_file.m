## Author: philippe coste <phil@phil-debian-pc>
## Created: 2022-10-05


function [Te,s] = get_tds200x_file(file)
  range = [0,3,Inf,4];
  sep   = ",";
  m     = dlmread(file,sep,range); # read time and signal colomns
  Te    = m(:,1);
  s     = m(:,2);
endfunction



