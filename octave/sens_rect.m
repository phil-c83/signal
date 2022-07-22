% detection sens du signal
clear all;
close all;
%clc;
pkg load signal;

%{
forme du signal à synthétiser ie créneau sans symetrie
 ____
|    |
|<T1>|
     |________|
<      T      >      
A*T1 = B*(T-T1) => B = A*T1/(T-T1)
%}

% coefficients de la série de fourier
function an=an_coef(A,T1,T,n)
  an=sin(2*pi*n*T1/T)*A/(pi*n)*(T/(T-T1));
endfunction

function bn=bn_coef(A,T1,T,n)
  bn=(cos(2*pi*n*T1/T)-1)*A/(pi*n)*(T/(T-T1));
endfunction

%{
fonction de synthèse du signal
A    : amplitude
T1   : Partie positive ie T-T1 partie négative
T    : Periode
Fe   : Frequence d'echantillonage
nTe  : vecteur temps
nmax : Nombre max d'harmoniques
%}
function s=synth(A,T1,T,Fe,nTe,nmax)  
  s = zeros(length(nTe),1);
  for k=1:nmax
    s += an_coef(A,T1,T,k)*cos(2*pi*k*nTe/T) + bn_coef(A,T1,T,k)*sin(2*pi*k*nTe/T);
  endfor      
endfunction

function [xc,max,imax,min,imin] = do_corr(x,y)
  xc=xcorr(x,y);     
  [max,imax]=max(xc);
  [min,imin]=min(xc);
endfunction



Fe=2560; % 46875;
Tref=0.1;
Tsig=0.3;
Nhq = 2; % nombre d'harmoniques
F1=420;
F2=470;
F3=510;
Anoise=.5; % variance du bruit


nTe = (0:1/Fe:Tref-1/Fe)';
% synthese signaux de référence
s1=synth(.5,2/F1/5,1/F1,Fe,nTe,Nhq);
s2=synth(.5,2/F2/5,1/F2,Fe,nTe,Nhq);
s3=synth(.5,2/F3/5,1/F3,Fe,nTe,Nhq);

%{
Sens en circuit ouvert:
  sur phases (1,2) : S1-2*S2+S3
  sur phases (2,3) : S1+S2-2*S3
  sur phases (3,1) : -2*S1+S2+S3
  
Sens en court circuit:
  sur phase 1 : 2*(S1-S2)
  sur phase 2 : 2*(S2-S3)
  sur phase 3 : 2*(S3-S1)
%}

% signaux en CO phase/phase
L1L2CO_ref = s1-2*s2+s3;
L2L3CO_ref = s1+s3-2*s3;
L3L1CO_ref = -2*s1+s2+s3;

% signaux en CC et CO phase/neutre
L1CC_L1NCO_ref = s1-s2; 
L2CC_L2NCO_ref = s2-s3; 
L3CC_L3NCO_ref = s3-s1; 


%{
figure;
plot(nTe,s1,".-b;s1;",nTe,s2,".-r;s2;",nTe,s3,".-g;s3;");
figure;
plot(nTe,L1_ref,".-b;s1-s2;",nTe,L2_ref,".-r;s2-s3;",nTe,L3_ref,".-g;s3-s1;");
%}

% synthese signaux de base observés
nTe = (0:1/Fe:Tsig-1/Fe)';
s1=synth(.5,2/F1/5,1/F1,Fe,nTe,Nhq);
s2=synth(.5,2/F2/5,1/F2,Fe,nTe,Nhq);
s3=synth(.5,2/F3/5,1/F3,Fe,nTe,Nhq);

% bruit
noise1=Anoise*randn(length(nTe),1);
noise2=Anoise*randn(length(nTe),1);
noise3=Anoise*randn(length(nTe),1);

% signaux CO phase/phase
L1L2CO_sig = s1-2*s2+s3;
L2L3CO_sig = s1+s3-2*s3;
L3L1CO_sig = -2*s1+s2+s3;

% signaux CO phase/phase bruités
L1L2CO_sign = L1L2CO_sig + noise1;
L2L3CO_sign = L2L3CO_sig + noise2;
L3L1CO_sign = L3L1CO_sig + noise3;

% signaux en CC et CO phase/neutre
L1CC_L1NCO_sig = s1-s2; 
L2CC_L2NCO_sig = s2-s3; 
L3CC_L3NCO_sig = s3-s1; 

