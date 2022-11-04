clear;
close all;
clc;
%{
section noyau magnetique: 1.6e-2 * 0.8e-2 = 1.28e-4 m^2
Bmax ~= 1.5 Tesla  => flux = 1.28e-4 * 1.5 = 192e-6 Wb
Dnoyau ~= 85e-3 m
Mu FeSi ~= 40e3 a 50e3
Reluc  ~= 85e-3*pi/(45e3*4*pi*1e-7*1.28e-4) ~= 37e3
signal L1: (420,470) (520,570) periode: n1/410=n2/420 => T1=41/410 = 0.1s
       L2: (470,510) (570,610) periode: 0.1s
       L3: (510,420) (610,520) periode: 0.1s

%}

pkg load signal;
Reluc=85e-3/(45e3*4e-7*1.28e-4); %37000


% read file tecktronic tds2000 series saved files
function m=read_tds200x_file(file,sep,row_n,col_n)
  m=dlmread(file,sep,row_n,col_n);
endfunction

function m=read_tds200x_dir(dirname,nfiles)
  files=[dirname "/*.CSV"];
  f=dir(files);

  m=[];
  for i=1:nfiles
    if i==1 % read time and values
      %[dirname "/" f(i).name]
      m1=read_tds200x_file([dirname "/" f(i).name],",",0,3);
      m=m1;
    else    % read only value time read in first file
      %[dirname "/" f(i).name]
      m1=read_tds200x_file([dirname "/" f(i).name],",",0,4);
      m=[m m1];
    endif
  endfor
endfunction

%{
function reluc=compute_reluc(at,flux)
  reluc=at ./ flux ;%mean(at ./ flux);
endfunction
%}

function xc=my_xcorr(x,y)
  xc=[];
  nx=length(x);
  ny=length(y);
  imax=min(nx,ny);
  for k=1:nx+ny-1
    xc(k)=0;
    for i=1:imax
      ix=nx-k+i;
      if ix > 0 && ix <= nx && i < ny
        xc(k) += x(ix)*y(i);
      endif
    endfor
  endfor
endfunction

%{
inputs
dirname : directory to read file on
nfiles  : number of files to readdir
outputs
m       : time/signal matrix
idx_0   : index of time 0
Te      : samples time period
Tobs    : signal duration
%}
function [m,idx_0,Te,Tobs]=process_measures(dirname,nfiles)
  m     = read_tds200x_dir(dirname,nfiles);
  Te    = m(2,1)-m(1,1);
  idx_0 = find(m(:,1)==0);% find time 0
  if length(idx_0) == 0 % no time zero
    idx_0 = 1;
  endif
  [rows,cols] = size(m);
  Tobs  = Te*rows;
endfunction

%{
plot m((idx_0:nTe-1)*Te,1) vs m((idx_0:nTe-1),i) i=2:n
inputs
m        : time/signal matix
Te       : sample time
idx_0    : time 0 index for starting plot
n        : samples to plot
fmt      : cell of FMT plot format strings
%}
function plot_signals(m,Te,idx_0,n,fmt)
  figure;
  t=idx_0:n-1;
  for i=1:length(fmt)
    hold on;
    plot(m(t,1),m(t,i+1),fmt{i});
  endfor
endfunction

function v=ms_value(s)
  v=sum(s .^ 2) / length(s);
endfunction

function v=rms_value(s)
  n=length(s);
  v=sqrt(ms_value(s));
endfunction

function p=Pactive(u,i)
  n = length(u);
  p = sum(u .* i)/n;
endfunction

function p=Papparente(u,i)
  p=rms_value(u)*rms_value(i);
endfunction

function p=period_sinus(s)
  % find sign changes for locating zeros
  % prod(p) < 0 => zero crossing between s(p) s(p+1)
  % prod(p) = 0 => zero crossing @ s(p)
  prod = s(1:end-1) .* s(2:end);
  %disp(prod);
  % find consecutive zeros ie a true zeros in data if any
  two_zeros=find(prod(1:end-1)==0 & prod(2:end)==0);
  % suppress the 1st one
  prod(two_zeros)=1;
  % find all sign changes and zeros
  idx = find(prod<=0);
  %disp(idx);
  n = length(idx)-1;
  % compute sum of distance between zeros
  s_diff = sum(idx(2:end) - idx(1:end-1));
  % compute period
  p = 2*s_diff/n;
