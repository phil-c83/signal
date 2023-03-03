pkg load signal;
clear all;
close all;


[U1,I1,Te]=dephased_sin(92160,480,0.01,pi/8,0.1);
Test_UI_cos(Te,480,U1,I1,[1 2 3 5 9],pi/8);
