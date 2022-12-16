pkg load signal
clear all;
close all;

SigSetFreqs=[410 440 470;520 560 590;610 640 670;710 740 770]';



% read file tecktronic dpo3000 series saved files
function m=read_dpo3000_file(file,sep,row_n,col_n)
  m=dlmread(file,sep,row_n,col_n);
endfunction

function s=get_dpo3000_file(file)
  m1 = read_dpo3000_file(file,",",0,0);
  dt_csv = m1(2,1)-m1(1,1);
  step = round(1e-4/dt_csv);% Te=100us
  printf("dt_csv=%f\n",dt_csv);
  n1 = length(m1);
  n  = round(n1/step);
  idx= (1:n)*step;
  s  = m1(idx,:);
endfunction



[fname, fpath, fltidx]=uigetfile("*.CSV");
% Fe = 10kHz
s=get_tds200x_file([fpath "/" fname]);
printf("Analysing %s\n",[fpath "/" fname]);
range=1:1024;
FFT=fft(s(range,2));
SigSetFeatures = Sig_features(s(range,2),FFT,10e3,SigSetFreqs,pi/4,1);
