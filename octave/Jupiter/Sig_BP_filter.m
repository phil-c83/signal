## Author:  <phil@archlinux>
## Created: 2022-10-24


%{
transfert function composed with low/high pass butterworth
   Kl,Kh   : vector static gain for low/high pass
   Wcl,Wch : vector cut off pulsation
   Ql,Qh   : vector quality factor
   w       : vector pulsation to eval

   return  : s vector values for w
%}
function s=Sig_BP_filter(Kl,Wcl,Ql,Kh,Wch,Qh,w)

  s = ones(length(w),1);
  for i=1:length(Kl)
    s =  s .* lp_2nd_butter(Kl(i),Wcl(i),Ql(i),w);
  endfor
  for i=1:length(Kh)
    s =  s .* hp_2nd_butter(Kh(i),Wch(i),Qh(i),w);
  endfor
endfunction


%{
eval low pass butterworth filter @ w
   K   : static gain
   Wc  : cut off pulsation
   Q   : Quality factor
   w   : vector pulsation to eval
%}
function s=lp_2nd_butter(K,Wc,Q,w)

  s =  K*Wc^2 ./ (Wc^2 + Wc/Q*i*w - w.^2 );

endfunction

%{
eval high pass butterworth filter @ w
   K   : static gain
   Wc  : cut off pulsation
   Q   : Quality factor
   w   : vector pulsation to eval
%}
function s=hp_2nd_butter(K,Wc,Q,w)

  s =  -K*w.^2 ./ (Wc^2 + Wc/Q*i*w - w.^2 );

endfunction



