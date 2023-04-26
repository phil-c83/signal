clear all;

U1min = 1.0;
U1max = 1.05;

dname = uigetdir ("/home/phil/MADE-SERVER/transfert/P_Coste/Jupiter22/","csv directory");

# find csv file name for R2=inf in the same directory
fpat  = [dname "/clamp-inf*"];
fname = glob(fpat);

[Fs0,U10,I10,P10,S10,R2]= csv_U1fixed(fname{1},U1min,U1max);

# find csv file name for all R2!=inf in the same directory
fpat  = [dname "/clamp-0.*"];
fnames = glob(fpat);

figure();
for k=1:size(fnames)(1)
  [Fs,U1,I1,P1,S1,R2]= csv_U1fixed(fnames{k},U1min,U1max);
  plot(Fs,P1,[";R2=" num2str(R2) ";"]);
  hold on;
endfor
title("P1 for all R2");
