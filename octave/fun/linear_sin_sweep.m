## Copyright (C) 2024


## Author:  <phil@archlinux>
## Created: 2024-09-30

# linear sweep from f0 to f1 from time t0 for period T at sample frequency Fe
# with initial phase p0
# d^2p(t)/dt^2 = a -> dp(t)/dt = a*t + b -> p(t) = 1/2*a*t^2 + b*t + c
# if one seek sweep from f0 to f1 in period T then one must fix
# a=2*pi*(f1-f0)/T, b=2*pi*f1, c=p0
function [s,t] = linear_sin_sweep (f0,f1,t0,T,p0,Fe)

  t = t0:1/Fe:t0+T;
  s = sin(pi * (((f1-f0)/T .* (t-t0) + 2*f0) .* (t-t0)) + p0);

endfunction
