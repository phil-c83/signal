clear all
close all
clc
pkg load signal;
%{
 [Fe,v] = lin_sweep(f0,T,k) : linear sweep from f0 to k/T with 
                     the next sample after the last will be 0.
          linear frequency for sweep function variation must 
          be linear so it is the integral that must be used ! 
 f0 : start frequency
 T  : time sweep duration
 k  : final frequency is k/T iif k > f0*T
 nfmax : number of points in final frequency period
 return :
 Fe : sampling frequency
 v  : signal row vector
%}
function [Fe,v] = lin_sweep(f0,T,k,nfmax)
  f1 = k/T;
  Fe = nfmax*f1;
  N  = T*Fe;
  t  = (0:N-1)*1/Fe;
  theta  = (f1-f0)/(2*T) * t.^2 + f0 * t;  
  v  = sin(2*pi*theta); 
endfunction

function [Fe,v]=lin_square_sweep(f0,T,k,nfmax)
  [Fe,s] = lin_sweep(f0,T,k,nfmax);
  v = sign(s);  
endfunction

% contruct a barker 13 signal from s
function b13=barker13(s)
  % barker 13 code +1 +1 +1 +1 +1 −1 −1 +1 +1 −1 +1 −1 +1  vector with s & s2
  b13=[s;s;s;s;s;-s;-s;s;s;-s;s;-s;s];  
endfunction

[Fe,v] = lin_sweep(300,10e-3,10,10);
barker = barker13(v');

[Fe,v] = lin_square_sweep(300,10e-3,10,10);
barker_sq = barker13(v');
d_barker_sq = [diff(barker_sq);0] * Fe;
noise = randn(length(barker_sq),1);

%figure; plot(v,"marker",'+');
figure; plot(barker_sq,"marker",'+');title("sq_barker");
figure; plot(d_barker_sq,"marker",'+');title("D(sq_barker)");

[b,a]=butter(2,[2*300/Fe,2*1000/Fe]);

output1=filter(b,a,barker_sq);
figure; plot(output1,"marker",'+');title("filtered sq_barker");
[C1,lag1]=xcorr(output1,barker_sq); 
[max1,imax1]=max(abs(C1));
figure;plot(lag1,C1/max1);title("inter filtered sqbarker sqbarker"); 

output2=filter(b,a,d_barker_sq);
figure; plot(output2,"marker",'+');title("filtered D(sqbarker)");
[C2,lag2]=xcorr(output2,barker_sq); 
[max2,imax2]=max(abs(C2));
figure;plot(lag2,C2/max2);title("inter filtered D(sqbarker) sqbarker"); 

[C5,lag5]=xcorr(output1,-barker_sq); 
[max5,imax5]=max(abs(C5));
figure;plot(lag5,C5/max5);title("inter filtered sqbarker -sqbarker"); 

[C6,lag6]=xcorr(output2,-barker_sq); 
[max6,imax6]=max(abs(C6));
figure;plot(lag6,C6/max6);title("inter filtered D(sqbarker) -sqbarker"); 


%{
[C3,lag3]=xcorr(output1,barker); 
[max3,imax3]=max(abs(C3));
figure;plot(lag3,C3/max3);title("inter filtered sqbarker barker"); 

[C4,lag4]=xcorr(output2,barker); 
[max4,imax4]=max(abs(C4));
figure;plot(lag4,C4/max4);title("inter filtered D(sqbarker) barker"); 
%}
