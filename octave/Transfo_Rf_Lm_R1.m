Rf=628e-3;
Lm=232e-6;
R1=390e-3;

TolCosphi = 0.1;
CosPhi = [0.99;0.94;0.92;0.91;0.90];
SupCosPhi = min(CosPhi+TolCosphi,1);
InfCosPhi = max(CosPhi-TolCosphi,-1);
I1rms = [0.981;0.625;0.603;0.591;0.583];
U1rms = [0.395;0.456;0.459;0.461;0.463];

[x,y]=pol2cart(-acos(CosPhi),I1rms);
I1=complex(x,y);
[x,y]=pol2cart(-acos(SupCosPhi),I1rms);
SupI1=complex(x,y);
[x,y]=pol2cart(-acos(InfCosPhi),I1rms);
InfI1=complex(x,y);


function Pv=ParamValues(p,dp,n)
  Pv = p-dp : 2*dp/n : p+dp;
endfunction

%{
Eval de I2 avec modèle transfo R1,Rf,Lm ie (Lf=0)
%}
function i2=I2_modele2(f,m,Lm,Rf,R1,I1,V1)
  XL = Lm*2*pi*f;
  %i2=abs(I1/m - (V1-R1*I1).*(Rf+i*XL)./(i*m*XL*Rf));
  i2 = ( XL.*(I1.*Rf-V1+I1*R1) + i*(V1-I1*R1) ) ./ (m.*XL.*Rf);
endfunction

%{
function ReI2 = I2_modele2(f,m,Lm,Rf,R1,I1,V1,phi)
  XL = Lm*2*pi*f;
  ReI2 = (XL*(I1*cos(phi)*Rf-V1+I1*R1*cos(phi))+I1*Rf*R1*sin(phi)) / (m*XL*Rf);
endfunction

function ImI2 = I2_modele2(f,m,Lm,Rf,R1,I1,V1,phi)
  XL = Lm*2*pi*f;
  ImI2 = (XL*(I1*sin(phi)*Rf+I1*R1*sin(phi))+V1*Rf-I1*Rf*R1*cos(phi)) / (m*XL*Rf);
endfunction
%}

%{
n1*I1-n2*I2 = Reluc*Flux ou
n1*Im=reluc*Flux,I1=Im+m*I2

n1*dFlux/dt = e1 = V1-R1*I1
Flux = e1/(n1*i*w)
n1*I1-n2*I2 = 1/n1*n1^2/Lm*(V1-R1*I1)/(i*w)
n1*I1-n2*I2 = n1*(V1-R1*I1)/(i*XL)
I1*(1-i*R1/XL)+i*V1/XL = m*I2
%}
function i2=I2_Th_Ampere_modele2(f,m,Lm,R1,I1,V1)
  XL = Lm*2*pi*f;
  i2 = 1/m*(I1*(1-i*R1/XL)+i*V1/XL);
endfunction

% n1*I1-n2*I2=Reluc*Flux=n1*I10
function i2=I2_I0_modele2(f,m,Lm,R1,I1,V1)
  i10 = I1(end);
  i2 =(I1-i10)/m;
endfunction


%{
Z = R1+(Rf//Lm) => Z = (R1*Rf^2+Lm^2*w^2*(R1+Rf) + i*(Lm*w*Rf^2))/(Rf^2+Lm^2*w^2)
S = U*conj(I) = Z*I*conj(I) = Z*I^2 = I^2*(R+i*X)
S = I^2*R+i*I^2*X  => P = I^2*R  Q = I^2*X
Q/I^2 = Lm*w*Rf^2/(Rf^2+Lm^2*w^2) P/I^2 = ((R1*Rf^2+Lm^2*w^2*(R1+Rf))/(Rf^2+Lm^2*w^2)

Rf = N(I,P,Q,R1) / (I^2*(P-I^2*R1))
Lm = N(I,P,Q,R1) / (I^2*Q*w)
N(I,P,Q,R1) = I^4*R1^2-2*I^2*P*R1+P^2+Q^2
%}
function [Rf,Lm]=eval_Rf_Lm(I,P,Q,R1,f)
  w  = 2*pi*f;
  N  = I.^4*R1^2-2.*I.^2.*P*R1+P.^2+Q.^2;
  Rf = N ./ (I.^2.*(P-I.^2*R1));
  Lm = N ./ (I.^2.*Q*w);
endfunction

%{
[Rf,Lm]=eval_Rf_Lm([1.05;1.338;1.082],[0.906;1.093;0.912],[0.389;0.513;0.407],R1,480)
I2_modele2(480,1/7,Lm,Rf,R1,I1,U1);
%}
%{
i2=I2_Th_Ampere_modele2(480,1/7,Lm,R1,I1,U1rms);
printf("Th_Ampere I2 = %4.3f\n",abs(i2));
printf("\n");
i2=I2_Th_Ampere_modele2(480,1/7,Lm,R1,SupI1,U1rms);
printf("Th_Ampere I2 = %4.3f\n",abs(i2));
printf("\n");
i2=I2_Th_Ampere_modele2(480,1/7,Lm,R1,InfI1,U1rms);
printf("Th_Ampere I2 = %4.3f\n",abs(i2));
printf("\n");

i2=I2_modele2(480,1/7,Lm,Rf,R1,I1,U1rms);
printf("Modele2 I2 = %4.3f\n",abs(i2));
printf("\n");
i2=I2_modele2(480,1/7,Lm,Rf,R1,SupI1,U1rms);
printf("Modele2 I2 = %4.3f\n",abs(i2));
printf("\n");
i2=I2_modele2(480,1/7,Lm,Rf,R1,InfI1,U1rms);
printf("Modele2 I2 = %4.3f\n",abs(i2));
printf("\n");

i2=I2_I0_modele2(480,1/7,Lm,R1,I1,U1rms);
printf("I10 I2 = %4.3f\n",abs(i2));
printf("\n");
i2=I2_I0_modele2(480,1/7,Lm,R1,SupI1,U1rms);
printf("I10 I2 = %4.3f\n",abs(i2));
printf("\n");
i2=I2_I0_modele2(480,1/7,Lm,R1,InfI1,U1rms);
printf("I10 I2 = %4.3f\n",abs(i2));
%}

PR1 = ParamValues(R1,0.2*R1,10);
XL  = 2*pi*480*Lm;
PXL = ParamValues(XL,0.2*XL,10);

[GR1,GXL] = meshgrid(PR1,PXL);


