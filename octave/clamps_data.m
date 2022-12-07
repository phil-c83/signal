% analyse clamps data
clear all;
close all;


Freqs=[410 440 470 520 560 590 610 640 670 710 740 770];
Freqs= [Freqs 2*Freqs]';

% Clamp parameters Lm(Vg,f),Rf(Vg,f) @ f fixed
function [Vg,Lm,Rf]=clamp_curves(cl,f)
  iv = find(cl(:,2)==f);
  Vg = cl(iv,3);
  Lm = cl(iv,4);
  Rf = cl(iv,5);
endfunction

%cl: clamp , freq , voltage , Lm , Rf
function plot_3d_Lm_curve(cl)
  plot3(cl(:,2),cl(:,3),cl(:,4));
endfunction

%{
 Lm(f,v) = a0+a1*f+a2*f^2+a3*v+a4*v^2
 Lmvalues = Z*a => a = inv(Z'*Z)*Z'*pvalues
 a = [a0 a1 a2 a3 a4]'
%}
function [a0,a1,a2,a3,a4]=clamp_Lm_estimate(fq,vg,Lmvalues)
  N    = length(fq);
  Z    = [ones(N,1),fq,fq.^2,vg,vg.^2];%design matrix
  ZTZ  = Z'*Z;
  ZTpa = Z'*Lmvalues;
  iZTZ = inv(ZTZ);
  a    = iZTZ*ZTpa;
  a0   = a(1);
  a1   = a(2);
  a2   = a(3);
  a3   = a(4);
  a4   = a(5);
endfunction

%{
 Rf(f,v) = a0+a1*f+a2*v+a3*v^2
 Rfvalues = Z*a => a = inv(Z'*Z)*Z'*pvalues
 a = [a0 a1 a2 a3]'
%}
function [a0,a1,a2,a3]=clamp_Rf_estimate(fq,vg,Rfvalues)
  N    = length(fq);
  Z    = [ones(N,1),fq,vg,vg.^2];%design matrix
  ZTZ  = Z'*Z;
  ZTpa = Z'*Rfvalues;
  iZTZ = inv(ZTZ);
  a    = iZTZ*ZTpa;
  a0   = a(1);
  a1   = a(2);
  a2   = a(3);
  a3   = a(4);
endfunction



function plot_clamps_curves(cl,freqs)
  figure;
  for f=1:length(freqs)
    [Vg,Lm,Rf]=clamp_curves(cl,freqs(f));
    subplot(2,1,1);
    clabel = ["--p;Lm " dec2base(freqs(f),10) ";"];
    plot(Vg,Lm,clabel);
    hold on;
    subplot(2,1,2);
    clabel = ["--p;Rf " dec2base(freqs(f),10) ";"];
    plot(Vg,Rf,clabel);
    hold on;
  endfor
endfunction


function plot_params_estimate(cl,f)

  [Vg,Lm,Rf] = clamp_curves(cl,f);

  figure;
  plot(Vg,Lm,";Lm me;");
  hold on;
  [a0,a1,a2] = MCparabolic(Vg,Lm);
  plot(Vg,a0+a1*Vg+a2*Vg.^2,";Lm x^2;");
  hold on;
  [a0,a1] = MCsqrt (Vg,Lm);
  plot(Vg,a0+a1*sqrt(Vg),";Lm sqrt;");

  figure;
  plot(Vg,Rf,";Rf me;");
  hold on;
  [a0,a1] = MClinear(Vg,Rf);
  plot(Vg,a0+a1*Vg,";Rf linear;");

endfunction

function [Vg,Lm,Rf,eLmsq,Lmsq,eRfli,Rfli]=params_estimate(cl,f)
  [Vg,Lm,Rf] = clamp_curves(cl,f);
  [a0,a1,a2] = MCparabolic(Vg,Lm);
  Lmsq       = [a0;a1;a2];
  eLmsq      = sum((a0+a1*Vg+a2*Vg.^2 - Lm).^2);
  [a0,a1]    = MClinear(Vg,Rf);
  Rfli       = [a0;a1];
  eRfli      = sum((a0+a1*Vg - Rf).^2);
endfunction

function [Lma0_vs_f,Lma1_vs_f,Lma2_vs_f]=plot_Lm_model_param(cl,freqs)

  Lma0_vs_f=[];
  Lma1_vs_f=[];
  Lma2_vs_f=[];
  for idx_f=1:length(freqs)
    [Vg,Lm,Rf,eLmsq,Lmsq,eRfli,Rfli]=params_estimate(cl,freqs(idx_f));
    Lma0_vs_f = [Lma0_vs_f;Lmsq(1)];
    Lma1_vs_f = [Lma1_vs_f;Lmsq(2)];
    Lma2_vs_f = [Lma2_vs_f;Lmsq(3)];

  %{
    printf("Clamps=%d f=%d Lma0=%g Lma1=%g Lma2=%g eLm=%f Rfa0=%f Rfa1=%f eRf=%f\n",
            1,freqs(idx_f),Lmsq(1),Lmsq(2),Lmsq(3),eLmsq,Rfli(1),Rfli(2),eRfli );
  %}
  endfor
  figure;
  plot(freqs,Lma0_vs_f,";a0;");
  hold on;
  plot(freqs,Lma1_vs_f,";a1;");
  hold on;
  plot(freqs,Lma2_vs_f,";a2;");
  hold on;
  [a0,a1]          = MClinear(freqs,Lma0_vs_f);
  plot(freqs,a0+a1*freqs,";ea0;");
  printf("Cl Lma0=%g*f+%g\n",a0,a1);

endfunction

function [a0,a1,a2,a3,a4]=Lm_estimate_and_plot(fq,vg,Lmvalues,label)

  [a0,a1,a2,a3,a4] = clamp_Lm_estimate(fq,vg,Lmvalues);
  figure;

  plot3(fq,vg,Lmvalues,["-k;" label ";"],
        fq,vg,a0+a1*fq+a2*fq.^2+a3*vg+a4*vg.^2,["-r;es" label ";"]);
  printf("%s(f,v)=%+g %+g*f %+g*f^2 %+g*v %+g*v^2\n",label,a0,a1,a2,a3,a4);

endfunction

function [a0,a1,a2,a3]=Rf_estimate_and_plot(fq,vg,Rfvalues,label)

  [a0,a1,a2,a3] = clamp_Rf_estimate(fq,vg,Rfvalues);
  figure;

  plot3(fq,vg,Rfvalues,["-k;" label ";"],
        fq,vg,a0+a1*fq+a2*vg+a3*vg.^2,["-r;es" label ";"]);
  printf("%s(f,v)=%+g %+g*f %+g*v %+g*v^2\n",label,a0,a1,a2,a3);

endfunction


[fname, fpath, fltidx]=uigetfile ("/home/phil/Made/git-prj/signal/data/*.csv");
file = [fpath "/" fname];
%csv : clamp , freq , voltage , Lm , Rf
m=dlmread(file,",",1,0);

% index for each clamp
i1 = find(m(:,1)==1.0); % idx clamp1
i2 = find(m(:,1)==2.0); % idx clamp2
i3 = find(m(:,1)==3.0); % idx clamp3

% data for each clamp
cl1 = m(i1,:);
cl2 = m(i2,:);
cl3 = m(i3,:);

%{
plot_params_estimate(cl1,410);
plot_params_estimate(cl1,520);
plot_params_estimate(cl1,610);
plot_params_estimate(cl1,710);

[Lma0,Lma1,Lma2] = plot_Lm_model_param(cl1,Freqs);
[Lma0,Lma1,Lma2] = plot_Lm_model_param(cl2,Freqs);
[Lma0,Lma1,Lma2] = plot_Lm_model_param(cl3,Freqs);

plot_clamps_curves(cl1,Freqs);
plot_clamps_curves(cl2,Freqs);
plot_clamps_curves(cl3,Freqs);
%}


%Lm clamp1
[a0,a1,a2,a3,a4]=Lm_estimate_and_plot(cl1(:,2),cl1(:,3),cl1(:,4),"Lm1");
%Rf clamp1
[a0,a1,a2,a3]=Rf_estimate_and_plot(cl1(:,2),cl1(:,3),cl1(:,5),"Rf1");
%plot_clamps_curves(cl1,Freqs);


%Lm clamp2
[a0,a1,a2,a3,a4]=Lm_estimate_and_plot(cl2(:,2),cl2(:,3),cl2(:,4),"Lm2");
%Rf clamp2
[a0,a1,a2,a3]=Rf_estimate_and_plot(cl2(:,2),cl2(:,3),cl2(:,5),"Rf2");

%Lm clamp3
[a0,a1,a2,a3,a4]=Lm_estimate_and_plot(cl3(:,2),cl3(:,3),cl3(:,4),"Lm3");
%Rf clamp3
[a0,a1,a2,a3]=Rf_estimate_and_plot(cl3(:,2),cl3(:,3),cl3(:,5),"Rf3");


