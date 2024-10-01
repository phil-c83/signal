clearvars;
close all;
addpath("../../fun");
output_precision(7);

dt = 50e-6;
Fe = 1/dt;
n  = 7 ;
# fix the right range for the bump
[Tei,Teo] = remap_range([1e-3,3e-3],[-1/2,1/2],Fe);

# s = bump(Teo) .* sin(2*pi*n*Teo);
# [s,t] = linear_sin_sweep (f0,f1,t0,T,p0,Fe)
s = bump(Teo) .*  linear_sin_sweep(100,1.6e3,1e-3,2e-3,0,Fe);


plot(Tei,s);
hold on;
Ds = diff(s) .* Fe;
plot(Tei,[0,Ds]/1e4);
hold on;
D2s= diff(Ds) .* Fe;
plot(Tei,[0,0,D2s]/1e8);

#plot bump signal
figure();
subplot(3,2,1);
plot(Tei,s);
legend("bump");

#plot fft bump signal
subplot(3,2,2);
idx = 1:length(s)/2;
df  = (idx-1) * 1/(Tei(end)-Tei(1));
sfft= fft(s);
plot(df,abs(sfft(idx)/length(s)));
legend("fft bump");

#plot derivative bump signal
subplot(3,2,3);
plot(Tei,[0,Ds]);
legend("Dbump");

#plot fft derivative bump signal
subplot(3,2,4);
idx = 1:length(Ds)/2;
df  = (idx-1) * 1/(Tei(end)-Tei(1));
Dsfft = fft(Ds);
plot(df,abs(Dsfft(idx)/length(Ds)));
legend("fft Dbump");


#plot second derivative bump signal
subplot(3,2,5);
plot(Tei,[0,0,D2s]);
legend("D2bump");

#plot fft second derivative bump signal
subplot(3,2,6);
idx = 1:length(D2s)/2;
df  = (idx-1) * 1/(Tei(end)-Tei(1));
D2sfft = fft(D2s);
plot(df,abs(D2sfft(idx)/length(D2s)));
legend("fft D2bump");




