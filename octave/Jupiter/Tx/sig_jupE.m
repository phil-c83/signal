## Author:  <phil@archlinux>
## Created: 2023-12-07

%{
forme du signal à synthétiser ie créneau sans symetrie
 ____
|    |
|<T1>|
     |________|
<      T      >
A*T1 = B*(T-T1) => B = A*T1/(T-T1)
T1=D*T  => B=A*D/(1-D)
x(t,T1,T) = A*(rect((t-T1/2)/T1)-T1/(T-T1)*rect((t-(T+T1)/2)/(T-T1)))

TF{x(t-a,T,T1)}(f) = A*T1*exp(-i*2*pi*a*f) *
                     {exp(-i*pi*T1*f)*sinc(pi*T1*f) -
                      exp(-i*pi*(T-T1)*f)*sinc(pi*(T-T1)*f)}
%}

function retval = sig_jupE (input1, input2)

endfunction
