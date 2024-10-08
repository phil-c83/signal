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
x(t,T1,T) = A*(rect((t-T1/2)/T1)-T1/(T-T1)*rect((t-(T+T1)/2)/(T-T1)))

TF{x(t-a,T,T1)}(f) = A*T1*exp(-i*2*pi*a*f) * 
                     {exp(-i*pi*T1*f)*sinc(pi*T1*f) - 
                      exp(-i*pi*(T-T1)*f)*sinc(pi*(T-T1)*f)}
%}

global Freqs=[410,440,470;
              520,560,590;
              610,640,670;
              710,740,770]';
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


% coefficients de la série de fourier
% A*(rect((t-T1/2)/T1)-T1/(T-T1)*rect((t-(T+T1)/2)/(T-T1)))
function an=an_coef(A,T1,T,n)
  an=sin(2*pi*n*T1/T)*A/(pi*n)*(T/(T-T1));
endfunction

function bn=bn_coef(A,T1,T,n)
  bn=-(cos(2*pi*n*T1/T)-1)*A/(pi*n)*(T/(T-T1));
endfunction 
%{
fonction de synthèse du signal
A    : amplitude
T1   : Partie positive ie T-T1 partie négative
T    : Periode
nTe  : vecteur temps
nmax : Nombre max d'harmoniques
%}
function s=synth(A,T1,T,nTe,nmax)  
  s = zeros(length(nTe),1);
  for k=1:nmax
    s += an_coef(A,T1,T,k)*cos(2*pi*k*nTe/T) + bn_coef(A,T1,T,k)*sin(2*pi*k*nTe/T);
  endfor    
endfunction

function [nTe,y]=zero_mean_rect(A,Fe,T1,T)
  nTe = 0:1/Fe:T-1/Fe;
  y = A*rectpuls(nTe-T1/2,T1) - T1/(T-T1)*A*rectpuls(nTe-(T1+(T-T1)/2),T-T1);
endfunction

% A*(rect((t-T1/2)/T1)-T1/(T-T1)*rect((t-(T+T1)/2)/(T-T1)))
function y=zero_mean_rect_train(A,nTe,T1,T,nT)  
    %delay and amplitude of each signal period
  dT  = ((0:T:nT-T))';
  d1  = [dT+T1/2,A*ones(floor(nT/T),1)];
  d2  = [dT+(T+T1)/2,(A*T1)/(T-T1)*ones(floor(nT/T),1)];
  y   =  pulstran(nTe,d1,"rectpuls",T1) - pulstran(nTe,d2,"rectpuls",T-T1);
endfunction

function [nTe,y]=signal_rect_jupiter(A,Fe,f1,f2,nT)
  nTe = (0:1/Fe:nT-1/Fe)';
  s_p = zero_mean_rect_train(A,Fe,nTe,2/f1/5,1/f1,nT) ;
  s_n = zero_mean_rect_train(A,Fe,nTe,2/f2/5,1/f2,nT) ;
  y   = s_p - s_n;  
endfunction

function [nTe,y]=signal_jupiter(A,Fe,f1,f2,nT)
  nTe = (0:1/Fe:nT-1/Fe)';
  s1  = synth(1/2,2/f1/5,1/f1,nTe,2);
  s2  = synth(1/2,2/f2/5,1/f2,nTe,2); 
  y   = s1-s2;  
endfunction






% analytic expr of X(f)=TF{rect((t-T1/2)/T1)-T1/(T-T1)*rect((t-(T+T1)/2)/(T-T1))}
function z=X_f(a,T1,T,f)
  z = exp(-i*2*pi*a*f) .* (
      exp(-i*pi*T1*f) .* sinc(T1*f) - 
      exp(-i*pi*(T+T1)*f) .* sinc((T-T1)*f) );  
endfunction  

function [a,phi]=signal_lag(Xf,T1,T,f,arg_fft) 
    
  phi = arg(Xf(0,T1,T,f))-arg_fft;  
  
  if(phi<0)
    a  = (2*pi+phi)/(2*pi*f);     
  else
    a  = phi/(2*pi*f);
  endif   
  
endfunction

function plot_fft_signal(nTe,y,yfft)
  N = length(nTe);
  Fe = 1/(nTe(2)-nTe(1));
  dF = Fe/N;
  ndF =(0:N/2-1)*dF;
  
  figure;
  subplot(3,1,1);
  plot(nTe,y,"--.k;sig;");
  subplot(3,1,2);
  plot(ndF,abs(yfft(1:N/2))/N,"--.b;mods;");
  subplot(3,1,3);
  plot(ndF,arg(yfft(1:N/2)),"--.g;args;");    
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

