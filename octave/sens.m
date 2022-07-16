%{
TF{A*sin(2*pi/T*t+a)} = A/2*[exp(i*a)*delta(v-1/T) + exp(-i*a)*delta(v+1/T)]
TF{A*cos(2*pi/T*t+a)} = A/(2*i)*[exp(i*a)*delta(v-1/T) - exp(-i*a)*delta(v+1/T)] 
%}
clear all;close all;clc;
global N=1280;
global Fn=1280;
global n=0:N-1;
global Nfft=256;
global Df=Fn/Nfft;
global F1=100;
global F2=120;

global ABS_MIN=1e-3;

f=(-Nfft/2:Nfft/2-1)*Df;

%{
function sgn=sig_polarity(re_n,re_p,im_n,im_p,abs_min)
  sgn: +1 -> sin, -1 -> -sin, 0 -> error
  re_n : re(-f)
  re_p : re(+f)
  im_n : im(-f)
  im_p : im(+f)
  abs_min : threshold for minimum value not estimated null

sin(2*pi*f*t + a)=s(t,a):
  Re(TF{s(t,0)}(-f)) = 0,    Re(TF{s(t,0)}(f)) = 0,    
  Im(TF{s(t,0)}(-f)) > 0,    Im(TF{s(t,0)}(f)) < 0
  
  Re(TF{s(t,pi/2)}(-f)) > 0, Re(TF{s(t,pi/2)}(f)) > 0, 
  Im(TF{s(t,pi/2)}(-f)) = 0, Im(TF{s(t,pi/2)}(f)) = 0
  
  a<>0 and a<>pi/2:
  Re(TF{s(t,a)}(-f)) > 0, Re(TF{s(t,0)}(f)) > 0,
  Im(TF{s(t,a)}(-f)) > 0, Im(TF{s(t,0)}(f)) < 0
  
-s(t,a):
  Re(TF{-s(t,0)}(-f)) = 0,    Re(TF{-s(t,0)}(f)) = 0,    
  Im(TF{-s(t,0)}(-f)) < 0,    Im(TF{-s(t,0)}(f)) > 0
  
  Re(TF{-s(t,pi/2)}(-f)) < 0, Re(TF{-s(t,pi/2)}(f)) < 0, 
  Im(TF{-s(t,pi/2)}(-f)) = 0, Im(TF{-s(t,pi/2)}(f)) = 0
  
  a<>0 and a<>pi/2:
  Re(TF{-s(t,a)}(-f)) < 0, Re(TF{-s(t,0)}(f)) < 0,
  Im(TF{-s(t,a)}(-f)) < 0, Im(TF{-s(t,0)}(f)) > 0
%}

function sgn=sig_polarity(re_n,re_p,im_n,im_p,abs_min)
  
  if (abs(re_n) < abs_min || abs(re_p) < abs_min)
    % a ~= 0
    if (im_n > 0 && im_p < 0)
      sgn = +1;
    elseif (im_n < 0 && im_p > 0)
      sgn = -1;
    else
      sgn = 0; % error
    endif
  elseif  (abs(im_n) < abs_min || abs(im_p) < abs_min)
    % a ~= pi/2
    if (re_n > 0 && re_p > 0)
      sgn = +1;
    elseif (re_n < 0 && re_p < 0)
      sgn = -1;
    else
      sgn = 0; % error
    endif
  else
    % a<>0 && a<>pi/2
    if (re_n > 0 && re_p > 0 && im_n > 0 && im_p < 0)
      sgn = +1;
    elseif (re_n < 0 && re_p < 0 && im_n < 0 && im_p > 0)
      sgn = -1;
    else
      sgn = 0; % error
    endif
  endif 

endfunction

function [arg_fn,arg_fp,phi_n,phi_p,tau_n,tau_p]=arg_diff(s_fft,df,f,arg_refn,arg_refp)
  N=length(s_fft);
  idx_f=f/df;
  f_p=s_fft(N/2+1+idx_f);
  f_n=s_fft(N/2+1-idx_f);
  arg_fn=arg(f_n);
  arg_fp=arg(f_p);
  phi_n=arg_fn - arg_refn;
  phi_p=arg_fp - arg_refp;
  tau_n=phi_n/(2*pi*f);
  tau_p=phi_p/(2*pi*f);
