Rf=628e-3;
Lm=232e-6;
R1=390e-3;

%releves @ R2=1e-3,15e-3,25e-3,50e-3,100e-3,200e-3,+Inf
%{
% mesure Tx jupE
CosUI = [0.98 ;0.97 ;0.95 ;0.92 ;0.92 ;0.91 ;0.9];
I1rms = [0.991;0.713;0.632;0.618;0.598;0.579;0.579];
U1rms = [0.397;0.443;0.456;0.461;0.463;0.468;0.466];
%}
% mesure oscillo TDS
U1rms = [.293;.378;.401;.408;.413;.416;.420];
I1rms = [.990;.7;.622;.605;.587;.578;.572];
CosUI = [.989;.953;.938;.928;.914;.901;.883];
I2rms = [5.71;2.01;1.03;.730;.380;.183;0];

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

% Distributed n values around p
function Pv=ParamValues(p,dp,n)
  Pv = (p-dp : 2*dp/n : p+dp)';
endfunction

%   abs(r-p) <= p*(1+rel_tol)
function r=rand_param(p,rel_tol)
  tol = p*rel_tol;
  r = tol*(2*rand(1)-1)+p;
endfunction

%{
Eval de I2 avec modèle transfo R1,Rf,Lm ie (Lf=0)
%}
function i2=I2_modele2(f,m,Lm,Rf,R1,I1rms,U1rms,cos_ui)
  XL = Lm*2*pi*f;
  [x,y] = pol2cart(-acos(cos_ui),I1rms);%inductive load
  I1 = complex(x,y);
  %i2=abs(I1/m - (V1-R1*I1).*(Rf+i*XL)./(i*m*XL*Rf));
  i2 = ( XL.*(I1.*Rf-U1rms+I1*R1) + i*(U1rms-I1*R1) ) ./ (m.*XL.*Rf);
endfunction

function i2=I2_M_modele2(f,m,Lm,Rf,R1,I1rms,U1rms,cos_ui)
  XL = Lm*2*pi*f;
  [x,y] = pol2cart(-acos(cos_ui),I1rms);%inductive load
  I1 = complex(x,y);
  i2 = 1/(m*XL)*(I1*(XL-i*R1)+i*U1rms);
endfunction

function i2=I2_Lf_M_modele2(f,m,Lf,Lm,Rf,R1,I1rms,U1rms,cos_ui)
  XL = Lm*2*pi*f;
  Xf = Lf*2*pi*f;
  [x,y] = pol2cart(-acos(cos_ui),I1rms);%inductive load
  I1 = complex(x,y);
  i2 = (I1*((XL+Xf)-i*R1)+i*U1rms)/(XL*m);
endfunction

%{
 I2 avec modèle transfo R1,Lm,Lf,Rf
 V1-I1*Z1-Zm*(I1-m*I2) = 0
 I2 = (I1*(Z1+Zm)-V1)/(m*Zm)
 Z1 = R1+i*Xf   Zm = Rf//XL
%}
function i2=I2_modele4(f,m,Lm,Lf,Rf,R1,I1rms,U1rms,cos_ui)
  XL = Lm*2*pi*f;
  Xf = Lf*2*pi*f;
  Z1 = R1+i*Xf;
  Zm = (Rf*XL^2+i*(Rf^2*XL))/(Rf^2+XL^2);
  [x,y] = pol2cart(-acos(cos_ui),I1rms);%inductive load
  I1 = complex(x,y);
  i2 = abs((I1*(Z1+Zm)-U1rms)/(m*Zm));
endfunction


% n1*I1-n2*I2=Reluc*Flux=n1*I10
function i2=I2_I0_modele2(f,m,Lm,R1,I1rms,U1rms,cos_ui)
  [x,y] = pol2cart(-acos(cos_ui),I1rms);%inductive load
  I1 = complex(x,y);
  i10 = I1(end);
  i2 =(I1-i10)/m;
endfunction

%{
Ampere theorem under hopkinson form
n1*I1-n2*I2 = Reluc*Flux ou
n1*Im=reluc*Flux,I1=Im+m*I2

n1*dFlux/dt = e1 = V1-R1*I1
Flux = e1/(n1*i*w)
n1*I1-n2*I2 = 1/n1*n1^2/Lm*(V1-R1*I1)/(i*w)
n1*I1-n2*I2 = n1*(V1-R1*I1)/(i*XL)
I1*(1-i*R1/XL)+i*V1/XL = m*I2
%}
function i2=I2_Hopkinson(f,m,Lm,R1,I1rms,U1rms,cos_ui)
  XL = Lm*2*pi*f;
  [x,y] = pol2cart(-acos(cos_ui),I1rms);%inductive load
  I1 = complex(x,y)
  R1I1 = abs(R1*I1)
  E1 = abs(U1rms - R1*I1)
  disp(U1rms);
  i2 = 1/m*(I1*(1-i*R1/XL)+i*U1rms/XL);
