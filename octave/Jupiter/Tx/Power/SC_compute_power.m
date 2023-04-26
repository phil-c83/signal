clear all;
close all;

function [Ud,Id] = sample_decimation(U,I,start,step,stop)
  Ud={};Id={};
  if (stop <= 0)
    for k=1:numel(U)
      Ud{numel(Ud)+1}=U{k}(start:step:end);
      Id{numel(Id)+1}=I{k}(start:step:end);
    endfor
  else
    for k=1:numel(U)
      Ud{numel(Ud)+1}=U{k}(start:step:stop);
      Id{numel(Id)+1}=I{k}(start:step:stop);
    endfor
  endif
endfunction

function Pa = active_power(U,I)
  Pa=[];
  for k=1:numel(U)
    try
      Pa=[Pa;cov(U{k},I{k})];
    catch
      printf("active_power(): record No %d error\n",k);
    end_try_catch
  endfor
endfunction

function [Pm,Pq] = active_power_with_median(P,k)
  for j=1:numel(P)-k
    Pm(j) = median(P(j:j+k));
    Pq(j) = iqr(P(j:j+k));
  endfor
endfunction

function show_stat(P,label,show,hold)
  printf("%20s std(P)=%6.2f\n",label,std(P));
  if( show )
    if (hold<=0)
      figure()
      plot(1:numel(P1),P1,";P1;");
      title(label);
    else
      plot(1:numel(P1),P1,";P1;");
    endif
  endif
endfunction

function show_powers(U,I,clamp,label)
  Pa  = active_power(U,I);
  [Pam5,Pq5] = active_power_with_median(Pa,5);
  [Pam7,Pq7] = active_power_with_median(Pa,7);
  [Pam9,Pq9] = active_power_with_median(Pa,9);

  strPa = ["P" num2str(clamp) "a " label];
  show_stat(Pa,strPa,0,0);

  strPam5 = [strPa " median5"];
  show_stat(Pam5,strPam5,0,0);
  strPq5 = [strPa " iqr5"];
  show_stat(Pq5,strPq5,0,0);

  strPam7 = [strPa " median7"];
  show_stat(Pam7,strPam7,0,0);
  strPq7 = [strPa " iqr7"];
  show_stat(Pq7,strPq7,0,0);

  strPam9 = [strPa " median9"];
  show_stat(Pam9,strPam9,0,0);
  strPq9 = [strPa " iqr9"];
  show_stat(Pq9,strPq9,0,0);
endfunction

function show_all_powers(U,I,clamp)
    # power with all samples
  show_powers(U,I,clamp,"All");

  # power with all samples on k-period
  [U_P,I_P] = sample_decimation(U,I,1,1,600);
  show_powers(U_P,I_P,clamp,"All k-P");

  # power with 1/2 (ie 2*n+1) samples decimation
  [U_2n1,I_2n1] = sample_decimation(U,I,1,2,-1);
  show_powers(U_2n1,I_2n1,clamp,"2n+1");

  # power with 1/2 samples (ie 2n+1) decimation on k-period
  [U_2n1P,I_2n1P] = sample_decimation(U,I,1,2,600);
  show_powers(U_2n1P,I_2n1P,clamp,"2n+1 k-P");

  # power with 1/2 (ie 2*n) samples decimation
  [U_2n,I_2n] = sample_decimation(U,I,2,2,-1);
  show_powers(U_2n,I_2n,clamp,"2n");

  # power with 1/2 (ie 2*n) samples decimation on k-period
  [U_2nP,I_2nP] = sample_decimation(U,I,2,2,600);
  show_powers(U_2nP,I_2nP,clamp,"2n k-P");
  printf("\n");
endfunction

fname=choose_file();
[U1,I1,U2,I2,U3,I3] = read_log (fname);

show_all_powers(U1,I1,1);
show_all_powers(U2,I2,2);
show_all_powers(U3,I3,3);

#{
Pa1 = active_power(U1,I1);
Pam1=active_power_with_median(Pa1,6);
Pam17=active_power_with_median(Pa1,8);
Pam19=active_power_with_median(Pa1,10);
figure();
hist(Pa1,10);
hold on;
plot(mean(Pa1),20,"*");

