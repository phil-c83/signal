close all;
clear all;

[fqname,fpath,fname] = choose_file();
[R2,T,Pa] = csv2mat(fqname);

# a = R2*(P-P0)
a = R2(1)*(Pa(:,1)-Pa(:,end));
ma= median(a);

figure();
for k=1:numel(R2)-1
  R2str = [";R2=" num2str(R2(k)) ";"];
  plot(T,Pa(:,k)-Pa(:,end),R2str);
  hold on;
endfor

figure();
for k=1:numel(R2)-1
  D = 1 ./ (Pa(:,k)-Pa(:,end));
  a = R2(1)*(Pa(:,1)-Pa(:,end));
  R= a .* D;
  Rstr = [";R2=" num2str(R2(k)) ";"];
  plot(T,R,Rstr);
  hold on;
endfor



P0_T20 = Pa(5,end);# P0 @ T= 20°C
a_T20  = R2(1)*(Pa(5,1)-Pa(5,end));
K      = 1.5e-3; # en W/°C

figure();
for k=1:numel(R2)-1
  D = 1./(Pa(:,k)-(P0_T20-K*(T-20)));
  #R= a_T20*D;
  R = ma*D;
  Rstr = [";R2=" num2str(R2(k)) ";"];
  plot(T,R,Rstr);
  hold on;
endfor

figure();
plot(T,Pa(:,end),";P0releve;",T,(P0_T20-K*(T-20)+0.01),";P0estimé;");
