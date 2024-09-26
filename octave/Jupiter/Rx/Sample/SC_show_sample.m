close all;
clear all;

Fe = 10240;
[fname, fpath, fltidx]=uigetfile("*.json");
if (fname != 0 )
  str = fileread([fpath fname]);
  # printf("%s\n", str);
  show_sample(Fe,str);
end

