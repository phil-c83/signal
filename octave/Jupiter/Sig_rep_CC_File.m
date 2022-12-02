clear all;
close all;

global idx_freqs_order=[42,83,45,89,48,95,53,105,57,113,60,119,62,123,65,129,68,135,72,143,75,149,78,155]';
global CC_phase=[4.34740296,0.64461441,3.82016056,0.34742992,3.37821982,0.07251097,2.79559496,5.95242922,2.39070519,5.61937539,2.12476747,5.39137232,1.96484024,5.24788405,1.74179083,5.03139729,1.53581696,4.81504649,1.26553518,4.53232755,1.09297982,4.32560573,0.91632345,4.09384946]';

global PowerMin = 0.002;
global SNMin    = 2.0;
global Unbalance_tol = .33; % 33%

function dp=CC_phase_correct(idx_f)
  global idx_freqs_order;
  global CC_phase;
  ix = [];
  for i=1:length(idx_f)
    ix  = [ix find(idx_freqs_order==(idx_f(i)))];
  endfor
  dp = CC_phase(ix);
endfunction


SigSetFreqs=[410 440 470;520 560 590;610 640 670;710 740 770]';

[fname, fpath, fltidx]=uigetfile ("*.CSV");
% Fe = 10kHz
s=get_tds200x_file([fpath "/" fname]);
printf("Analysing %s\n",[fpath "/" fname]);
range=1:1000;
FFT=fft(s(range,2));
sf = Sig_features(s(range,2),FFT,10e3,SigSetFreqs,@CC_phase_correct,pi/4,1);
SigCC = Sig_rep_CC (s(range,2),FFT,sf,PowerMin,SNMin,Unbalance_tol);

for k=1:length(SigCC)
  if ( SigCC(k).error == 0 )
    printf("SigSet = %d L%d Sens = %d\n",SigCC(k).Sets,SigCC(k).Lx,SigCC(k).Sens);
  elseif  ( SigCC(k).error == -1 )
    printf("SigSet = %d Error:Low Power or Bad S/N\n",SigCC(k).Sets);
  elseif  ( SigCC(k).error == -2 )
    printf("SigSet = %d R12=%4.2f R13=%4.2f Error:Power Ratio\n",SigCC(k).Sets,SigCC(k).Rp_12,SigCC(k).Rp_13);
  else
    printf("SigSet = %d Error:Unexpected\n",SigCC(k).Sets);
  endif
endfor
