## Copyright (C) 2022


## Author:  <phil@archlinux>
## Created: 2022-12-08

% input csv file: clamp,Freq,dac_lsb,e1,Lm,Rf
% output matrix : clamp,Freq,e1,Lm,Rf
function [cl1,cl2,cl3] = csv_Lm_Rf(file)

  m=dlmread(file,",",1,0);% skip 1st line
  % index for each clamp
  i1 = find(m(:,1)==1.0); % idx clamp1
  i2 = find(m(:,1)==2.0); % idx clamp2
  i3 = find(m(:,1)==3.0); % idx clamp3

  % data for each clamp ie Freq,e1,Lm,Rf
  cl1 = m(i1,[2 4 5 6]);
  cl2 = m(i2,[2 4 5 6]);
  cl3 = m(i3,[2 4 5 6]);

endfunction
