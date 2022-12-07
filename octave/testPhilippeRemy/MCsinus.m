function [a,phi,const,theta]=MCsinus(f0, t, s)
%Modele pour le MC ---> a*sin(2*pi*f0*t+ phi) + const
%Input:
%f0 : frequence du signal
%t : temps (vecteur colonne)
%s : signal (vecteur colonne)
%Output:
%a: amplitude du sinus
%phi: phase du sinus
%const: offset du sinus
%theta: vecteur des estimes du MC



A=[sin(2*pi*f0*t), cos(2*pi*f0*t),ones(length(t),1)];

somATA=A'*A;
iATA=inv(somATA);

somATs=A'*s;
theta=iATA*somATs;

phi=atan2(theta(2),theta(1)); %atan2 donne la phase sur [-pi;pi]
a=sqrt(theta(2)^2+theta(1)^2);
const=theta(3);