figure();
hist(Pam1,10);
hold on;
plot(mean(Pa1),20,"*");

figure();
hist(Pam17,10);
hold on;
plot(mean(Pa1),20,"*");

figure();
hist(Pam19,10);
hold on;
plot(mean(Pa1),20,"*");
#}
#{

Pa2 = active_power(U2,I2);
figure();
hist(Pa2,10);
Pa3 = active_power(U3,I3);
figure();
hist(Pa3,10);
#}
#{
minPa1 = min(Pa1);
maxPa1 = max(Pa1);
edge   = minPa1:(maxPa1-minPa1)/10:maxPa1;
hst    = histc(Pa1,edge);
plot(edge,hst);
#}






#{
function P = active_power(U,I,start,step,stop)
  P=[];
  for k=1:numel(U)
    if (stop <= 0)
      P=[P;cov(U{k}(start:step:end),I{k}(start:step:end))];
    else
      P=[P;cov(U{k}(start:step:stop),I{k}(start:step:stop))];
    endif
  endfor
endfunction



function [P1,P2,P3] = active_powers(U1,I1,U2,I2,U3,I3,start,step,stop)
  P1 = active_power(U1,I1,start,step,stop);
  P2 = active_power(U2,I2,start,step,stop);
  P3 = active_power(U3,I3,start,step,stop);
endfunction

function Pm = active_power_median(P,k)
  for j=1:numel(P)-k
    Pm(j) = median(P(j:j+k));
  endfor
endfunction

function [P1m,P2m,P3m] = active_powers_median(P1,P2,P3,k)
  P1m = active_power_median(P1,k);
  P2m = active_power_median(P2,k);
  P3m = active_power_median(P3,k);
endfunction

function plot_stat(P1,P2,P3,label,show)
  printf("%s std(P1)=%6.2f std(P2)=%6.2f std(P3)=%6.2f\n",label,std(P1),std(P2),std(P3));
  if( show )
    figure();
    plot(1:numel(P1),P1,";P1;",1:numel(P2),P2,";P2;",1:numel(P3),P3,";P3;");
    title(label);
  endif
endfunction

[P1,P2,P3] = plot_stat(U1,I1,U2,I2,U3,I3,1,1,-1, "samples All.....",0);
P1m = slide_median(P1,5);
P2m = slide_median(P2,5);
P3m = slide_median(P3,5);
printf("std(P1m)=%6.2f std(P2m)=%6.2f std(P3m)=%6.2f\n",std(P1m),std(P2m),std(P3m));

[P1,P2,P3]=plot_stat(U1,I1,U2,I2,U3,I3,1,1,600,"k-Periodes .....",0);
P1m = slide_median(P1,5);
P2m = slide_median(P2,5);
P3m = slide_median(P3,5);
printf("std(P1m)=%6.2f std(P2m)=%6.2f std(P3m)=%6.2f\n",std(P1m),std(P2m),std(P3m));

[P1,P2,P3]=plot_stat(U1,I1,U2,I2,U3,I3,1,2,-1,"samples 2*n+1...",0);
P1m = slide_median(P1,5);
P2m = slide_median(P2,5);
P3m = slide_median(P3,5);
printf("std(P1m)=%6.2f std(P2m)=%6.2f std(P3m)=%6.2f\n",std(P1m),std(P2m),std(P3m));


plot_stat(U1,I1,U2,I2,U3,I3,1,1,-1, "samples All.....",1);
plot_stat(U1,I1,U2,I2,U3,I3,1,2,-1, "samples 2*n+1...",1);
plot_stat(U1,I1,U2,I2,U3,I3,2,2,-1, "samples 2*n ....",1);

plot_stat(U1,I1,U2,I2,U3,I3,1,1,600,"k-Periodes .....",1);
plot_stat(U1,I1,U2,I2,U3,I3,1,2,600,"k-Periodes 2*n+1",1);
plot_stat(U1,I1,U2,I2,U3,I3,2,2,600,"k-Periodes 2*n..",1);
#}