endfunction

%{
  if plot_fft
    figure
    Df=1/Tobs;
    Df_v = (0:Tsig_n/2-2)*Df;
    fft_V1=fft(m(Tsig_range,2));
    fft_I1=fft(m(Tsig_range,3));
    fft_I2=fft(m(Tsig_range,4));
    fft_phi=fft(flux);
    plot(Df_v,2*abs(fft_V1(1:Tsig_n/2-1)/Tsig_n),".-y;V1;",
         Df_v,2*abs(fft_I1(1:Tsig_n/2-1)/Tsig_n),".-b;I1;",
         Df_v,2*abs(fft_I2(1:Tsig_n/2-1)/Tsig_n),".-m;Dphi;",
         Df_v,2*abs(fft_phi(1:Tsig_n/2-1)/Tsig_n*Phico*1e4),".-k;phi*10^4;");
  endif
%}

%{
determiner l'inductance magnetisante et la resistance equivalente aux pertes
essai en circuit ouvert @ V1 nominal
inputs
u   : vecteur tension
i   : vecteur courant
T   : periode sinus
outputs
Rf  : resistance de perte
Lm  : inductance magnetisante
S   : puissance apparente
P   : puissance active
Q   : puissance reactive
%}
function [Rf,Lm,U,I,S,P,Q]=mesure_co(u,i,T)
  U2  = ms_value(u);
  U   = sqrt(U2);
  I   = rms_value(i);
  S   = U * I;
  P   = Pactive(u,i);
  Q   = sqrt(S^2-P^2);
  Rf  = U2/P;
  Lm  = U2/(2*pi*1/T)/Q  ;
endfunction

%{
determiner l'inductance de fuite et la resistance serie
essai en court circuit secondaire @ 10% de V1 nominal
inputs
u   : vecteur tension
i   : vecteur courant
m   : rapport transformation
T   : periode sinus
outputs
Rs  : resistance serie
Lf  : inductance fuite
S   : puissance apparente
P   : puissance active
Q   : puissance reactive
%}
function [Rs,Lf,U,I,S,P,Q]=mesure_cc(u,i,m,T)

  U2  = ms_value(u);
  U   = sqrt(U2);
  I   = rms_value(i);
  S   = U * I;
  P   = Pactive(u,i);
  Q   = sqrt(S^2-P^2);
  Rs  = m^2*P/I^2;
  Lf  = m^2*Q/(2*pi*1/T*I^2);
endfunction
%{

%}
function [V1,I1,I2,S1,P1,Q1]=mesure_ccr(u1,i1,i2)
  V1 = rms_value(u1);
  I1 = rms_value(i1);
  I2 = rms_value(i2);
  S1 = V1*I1;
  P1 = Pactive(u1,i1);
  Q1 = sqrt(S1^2-P1^2);
endfunction

%{
Eval de I2 avec modèle transfo R1,Lm ie (Lf=0,Rs=+inf)
%}
function i2=I2_modele1(f,m,Lm,R1,I1,V1)
  XL = Lm*2*pi*f;
  i2=1/m*abs((1-i*R1/XL)*I1+i*V1/XL);
  printf("1/T=%f m=%f Lm=%f R1=%f I1=%f V1=%f I2=%f\n",f,m,Lm,R1,I1,V1,i2);
endfunction

%{
Eval de I2 avec modèle transfo R1,Rf,Lm ie (Lf=0)
%}
function i2=I2_modele2(f,m,Lm,Rf,R1,I1,V1)
  XL = Lm*2*pi*f;
  i2=abs(I1/m - (V1-R1*I1)*(Rf+i*XL)/(i*m*XL*Rf));
  %printf("1/T=%f m=%f Lm=%f Rf=%f R1=%f I1=%f V1=%f I2=%f\n",f,m,Lm,Rf,R1,I1,V1,i2);
  printf("I2=%f ",i2);
  printf("\n");
