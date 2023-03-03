## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-02-28

# find angle phase between sinusoide
# s1 and s2 sinus with same frequency.
# W numeric sampling frequency ie 2*pi*Fs/Fe
# N sampling factor ie Fe = 4*N*Fs
function phi = Qangle(s1,s2,W,N)
  shift = pi/(2*W)+1 ; # sample in pi/2
  # nearest number of sample for duration multiple of 1/Fs
  Ns    = round(floor((length(s1)-shift)/(2*pi*W)) * (2*pi*W));
  s1Q   = s1(shift:Ns+shift-1);
  s1N   = s1(1:Ns);
  s2N   = s2(1:Ns);
  s1s2  = s1N'*s2N;
  s1Qs2 = s1Q'*s2N;
  phi   = atan2(s1Qs2,s1s2);

  #{
  figure();
  subplot(3,1,1);
  plot(s1N);
  subplot(3,1,2);
  plot(s1Q);
  subplot(3,1,3);
  plot(s2N);
  #}
endfunction
