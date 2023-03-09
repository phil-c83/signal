## Copyright (C) 2023
#

## Author:  <phil@archlinux>
## Created: 2023-03-09

function [GFs,GU1,GZ]=plane_grid(Fs,U1,Z)
  freqs =[410 440 470 520 560 590 610 640 670 710 740 770]';
  freqs = [freqs;2*freqs];
  idxFs = [];
  for i=1:length(freqs)
    ix = find(Fs==freqs(i));
    idxFs = [idxFs,ix];
  endfor
  GFs     = Fs(idxFs);
  GU1     = U1(idxFs);
  GZ      = Z(idxFs);
endfunction
