% clamps data analyse
clear all;
close all;

Freqs=[410 440 470 520 560 590 610 640 670 710 740 770];
Freqs= [Freqs 2*Freqs]';


[fname, fpath, fltidx]=uigetfile ("*.csv");
file = [fpath "/" fname];
% clamp , freq , voltage , Lm , Rf
m=dlmread(file,",",1,0);

% index for each clamp
i1 = find(m(:,1)==1.0); % idx clamp1
i2 = find(m(:,1)==2.0); % idx clamp2
i3 = find(m(:,1)==3.0); % idx clamp3

% data for each clamp
cl1 = m(i1,:);
cl2 = m(i2,:);
cl3 = m(i3,:);

function [Vg,Lm,Rf]=clamp_curves(cl,f)
  iv = find(cl(:,2)==f);
    Vg = cl(iv,3);
    Lm = cl(iv,4);
    Rf = cl(iv,5);
endfunction


function plot_clamps_curves(cl,freqs)
  figure;
  for f=1:length(freqs)
    iv = find(cl(:,2)==freqs(f));
    Vg = cl(iv,3);
    Lm = cl(iv,4);
    Rf = cl(iv,5);
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




%plot_clamps_curves(cl1,Freqs);
%plot_clamps_curves(cl2,Freqs);
%plot_clamps_curves(cl3,Freqs);

[Vg,Lm,Rf] = clamp_curves(cl1,410);
[a,b] = MCsqrt (Vg,Lm)
figure;
subplot(1,2,1);
plot(Vg,Lm,";Lm me;");
subplot(1,2,2);
plot(Vg,a*sqrt(Vg)+b,";Lm es;");

[Vg,Lm,Rf] = clamp_curves(cl1,440);
[a,b] = MCsqrt (Vg,Lm)
[Vg,Lm,Rf] = clamp_curves(cl1,470);
[a,b] = MCsqrt (Vg,Lm)
[Vg,Lm,Rf] = clamp_curves(cl1,520);
[a,b] = MCsqrt (Vg,Lm)

