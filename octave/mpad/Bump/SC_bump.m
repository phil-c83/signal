clearvars;
close all;
addpath("../../fun");
output_precision(7);

dt = 50e-6;
Fe = 1/dt;
n  = 7 ;
# fix the right range for the bump
[Tei,Teo] = remap_range([1e-3,3e-3],[-1/2,1/2],Fe);

s = bump(Teo) .* sin(2*pi*n*Teo);

plot(Tei,s);
hold on;
Ds = diff(s) .* Fe;
plot(Tei,[0,Ds]/10000);

#plot bump signal
figure();
subplot(3,1,1);
plot(Tei,s);
legend("Dbump");

#plot derivative bump signal
subplot(3,1,2);
plot(Tei,[0 Ds]);
legend("Dbump");

#plot fft derivative bump signal
subplot(3,1,3);
idx = 1:length(Ds)/2;
df  = (idx-1) * 1/(Tei(end)-Tei(1));
Dsfft = fft(Ds);
plot(df,abs(Dsfft(idx)/length(Ds)));
legend("fft Dbump");




