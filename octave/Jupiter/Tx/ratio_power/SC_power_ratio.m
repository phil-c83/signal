close all;
clear all;

function [fname,fpath,U1_inf,S1_inf,Fs,U1,I1,P1,cos_ui,I2,R2] = read_csv_UI()

  [fname, fpath, fltidx]=uigetfile ("/home/phil/MADE-SERVER/transfert/P_Coste/Jupiter22/","U I.. measures");
  file = [fpath "/" fname];
  printf("file=%s\n",file);

  # find csv for inf load
  infpat  = [fpath "clamp-inf*"];
  infname = glob(infpat);
  m = dlmread(infname{1},",",1,0);
  S1_inf  = m(:,2) .* m(:,3);
  U1_inf  = m(:,2);

  # get R2 value
  fid = fopen (file);
  header = fgetl(fid);
  fclose(fid);
  pos    = strfind(header,"#R2=");
  R2     = str2num(header(37:end));
  %Fs,U1,I1,P1,cos_ui,I2

  m=dlmread(file,",",1,0);

  Fs      = m(:,1);
  U1      = m(:,2);
  I1      = m(:,3);
  P1      = m(:,4);
  cos_ui  = m(:,5);
  I2      = m(:,6);
endfunction

[fname,fpath,Fs,U1,I1,P1,cos_ui,I2,R2] = read_csv_measures();

# find csv for infinite load ie I2=0
infpat  = [fpath "clamp-inf*"];
infname = glob(infpat);
m = dlmread(infname{1},",",1,0);
S1_inf  = m(:,2) .* m(:,3);
U1_inf  = m(:,2);

plot_power_ratio(Fs,U1_inf,S1_inf,U1,I1,I2,R2);

