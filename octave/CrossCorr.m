## Copyright (C) 2021
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{retval} =} CrossCorr (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author:  <phil@dell-arch>
## Created: 2021-10-09

function xc = CrossCorr (v1,v2)
  ncorr = 2*length(v1)+length(v2)-2;
  
  for k = 1:ncorr
    maxj = min([length(v1),length(v2),k]); 
    s1=v1(length(v1):-1:length(v1)-maxj+1)
    s2=v2(1:maxj)
    sums = sum(s1 .* s2)
    xc(k) = sum( v1(length(v1):-1:length(v1)-maxj+1) .* v2(1:maxj) );
  endfor
  
endfunction
