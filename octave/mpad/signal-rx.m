# invocation:  octave --persist <this-file.m> 

1; # fichier script

clear -a;
pkg load specfun;

global Fm     = 50;    # main power wave frequency
global Fm_div = 4;    # main power wave frequency divisor for current wave generator
global NPTS   = 512;
global NPER   = 5; # periods number
global Dt     = Fm_div * NPER / (NPTS * Fm); # time step
global Df     = 1 / (NPTS * Dt);      # frequency step
global Fmax   = 200;


function s=rect(t,T)
    s = heaviside(t) - heaviside(t - T/2);
end

function s=rect_wave(t,T)
    s = rect(t - floor(t/T)*T,T);
end


# current signal waveform
# n : points 
# dt: time step
# T : signal period
# s : output signal
function s=rx_wave(dt,T,n)
    global Fm;
    global Fm_div;    
    
    ndt=(0:n-1)*dt;
    g = sin(2*pi*Fm*ndt);
    h = rect_wave(ndt,T);
    s = g .* h ;
end

s = rx_wave(Dt,Fm_div/Fm,NPTS);
tf = fft(s)/NPTS;
figure;
subplot(2,1,1);
plot((0:NPTS-1)*Dt,s);
subplot(2,1,2);
np = round(200/Df);
plot((0:np-1)*Df,2*abs(tf(1:np)));
printf("Dt=%2.5f Df=%2.5f\n",Dt,Df);
