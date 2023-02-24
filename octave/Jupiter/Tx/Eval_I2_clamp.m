## Copyright (C) 2023
##

## Author:  <phil@archlinux>
## Created: 2023-01-16

  m = 1/7;
% model csv file must be created before calling

  [fname,fpath,f,U1,I1,P1,I2] = read_csv_measures();

  a0_anRf = dlmread([fpath "/" "Rf_model.csv"],",",0,0);% read row vector a0_an from .csv file
  a0_anLm = dlmread([fpath "/" "Lm_model.csv"],",",0,0);% read row vector a0_an from .csv file
  R1 = dlmread([fpath "/" "R1.csv"],",",0,0);

  [I2_m,E1,Zm,Rf,Lm] = Eval_I2_model (I1,U1,P1,R1,f,m,a0_anRf',a0_anLm');
  Di2 = abs(I2_m-I2); % absolute error
  Di2_I2 = Di2 ./ I2; % relative error

  printf("I2=%5.2f I2_m=%5.2f DI2=%5.2f DI2/I2=%5.2f E1=%5.2f Rf=%7.6f Lm=%7.6f Zm=%g\n",[I2,I2_m,Di2,Di2_I2,E1,Rf,Lm,abs(Zm)]');


