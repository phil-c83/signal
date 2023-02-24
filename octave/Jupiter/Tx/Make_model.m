close all;
clear all;

R1_P1 = 367e-3;
R1_P2 = 344e-3;
R1_P3 = 352e-3;


cstr = inputdlg ("R1 value in Ohm?", "Clamp model");
if length(cstr) == 1
  R1 =str2double(cstr(1));
else
  return
endif

[fname,fpath,f,U1,I1,P1,I2] = read_csv_measures();

E1 = Eval_E1 (I1,U1,P1,R1);
[a0_anRf Rf] = Make_Rf_model (I1,U1,E1,P1,R1,f);
[a0_anLm Lm] = Make_Lm_model (I1,U1,E1,P1,R1,f);

% save R1 and model value
dlmwrite([fpath "/" "Rf_model.csv"],a0_anRf');
dlmwrite([fpath "/" "Lm_model.csv"],a0_anLm');
dlmwrite([fpath "/" "R1.csv"],R1);

Rf_ml = Eval_poly_model(f,E1,a0_anRf);
Lm_ml = Eval_poly_model(f,E1,a0_anLm);

figure();
label = "Lm";
% plot measured Lm and estimated Lm
plot3(f,E1,Lm,["-*k;" label ";"],
      f,E1,Lm_ml,["-*r;es" label ";"]);

figure();
label = "Rf1";
% plot measured Lm and estimated Lm
plot3(f,E1,Rf,["-*k;" label ";"],
      f,E1,Rf_ml,["-*r;es" label ";"]);


