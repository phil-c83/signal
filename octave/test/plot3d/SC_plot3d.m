Te=(0:299)*1/100;
f1 = exp(i*2*pi*Te);
fcos = (f1+conj(f1))/2;
fsin = (f1-conj(f1))/(2*i);
fcos_r = fcos * exp(i*pi/3);
f1_r   = f1*exp(i*pi/4);
figure()
plot3(Te,real(f1),imag(f1),
      Te,real(fcos),imag(fcos),
      Te,real(fcos_r),imag(fcos_r),
      Te,real(f1_r),imag(f1_r))
figure()
plot( Te,real(fcos_r),Te,imag(fcos_r))

