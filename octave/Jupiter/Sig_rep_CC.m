## Author: philippe coste <phil@phil-debian-pc>
## Created: 2022-10-05

%{
s       : signal points
FFT     : FFT signal
sf      : SigFeatures for s
power_min : min power for signal to be taken into account
sn_min  : S/N min for max power freq
tol     : unbalance ratio    0 < tol <= 1

ret     : struct SigCC array
%}
function SigCC = Sig_rep_CC (s,FFT,sf,power_min,sn_min,tol)
    for k = 1:sf.nSets % for all frequencies set

      cur = sf.SetPoweriSort(sf.nSets-k+1); % process in order of power
      % default SigCC init
      SigCC(k).error = 0;
      SigCC(k).Sets  = cur;
      SigCC(k).Rp_12 = 0; % 1st power frequency / 2nd power frequency
      SigCC(k).Rp_13 = 0; % 1st power frequency / 3rd power frequency
      SigCC(k).Lx    = 0;
      SigCC(k).Sens  = 0;

      idx_1st = sf.SigSets(cur).iSortH0(sf.nFreqs); % index for max power
      idx_2nd = sf.SigSets(cur).iSortH0(sf.nFreqs-1);
      idx_3rd = sf.SigSets(cur).iSortH0(sf.nFreqs-2);

      % enough power for this Set and good S/N ?
      if( sf.SigSets(cur).SetPower >= power_min    &&
          sf.SigSets(cur).FreqSN(idx_1st) > sn_min &&
          sf.SigSets(cur).FreqSN(idx_2nd) > sn_min   )

        power_1st = sf.SigSets(cur).Dsp(idx_1st);
        power_2nd = sf.SigSets(cur).Dsp(idx_2nd);
        power_3rd = sf.SigSets(cur).Dsp(idx_3rd);

        % avoid dividing by 0
        if( power_2nd < eps )
          power_2nd = eps;
        endif
        if( power_3rd < eps )
          power_3rd = eps;
        endif

        SigCC(k).Rp_12 = power_1st / power_2nd;
        SigCC(k).Rp_13 = power_1st / power_3rd;

        if( SigCC(k).Rp_12 < (1 + 2*tol)  &&
            SigCC(k).Rp_13 > (1 / tol^2)    )
            [SigCC(k).Sens,SigCC(k).Lx] = Sig_phase_CC(sf.SigSets(cur),idx_1st,idx_2nd);
            if( SigCC(k).Sens == 0 && SigCC(k).Lx == 0 )
                SigCC(k).error = -3;% unexpected error
            endif
        else
            SigCC(k).error = -2; % power ratio fail
        endif
      else
        SigCC(k).error = -1; % not enough power or bad S/N
      endif
  endfor
endfunction

