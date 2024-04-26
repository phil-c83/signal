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

%{
  [t,v]=square(f,nf,nT) : square signal
  f  : frequency
  n2f: sampling frequency 2*nf*f
  nT : number of periods
  return :
  t : row time vector
  v : row square signal @f for nT periods  
%}
function [t,v]=square(f,n2f,nT)
  Te = 1/(2*n2f*f);
  N  = 2*nT*n2f;
  n  = (0:N-1);   
  v  = power(-1,floor(n/n2f));
  t  = n*Te;
endfunction


%{
[t,v] = lin_sweep(300,10e-3,4,20);
figure;plot(t,v,"marker",'+');

t=(0:39)*250e-6;
v=chirp(t,300,1e-2,400,'linear',-90);
figure;plot(t,v);

[t,v]=square(100,10,5);
figure;plot(t,v,"marker",'+');
%}
%{
function [t,v]=lin_square_sweep(f0,n2f,T,k)
  f1 = k/T + f0;
  Te = 1/(2*n2f*f);  
  N  = 2*nT/Te;
  t  = (0:N-1)*Te;
  v  = power(-1,floor(t));
endfunction
%}

function [Fe,v]=lin_square_sweep(f0,T,k,nfmax)
  [Fe,s] = lin_sweep(f0,T,k,nfmax);
  v = sign(s);  
endfunction

[Fe,v] = lin_square_sweep(300,10e-3,10,10);
figure; plot((0:length(v)-1)/Fe,v,"marker",'+')
  

% contruct a barker 13 signal from s
function b13=barker13(s)
  % barker 13 code +1 +1 +1 +1 +1 −1 −1 +1 +1 −1 +1 −1 +1  vector with s & s2
  b13=[s;s;s;s;s;-s;-s;s;s;-s;s;-s;s];  
endfunction

%{
 zeros_padding() : adding n zeros to vector v
 v: columns vector, 
 n: number of zeros to insert in front (if n>0) or 
    on back (if n<0) of v
 return vs: vector of the same length of v 
%}
function vs=zeros_padding(v,n)  
  if n > 0     
    vs=[zeros(n,1);v(1:end-n)];
  elseif n < 0
    vs=[v(-n+1:end);zeros(-n,1)];
  else
    vs=v;
  end
end

function [C,lag]=test_corr(v,v_ref,npad)
  
  m_v=zeros_padding(v,npad);
  [C,lag]=xcorr(m_v,v_ref);   
  
end

function r = detect_signal(v,v_ref,npad,nfft,show,str)
  [C,L]=test_corr(v,v_ref,npad);  
  if show 
    figure;
    plot(L,C);
    title(str); 
  endif
  [max,imax]=max(C);
  irange = imax-nfft:imax+nfft-1;
  CenterC = C(irange);
  if show 
    figure; 
    plot(irange,CenterC,"marker",'+');
    title1 = sprintf("center %s",str);
    title(title1);
  endif
  
  fftC = fft(CenterC);
  re =  sum(real(fftC).^2);
  im =  sum(imag(fftC).^2);
  r  = re/im; 
  printf("%s : ratio=%e\n",str,r); 
endfunction


[Fe,v] = lin_sweep(300,10e-3,10,10);
figure; plot((0:length(v)-1)/Fe,v,"marker",'+')
t=(0:99)*1e-4;
v=chirp(t,300,1e-2,1000,'linear',-90);
figure;plot(t,v);

barker = barker13(v');
d_barker = [diff(barker);0] * Fe;
noise = randn(length(barker),1);
%{
%figure; plot(v,"marker",'+')
figure; plot(barker,"marker",'+');title("barker");
figure; plot(d_barker,"marker",'+');title("D(barker)");
figure; plot(barker+noise,"marker",'+');title("Noisy barker");
figure; plot(d_barker+1e4*noise,"marker",'+');title("Noisy D(barker)");
%}

%{
r1 = detect_signal(barker,barker,0,32,1,"auto barker");
r2 = detect_signal(barker+noise/5,barker,0,32,1,"inter noisy barker barker");
r3 = detect_signal(d_barker,barker,0,32,1,"inter D(barker) barker");
r4 = detect_signal(d_barker+4e6*noise,barker,0,32,1,"inter noisy D(barker) barker");
%}