endfunction
%{
Eval de I2 avec modèle transfo R1,Lm,Lf ie (Rs=+inf)
%}
function i2=I2_modele3(f,m,Lm,Lf,R1,I1,V1)
  XL = Lm*2*pi*f;
  XF = Lf*2*pi*f;
  i2=abs((I1*(R1+i*(XL+XF))-V1)/(i*m*XL));
  printf("1/T=%f m=%f Lm=%f Lf=%f R1=%f I1=%f V1=%f I2=%f\n",f,m,Lm,Lf,R1,I1,V1,i2);
endfunction

%{
Eval de I2 avec modèle transfo R1,Lm,Lf,Rs
%}
function i2=I2_modele4(f,m,Lm,Lf,Rf,R1,I1,V1)
  XL = Lm*2*pi*f;
  XF = Lf*2*pi*f;
  Z1 = R1+i*XF;
  Zm = Rf+i*XL;
  i2 = abs((I1*(i*Rf*XL + Z1*Zm) - V1*Zm )/(i*XL*m*Rf));
  printf("1/T=%f m=%f Lm=%f Lf=%f Rf=%f R1=%f I1=%f V1=%f I2=%f\n",f,m,Lm,Lf,Rf,R1,I1,V1,i2);
endfunction

%{
Eval de I2 avec modèle transfo Lm,Lf
%}
function i2=I2_modele5(f,m,Lm,Lf,R1,I1,V1)
  XL = Lm*2*pi*f;
  XF = Lf*2*pi*f;
  i2 = abs((I1*(i*(XL+XF)) - V1)/(i*XL*m));
  printf("1/T=%f m=%f Lm=%f Lf=%f R1=%f I1=%f V1=%f I2=%f\n",f,m,Lm,Lf,R1,I1,V1,i2);
endfunction




fmt_plot3={"--.y;U1;";"--.b;I1;";"--.m;I2;"};
fmt_plot4={"--.y;Ch1;";"--.b;Ch2;";"--.m;Ch3;";"--.k;Ch4;"};
fmt_co="V1rms=%f I1rms=%f S1=%f P1=%f Q1=%f Rf=%f Lm=%f Te=%f 1/T=%f\n";
fmt_cc="V1rms=%f I1rms=%f S1=%f P1=%f Q1=%f Rs=%f Lf=%f Te=%f 1/T=%f\n";
fmt_ccr="V1rms=%f I1rms=%f I2rms=%f S=%f P=%f Q=%f R2=%f Te=%f 1/T=%f\n";

% essai en co f=500Hz mesure I1 sur 0.1R
str="./data/ALL0000";
[m,idx_0,Te,Tobs]=process_measures(str,3);
T=period_sinus(m(idx_0:end,2))*Te;
[Rf,Lm,U,I,S,P,Q]=mesure_co(m(:,2),m(:,3),T);
printf(fmt_co,U,I,S,P,Q,Rf,Lm,Te,1/T);
%plot_signals(m,Te,idx_0,length(m(:,2))-idx_0+1,fmt_plot3);

% essai en co f=500Hz mesure I1 sur 0.1R
str="./data/ALL0001";
[m,idx_0,Te,Tobs]=process_measures(str,3);
T=period_sinus(m(idx_0:end,2))*Te;
[Rf,Lm,U,I,S,P,Q]=mesure_co(m(:,2),m(:,3),T);
printf(fmt_co,U,I,S,P,Q,Rf,Lm,Te,1/T);
%plot_signals(m,Te,idx_0,length(m(:,2))-idx_0+1,fmt_plot3);

I2I1=[0 I];
I2I1_m1=[0 I];% I2 calculé avec model1
I2I1_m2=[0 I];% I2 calculé avec model2
I2I1_m3=[0 I];% I2 calculé avec model3
I2I1_m4=[0 I];% I2 calculé avec model4
I2I1_m5=[0 I];% I2 calculé avec model4


