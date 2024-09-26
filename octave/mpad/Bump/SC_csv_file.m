clearvars;
ext = "CSV";
[fqname,fpath,fname]=choose_file(ext);
printf("opening %s\n",fqname);

[Tau,s] = get_tds200x_file(fqname);

dt     = Tau(2,1) - Tau(1,1);
printf("dt=%f\n",dt);

Ts  = 580e-6; # derived bump signal duration
Fe  = 1/dt;
Te  = (-Ts:1/Fe:Ts) ;

sref= Dbump(2*Te/Ts);
#plot(Te,sref);

[co,lag]  = xcorr(s,sref);

Tco = (0:length(s)+length(sref)-2)*dt;

plot(lag*dt,co);
