## Copyright (C) 2023


## Author:  <phil@archlinux>
## Created: 2023-03-09

function plot_3D (Fs,U1,Z,R2,labelZ)
  [GFs,GU1,GZ]=plane_grid(Fs,U1,Z);

  figure();
  surf(GFs,GU1,GZ);
  xlabel("Fs");
  ylabel("U1");
  zlabel(labelZ);
  title(["R2=" num2str(R2)]);
endfunction
