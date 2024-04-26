# invocation : octave --persist <this-file.m>

1;
clear -a;
pkg load control;

# main power period
Tm = 1/50; 

s = tf('s');

w0r = 2*pi/Tm;
Qr  = 5;
# band reject filter laplace transform
R=(s^2 + w0r^2)/(s^2 + w0r/Qr*s + w0r^2);

wci = 2*pi*5;
# integrator laplace transform
I = 1 / (1 + 1/wci*s);
# bode(I*R);

wclp = 2*pi*100;
Klp  = 1;
# low pass butterworth
LP = Klp / ((s/wclp)^2 + sqrt(2)*s/wclp +1);
bode(LP);


