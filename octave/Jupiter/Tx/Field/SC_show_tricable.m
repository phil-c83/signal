close all;
clear all;


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
