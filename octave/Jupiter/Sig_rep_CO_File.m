clear all;
close all;

global PowerMin = 0.1;
global SNMin    = 2.0;
global Unbalance_tol = .33; % 33%


SigSetFreqs=[410 440 470;520 560 590;610 640 670;710 740 770]';

[fname, fpath, fltidx]=uigetfile ("*.CSV");
% Fe = 10kHz
s=get_tds200x_file([fpath "/" fname]);
printf("Analysing %s\n",[fpath "/" fname]);
range=1:1000;
FFT=fft(s(range,2));
sf = Sig_features(s(range,2),FFT,10e3,SigSetFreqs,pi/4,1);
SigCO = Sig_rep_CO (s(range,2),FFT,sf,PowerMin,SNMin,Unbalance_tol);

%{ 
struct SigCO 
SigCO(k).error 
SigCO(k).Sets  
SigCO(k).Rp_12 
SigCO(k).Rp_13 
SigCO(k).pt1   
SigCO(k).pt2   
%}

for k=1:length(SigCO)
  if ( SigCO(k).error == 0 )
    printf("SigSet = %d PT1=%d PT2=%d\n",SigCO(k).Sets,SigCO(k).pt1,SigCO(k).pt2);
  elseif  ( SigCO(k).error == -1 )
    printf("SigSet = %d Error:Low Power\n",SigCO(k).Sets);
  elseif  ( SigCO(k).error == -2 )
    printf("SigSet = %d R12=%4.2f R13=%4.2f Error:Power Ratio\n",SigCO(k).Sets,SigCO(k).Rp_12,SigCO(k).Rp_13); 
  elseif  ( SigCO(k).error == -3 )
    printf("SigSet = %d Error: Bad S/N\n",SigCO(k).Sets,SigCO(k).Rp_12,SigCO(k).Rp_13);       
  elseif  ( SigCO(k).error == -4 )
    printf("SigSet = %d Error: Bad Phase Id\n",SigCO(k).Sets);         
  elseif  ( SigCO(k).error == -5 )
    printf("SigSet = %d PT1=%d PT2=%d\n",SigCO(k).Sets,SigCO(k).pt1,SigCO(k).pt2);  
  else    
    printf("SigSet = %d Error:Unexpected\n",SigCO(k).Sets);  
  endif
endfor  