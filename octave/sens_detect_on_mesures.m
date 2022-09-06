pkg load signal
clear all;
close all;

S1_f=[410,440,470]';
S2_f=[520,560,590]';
S3_f=[610,640,670]';
S4_f=[710,740,770]';

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

%{
x(t) = A*rect(t-T1/2,T1) - A*T1/(T-T1)*rect(t-(T1+T)/2,T-T1)
sinc=sin(pi*x)/(pi*x)
TF{x(t-a,T,T1)}(f) = A*T1*exp(-i*2*pi*a*f) * 
                     {exp(-i*pi*T1*f)*sinc(T1*f) - 
                      exp(-i*pi*(T+T1)*f)*sinc((T-T1)*f)}
  --> -a = {arg(TF{x(t-a,T,T1)}(f)) - arg(z1-z2)} * 1/(2*pi*f)
       a = {arg(z1-z2) - arg(TF{x(t-a,T,T1)}(f))} * 1/(2*pi*f)
      z1= exp(-i*pi*T1*f)*sinc(T1*f)
      z2= exp(-i*pi*(T+T1)*f)*sinc((T-T1)*f)
%}                      
function [a,phi]=signal_lag(T1,T,f,arg_fft)
  z1 = exp(-i*pi*T1*f)*sinc(T1*f);
  z2 = exp(-i*pi*(T+T1)*f)*sinc((T-T1)*f);
  
  phi = arg(z1-z2)-arg_fft;
  %{
  if(phi<0)
    a  = -phi*1/(2*pi*f);     
  else
    a  = (2*pi-phi)/(2*pi*f);
  endif
  %}
  
  a = phi/(2*pi*f)+T1;
  if(a<0)
      a = T+a;
  endif    
  
endfunction

% analytic expr of X(f)=TF{rect((t-T1/2)/T1)-T1/(T-T1)*rect((t-(T+T1)/2)/(T-T1))}
function z=X_f(a,T1,T,f)
  z = exp(-i*2*pi*(a-T1)*f) .* (
      exp(-i*pi*T1*f) .* sinc(T1*f) - 
      exp(-i*pi*(T+T1)*f) .* sinc((T-T1)*f) );  
endfunction 

function [s,a,argf,arg2f,arg2f_c]=sens_eval(fft,f,df,N,T,T1,tol)
  argf  = arg(fft(Freq2FftIndex(f,df,N)));  % arg(TF{s(t-a)}(f)) mesuré
  arg2f = arg(fft(Freq2FftIndex(2*f,df,N)));% arg(TF{s(t-a)}(2*f)) mesuré
  % calcul du retard 'a' de s(t-a)
  [a,phi]=signal_lag(T1,T,f,argf);
  % calcul arg(TF{s(t-a)}(2*f)) avec 'a'
  z = X_f(a,T1,T,2/T);
  arg2f_c = arg(z);
  % comparaison avec tolerance ...
  if (abs(arg2f - arg2f_c) < tol)
    s=1; % sens direct
  else
    s=-1; % sens inverse 
  endif  
endfunction

function plot_signal_and_fft(nTe,y,yfft,FMAX)
  N = length(nTe);
  Fe = 1/(nTe(2)-nTe(1));
  dF = Fe/N;
  idx_max=round(FMAX/dF);
  idx=(0:idx_max);
  ndF = idx*dF;
  %yffts = fftshift(yfft);
  figure;
  subplot(3,1,1);
  plot(nTe,y,"--pk;sig;");
  subplot(3,1,2);
  plot(ndF,2*abs(yfft(idx+1))/N,"--pb;mods;");
  subplot(3,1,3);
  plot(ndF,arg(yfft(idx+1)),"--pg;args;");  
  %figure;
  %plot3(ndF,yffts);  
endfunction  

m1=dlmread("../data/L1.csv",",",0,0);
dt_csv=m1(2,1)-m1(1,1);% ie 1/Fe=1us pour ces enregistrements
printf("dt_csv=%f\n",dt_csv);
%figure;
%plot(m1(:,1),m1(:,2),"--.b;L1;");
idx0=find(m1(:,1)==0.2); % on se place ds le signal a t=0.2s
% 1 point sur 100 a partir de t=0.2s pendant 0.1s 1/Fe=10us N=1000
idx=(0:999)*100+idx0; 
s1=m1(idx,:);
%plot(s1(:,1),s1(:,2));
ffts1=fft(s1(:,2));
plot_signal_and_fft(s1(:,1),s1(:,2),ffts1,1000);


% index du fondamental et 1er harmonique pour chaque jeu de signaux
S1_H0_idx=Freq2FftIndex(S1_f,10,1000);
S1_H1_idx=Freq2FftIndex(2*S1_f,10,1000);

S2_H0_idx=Freq2FftIndex(S2_f,10,1000);
S2_H1_idx=Freq2FftIndex(2*S2_f,10,1000);

S3_H0_idx=Freq2FftIndex(S3_f,10,1000);
S3_H1_idx=Freq2FftIndex(2*S3_f,10,1000);

S4_H0_idx=Freq2FftIndex(S4_f,10,1000);
S4_H1_idx=Freq2FftIndex(2*S4_f,10,1000);

%puissance du signal pour chaque jeu de signaux
N=length(ffts1);
%puissance de chaque hamonique
p_S1_H=2/N^2*(ffts1([S1_H0_idx;S1_H1_idx]) .* conj(ffts1([S1_H0_idx;S1_H1_idx])));
p_S2_H=2/N^2*(ffts1([S2_H0_idx;S2_H1_idx]) .* conj(ffts1([S2_H0_idx;S2_H1_idx])));
p_S3_H=2/N^2*(ffts1([S3_H0_idx;S3_H1_idx]) .* conj(ffts1([S3_H0_idx;S3_H1_idx])));
p_S4_H=2/N^2*(ffts1([S4_H0_idx;S4_H1_idx]) .* conj(ffts1([S4_H0_idx;S4_H1_idx])));

%puissance totale pour chaque jeu de signaux
p_S1=sum(p_S1_H);
p_S2=sum(p_S2_H);
p_S3=sum(p_S3_H);
p_S4=sum(p_S4_H);

%
[s,a,argf,arg2f,arg2f_c]=sens_eval(ffts1,410,10,1000,1/410,2/410/5,0.1);
printf("sens=%d,T=%f a=%f,argf=%+f,arg2f=%+f,arg2f_c=%+f\n",s,1/410,a,argf,arg2f,arg2f_c);

[s,a,argf,arg2f,arg2f_c]=sens_eval(-ffts1,410,10,1000,1/410,2/410/5,0.1);
printf("sens=%d,T=%f a=%f,argf=%+f,arg2f=%+f,arg2f_c=%+f\n",s,1/410,a,argf,arg2f,arg2f_c);

%{
m2=dlmread("../data/L2.csv",",",0,0);
figure;
plot(m2(:,1),m2(:,2),"--.b;L2;");

m3=dlmread("../data/L3.csv",",",0,0);
figure;
plot(m3(:,1),m3(:,2),"--.b;L3;");
%}