clear all;

[fname,fpath,Fs,U1,I1,P1,cos_ui,I2,R2] = read_csv_measures();

# find csv for infinite load in the same directory
  infpat  = [fpath "clamp-inf*"];
  infname = glob(infpat);
  m = dlmread(infname{1},",",1,0);
  P10  = m(:,4);

  plot_3D (Fs,U1,R2*I2./P1,R2,"P2/P1");