% compare fft with Ft @ discrete frequencies for jupiter signal
function fft_and_dft(lag,A,Fe,N,T1,T,nT)
  global Freqs;
  df=Fe/N;
  ndf=(0:N/2-1)*df;
  % DFT with FT with Fe/N step  
  dft=X_f(-lag,T1,T,ndf);
  
  %[nTe,y]=zero_mean_rect_train(A,Fe,T1,T,2*nT);  
  %[nTe,y]=signal_jupiter(A,Fe,Freqs(1,1),Freqs(2,1),2*nT);
  
  [nTe,y]=signal_jupiter(A,Fe,Freqs(1,1),Freqs(2,1),2*nT);
  
  range=1+round(lag*Fe):N+round(lag*Fe);
  yfft = fft(y(range));
  
  plot_fft_signal(nTe(range),y(range),yfft);
  
  
  printf("fft(f)=%s X(f)=%s fft(2f)=%s  X(2f)=%s\n",
            num2str(2*yfft(Freq2FftIndex(1/T,df,N))/N),
            num2str(dft(1/T/10+1)),
            num2str(2*yfft(Freq2FftIndex(2/T,df,N))/N),
            num2str(dft(2/T/10+1)));
  printf("Arg(fft(f))=%+3.2f Arg(X(f))=%+3.2f Arg(fft(2f))=%+3.2f  Arg(X(2f))=%+3.2f\n",
            arg(yfft(Freq2FftIndex(1/T,df,N))),
            arg(dft(1/T/10+1)),
            arg(yfft(Freq2FftIndex(2/T,df,N))),
            arg(dft(2/T/10+1)));    
endfunction

fft_and_dft(0,1,Fe,N,2/410/5,1/410,nT);
fft_and_dft(5/Fe,1,Fe,N,2/410/5,1/410,nT);
fft_and_dft(20/Fe,1,Fe,N,2/410/5,1/410,nT);


%{
% DFT with FT with 10Hz step
ndf=(0:511)*10;
z=X_f(0,2/410/5,1/410,ndf);

[nTe,y]=zero_mean_rect_train(1,Fe,2/410/5,1/410,2*nT);  
yfft = fft(y(1:N));
figure;
subplot(2,1,1);
plot(ndf,abs(z),"--.k;DFT;",ndf,abs(2*yfft(1:512)/N),"--.b;FFT;");
subplot(2,1,2);
plot(ndf,arg(z),"--.k;DFT;",ndf,arg(2*yfft(1:512)/N),"--.b;FFT;");
printf("fft(f)=%s X(f)=%s fft(2f)=%s  X(2f)=%s\n",
            num2str(2*yfft(Freq2FftIndex(410,10,1024))/N),
            num2str(z(410/10+1)),
            num2str(2*yfft(Freq2FftIndex(2*410,10,1024))/N),
            num2str(z(2*410/10+1)));
printf("Arg(fft(f))=%+3.2f Arg(X(f))=%+3.2f Arg(fft(2f))=%+3.2f  X(2f)=%+3.2f\n",
            arg(yfft(Freq2FftIndex(410,10,1024))),
            arg(z(410/10+1)),
            arg(yfft(Freq2FftIndex(2*410,10,1024))),
            arg(z(2*410/10+1)));            
%}




%{ 
%signal 
for f=Freqs(1)
  d_cycle=2/f/5;
  %function [nTe,y]=zero_mean_rect_train(A,Fe,T1,T,nT)
  [nTe,y]=zero_mean_rect_train(1,Fe,d_cycle,1/f,2*nT);  
  dF = Fe/N;
  printf("\n");
  for lag=0:floor(Fe/f)    
    % s(t-a)
    yfft = fft(y(1+lag:N+lag));
    idx0 = Freq2FftIndex(f,dF,N);
    idx1 = Freq2FftIndex(2*f,dF,N);
    [slag,phi] = signal_lag(d_cycle,1/f,f,arg(yfft(idx0)));
    z1f    = X_f(slag,d_cycle,1/f,f);
    z2f    = X_f(slag,d_cycle,1/f,2*f);
    
    printf("fft(f)=%s X(f)=%s fft(2f)=%s  X(2f)=%s\n",
            num2str(2*yfft(idx0)/N),num2str(z1f),num2str(2*yfft(idx1)/N),num2str(z2f));
    %{        
    printf(" S(t) f=%d lag=%f idf=%d idx2f=%d arg(X(f))=%f arg(X(2f))=%f *--* sig_lag=%f phi=%f arg(X(2*f))=%f\n",
            f,lag/Fe,idx0,idx1,arg(yfft(idx0)),arg(yfft(idx1)),slag,phi,arg(z2f));
    
    % -s(t-a)
    yfftn = fft(-y(1+lag:N+lag));
    [slagn,phin] = signal_lag(d_cycle,1/f,f,arg(yfftn(idx0)));
    z2fn    = X_f(slag,d_cycle,1/f,2*f);
    printf("-S(t) f=%d lag=%f idf=%d idx2f=%d arg(X(f))=%f arg(X(2f))=%f *--* sig_lag=%f phi=%f arg(X(2*f))=%f\n",
            f,lag/Fe,idx0,idx1,arg(yfftn(idx0)),arg(yfftn(idx1)),slagn,phin,arg(z2fn));
    %}        
  endfor    
endfor
%}



