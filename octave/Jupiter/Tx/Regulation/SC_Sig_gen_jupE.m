## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-02-23
close all;
clearvars;

# get recorded phase corrections to apply
source("DATA_Phase_fix.m");


T  = 0.1;
Fe = 8e3;
Te = 0:1/Fe:T-1/Fe;

s = Sig_gen_jupE (1.5,410,440,470,Te,dP_S0);

plot(Te,s(:,1),"g",Te,s(:,2),"y",Te,s(:,3),"r");


