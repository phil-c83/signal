clear all;
close all;

global PowerMin = 0.1;
global MaxTol   = 1.56; % 25%
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