% essai en cc (V1 ~= 10% V1n) f=500Hz mesure I1 sur 0.1R
str="./data/ALL0002";
[m,idx_0,Te,Tobs]=process_measures(str,3);
T=period_sinus(m(idx_0:end,2))*Te;
[Rs,Lf,U,I,S,P,Q]=mesure_cc(m(:,2),m(:,3),1/4,T);
printf(fmt_cc,U,I,S,P,Q,Rs,Lf,Te,1/T);
%plot_signals(m,Te,idx_0,length(m(:,2))-idx_0+1,fmt_plot3);

% valeur retenues des parametres des modeles
LM=Lm;
RF=Rf;
R1=0.1;
LF=Lf;

% essai en cc (V1 ~= 10% V1n) f=500hz mesure I1 sur 0.1R
str="./data/ALL0003";
[m,idx_0,Te,Tobs]=process_measures(str,3);
T=period_sinus(m(idx_0:end,2))*Te;
[Rs,Lf,U,I,S,P,Q]=mesure_cc(m(:,2),m(:,3),1/4,T);
printf(fmt_cc,U,I,S,P,Q,Rs,Lf,Te,1/T);
%plot_signals(m,Te,idx_0,length(m(:,2))-idx_0+1,fmt_plot3);

%essai secondaire sur 1R
str="./data/ALL0004";
[m,idx_0,Te,Tobs]=process_measures(str,3);
T=period_sinus(m(idx_0:end,2))*Te;
[V1rms,I1rms,I2rms,S1,P1,Q1]=mesure_ccr(m(idx_0:end,2),m(idx_0:end,3),m(idx_0:end,4));
printf(fmt_ccr,V1rms,I1rms,I2rms,S1,P1,Q1,1,Te,1/T);

I2I1=[I2I1;I2rms I1rms];

I2_m1=I2_modele1(1/T,1/4,LM,R1,I1rms,V1rms);
I2I1_m1=[I2I1_m1;I2_m1 I1rms];

I2_m2=I2_modele2(1/T,1/4,LM,RF,R1,I1rms,V1rms);
I2I1_m2=[I2I1_m2;I2_m2 I1rms];

