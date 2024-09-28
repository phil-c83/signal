clearvars;
addpath("../../fun");
output_precision(7);

dt = 20e-6;
Fe = 1/dt;
n  = 5 ;
[Tei,Teo] = remap_range([1e-3,2e-3],[-1/2,1/2],Fe);

#{
s  = Rect(Teo);
plot(Tei,s);
hold on;
#}

s = bump(Teo) .* sin(2*pi*n*Teo);
plot(Tei,s);
hold on;

Ds = diff(s) .* Fe;

plot(Tei,[0,Ds]/10000);





