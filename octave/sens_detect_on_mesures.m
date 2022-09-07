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
x(t) = A*(rect((t-T1/2)/T1)-T1/(T-T1)*rect((t-(T+T1)/2)/(T-T1)))
sinc = sin(pi*x)/(pi*x)
TF{x(t)}(f)   = A*T1*{exp(-i*pi*T1*f)*sinc(T1*f) - 
                      exp(-i*pi*(T+T1)*f)*sinc((T-T1)*f)}
TF{x(t-a)}(f) = exp(-i*2*pi*a*f) * TF{x(t)}(f)
   
    2*pi*f*a  = arg(TF{x(t)}(f)) - arg(TF{x(t-a)}(f));    
%}
% analytic expr of X(f)
function z=X_f(a,T1,T,f)
  z = exp(-i*2*pi*a*f) .* (
      exp(-i*pi*T1*f) .* sinc(T1*f) - 
      exp(-i*pi*(T+T1)*f) .* sinc((T-T1)*f) );  
endfunction 
                      
function [a,phi]=signal_lag(Xf,T1,T,f,arg_fft) 
    
  phi = arg(Xf(0,T1,T,f))-arg_fft;
  
  %{
  if(phi<0)
    a  = -phi*1/(2*pi*f);     
  else
    a  = (2*pi-phi)/(2*pi*f);
  endif 
  %}
  
  if(phi<0)
    a  = (2*pi+phi)/(2*pi*f);     
  else
    a  = phi/(2*pi*f);
  endif   
  
endfunction
%{ 
   TF{x(t+T1)}(f) =  exp(i*2*pi*f*T1) * TF{x(t)}(f)
   TF{x(t+T1)}(f) <->  exp(i*pi*T1*f)*sinc(T1*f) - 
                      exp(-i*pi*(T-T1)*f)*sinc((T-T1)*f)
   TF{x(t+T1-a)}(f) <-> exp(-i*2*pi*f*a)*TF{x(t+T1)}(f) =           
                        exp(-i*2*pi*f*a)*[exp(i*pi*T1*f)*sinc(T1*f) - 
                                          exp(-i*pi*(T-T1)*f)*sinc((T-T1)*f)] 
%}
function z=Y_f(a,T1,T,f)
  z = exp(-i*2*pi*f*a) .* (
      exp(i*pi*T1*f) .* sinc(T1*f) -
      exp(-i*pi*(T-T1)*f) .* sinc((T-T1)*f) );
endfunction


function [s,a,phi,argf,arg2f,arg2f_c]=sens_eval(Xf,fft,f,df,N,T,T1,tol)
  argf  = arg(fft(Freq2FftIndex(f,df,N)));  % arg(TF{s(t-a)}(f)) mesuré
  arg2f = arg(fft(Freq2FftIndex(2*f,df,N)));% arg(TF{s(t-a)}(2*f)) mesuré
  % calcul du retard 'a' de s(t-a)
  [a,phi]=signal_lag(Xf,T1,T,f,argf);
  % calcul arg(TF{s(t-a)}(2*f)) avec 'a'
  z = Xf(a,T1,T,2/T);
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

% read file tecktronic tds2000 series saved files 
function m=read_tds200x_file(file,sep,row_n,col_n)
  m=dlmread(file,sep,row_n,col_n);
endfunction

function s=get_tds200x_file(file)
  m1 = read_tds200x_file(file,",",0,3);
  dt_csv = m1(2,1)-m1(1,1);
  step = round(dt_csv/1e-4);% Te=100us  
  printf("dt_csv=%f\n",dt_csv);
  n1 = length(m1);
  n  = round(n1/step);
  idx= (1:n)*step;
  s  = m1(idx,:);  
endfunction

function analyse_signal(s,offset)
  range=offset:1000+offset;
  ffts=fft(s(range,2));
  plot_signal_and_fft(s(range,1),s(range,2),ffts,1000);

  [s,a,phi,argf,arg2f,arg2f_c]=sens_eval(@X_f,ffts,410,10,1000,1/410,2/410/5,0.1);
  printf("sens=%d,T=%f a=%f,argf=%+3.2f,phi=%+3.2f,arg2f=%+3.2f,arg2f_c=%+3.2f\n",
          s,1/410,a,argf,phi,arg2f,arg2f_c);  
endfunction  

s=get_tds200x_file("../data/F0000L1.CSV");
analyse_signal(s,1);
analyse_signal(s,200);
analyse_signal(s,500);


s=get_tds200x_file("../data/F0001L1.CSV");
analyse_signal(s,1);
analyse_signal(s,200);
analyse_signal(s,500);







%{
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

%}


%{
[s,a,argf,arg2f,arg2f_c]=sens_eval(@Y_f,ffts1,410,10,1000,1/410,2/410/5,0.1);
printf("sens=%d,T=%f a=%f,argf=%+f,arg2f=%+f,arg2f_c=%+f\n",s,1/410,a,argf,arg2f,arg2f_c);

[s,a,argf,arg2f,arg2f_c]=sens_eval(@Y_f,-ffts1,410,10,1000,1/410,2/410/5,0.1);
printf("sens=%d,T=%f a=%f,argf=%+f,arg2f=%+f,arg2f_c=%+f\n",s,1/410,a,argf,arg2f,arg2f_c);
%}

%{
m2=dlmread("../data/L2.csv",",",0,0);
figure;
plot(m2(:,1),m2(:,2),"--.b;L2;");

m3=dlmread("../data/L3.csv",",",0,0);
figure;
plot(m3(:,1),m3(:,2),"--.b;L3;");
%}