## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-09-13

function Sp = GreatestPeriodicSequence(S)
  dS  = S(2)-S(1);
  tol = abs(dS);
  printf("tol=%f\n",tol);
  s_slope = sign(dS);
  # iv form N-1 to 1
  iv  = find( abs( S(1:end-1)-S(1) ) < tol );
  disp(iv);
  is  = find( sign(S(iv+1)-S(iv)) == s_slope );
  disp(is);
  # select best last point
  if( abs(S(iv(is(end))) - S(1)) > abs(S(iv(is(end-1))) - S(1)) )
    last = iv(is(end-1))
  else
    last = iv(is(end))
  end

  Sp  = S(1:last);
endfunction
