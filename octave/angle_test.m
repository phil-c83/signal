pkg load signal;
clear all;
close all;

function [s1,s2,Te]=gen_dephased_sin(Fs,Tmax,N,phi,var_n)
  Ns   = floor(Tmax*4*N*Fs); # number of samples
  Te   = (0:Ns-1)'*1/(4*N*Fs);
  n_s1 = randn(Ns,1)*var_n;
  n_s2 = randn(Ns,1)*var_n;
  s1   = sin(2*pi*Fs*Te) + n_s1;
  s2   = sin(2*pi*Fs*Te+phi) + n_s1;

  #{
  figure();
  subplot(2,1,1);
  plot(Te,s1);
  subplot(2,1,2);
  plot(Te,s2);
  #}
endfunction





function [phiMC,phiCOV,cosMC,cosCOV]=test_angle(Te,U1,I1,Fs)
  [phi1,phi2,phiMC] = MCangle(I1,U1,480,Te);
  cosCOV  = cov(U1,I1,1)/sqrt(cov(U1,U1,1)*cov(I1,I1,1));
  phiCOV  = acos(cosCOV);
  cosMC   = cos(phiMC);
  printf("Fe=%7.2f phiMC=%5.4f cosMC=%5.4f phiCov=%5.4f cosCov=%5.4f\n",
          1/(Te(2)-Te(1)),phiMC,cosMC,phiCOV,cosCOV);
endfunction



#{
function phi12=test_MCangle(Fe,f,N,phi1,phi2,var_noise)
  Te = (0:N-1)'*1/Fe;
  ns1= randn(N,1)*var_noise;
  ns2= randn(N,1)*var_noise;
  s1 = sin(2*pi*f*Te+phi1) + ns1;
  s2 = sin(2*pi*f*Te+phi2) + ns2 ;

  [phi1,phi2,phi12] = MCangle(s1,s2,f,Te);
  printf("Phi1=%1.4f phi2=%1.4f phi12=%1.4f cos=%1.4f\n",phi1,phi2,phi12,cos(phi12));
endfunction

N  = 10;
Fs = 480;
Fe = 4*N*Fs;
W  = pi/(2*N); # 2*pi*Fs/Fe = 2*pi*Fs/(4*N*Fs)
[s1,s2,Te] = gen_dephased_sin(Fs,5,N,pi/10,0.05);
[phi1,phi2,phiMC] = MCangle(s2,s1,Fs,Te);
phiQ = Qangle(s1,s2,W,N);
cos_cov = cov(s1,s2)/sqrt(cov(s1,s1)*cov(s2,s2));
printf("phiMC=%5.4f phiQ=%5.4f phiCov=%5.4f\n",phiMC,phiQ,acos(cos_cov));
#}

[fname,fpath,Te,U1,I1,I2] = read_csv_UI();
figure();
subplot(3,1,1);
plot(Te,U1);
subplot(3,1,2);
plot(Te,I1);
subplot(3,1,3);
plot(Te,I2);



