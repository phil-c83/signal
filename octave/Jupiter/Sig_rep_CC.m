## Author: philippe coste <phil@phil-debian-pc>
## Created: 2022-10-05


%{
s       : signal points
FFT     : FFT signal
sf      : SigFeatures for s
pmin    : min power for signal for taken into account 
max_tol : tol ratio for the 2 max power frequencies signal
min_tol : tol ratio for the max and min power frequencies signal

ret     : struct SigCC array
%}
function SigCC = Sig_rep_CC (s,FFT,sf,power_min,max_tol,min_tol)  
    for k = 1:sf.nSets % for all frequencies set
      
      cur = sf.SetPoweriSort(sf.nSets-k+1); % process in order of power      
      
      SigCC(k).error = 0;
      SigCC(k).Sets  = cur;
      SigCC(k).Rp_12 = 0;
      SigCC(k).Rp_13 = 0;
      
      idx_1st = sf.SigSets(cur).iSortH0(sf.nFreqs); % index for max power
      idx_2nd = sf.SigSets(cur).iSortH0(sf.nFreqs-1);
      idx_3rd = sf.SigSets(cur).iSortH0(sf.nFreqs-2);
      
      if( sf.SigSets(cur).SetPower >= power_min ) % enough power ?
      
        power_1st = sf.SigSets(cur).FreqPower(idx_1st);
        power_2nd = sf.SigSets(cur).FreqPower(idx_2nd);
        power_3rd = sf.SigSets(cur).FreqPower(idx_3rd);
        
        % avoid dividing by 0
        if( power_2nd < eps )
          power_2nd = eps;
        endif
        if( power_3rd < eps )
          power_3rd = eps;
        endif
        
        SigCC(k).Rp_12 = power_1st / power_2nd;
        SigCC(k).Rp_13 = power_1st / power_3rd;
        
        if( SigCC(k).Rp_12 < max_tol  && 
            SigCC(k).Rp_13 > min_tol ) 
            
            if( (idx_1st == 1 && idx_2nd == 2) ||
                (idx_1st == 2 && idx_2nd == 1) ) % index for L1
                if( sf.SigSets(cur).Sens(1) == +1 && sf.SigSets(cur).Sens(2) == -1 )
                  % L1 sens direct
                  SigCC(k).Lx   = 1;
                  SigCC(k).Sens = 1;
                elseif( sf.SigSets(cur).Sens(1) == -1 && sf.SigSets(cur).Sens(2) == +1 )
                  % L1 sens inverse
                  SigCC(k).Lx   = 1 ;
                  SigCC(k).Sens = -1;
                else
                  % L1 sens indetermine
                  SigCC(k).Lx   = 1 ;
                  SigCC(k).Sens = 0;
                endif  
                
            elseif((idx_1st == 2 && idx_2nd == 3) ||
                   (idx_1st == 3 && idx_2nd == 2) ) % index for L2
                if( sf.SigSets(cur).Sens(2) == 1 && sf.SigSets(cur).Sens(3) == -1 )
                  % L2 sens direct
                  SigCC(k).Lx   = 2;
                  SigCC(k).Sens = 1;
                elseif( sf.SigSets(cur).Sens(2) == -1 && sf.SigSets(cur).Sens(3) == +1 )
                  % L2 sens inverse
                  SigCC(k).Lx   = 2 ;
                  SigCC(k).Sens = -1;
                else
                  % L2 sens indetermine
                  SigCC(k).Lx   = 2 ;
                  SigCC(k).Sens = 0;
                endif 
                ;
            elseif((idx_1st == 3 && idx_2nd == 1) ||
                   (idx_1st == 1 && idx_2nd == 3) ) % index for L3
                if( sf.SigSets(cur).Sens(3) == 1 && sf.SigSets(cur).Sens(1) == -1 )
                  % L3 sens direct
                  SigCC(k).Lx   = 3;
                  SigCC(k).Sens = 1;
                elseif( sf.SigSets(cur).Sens(3) == -1 && sf.SigSets(cur).Sens(1) == +1 )
                  % L3 sens inverse
                  SigCC(k).Lx   = 3 ;
                  SigCC(k).Sens = -1;
                else
                  % L2 sens indetermine
                  SigCC(k).Lx   = 3 ;
                  SigCC(k).Sens = 0;
                endif                    
            else
              SigCC(k).error = -3;% unexpected error
            endif            
        else
            SigCC(k).error = -2; % power ratio fail            
        endif    
      else
        SigCC(k).error = -1; % not enough power        
      endif    
  endfor
endfunction
