clearvars;
output_precision(16);

dt = 20e-6;
Fe = 1/dt;
Ts = 580e-6;

Te = (-Ts:1/Fe:Ts);
s  = bumpz(Te/Ts);
plot(Te,s);
hold on;
s  = Dbumpz(Te/Ts);
plot(Te,s);

