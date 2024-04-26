## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-02-23
close all;
clearvars;


# phase correction for freq sets

Pcsf0 = [ 0.0                 ,  0.0 ;
          0.0                 ,  0.0 ;
          0.0                 ,  0.0 ];

Pcsf1 = [ 0.24428265          , -0.0748862184955752  ;
          0.22092883035398225 , -0.12159385778761067 ;
          0.19757501070796457 , -0.16830149707964603 ];

Pcsf2 = [ 0.15865197796460173 , -0.2461475625663717  ;
          0.12751355176991147 , -0.30842441495575224 ;
          0.10415973212389379 , -0.3551320542477876  ];

Pcsf3 = [ 0.08859051902654869 , -0.3862704804424778  ;
          0.06523669938053095 , -0.4329781197345133  ;
          0.04188287973451321 , -0.47968575902654875 ];

Pcsf4 = [ 0.010744453539823007 , -0.5419626114159292 ;
         -0.012609366106194675, -0.5886702507079645  ;
         -0.03596318575221236 ,  -0.6353778899999999 ];

global K1 K2 P1 P2 A;

function init_gen(VGrms,D)
  global K1 K2 P1 P2 A;
  K1 = Eval_Kn(1,D);
  K2 = Eval_Kn(2,D);
  P1 = Eval_Pn(1,D);
  P2 = Eval_Pn(2,D);
  A  = VGrms/sqrt(K1^2+K2^2);
endfunction

function Kn = Eval_Kn(n,D)
  Kn = sqrt(2)/(pi*n*(1-D))*sqrt(1-cos(2*pi*n*D));
endfunction

function Pn = Eval_Pn(n,D)
  Pn = atan(sin(2*pi*n*D)/(1-cos(2*pi*n*D)));
endfunction


# Sfx = K1*sin(2*pi*fx/Fe*n+P1) + K2*[sin(4*pi*fx/Fe*n+P2)
function s = Sig_gen_jupE (f1,f2,f3,Fe,n,Pc)
  global K1 K2 P1 P2 A;

  s = zeros(1,3);
  s1 = K1*sin(2*pi*f1/Fe*n+P1-Pc(1,1)) + K2*sin(4*pi*f1/Fe*n+P2-Pc(1,2));
  s2 = K1*sin(2*pi*f2/Fe*n+P1-Pc(2,1)) + K2*sin(4*pi*f2/Fe*n+P2-Pc(2,2));
  s3 = K1*sin(2*pi*f3/Fe*n+P1-Pc(3,1)) + K2*sin(4*pi*f3/Fe*n+P2-Pc(3,2));
  s(1,1) = s1-s2;
  s(1,2) = s2-s3;
  s(1,3) = s3-s1;
endfunction

Fe = 8e3;
n  = (Fe*0.1)-1;
#S  = zeros(n,3);
init_gen(1,2/5);
for k=0:n
  s = Sig_gen_jupE (410,440,470,Fe,k,Pcsf0);
  S(k+1,1) = s(1);
  S(k+1,2) = s(2);
  S(k+1,3) = s(3);
end

printf("K1=%2.4f K2=%2.4f P1=%2.4f P2=%2.4f\n",K1,K2,P1,P2);
plot(0:n,S(:,1),"g",0:n,S(:,2),"y",0:n,S(:,3),"r");


