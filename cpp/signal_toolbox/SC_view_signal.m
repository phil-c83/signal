clearvars;
# pkg load signal;
addpath("../../octave/mpad/Bump");
ext = "m";
[fqname,fpath,fname]=choose_file(ext);
printf("opening %s\n",fqname);

v=load(fqname);

plot(v(:,1),v(:,2));

