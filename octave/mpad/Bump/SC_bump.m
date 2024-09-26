clearvars;

#output_precision(16);

dt = 20e-6;
Fe = 1/dt;
Ts = 580e-6;

Te = (-Ts:1/Fe:Ts) ;


s=bump(2*Te/Ts);
plot(Te,s);

s=Dbump(2*Te/Ts);
hold on;
plot(Te,s);

