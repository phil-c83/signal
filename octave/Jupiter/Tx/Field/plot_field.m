

function plot_field(theta,Bs1,Bs2,Bs3,title_str)
  if iscomplex(Bs1)
    figure();
    plot3(theta,Bs1,";Bs1;",theta,Bs2,";Bs2;",theta,Bs3,";Bs3;");
    figure();
    plot(theta,abs(Bs1),";abs(Bs1);",theta,abs(Bs2),";abs(Bs2);",theta,abs(Bs3),";abs(Bs3);");
    figure();
    plot(theta,arg(Bs1),";arg(Bs1);",theta,arg(Bs2),";arg(Bs2);",theta,arg(Bs3),";arg(Bs3);");
    figure()
    x=cos(theta);
    y=sin(theta);
    quiver(x,y,real(Bs1),imag(Bs1),";Bs1;");
    hold on;
    quiver(x,y,real(Bs2),imag(Bs2),";Bs2;");
    hold on;
    quiver(x,y,real(Bs3),imag(Bs3),";Bs3;");

  else
    figure();
    plot(theta,Bs1,";Bs1;",theta,Bs2,";Bs2;",theta,Bs3,";Bs3;");
  endif
endfunction




#{
# cable HTA 3 conducteurs
r = 1;
step = pi/20;
theta = 0:step:pi;
a = exp(i*2*pi/3);
z1 = i*2*r/sqrt(3);
z2 = z1*a^2;
z3 = z1*a;
z  = z1+r*exp(i*theta);
[Bs1,Bs2,Bs3] = fields_v(z1,z2,z3,z);
plot_field(theta,Bs1,Bs2,Bs3,"cable HTA");

# cable HTA 3 conducteurs autour sur le rayon exterieur ie parfois sur aucun conducteur
r = 1;
step = pi/20;
theta = -2*pi+step:step:2*pi;
a = exp(i*2*pi/3);
z1 = i*2*r/sqrt(3);
z2 = z1*a^2;
z3 = z1*a;
z  = r*(1+2/sqrt(3))*exp(i*theta);
[Bs1,Bs2,Bs3] = fields_v(z1,z2,z3,z);
plot_field(theta,Bs1,Bs2,Bs3,"cable HTA");
#}