endfunction

function sgn=find_polarity(s,idx_f1,idx_f2)
  global ABS_MIN;
  N=length(s);
  sfft=fftshift(fft(s)/N);
  
  re_f1p=real(sfft(N/2+1+idx_f1));
  re_f1n=real(sfft(N/2+1-idx_f1));
  im_f1p=imag(sfft(N/2+1+idx_f1));
  im_f1n=imag(sfft(N/2+1-idx_f1));
  
  re_f2p=real(sfft(N/2+1+idx_f2));
  re_f2n=real(sfft(N/2+1-idx_f2));
  im_f2p=imag(sfft(N/2+1+idx_f2));
  im_f2n=imag(sfft(N/2+1-idx_f2));
  
  printf("\tre_f1n=%2.3f re_f1p=%2.3f im_f1n=%2.3f im_f1p=%2.3f arg(-f1)=%3.2f arg(f1)=%3.2f\n",
          re_f1n,re_f1p,im_f1n,im_f1p,arg(sfft(N/2+1-idx_f1))/pi*180,arg(sfft(N/2+1+idx_f1))/pi*180);
  printf("\tre_f2n=%2.3f re_f2p=%2.3f im_f2n=%2.3f im_f2p=%2.3f arg(-f2)=%3.2f arg(f2)=%3.2f\n",
          re_f2n,re_f2p,im_f2n,im_f2p,arg(sfft(N/2+1-idx_f2))/pi*180,arg(sfft(N/2+1+idx_f2))/pi*180);  
          
  sgn_f1=sig_polarity(re_f1n,re_f1p,im_f1n,im_f1p,ABS_MIN);
  sgn_f2=sig_polarity(re_f2n,re_f2p,im_f2n,im_f2p,ABS_MIN);
  
  if (sgn_f1 == +1 && sgn_f2 == -1)
    sgn = +1;
  elseif (sgn_f1 == -1 && sgn_f2 == +1)
    sgn = -1;
  else
    sgn = 0; % error
  endif 
  
endfunction

function slice=sig_slice(s,start,n)
  slice = s(start:start+n-1);
endfunction

% 
S1=sin(2*pi*F1/Fn*n);
S2=sin(2*pi*F2/Fn*n);

S12=S1-S2;
S21=S2-S1;
%{
figure();
plot(n*1/Fn,S12);
figure();
plot(n*1/Fn,S21);
%}
% slice of signal for fft

%{
SP12=fftshift(fft(S12(idx_fft))/Nfft);
SP21=fftshift(fft(S21(idx_fft))/Nfft);

re_SP12=real(SP12);
im_SP12=imag(SP12);

figure();plot(f,re_SP12);legend("Re(SP12)");
figure();plot(f,im_SP12);legend("Im(SP12)");

re_SP21=real(SP21);
im_SP21=imag(SP21);

figure();plot(f,re_SP21);legend("Re(SP21)");
figure();plot(f,im_SP21);legend("Im(SP21)");
%}

idx_f1=F1/Df;
idx_f2=F2/Df;
for start=1:20
  printf("\n");
  sl=sig_slice(S12,start,Nfft);  
  s_fft=fftshift(fft(sl)/Nfft);
  [arg_fn,arg_fp,phi_n,phi_p,tau_n,tau_p]=arg_diff(s_fft,Df,F1,arg(i),arg(-i));  
  printf("S12 lag=%3d f=%3d arg(-f)=%+6.2f arg(+f)=%+6.2f phi_n=%+6.2f phi_p=%+6.2f tau_n=%+f tau_p=%+f\n",
          start-1,F1,arg_fn/pi*180,arg_fp/pi*180,phi_n/pi*180,phi_p/pi*180,tau_n,tau_p);  
          
  [arg_fn,arg_fp,phi_n,phi_p,tau_n,tau_p]=arg_diff(s_fft,Df,F2,-arg(i),-arg(-i));  
  printf("S12 lag=%3d f=%3d arg(-f)=%+6.2f arg(+f)=%+6.2f phi_n=%+6.2f phi_p=%+6.2f tau_n=%+f tau_p=%+f\n",
          start-1,F2,arg_fn/pi*180,arg_fp/pi*180,phi_n/pi*180,phi_p/pi*180,tau_n,tau_p);            
          
endfor
