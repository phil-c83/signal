close all;
clear all;

#[s1,s2,s3]=fields(c1,c2,c3,r,theta)
# tripolaire cable
c1 = 1/2*exp(i*pi/3);
c2 = 1/2*exp(i*5*pi/3);
c3 = 1/2;
theta = 0:pi/20:2*pi;
[s1,s2,s3]=fields(c1,c2,c3,1,theta);
figure();
plot(theta,s1,";s1;");
hold on;
plot(theta,s2,";s2;");
hold on;
plot(theta,s3,";s3;");

# tetrapolaire cable
c1 = 1/2*exp(i*5*pi/18);
c2 = 1/2*exp(i*25*pi/18);
c3 = 1/2*exp(i*15*pi/18);
[s1,s2,s3]=fields(c1,c2,c3,1,theta);
figure();
plot(theta,s1,";s1;");
hold on;
plot(theta,s2,";s2;");
hold on;
plot(theta,s3,";s3;");
