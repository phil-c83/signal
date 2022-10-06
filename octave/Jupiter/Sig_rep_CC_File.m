clear all;
close all;

global PowerMin = 0.1;
global MaxTol   = 1.77; % 33%
global MinTol   = 5.0;

SigSetFreqs=[410 440 470;520 560 590;610 640 670;710 740 770]';

[fname, fpath, fltidx]=uigetfile ("*.CSV");
% Fe = 10kHz
s=get_tds200x_file([fpath "/" fname]);
printf("Analysing %s\n",[fpath "/" fname]);
range=1:1000;
FFT=fft(s(range,2));
sf = Sig_features(s(range,2),FFT,10e3,SigSetFreqs,pi/4,1);
SigCC = Sig_rep_CC (s(range,2),FFT,sf,0.1,MaxTol,MinTol);

for k=1:length(SigCC)
  if ( SigCC(k).error == 0 )
    printf("SigSet = %d L%d Sens = %d\n",SigCC(k).Sets,SigCC(k).Lx,SigCC(k).Sens);
  elseif  ( SigCC(k).error == -1 )
    printf("SigSet = %d Error:Low Power\n",SigCC(k).Sets);
  elseif  ( SigCC(k).error == -2 )
    printf("SigSet = %d R12=%4.2f R13=%4.2f Error:Power Ratio\n",SigCC(k).Sets,SigCC(k).Rp_12,SigCC(k).Rp_13);  
  else
    printf("SigSet = %d Error:Unexpected\n",SigCC(k).Sets);  
  endif
endfor  
