close all;
clearvars;

D  = 2.0/5.0;
Fe = 16e3;
N  = Fe*0.1;
Te = (0:N)*1/Fe;

S = Sig_gen (1,D,410,430,Te);

plot(Te,S);

Srms = sqrt(cov(S,S))