endfunction

function [r1,lm,i2]=Minimize_I2_with_r1_lm(f,m,Lm,R1,I1rms,U1rms,cos_ui,I2rms)
  min_err2 = realmax;
  PR1 = ParamValues(R1,0.3*R1,20);
  PLm = ParamValues(Lm,0.3*Lm,20);

  for i=1:length(PR1)
    for j=1:length(PLm)
      I2c = abs(I2_Hopkinson(f,m,PLm(j),PR1(i),I1rms,U1rms,cos_ui));
      err2= sum((I2c-I2rms).^2);
      if(err2 < min_err2)
        min_err2 = err2;
        r1 = PR1(i);
        lm = PLm(j);
        i2 = I2c;
      endif
    endfor
  endfor

endfunction

function [best_cos,best_i2,min_err2,adj]=Minimize_I2_with_cosui(f,m,Lm,R1,I1rms,U1rms,cos_ui,I2rms)
  niter = 10000;
  adj_value = 0.1;
  min_err2 = realmax;
  best_cos = ones(length(cos_ui),1);

  for i=1:niter
    adjv = rand(length(cos_ui),1)*2*adj_value-adj_value;
    cosui = min(cos_ui + adjv,1);
    I2c = abs(I2_Hopkinson(f,m,Lm,R1,I1rms,U1rms,cosui));
    err2= sum((I2c-I2rms).^2);
    if(err2 < min_err2)
      min_err2 = err2;
      best_cos = cosui;
      best_i2  = I2c;
      adj = adjv;
    endif
  endfor
endfunction

function [b_Lm,b_Lf,b_R1,b_Rf,b_I2rms]=Minimize_model4(f,m,Lm,Lf,R1,Rf,I1rms,U1rms,I2rms,cos_ui)
  min_err = realmax;
  niter = 1000000;
  rel_tol = 0.3;
  for i=1:niter
    p_R1 = rand_param(R1,rel_tol);
    p_Lm = rand_param(Lm,rel_tol);
    p_Rf = rand_param(Rf,rel_tol);
    p_Lf = rand_param(Lf,rel_tol);
    I2e  = abs(I2_modele4(f,m,p_Lm,p_Lf,p_R1,p_Rf,I1rms,U1rms,cos_ui));
    err2  = sum((I2e-I2rms).^2);
    if( err2 < min_err )
      min_err = err2;
      b_R1 = p_R1;
      b_Rf = p_Rf;
      b_Lm = p_Lm;
      b_Lf = p_Lf;
      b_I2rms = I2e;
    endif
  endfor
endfunction


function [b_Lm,b_Lf,b_R1,b_Rf,b_I2rms]=VMinimize_model4(f,m,Lm,Lf,R1,Rf,I1rms,U1rms,I2rms,cos_ui)
  min_err = realmax;
  niter = 1000000;
  rel_tol = 0.3;
  r = rel_tol*(2*rand(4,niter)-1)+1;
  p = diag([Lm;Lf;R1;Rf]);% random values for each params ie p +/- (p*rel_tol)
  rp = p*r;

  for i=1:niter
    I2e  = abs(I2_modele4(f,m,rp(1,i),rp(2,i),rp(3,i),rp(4,i),I1rms,U1rms,cos_ui));
    err2  = sum((I2e-I2rms).^2);
    if( err2 < min_err )
      min_err = err2;
      b_R1 = rp(3,i);
      b_Rf = rp(4,i);
      b_Lm = rp(1,i);
      b_Lf = rp(2,i);
      b_I2rms = I2e;
    endif
  endfor
endfunction


% eval de E1=U1-R*I1
function E1=eval_e1(U1rms,I1rms,cosui,R1)
  [x,y] = pol2cart(-acos(cosui),I1rms);%inductive load
  I1 = complex(x,y);
  E1 = abs(U1rms-R1*I1);
endfunction

% valeurs mesurees
%E1=eval_e1([.293;.378;.401;.408;.413;.416;.420],[.990;.7;.622;.605;.587;.578;.572],[.989;.953;.938;.928;.914;.901;.883],300e-3)
[b_Lm,b_Lf,b_R1,b_Rf,b_I2rms]=VMinimize_model4(480,1/7,Lm,20e-6,500e-3,320e-3,I1rms,U1rms,I2rms,CosUI)
%[b_Lm,b_Lf,b_R1,b_Rf,b_I2rms]=Minimize_model4(480,1/7,Lm,0,R1,Rf,I1rms,U1rms,I2rms,CosUI)

%{
[r1,lm,i2]=Minimize_I2_with_r1_lm(480,1/7,Lm,R1,I1rms,U1rms,CosUI,I2rms)
[best_cos,i2,err,adj]=Minimize_I2_with_cosui(480,1/7,Lm,R1,I1rms,U1rms,CosUI,I2rms)
%}