I2_m3=I2_modele3(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m3=[I2I1_m3;I2_m3 I1rms];

I2_m4=I2_modele4(1/T,1/4,LM,LF,RF,R1,I1rms,V1rms);
I2I1_m4=[I2I1_m4;I2_m4 I1rms];

I2_m5=I2_modele5(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m5=[I2I1_m5;I2_m5 I1rms];

%essai secondaire sur 1/3R
str="./data/ALL0005";
[m,idx_0,Te,Tobs]=process_measures(str,3);
T=period_sinus(m(idx_0:end,2))*Te;
[V1rms,I1rms,I2rms,S1,P1,Q1]=mesure_ccr(m(idx_0:end,2),m(idx_0:end,3),m(idx_0:end,4));
printf(fmt_ccr,V1rms,I1rms,I2rms,S1,P1,Q1,1/3,Te,1/T);

I2I1=[I2I1;I2rms I1rms];

I2_m1=I2_modele1(1/T,1/4,LM,R1,I1rms,V1rms);
I2I1_m1=[I2I1_m1;I2_m1 I1rms];

I2_m2=I2_modele2(1/T,1/4,LM,RF,R1,I1rms,V1rms);
I2I1_m2=[I2I1_m2;I2_m2 I1rms];

I2_m3=I2_modele3(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m3=[I2I1_m3;I2_m3 I1rms];

I2_m4=I2_modele4(1/T,1/4,LM,LF,RF,R1,I1rms,V1rms);
I2I1_m4=[I2I1_m4;I2_m4 I1rms];

I2_m5=I2_modele5(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m5=[I2I1_m5;I2_m5 I1rms];

%essai secondaire sur 1/4R
str="./data/ALL0006";
[m,idx_0,Te,Tobs]=process_measures(str,3);
T=period_sinus(m(idx_0:end,2))*Te;
[V1rms,I1rms,I2rms,S1,P1,Q1]=mesure_ccr(m(idx_0:end,2),m(idx_0:end,3),m(idx_0:end,4));
printf(fmt_ccr,V1rms,I1rms,I2rms,S1,P1,Q1,1/4,Te,1/T);

I2I1=[I2I1;I2rms I1rms];

I2_m1=I2_modele1(1/T,1/4,LM,R1,I1rms,V1rms);
I2I1_m1=[I2I1_m1;I2_m1 I1rms];

I2_m2=I2_modele2(1/T,1/4,LM,RF,R1,I1rms,V1rms);
I2I1_m2=[I2I1_m2;I2_m2 I1rms];

I2_m3=I2_modele3(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m3=[I2I1_m3;I2_m3 I1rms];

I2_m4=I2_modele4(1/T,1/4,LM,LF,RF,R1,I1rms,V1rms);
I2I1_m4=[I2I1_m4;I2_m4 I1rms];

I2_m5=I2_modele5(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m5=[I2I1_m5;I2_m5 I1rms];

%essai secondaire sur 0.1R
str="./data/ALL0007";
[m,idx_0,Te,Tobs]=process_measures(str,3);
T=period_sinus(m(idx_0:end,2))*Te;
[V1rms,I1rms,I2rms,S1,P1,Q1]=mesure_ccr(m(idx_0:end,2),m(idx_0:end,3),m(idx_0:end,4));
printf(fmt_ccr,V1rms,I1rms,I2rms,S1,P1,Q1,R1,Te,1/T);

I2I1=[I2I1;I2rms I1rms];

I2_m1=I2_modele1(1/T,1/4,LM,R1,I1rms,V1rms);
I2I1_m1=[I2I1_m1;I2_m1 I1rms];

I2_m2=I2_modele2(1/T,1/4,LM,RF,R1,I1rms,V1rms);
I2I1_m2=[I2I1_m2;I2_m2 I1rms];

I2_m3=I2_modele3(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m3=[I2I1_m3;I2_m3 I1rms];

I2_m4=I2_modele4(1/T,1/4,LM,LF,RF,R1,I1rms,V1rms);
I2I1_m4=[I2I1_m4;I2_m4 I1rms];

I2_m5=I2_modele5(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m5=[I2I1_m5;I2_m5 I1rms];

%essai secondaire sur 0.05R
str="./data/ALL0008";
[m,idx_0,Te,Tobs]=process_measures(str,3);
T=period_sinus(m(idx_0:end,2))*Te;
[V1rms,I1rms,I2rms,S1,P1,Q1]=mesure_ccr(m(idx_0:end,2),m(idx_0:end,3),m(idx_0:end,4));
printf(fmt_ccr,V1rms,I1rms,I2rms,S1,P1,Q1,0.05,Te,1/T);

I2I1=[I2I1;I2rms I1rms];

I2_m1=I2_modele1(1/T,1/4,LM,R1,I1rms,V1rms);
I2I1_m1=[I2I1_m1;I2_m1 I1rms];

I2_m2=I2_modele2(1/T,1/4,LM,RF,R1,I1rms,V1rms);
I2I1_m2=[I2I1_m2;I2_m2 I1rms];

I2_m3=I2_modele3(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m3=[I2I1_m3;I2_m3 I1rms];

I2_m4=I2_modele4(1/T,1/4,LM,LF,RF,R1,I1rms,V1rms);
I2I1_m4=[I2I1_m4;I2_m4 I1rms];

I2_m5=I2_modele5(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m5=[I2I1_m5;I2_m5 I1rms];

%essai secondaire sur 0.03R
str="./data/ALL0009";
[m,idx_0,Te,Tobs]=process_measures(str,3);
T=period_sinus(m(idx_0:end,2))*Te;
[V1rms,I1rms,I2rms,S1,P1,Q1]=mesure_ccr(m(idx_0:end,2),m(idx_0:end,3),m(idx_0:end,4));
printf(fmt_ccr,V1rms,I1rms,I2rms,S1,P1,Q1,0.03,Te,1/T);

I2I1=[I2I1;I2rms I1rms];

I2_m1=I2_modele1(1/T,1/4,LM,R1,I1rms,V1rms);
I2I1_m1=[I2I1_m1;I2_m1 I1rms];

I2_m2=I2_modele2(1/T,1/4,LM,RF,R1,I1rms,V1rms);
I2I1_m2=[I2I1_m2;I2_m2 I1rms];

I2_m3=I2_modele3(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m3=[I2I1_m3;I2_m3 I1rms];

I2_m4=I2_modele4(1/T,1/4,LM,LF,RF,R1,I1rms,V1rms);
I2I1_m4=[I2I1_m4;I2_m4 I1rms];

I2_m5=I2_modele5(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m5=[I2I1_m5;I2_m5 I1rms];

%essai secondaire sur 0.02R
str="./data/ALL0011";
[m,idx_0,Te,Tobs]=process_measures(str,3);
T=period_sinus(m(idx_0:end,2))*Te;
[V1rms,I1rms,I2rms,S1,P1,Q1]=mesure_ccr(m(idx_0:end,2),m(idx_0:end,3),m(idx_0:end,4));
printf(fmt_ccr,V1rms,I1rms,I2rms,S1,P1,Q1,0.02,Te,1/T);

I2I1=[I2I1;I2rms I1rms];

I2_m1=I2_modele1(1/T,1/4,LM,R1,I1rms,V1rms);
I2I1_m1=[I2I1_m1;I2_m1 I1rms];

I2_m2=I2_modele2(1/T,1/4,LM,RF,R1,I1rms,V1rms);
I2I1_m2=[I2I1_m2;I2_m2 I1rms];

I2_m3=I2_modele3(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m3=[I2I1_m3;I2_m3 I1rms];

I2_m4=I2_modele4(1/T,1/4,LM,LF,RF,R1,I1rms,V1rms);
I2I1_m4=[I2I1_m4;I2_m4 I1rms];

I2_m5=I2_modele5(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m5=[I2I1_m5;I2_m5 I1rms];

%essai secondaire sur 0.01R
str="./data/ALL0010";
[m,idx_0,Te,Tobs]=process_measures(str,3);
T=period_sinus(m(idx_0:end,2))*Te;
[V1rms,I1rms,I2rms,S1,P1,Q1]=mesure_ccr(m(idx_0:end,2),m(idx_0:end,3),m(idx_0:end,4));
printf(fmt_ccr,V1rms,I1rms,I2rms,S1,P1,Q1,0.01,Te,1/T);

I2I1=[I2I1;I2rms I1rms];

I2_m1=I2_modele1(1/T,1/4,LM,R1,I1rms,V1rms);
I2I1_m1=[I2I1_m1;I2_m1 I1rms];

I2_m2=I2_modele2(1/T,1/4,LM,RF,R1,I1rms,V1rms);
I2I1_m2=[I2I1_m2;I2_m2 I1rms];

I2_m3=I2_modele3(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m3=[I2I1_m3;I2_m3 I1rms];

I2_m4=I2_modele4(1/T,1/4,LM,LF,RF,R1,I1rms,V1rms);
I2I1_m4=[I2I1_m4;I2_m4 I1rms];

I2_m5=I2_modele5(1/T,1/4,LM,LF,R1,I1rms,V1rms);
I2I1_m5=[I2I1_m5;I2_m5 I1rms];

figure;
plot(I2I1(:,1),I2I1(:,2),".-k;I1vsI2;");

figure;
plot(I2I1_m1(:,1),I2I1_m1(:,2),".-b;I1vsI2;");

figure;
plot(I2I1_m2(:,1),I2I1_m2(:,2),".-r;I1vsI2;");

figure;
plot(I2I1_m3(:,1),I2I1_m3(:,2),".-g;I1vsI2;");

figure;
plot(I2I1_m4(:,1),I2I1_m4(:,2),".-m;I1vsI2;");

figure;
plot(I2I1_m5(:,1),I2I1_m5(:,2),".-c;I1vsI2;");
