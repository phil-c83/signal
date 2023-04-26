close all;
clear all;

[fqname,fpath,fname] = choose_file();
[R2,T,Pa] = csv2mat(fqname);

a = R2(1)*(Pa(:,1)-Pa(:,end));
ma= median(a);
figure();
for k=1:numel(R2)
  R2str = [";R2=" num2str(R2(k)) ";"];
  plot(T,Pa(:,k),R2str);
  hold on;
endfor


[a0,a1] = MCLinearR2Temp (Pa(:,1:end-1),Pa(:,end),T,R2);
printf("P-P0=%f/R2 + %f*T \t median(a)=%f\n",a0,a1,ma);

#{
figure();
plot(T,a,";a;",T,ones(1,numel(T))*ma,";median;");

figure();
for k=1:numel(R2)
  R2str = [";R2=" num2str(R2(k)) ";"];
  plot(T,a0*1/R2(k)+a1*T+Pa(:,end),R2str);
  hold on;
endfor

figure();
for k=1:numel(R2)
  R2str = [";R2=" num2str(R2(k)) ";"];
  plot(T,ma*1/R2(k)+200e-6*T+Pa(:,end),R2str);
  hold on;
endfor
#}

figure();
for k=1:numel(R2)-1
  D = 1./(Pa(:,k)-Pa(:,end)-a1*T);
  R= a0*D;
  Rstr = [";R2=" num2str(R2(k)) ";"];
  plot(T,R,Rstr);
  hold on;
endfor

figure();
for k=1:numel(R2)-1
  D = 1./(Pa(:,k)-Pa(:,end)-200e-6*T);
  R= ma*D;
  Rstr = [";R2=" num2str(R2(k)) ";"];
  plot(T,R,Rstr);
  hold on;
endfor

