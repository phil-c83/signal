## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-03-06


function plot_2D(Fs,U1,Z,R2,labelZ)
  [GFs,GU1,GZ]=plane_grid(Fs,U1,Z);
  figure();

  for k=1:size(GFs)(1)
    plot(GFs(k,:),GZ(k,:),[";" num2str(U1(k,1)) ";"]);
    hold on;
  endfor

  xlabel("Fs");
  ylabel(labelZ);
  title(["R2=" num2str(R2)]);

endfunction
