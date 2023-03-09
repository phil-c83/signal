pkg load signal;
clear all;
close all;

function [fname,fpath,Te,U1,I1,I2] = read_csv_UI()

  [fname, fpath, fltidx]=uigetfile ("/home/phil/MADE-SERVER/transfert/P_Coste/Jupiter22/","U I.. measures");
  file = [fpath "/" fname];
  %Te,U1,I1,I2
  m=dlmread(file,",",1,0);% skip 1st line
  Te  = m(:,1);
  U1  = m(:,2);
  I1  = m(:,3);
  I2  = m(:,4);
endfunction

[fname,fpath,Te,U1,I1,I2] = read_csv_UI();
[cosMC,cosCOV] = eval_cosui(Te,480,U1,I1);
printf("cos_mc=%5.4f cos_cov=%5.4f\n",cosMC,cosCOV);
