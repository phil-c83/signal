pkg load signal
clear all;
close all;

% read file tecktronic tds2000 series saved files
function m=read_tds200x_file(file,sep,row_n,col_n)
  m=dlmread(file,sep,row_n,col_n);
endfunction

function [s,dt]=get_tds200x_file(file)
  s = read_tds200x_file(file,",",0,3);
  dt = s(2,1)-s(1,1);
endfunction


% plot s(t) and abs/arg(FFT(s(t))) s(0)=f(t-T0)
function Sig_plot(s,T0,FFT,Fe,FMAX,text)
  N  = length(FFT);
  dF = Fe/N;
  idx_max=round(FMAX/dF);
  idx=(0:idx_max);
  ndF = idx*dF;
  nTe = T0:1/Fe:T0+1/Fe*(N-1);

  figure;
  subplot(3,1,1);
  plot(nTe,s,["--pk;" text ";"]);
  subplot(3,1,2);
  plot(ndF(2:end),2*abs(FFT(2:idx_max+1))/N,"--pb;mods;");
  subplot(3,1,3);
  plot(ndF(2:end),arg(FFT(idx(2:idx_max+1))),"--pg;args;");
  %figure;
  %plot3(ndF,FFT);
endfunction

% s: matrix with col1:time col2:data
function slice=Sig_get_slice(s,t0,t1)
  slice=find(s(:,1)>=t0 & s(:,1)<=t1);
endfunction



function [vrms,irms,P,S,Q,cosui]=Sig_powers(u,i)
  % P = sum(u_j * i_j)/N - sum(u_j)*sum(i_j)/N^2
  vrms = sqrt(var(u,1));
  irms = sqrt(var(i,1));
  P    = (u'*i)/length(u);
  P   -= sum(u)*sum(i)/length(i)^2;
  S    = vrms*irms;
  cosui= P/S;
  Q    = sqrt(S^2-P^2);
endfunction

function dname=select_dir(pname)
  dname  = uigetdir(pname);
  printf("Into Dir=%s\n",dname);
endfunction

% select file matching pattern 'fglob' from initial path 'pname' on
% chosen dir. Show from start time 'Ts' to stop time 'Te' with title
% 'text' and FFT with 0<=f<=FMAX.
function [s,dt]=show_data_file(dname,fglob,text,Ts,Te,FMAX)
  printf("Into Dir=%s for Glob=%s\n",dname,fglob);
  odir   = cd(dname);
  fnames = glob(fglob);
  fname  = [dname "/" fnames{1}];% assume glob patern match one file
  printf("Analysing file=%s\n",fname);
  [m,dt]=get_tds200x_file(fname);
  slice=Sig_get_slice(m(:,1),Ts,Te);
  s = m(slice,2);
  FFT=fft(s);
  Sig_plot(s,m(slice(1),1),FFT,1/dt,FMAX,text);
  cd(odir);
endfunction


dname = select_dir("/home/phil/Made/git-prj/signal/data/Tx_RegulI2");
[E1,dt]=show_data_file(dname,"*CH1.CSV","E1",0,0.04,480*10);
[I1,dt]=show_data_file(dname,"*CH2.CSV","I1",0,0.04,480*10);
[U1,dt]=show_data_file(dname,"*CH3.CSV","U1",0,0.04,480*10);
erms = sqrt(var(E1,1));
[vrms,irms,P,S,Q,cosui]=Sig_powers(U1,I1);
printf("U1rms=%4.3fV I1rms=%4.3fA E1rms=%4.3fv S=%4.3fVA P=%4.3fW Q=%4.3fVAR Cos=%4.3f\n",
        vrms,irms,erms,S,P,Q,cosui);





