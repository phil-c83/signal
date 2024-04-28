## Author:  <phil@dell-arch>
## Created: 2023-12-09

function y = rtrig(x)
  y=zeros(length(x),1);
  i_0=find(x>0);
  i_1=find(x(i_0)<1);
  y(i_0(i_1))=1-x(i_0(i_1));
endfunction
