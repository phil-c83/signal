## Author: philippe coste <phil@phil-debian-pc>
## Created: 2022-10-07

%{
s         : signal points
FFT       : FFT signal
sf        : SigFeatures for s
power_min : min power for signal to be taken into account 
sn_min    : S/N min for max power freq
tol       : unbalanced ratio max     0 < tol <= 1

ret     : struct SigCC array
%}
function SigCO = Sig_rep_CO(s,FFT,sf,power_min,sn_min,tol) 
    
   for k = 1:sf.nSets % for all frequencies set
      
      cur = sf.SetPoweriSort(sf.nSets-k+1); % process in order of power      
      
      % default SigCO init
      SigCO(k).error = 0;
      SigCO(k).Sets  = cur;
      SigCO(k).Rp_12 = 0;
      SigCO(k).Rp_13 = 0;
      SigCO(k).pt1   = -1;
      SigCO(k).pt2   = -1;
      
      idx_1st = sf.SigSets(cur).iSortH0(sf.nFreqs); % index for max power
      idx_2nd = sf.SigSets(cur).iSortH0(sf.nFreqs-1);
      idx_3rd = sf.SigSets(cur).iSortH0(sf.nFreqs-2);
      
      % enough power for this Set and good S/N ?
      if( sf.SigSets(cur).SetPower >= power_min )
      
            power_1st = sf.SigSets(cur).Dsp(idx_1st);
            power_2nd = sf.SigSets(cur).Dsp(idx_2nd);
            power_3rd = sf.SigSets(cur).Dsp(idx_3rd);        
            
            
            if( sf.SigSets(cur).FreqSN(idx_1st) > sn_min && 
                sf.SigSets(cur).FreqSN(idx_2nd) > sn_min    )  
            
                 % avoid dividing by 0
                if( power_2nd < eps )
                    power_2nd = eps;
                endif
                if( power_3rd < eps )
                    power_3rd = eps;
                endif
                
                if( sf.SigSets(cur).FreqSN(idx_3rd) > sn_min )
                    % case Sig_rep_CO() between 2 phases ie -2*S_i1 + S_i2 + S_i3
                    
                    SigCO(k).Rp_12 = power_1st / (4*power_2nd);
                    SigCO(k).Rp_13 = power_1st / (4*power_3rd);                
                    
                    if( abs(SigCO(k).Rp_12 - 1) <= tol &&
                        abs(SigCO(k).Rp_13 - 1) <= tol )                        
                        [phase_pt1,phase_pt2] = Sig_phase_CO(sf.SigSets(cur),idx_1st); 
                        SigCO(k).pt1 = phase_pt1;
                        SigCO(k).pt2 = phase_pt2;
                    else
                        SigCO(k).error = -2; % bad power ratio;
                    endif                  
                    
                else
                    % case Sig_rep_CO() between phase Neutral ie S_i1 - S_i2
                    % same signal as  Sig_rep_CC()
                    [sens,phase] = Sig_phase_CC(sf.SigSets(cur),idx_1st,idx_2nd);            
                    if ( phase == -1 ) % erreur                        
                        SigCO(k).error = -4; % Pb ID phase;
                    else
                        if( sens == 1 )
                          SigCO(k).pt1 = phase;
                          SigCO(k).pt2 = 0 ; % neutral
                        elseif( sens == -1 )
                            SigCO(k).pt2 = phase;
                            SigCO(k).pt1 = 0 ; % neutral
                        else % erreur
                            SigCO(k).error = -5; % Pb ID sens;
                            SigCO(k).pt1 = phase;
                            SigCO(k).pt2 = phase;
                        endif                        
                    endif                    
                endif
            
            else             
                SigCO(k).error = -3; % bad S/N
            endif  
        
      else
        SigCO(k).error = -1; % not enough power
      endif    
      
   endfor   

endfunction

% identify phase by max power index 
function [phase_pt1,phase_pt2]=Sig_phase_CO(sigset,index)
    if( sigset.Sens(index) == -1 && 
        sigset.Sens(next_index(index,3)) == +1 &&
        sigset.Sens(next_index(next_index(index,3),3)) == +1 )
        % sens direct 
        phase_pt1 = prev_index(index,3);
        phase_pt2 = index;
    elseif( sigset.Sens(index) == +1 && 
            sigset.Sens(next_index(index,3)) == -1 &&
            sigset.Sens(next_index(next_index(index,3),3)) == -1 )
        % sens inverse    
        phase_pt1 = index;
        phase_pt2 = prev_index(index,3);
    else        
        % sens unknown we identify not pointed phase
        phase_pt1 = next_index(index,3);
        phase_pt2 = next_index(index,3);        
    endif     
endfunction

% prev(k,m) , 1 <= k <= m  : (k-1+m-1) mod m + 1 
function prev = prev_index(index,m)
    prev = mod(index+m-2,m) + 1;
endfunction

% next(k,m) , 1 <= k <= m  : k-1+1 mod m + 1 
function next = next_index(index,m)
    next = mod(index,m) + 1 ;
endfunction