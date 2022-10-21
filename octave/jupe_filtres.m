pkg load control;
clear all;
close all;

SigSetFreqs=[410 440 470 520 560 590 610 640 670 710 740 770];
Freqs=[SigSetFreqs,SigSetFreqs*2]';

function print_filter_phases(H,f)
  args = arg(H(2*pi*f));
  N    = length(f)/2;
  for k=1:N
    printf("f=%4d arg@f=%+3.2f arg(w)/w=%+6.5f 2f=%4d arg@2f=%+3.2f arg(2w)/2w=%+6.5f\n",
            f(k),args(k),args(k)/(2*pi*f(k)),f(k+N),args(k+N),args(k+N)/(2*pi*f(k+N)));
  endfor
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

%{
figure;
bode(Hl1);
figure;
bode(Hl2);
figure;
bode(Hl3);
figure;
bode(Hl1*Hl2*Hl3);
%}

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

print_filter_phases(H,Freqs);











