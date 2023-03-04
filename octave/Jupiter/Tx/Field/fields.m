## Copyright (C) 2023
##

## Author:  <phil@dell-arch>
## Created: 2023-03-04

function [s1,s2,s3]=fields(c1,c2,c3,r,theta)
  c1x = r*exp(i*theta)-c1;
  c2x = r*exp(i*theta)-c2;
  c3x = r*exp(i*theta)-c3;
  s1 = (abs(c2x.*c3x)-abs(c1x.*c2x))./(r*abs(c1x.*c2x.*c3x));
  s2 = (abs(c1x.*c3x)-abs(c2x.*c3x))./(r*abs(c1x.*c2x.*c3x));
  s3 = (abs(c1x.*c2x)-abs(c1x.*c3x))./(r*abs(c1x.*c2x.*c3x));
endfunction
