clearvars;
output_precision(16);

dt = 20e-6;
Fe = 1/dt;
Ts = [-1/2,1/2];

Te = (-Ts:1/Fe:Ts);
s  = nbump(Te);
plot(Te,s);

#{
hold on;
s  = Dbumpz(Te/Ts);
plot(Te,s);
#}

