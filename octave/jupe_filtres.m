pkg load control;
clear all;
close all;

SigSetFreqs=[410 440 470 520 560 590 610 640 670 710 740 770];
Freqs=[SigSetFreqs,SigSetFreqs*2]';

% static gain, cut off pulsation and quality factor for low pass filter
Kl = [1.75;1.75;1.75]';
Wcl= 2*pi*[1977;1977;2009]';
Ql = [0.514;0.697;1.944]';

% static gain, cut off pulsation and quality factor for high pass filter
Kh = [1.036;1.33;1.91;2.6]';
Wch= 2*pi*[338;338;338;338]';
Qh = [0.509;0.599;0.917;2.5]';



function print_filter_phases(s,f)
  args = arg(s);
  N    = length(f)/2;
  tau  = -args ./ (2*pi*f) ;
  it   = find(tau<0);
  tau(it) = 1 ./ f(it) + tau(it);
  for k=1:N
    printf("f=%4d arg@f=%+3.2f Tw=%+7.6f 2f=%4d arg@2f=%+3.2f T2w=%+7.6f\n",
            f(k),args(k),tau(k),f(k+N),args(k+N),tau(k+N));
  endfor
  printf("\n");
endfunction

s   = tf('s');

%   low pass
% 1st Pb stage
K1  = 1.75;
Wc1 = 2*pi*1977;
Q1  = 0.514;

% 2nd Pb stage
K2  = K1;
Wc2 = Wc1;
Q2  = 0.697;

% 3rd Pb stage

K3  = K1;
Wc3 = 2*pi*2009;
Q3  = 1.944;

% low pass
%H(s) = K*Wc^2 / (Wc^2 + Wc/Q*s + s^2);

Hl1 = K1*Wc1^2 / (Wc1^2 + Wc1/Q1*s + s^2);
Hl2 = K2*Wc2^2 / (Wc2^2 + Wc2/Q2*s + s^2);
Hl3 = K3*Wc3^2 / (Wc3^2 + Wc3/Q3*s + s^2);
Hl  = Hl1*Hl2*Hl3;


% high pass
% H(s) = K*s^2 / (Wc^2 + Wc/Q*s + s^2)
Wc  = 2*pi*338;
% 1st stage
Kh1 = 1.036;
Qh1 = 0.509;
% 2nd stage
Kh2 = 1.33;
Qh2 = 0.599;
% 3rd stage
Kh3 = 1.91;
Qh3 = 0.917;
% 4th stage
Kh4 = 2.6;
Qh4 = 2.5;

Hh1 = Kh1*s^2 / (Wc^2 + Wc/Qh1*s + s^2);
Hh2 = Kh2*s^2 / (Wc^2 + Wc/Qh2*s + s^2);
Hh3 = Kh3*s^2 / (Wc^2 + Wc/Qh3*s + s^2);
Hh4 = Kh4*s^2 / (Wc^2 + Wc/Qh4*s + s^2);
Hh = Hh1*Hh2*Hh3*Hh4;

H = Hl*Hh;
figure;
bode(H);





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


%{
transfert function composed with low/high pass butterworth
   Kl,Kh   : vector static gain for low/high pass
   Wcl,Wch : vector cut off pulsation
   Ql,Qh   : vector quality factor
   w       : vector pulsation to eval

   return  : s vector values for w
%}
function s=bp_butter(Kl,Wcl,Ql,Kh,Wch,Qh,w)

  s = ones(length(w),1);
  for i=1:length(Kl)
    s =  s .* lp_2nd_butter(Kl(i),Wcl(i),Ql(i),w);
  endfor
  for i=1:length(Kh)
    s =  s .* hp_2nd_butter(Kh(i),Wch(i),Qh(i),w);
  endfor
endfunction

s = bp_butter(Kl,Wcl,Ql,Kh,Wch,Qh,2*pi*Freqs);
print_filter_phases(s,Freqs);







