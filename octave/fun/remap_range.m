## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-09-27

#{
  map : ir=[u1,u2] -> or=[v1,v2]
  map(x) = [(v2-v1) / (u2-u1)] * (x-u1) + v1
  ir : input range
  or : output range
  Fe : discrete time step
  Tei: input time vector
  Teo: output time vector
#}
function [Tei,Teo] = remap_range(ir,or,Fe)

  a   = (or(2)-or(1)) / (ir(2)-ir(1)) ;
  Tei = ir(1):1/Fe:ir(2) ;
  Teo = a*(Tei-ir(1))+or(1);

endfunction
