clear all;
close all;

function plot_field(theta,Bs1,Bs2,Bs3,title_str)

figure();
plot(theta,Bs1,";Bs1;");
hold on;
plot(theta,Bs2,";Bs2;");
hold on;
plot(theta,Bs3,";Bs3;");
title(title_str);
endfunction

# cables tripolaire ie 3 conducteurs dans le même câble
r  = 1;
step = pi/20;
theta = -2*pi+step:step:2*pi;
z  = r*exp(i*theta);
a  = exp(i*2*pi/3);
z1 = r/2*exp(i*pi/3);
z2 = z1*a^2;
z3 = z1*a;
[Bs1,Bs2,Bs3] = fields_v(z1,z2,z3,z);
plot_field(theta,Bs1,Bs2,Bs3,"cable tripolaire");

# cables tetrapolaire ie 4 conducteurs dans le même câble
r  = 1;
step = pi/20;
theta = -2*pi+step:step:2*pi;
z  = r*exp(i*theta);
a  = exp(i*5*pi/9);
z1 = r/2*exp(i*5*pi/18);
z2 = z1*a^2;
z3 = z1*a;
[Bs1,Bs2,Bs3] = fields_v(z1,z2,z3,z);
plot_field(theta,Bs1,Bs2,Bs3,"cable tetrapolaire");

# cable HTA 3 conducteurs
r = 1;
step = pi/20;
theta = 0:step:pi;
a = exp(i*2*pi/3);
z1 = i*2*r/sqrt(3);
z2 = z1*a^2;
z3 = z1*a;
z  = z1+r*exp(i*theta);
[Bs1,Bs2,Bs3] = fields_v(z1,z2,z3,z);
plot_field(theta,Bs1,Bs2,Bs3,"cable HTA");
