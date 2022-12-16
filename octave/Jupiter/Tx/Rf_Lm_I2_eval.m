% Rf,Lm,I2 eval
clear all;
close all;

% Zm = Rf//(i*Lm*w)
function Zm = eval_Zm(Rf,Lm,f)
  Xm = 2*pi*f.*Lm;
  Zm = (Rf.*Xm.^2+i*Rf.^2.*Xm)./(Rf.^2+Xm.^2);
endfunction

%{
compute Zm,Lm,Rf with values from measures I2==0 ie open circuit
Z = R1+(Rf//Lm) => Z = (R1*Rf^2+Lm^2*w^2*(R1+Rf) + i*(Lm*w*Rf^2))/(Rf^2+Lm^2*w^2)
S = U*conj(I) = Z*I*conj(I) = Z*I^2 = I^2*(R+i*X)
S = I^2*R+i*I^2*X  => P = I^2*R  Q = I^2*X
Q/I^2 = Lm*w*Rf^2/(Rf^2+Lm^2*w^2)
P/I^2 = ((R1*Rf^2+Lm^2*w^2*(R1+Rf))/(Rf^2+Lm^2*w^2)

Rf = N(I,P,Q,R1) / (I^2*(P-I^2*R1))
Lm = N(I,P,Q,R1) / (I^2*Q*w)
N(I,P,Q,R1) = I^4*R1^2-2*I^2*P*R1+P^2+Q^2
%}
function [Zm,Rf,Lm] = eval_Zm_with_measures(I,U,cos_ui,R1,f)
  w  = 2*pi*f;
  P = U .* I .* cos_ui;
  Q = sqrt((U .* I).^2 - P.^2);
  N  = I.^4.*R1.^2-2*I.^2.*P.*R1+P.^2+Q.^2;
  Rf = N ./ (I.^2.*(P-I.^2.*R1));
  Lm = N ./ (I.^2.*Q.*w);
  Zm = eval_Zm(Rf,Lm,f);
endfunction

% I2 eval with measures
function I2c = eval_I2(V1,I1,cos_ui,R1,Zm,m)
  I1c = I1.*(cos_ui - i*(sqrt(1-cos_ui.^2)));
  I2c = (V1-I1c.*(Zm+R1))./(m*Zm);
endfunction

%u(f,v) = a0 + a1*f + a2*v + a3*f^2 + a4*f*v + a5*v^2 + a6*f^2*v + a7*f*v^2 + a8*f^2*v^2
function u=eval_poly(f,v,a)
  N  = length(f);
  u  = [ones(N,1), f, v, f.^2, f.*v, v.^2, f.^2.*v, f.*v.^2, f.^2.*v.^2] * a;
endfunction



[f,e1,Lm,Rf] = read_csv_Lm_Rf(1);
% Rf(f,v) parameters model with measures
% MCDeg4(f, v, values, select)
[etype_Rf1,emax_Rf1,a_Rf1] = MCDeg4(f,e1,Rf, [1 1 1 0 0 1 0 0 0]);
printf("%s(f,v)= %+g %+g*f %+g*v %+g*f^2 %+g*f*v %+g*v^2 %+g*f^2*v %+g*f*v^2 %+g*f^2*v^2 std=%f emax=%f\n",
        "Rf1",a_Rf1(1),a_Rf1(2),a_Rf1(3),a_Rf1(4),a_Rf1(5),a_Rf1(6),a_Rf1(7),a_Rf1(8),a_Rf1(9),etype_Rf1,emax_Rf1);

% Lm(f,v) parameters model with measures
[etype_Lm1,emax_Lm1,a_Lm1] = MCDeg4(f,e1,Lm, [1 1 1 1 1 1 1 1 1]);
printf("%s(f,v)= %+g %+g*f %+g*v %+g*f^2 %+g*f*v %+g*v^2 %+g*f^2*v %+g*f*v^2 %+g*f^2*v^2 std=%f emax=%f\n",
        "Lm1",a_Lm1(1),a_Lm1(2),a_Lm1(3),a_Lm1(4),a_Lm1(5),a_Lm1(6),a_Lm1(7),a_Lm1(8),a_Lm1(9),etype_Lm1,emax_Lm1);

% eval_poly(f,v,a)
Lm1_e = eval_poly(f,e1,a_Lm1);
Rf1_e = eval_poly(f,e1,a_Rf1);
% eval_Zm(Rf,Lm,f)
Zm1_e = eval_Zm(Rf1_e,Lm1_e,f);

figure();
label = "Lm1";
% plot measured Lm and estimated Lm
plot3(f,e1,Lm,["-*k;" label ";"],
      f,e1,Lm1_e,["-*r;es" label ";"]);

figure();
label = "Rf1";
% plot measured Lm and estimated Lm
plot3(f,e1,Rf,["-*k;" label ";"],
      f,e1,Rf1_e,["-*r;es" label ";"]);

figure();
label = "Rf1_err";
plot3(f,e1,abs(Rf-Rf1_e),["-*k;" label ";"]);

figure();
label = "Lm1_err";
plot3(f,e1,abs(Lm-Lm1_e),["-*k;" label ";"]);


% get measures U,I ... from file
[f,U1,E1,I1,cos_ui,R1,I2_m] = read_csv_U_I_Cos(1);
[Zm1_m,Rf1_m,Lm1_m] = eval_Zm_with_measures(I1,U1,cos_ui,R1,f);

% eval_poly(f,v,a)
Lm1_e = eval_poly(f,E1,a_Lm1);
Rf1_e = eval_poly(f,E1,a_Rf1);
% eval_Zm(Rf,Lm,f)
Zm1_e = eval_Zm(Rf1_e,Lm1_e,f);
% eval_I2(V1,I1,cos_ui,R1,Zm,m)
I2ce = eval_I2(U1,I1,cos_ui,R1,Zm1_e,1/7);
printf("f=%3d E1=%5.3f Zm_e=%07.6f Lm_e=%07.6f Rf_e=%07.6f Lm_m=%07.6f Rf_m=%07.6f I2_e=%07.4f I2_m=%07.4f\n",
        [f,E1,abs(Zm1_e),Lm1_e,Rf1_e,Lm1_m,Rf1_m,abs(I2ce),I2_m]');

%{
figure();
[ff,ee]=meshgrid(f,e1);
surf(ff,ee,abs(Lm-Lm1_p));
%}




%{
% get  freq,V1,E1,I1,cos_ui,R1,I2 from csv file
[fname, fpath, fltidx]=uigetfile ("/home/phil/Made/git-prj/signal/data/*.csv","V1,E1,I1 ...");
file = [fpath "/" fname];
%freq,V1,E1,I1,cos_ui,R1,I2
m1 = csv_Clamps_measures(file);

% find values for open secondary ie open circuit test to parameters model
im1   = find(m1(:,7)==0.0); % ie I2==0
m1_oc = m1(im1,:);
% eval_Zm_with_measures(I,U,cos_ui,R1,f)
[Zm_m,Rf_m,Lm_m] = eval_Zm_with_measures(m1_oc(:,4),m1_oc(:,2),m1_oc(:,5),m1_oc(:,6),m1_oc(:,1));
% eval_I2(V1,I1,cos_ui,R1,Zm,m)
I2_m = abs(eval_I2(m1_oc(:,2),m1_oc(:,4),m1_oc(:,5),m1_oc(:,6),Zm_m,1/7));
printf("f=%3d E1=%5.3f Zm_m=%07.6f Lm_m=%07.6f Rf_m=%07.6f I2_m=%07.4f\n",
        [m1_oc(:,1),m1_oc(:,3),abs(Zm_m),Lm_m,Rf_m,I2_m]');


% Rf(f,v) parameters model with measures
% MCDeg4(f, v, values, select)
[etype_Rf1,emax_Rf1,a_Rf1] = MCDeg4(m1_oc(:,1),m1_oc(:,3),Rf_m, [1 1 1 0 0 1 0 0 0]);
printf("%s(f,v)= %+g %+g*f %+g*v %+g*f^2 %+g*f*v %+g*v^2 %+g*f^2*v %+g*f*v^2 %+g*f^2*v^2 std=%f emax=%f\n",
        "Rf1",a_Rf1(1),a_Rf1(2),a_Rf1(3),a_Rf1(4),a_Rf1(5),a_Rf1(6),a_Rf1(7),a_Rf1(8),a_Rf1(9),etype_Rf1,emax_Rf1);


% Lm(f,v) parameters model with measures
[etype_Lm1,emax_Lm1,a_Lm1] = MCDeg4(m1_oc(:,1),m1_oc(:,3),Lm_m, [1 1 1 1 1 1 1 1 1]);
printf("%s(f,v)= %+g %+g*f %+g*v %+g*f^2 %+g*f*v %+g*v^2 %+g*f^2*v %+g*f*v^2 %+g*f^2*v^2 std=%f emax=%f\n",
        "Lm1",a_Lm1(1),a_Lm1(2),a_Lm1(3),a_Lm1(4),a_Lm1(5),a_Lm1(6),a_Lm1(7),a_Lm1(8),a_Lm1(9),etype_Lm1,emax_Lm1);



%eval_poly(f,v,a)
Lm1_p = eval_poly(m1_oc(:,1),m1_oc(:,3),a_Lm1);
Rf1_p = eval_poly(m1_oc(:,1),m1_oc(:,3),a_Rf1);
%eval_Zm(Rf,Lm,f)
Zm1_p = eval_Zm(Rf1_p,Lm1_p,m1_oc(:,1));


figure();
label = "Lm1";
% plot measured Lm and estimated Lm
plot3(m1_oc(:,1),m1_oc(:,3),Lm_m,["-*k;" label ";"],
      m1_oc(:,1),m1_oc(:,3),Lm1_p,["-*r;es" label ";"]);
printf("\n");


%eval_poly(f,v,a)
Lm1_p = eval_poly(m1(:,1),m1(:,3),a_Lm1);
Rf1_p = eval_poly(m1(:,1),m1(:,3),a_Rf1);
%eval_Zm(Rf,Lm,f)
Zm1_p = eval_Zm(Rf1_p,Lm1_p,m1(:,1));
% eval_I2(V1,I1,cos_ui,R1,Zm,m)
I2_p  = abs(eval_I2(m1(:,2),m1(:,4),m1(:,5),m1(:,6),Zm1_p,1/7));
printf("f=%3d E1=%5.3f Zm_p=%07.6f Lm_p=%07.6f Rf_p=%07.6f I2_p=%07.4f I2_m=%07.4f\n",
        [m1(:,1),m1(:,3),abs(Zm1_p),Lm1_p,Rf1_p,I2_p,m1(:,7)]');

%}

%{
% eval Rf
[etype_Rf1,emax_Rf1,a_Rf1] = MCDeg4(cl1(:,1),cl1(:,3),cl1(:,5), [1 1 1 0 0 1 0 0 0]);
printf("%s(f,v)= %+g %+g*f %+g*v %+g*f^2 %+g*f*v %+g*v^2 %+g*f^2*v %+g*f*v^2 %+g*f^2*v^2 std=%f emax=%f\n",
        "Rf1",a_Rf1(1),a_Rf1(2),a_Rf1(3),a_Rf1(4),a_Rf1(5),a_Rf1(6),a_Rf1(7),a_Rf1(8),a_Rf1(9),etype_Rf1,emax_Rf1);

% eval Lm
[etype_Lm1,emax_Lm1,a_Lm1] = MCDeg4(cl1(:,1),cl1(:,3),cl1(:,4), [1 1 1 1 1 1 1 1 1]);
printf("%s(f,v)= %+g %+g*f %+g*v %+g*f^2 %+g*f*v %+g*v^2 %+g*f^2*v %+g*f*v^2 %+g*f^2*v^2 std=%f emax=%f\n",
        "Lm1",a_Lm1(1),a_Lm1(2),a_Lm1(3),a_Lm1(4),a_Lm1(5),a_Lm1(6),a_Lm1(7),a_Lm1(8),a_Lm1(9),etype_Lm1,emax_Lm1);


%Freq,dac_lsb,e1,Lm,Rf
label = "Lm1";
plot3(cl1(:,1),cl1(:,3),cl1(:,4),["-k;" label ";"],
      cl1(:,1),cl1(:,3),eval_poly(cl1(:,1),cl1(:,3),a_Lm1),["-r;es" label ";"]);

[Zm_p,Rf_p,Lm_p] = eval_Zm_with_poly(Rf1_coefs,Lm1_coefs,m1(:,1),m1(:,3));
I2_p = abs(eval_I2(m1(:,2),m1(:,4),m1(:,5),m1(:,6),Zm_p,1/7));


printf("\n");
Rf1_p = eval_poly(m1_oc(:,1),m1_oc(:,3),a_Rf1);
Lm1_p = eval_poly(m1_oc(:,1),m1_oc(:,3),a_Lm1);
Zm1_p = eval_Zm(Rf1_p,Lm1_p,m1_oc(:,1));
I2_p  = abs(eval_I2(m1_oc(:,2),m1_oc(:,4),m1_oc(:,5),m1_oc(:,6),Zm1_p,1/7));
printf("f=%3d E1=%5.3f Zm_p=%07.6f Lm_p=%07.6f Rf_p=%07.6f I2_p=%07.4f\n",
        [m1_oc(:,1),m1_oc(:,3),abs(Zm1_p),Lm1_p,Rf1_p,I2_p]');


printf("\n");
[Zm_p,Rf_p,Lm_p] = eval_Zm_with_poly(Rf1_coefs,Lm1_coefs,m1_oc(:,1),m1_oc(:,3));
I2_p = abs(eval_I2(m1_oc(:,2),m1_oc(:,4),m1_oc(:,5),m1_oc(:,6),Zm_p,1/7));
printf("Zm_p=%07.6f Lm_p=%07.6f Rf_p=%07.6f I2_p=%07.4f\n",
        [abs(Zm_p),Lm_p,Rf_p,I2_p]');

printf("\n");
Zm_pm = eval_Zm(Rf_p,Lm_m,m1_oc(:,1));
I2_pm = abs(eval_I2(m1_oc(:,2),m1_oc(:,4),m1_oc(:,5),m1_oc(:,6),Zm_pm,1/7));
printf("Zm_pm=%07.6f Lm_m=%07.6f Rf_m=%07.6f I2_pm=%07.4f\n",
        [abs(Zm_pm),Lm_m,Rf_p,I2_pm]');



printf("Zm_p=%07.6f Lm_p=%07.6f Rf_p=%07.6f I2_p=%05.2f -- Zm_m=%07.6f Lm_m=%07.6f Rf_m=%07.6f I2_m=%05.2f\n",
        abs(Zm_p),Lm_p,Rf_p,I2_p,abs(Zm_m),Lm_m,Rf_m,I2_m);
%}

%{
Rf1(f,v)=+0.462559 +0.00025742*f +0.303987*v -0.0629258*v^2
Lm1(f,v)=+9.15858e-06 +4.0168e-07*f -1.30753e-10*f^2 +0.000239287*v -7.16174e-05*v^2
Zm_m=0.472351 Lm_m=0.000258 Rf_m=0.629801 I2_m=00.0000
Zm_m=0.603766 Lm_m=0.000340 Rf_m=0.788478 I2_m=00.0000
Zm_m=0.547534 Lm_m=0.000214 Rf_m=0.710159 I2_m=00.0000
Zm_m=0.624409 Lm_m=0.000252 Rf_m=0.792388 I2_m=00.0000
Zm_m=0.691456 Lm_m=0.000283 Rf_m=0.871022 I2_m=00.0000

Zm_p=0.446641 Lm_p=0.000221 Rf_p=0.654661 I2_p=00.4707
Zm_p=0.595862 Lm_p=0.000321 Rf_p=0.803920 I2_p=00.4296
Zm_p=0.598790 Lm_p=0.000276 Rf_p=0.710707 I2_p=00.5404
Zm_p=0.681474 Lm_p=0.000333 Rf_p=0.791365 I2_p=01.0396
Zm_p=0.750168 Lm_p=0.000377 Rf_p=0.862968 I2_p=01.5070
%}
