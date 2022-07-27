pkg load signal
clear all;
close all;
%graphics_toolkit("qt"); set in .octaverc
%{
forme du signal à synthétiser ie créneau sans symetrie
 ____
|    |
|<T1>|
     |________|
<      T      >      
A*T1 = B*(T-T1) => B = A*T1/(T-T1)
x(t)=A*rect(t-T1/2,T1) - A*T1/(T-T1)*rect(t-(T1+T)/2,T-T1)

TF{x(t-a,T,T1)}(f) = A*T1*exp(-i*2*pi*a*f) * 
                     {exp(-i*pi*T1*f)*sinc(pi*T1*f) - 
                      exp(-i*pi*(T-T1)*f)*sinc(pi*(T-T1)*f)}
%}

Freqs=[410,440,470,520,560,590,610,640,670,710,740,770];
nT  = 0.1;
N   = 1024;
Te = nT/N;
Fe  = 1/Te;

function idx=Freq2FftIndex(f,df,N)
  k = round(abs(f/df));
  if ( f>0 )
    idx = k+1;
  elseif ( f<0 )
    idx = N-k+1;
  else
    idx = 1;
  endif
endfunction  

function [nTe,y]=zero_mean_rect(A,Fe,T1,T)
  nTe = 0:1/Fe:T-1/Fe;
  y = A*rectpuls(nTe-T1/2,T1) - T1/(T-T1)*A*rectpuls(nTe-(T1+(T-T1)/2),T-T1);
endfunction

%
function [nTe,y]=zero_mean_rect_train(A,Fe,T1,T,nT)
  nTe = ((0:1/Fe:nT-1/Fe))';
  %delay and amplitude of each signal period
  dT  = ((0:T:nT-T))';
  d1  = [dT+T1/2,A*ones(floor(nT/T),1)];
  d2  = [dT+(T+T1)/2,(A*T1)/(T-T1)*ones(floor(nT/T),1)];
  y   =  pulstran(nTe,d1,"rectpuls",T1) - pulstran(nTe,d2,"rectpuls",T-T1);
endfunction

%{
x(t) = A*rect(t-T1/2,T1) - A*T1/(T-T1)*rect(t-(T1+T)/2,T-T1)
sinc=sin(pi*x)/(pi*x)
TF{x(t-a,T,T1)}(f) = A*T1*exp(-i*2*pi*a*f) * 
                     {exp(-i*pi*T1*f)*sinc(T1*f) - 
                      exp(-i*pi*(T+T1)*f)*sinc((T-T1)*f)}
  --> -a = {arg(TF{x(t-a,T,T1)}(f)) - arg(z1-z2)} * 1/(2*pi*f)
      z1= exp(-i*pi*T1*f)*sinc(T1*f)
      z2= exp(-i*pi*(T+T1)*f)*sinc((T-T1)*f)
%}                      
function [a,phi]=signal_lag(T1,T,f,arg_fft)
  z1=exp(-i*pi*T1*f)*sinc(T1*f);
  z2=exp(-i*pi*(T+T1)*f)*sinc((T-T1)*f);
  
  phi= (arg(z1-z2)-arg_fft);
  if(phi<0)
    a  = -phi*1/(2*pi*f); 
  else
    a  = (2*pi-phi)/(2*pi*f);
  endif
endfunction

% analytic expr of X(f)
function z=X_f(a,T1,T,f)
  z = exp(-i*2*pi*a*f) * (
      exp(-i*pi*T1*f)*sinc(T1*f) - 
      exp(-i*pi*(T+T1)*f)*sinc((T-T1)*f) );  
endfunction  

function plot_fft_signal(nTe,y,yfft)
  N = length(nTe);
  Fe = 1/(nTe(2)-nTe(1));
  dF = Fe/N;
  ndF = -Fe/2:dF:Fe/2-dF;
  yffts = fftshift(yfft);
  figure;
  subplot(3,1,1);
  plot(nTe,y,"--.k;sig;");
  subplot(3,1,2);
  plot(ndF,abs(yffts)/N,"--.b;mods;");
  subplot(3,1,3);
  plot(ndF,arg(yffts)*180/pi,"--.g;args;");  
  figure;
  plot3(ndF,yffts);  
endfunction  

function q=quadran(z)
  th=arg(z);
  if(th>=0)
    if(th>pi/2)
      q=2;
    else
      q=1;
    endif  
  else
    if(th<-pi/2)
      q=3;
    else
      q=4;
    endif  
  endif
endfunction

function s=sens_det(y)
  iy=find(y>=0);
  if( length(iy) > length(y)-length(iy) )
    s=1;
  else
    s=0;
  endif  
endfunction

function signal_harmonic_properties(nTe,y,yfft,f,k,lag,str)
  N = length(nTe);
  Fe = 1/(nTe(2)-nTe(1));
  dF = Fe/N;
  % index of f
  idx0 = Freq2FftIndex(f,dF,N);  
  printf("%s lag=%2d f=%3.0f abs(f)=% 2.2f arg(f)=%+ 3.2f ",
         str,lag,f,abs(yfft(idx0))/N,
         arg(yfft(idx0))*180/pi);
  % phase diff between i*f and f 
  for i=2:k
    idx = Freq2FftIndex(i*f,dF,N);    
    printf("abs(%df)=%02.2f arg(%df)=%+03.2f arg(%df)-arg(f)=%+ 3.2f ",
           i,abs(yfft(idx))/N,i,arg(yfft(idx))*180/pi,
           i,arg(yfft(idx)/yfft(idx0))*180/pi);
  endfor
  printf("\n");
  %printf("sens=%d\n",sens_detect(y));
endfunction  



% signal 
for f=Freqs
  [nTe,y]=zero_mean_rect_train(1,Fe,3/f/5,1/f,2*nT);  
  dF = Fe/N;
  printf("\n");
  for lag=0:floor(Fe/f)    
    % s(t-a)
    yfft = fft(y(1+lag:N+lag));
    idx0 = Freq2FftIndex(f,dF,N);
    idx1 = Freq2FftIndex(2*f,dF,N);
    [slag,phi] = signal_lag(3/f/5,1/f,f,arg(yfft(idx0)));
    z    = X_f(slag,3/f/5,1/f,2*f);
    printf(" S(t) f=%d lag=%f idf=%d idx2f=%d arg(X(f))=%f arg(X(2f))=%f *--* sig_lag=%f phi=%f arg(X(2*f))=%f\n",
            f,lag/Fe,idx0,idx1,arg(yfft(idx0)),arg(yfft(idx1)),slag,phi,arg(z));
    
    % -s(t-a)
    yfftn = fft(-y(1+lag:N+lag));
    [slagn,phin] = signal_lag(3/f/5,1/f,f,arg(yfftn(idx0)));
    zn    = X_f(slag,3/f/5,1/f,2*f);
    printf("-S(t) f=%d lag=%f idf=%d idx2f=%d arg(X(f))=%f arg(X(2f))=%f *--* sig_lag=%f phi=%f arg(X(2*f))=%f\n",
            f,lag/Fe,idx0,idx1,arg(yfftn(idx0)),arg(yfftn(idx1)),slagn,phin,arg(zn));
  endfor    
endfor




