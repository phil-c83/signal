clear all;


[fname, fpath, fltidx]=uigetfile("*.json");
if (fname != 0 )
  str = fileread([fpath fname]);
  # printf("%s\n", str);
  write_sample(fpath,fname,str);
end
