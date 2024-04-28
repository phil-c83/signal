## Author:  <phil@dell-arch>
## Created: 2023-12-09
function y = gate (x)
  y = zeros (length (x), 1);
  y(find (abs (x) < 0.5)) = 1;
endfunction

