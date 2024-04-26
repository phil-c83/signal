# invocation:  octave --persist <this-file.m> 

1; # fichier script

clear -a;

# band pass transfers function 
# H(s)= (K*W0*s/Q) / (s^2 + (W0/Q)*s + W0^2)
# C1 ~ 10/F0 µF, C2 > C1*(K/Q^2-1)
# R1= Q/K * 1/(2*pi*F0*C1)
# R2= 1/Q * 1/((C1*(1-K/Q^2)+C2)*2*pi*F0)
# R3= Q/(2*pi*F0) * 1/(C1+1/C2)

function [r1,r2,r3]=MFB_band_pass(F0,Q,K,C1,C2)
    if (K/Q^2-1 < 0) error("K/Q^2-1 < 0"); endif
    if (C2 <= C1*(K/Q^2-1)) error("C2 <= C1*(K/Q^2-1)"); endif    
    
    r1=Q/K * 1/(2*pi*F0*C1);
    r2=1/Q * 1/((C1*(1-K/Q^2)+C2)*2*pi*F0);
    r3=Q/(2*pi*F0) * (1/C1+1/C2);

end

# VCVS band reject
# H(s) = (S^2 + W0^2) / (S^2 + (W0/Q) * S + W0^2)
# C1 ~ 10/F0 µF
# R1= 1/(2*pi*F0*Q*C1)
# R2= 2*Q/(2*pi*F0*C1)
# R3= R1//R2 = R1*R2 / (R1+R2)

function [r1,r2,r3]=VCVS_band_reject(F0,Q,C1)
    r1= 1/(4*pi*F0*Q*C1);
    r2= 2*Q/(2*pi*F0*C1);
    r3= r1*r2 / (r1+r2);
end


# VCVS Low pass butterworth
# C2 ~ 10/Fc µF, C1 < C2/2
# R1= 2/((sqrt(2)*C2 + sqrt(2+C2^2-4*C1*C2))*2*pi*Fc)
# R2= 1/(C1*C2*R1*(2*pi*Fc)^2)
function [r1,r2]=VCVS_butterworth_low_pass(Fc,C1,C2)
    r1=2/((sqrt(2)*C2 + sqrt(2*C2^2-4*C1*C2))*2*pi*Fc);
    r2= 1/(C1*C2*r1*(2*pi*Fc)^2);
end