% signaux en CC et CO phase/neutre bruités
L1CC_L1NCO_sign = L1CC_L1NCO_sig + noise1; 
L2CC_L2NCO_sign = L2CC_L2NCO_sig + noise2; 
L3CC_L3NCO_sign = L3CC_L3NCO_sig + noise3;  


plot(nTe,L1CC_L1NCO_sig,".-b;L1;",nTe,-L1CC_L1NCO_sig,".-r;-L1;");

%{
figure;
nplot=1:1000;
plot(nTe(nplot),L1_sig(nplot),".-b;L1;",
     nTe(nplot),L2_sig(nplot),".-r;L2;",
     nTe(nplot),L3_sig(nplot),".-g;L3;");
figure;
plot(nTe(nplot),L1_sign(nplot),".-b;L1;",
     nTe(nplot),L2_sign(nplot),".-r;L2;",
     nTe(nplot),L3_sign(nplot),".-g;L3;");
%} 

%{
figure;
plot((0:1/Fe:Tref-1/Fe)',L1_ref,".-b;L1_ref;",
     (0:1/Fe:Tsig-1/Fe)',L1_sign,".-r;L1_sign;");
plot(L1_corr1);
figure;
plot(L1_corr2);
%}
                                                 

                                                 
nsamples=length(L1L2CO_ref);
% correlation en CO L1/L2 avec bruit
[xc,max,imax,min,imin] = do_corr(L1L2CO_ref,L1L2CO_sign);
printf("xcorr(L1L2CO_ref,L1L2CO_sign):Max=%f Min=%f\n",xc(imax),xc(imin));

% correlation en CO -L1/L2 avec bruit
[xc,max,imax,min,imin] = do_corr(L1L2CO_ref,-L1L2CO_sign);
printf("xcorr(L1L2CO_ref,-L1L2CO_sign):Max=%f Min=%f\n",xc(imax),xc(imin));

% correlation en CC L1 ou CO L1N avec bruit
[xc,max,imax,min,imin] = do_corr(L1CC_L1NCO_ref,L1CC_L1NCO_sign);
printf("xcorr(L1CC_L1NCO_ref,L1CC_L1NCO_sign):Max=%f Min=%f\n",xc(imax),xc(imin));

% correlation en CC -L1 ou CO -L1N avec bruit
[xc,max,imax,min,imin] = do_corr(L1CC_L1NCO_ref,-L1CC_L1NCO_sign);
printf("xcorr(L1CC_L1NCO_ref,-L1CC_L1NCO_sign):Max=%f Min=%f\n",xc(imax),xc(imin));

%{
[xc,max,imax,min,imin] = do_corr(L1_sig(100:nsamples+100),L1_ref);
printf("xcorr(L1_sig,L1_ref):Max=%f Min=%f\n",xc(imax),xc(imin));

[xc,max,imax,min,imin] = do_corr(L1_sig(1000:end),L1_ref);
printf("xcorr(L1_sig(1000:end),L1_ref):Max=%f Min=%f\n",xc(imax),xc(imin));

[xc,max,imax,min,imin] = do_corr(-L1_sig,L1_ref);
printf("xcorr(-L1_sig,L1_ref):Max=%f Min=%f\n",xc(imax),xc(imin));

[xc,max,imax,min,imin] = do_corr(L1_sign,L1_ref);
printf("xcorr(L1_sign,L1_ref):Max=%f Min=%f\n",xc(imax),xc(imin));

[xc,max,imax,min,imin] = do_corr(-L1_sign,L1_ref);
printf("xcorr(-L1_sign,L1_ref):Max=%f Min=%f\n",xc(imax),xc(imin));


[xc,max,imax,min,imin] = do_corr(L1_sig,L2_ref);
printf("xcorr(L1_sig,L2_ref):Max=%f Min=%f\n",xc(imax),xc(imin));

[xc,max,imax,min,imin] = do_corr(L1_sign,L2_ref);
printf("xcorr(L1_sign,L2_ref):Max=%f Min=%f\n",xc(imax),xc(imin));

[xc,max,imax,min,imin] = do_corr(L1_sig,L3_ref);
printf("xcorr(L1_sig,L3_ref):Max=%f Min=%f\n",xc(imax),xc(imin));

[xc,max,imax,min,imin] = do_corr(L1_sign,L3_ref);
printf("xcorr(L1_sign,L3_ref):Max=%f Min=%f\n",xc(imax),xc(imin));
%}


