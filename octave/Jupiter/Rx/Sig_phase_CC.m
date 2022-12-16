## Author: philippe coste <phil@phil-debian-pc>
## Created: 2022-10-11
%{
    Phase identification
ss      : SigSetFeatures.SigSets type voir Sig_features.m
idx_1st : index for max power frequency
idx_2nd : index for 2nd power frequency

return 
sens    : -1,0,1 ie reverse,unknown,direct
phase   : -1,0,1,2,3 ie unknown,LN,L1,L2,L3
%}
function [sens,phase] = Sig_phase_CC(ss,idx_1st,idx_2nd)
    
    if( (idx_1st == 1 && idx_2nd == 2) ||
        (idx_1st == 2 && idx_2nd == 1) ) % index for L1
        if( ss.Sens(1) == +1 && ss.Sens(2) == -1 )
          % L1 sens direct
          phase = 1;
          sens  = 1;
        elseif( ss.Sens(1) == -1 && ss.Sens(2) == +1 )
          % L1 sens inverse
          phase = 1 ;
          sens  = -1;
        else
          % L1 sens indetermine
          phase = 1 ;
          sens  = 0;
        endif  
                
    elseif((idx_1st == 2 && idx_2nd == 3) ||
           (idx_1st == 3 && idx_2nd == 2) ) % index for L2
        if( ss.Sens(2) == 1 && ss.Sens(3) == -1 )
          % L2 sens direct
          phase = 2;
          sens  = 1;
        elseif( ss.Sens(2) == -1 && ss.Sens(3) == +1 )
          % L2 sens inverse
          phase = 2 ;
          sens  = -1;
        else
          % L2 sens indetermine
          phase = 2 ;
          sens  = 0;
        endif 
        ;
    elseif((idx_1st == 3 && idx_2nd == 1) ||
           (idx_1st == 1 && idx_2nd == 3) ) % index for L3
        if( ss.Sens(3) == 1 && ss.Sens(1) == -1 )
          % L3 sens direct
          phase = 3;
          sens  = 1;
        elseif( ss.Sens(3) == -1 && ss.Sens(1) == +1 )
          % L3 sens inverse
          phase = 3 ;
          sens  = -1;
        else
          % L2 sens indetermine
          phase = 3 ;
          sens  = 0;
        endif
    else % bad indexes
        phase = -1 ;
        sens  = 0 ;
    endif    
endfunction
