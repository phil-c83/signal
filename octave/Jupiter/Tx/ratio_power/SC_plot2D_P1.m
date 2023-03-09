clear all;

[fname,fpath,Fs,U1,I1,P1,cos_ui,I2,R2] = read_csv_measures();
plot_2D(Fs,U1,P1,R2,"P1");



