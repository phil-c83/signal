clear all;
close all;

# fplot(@gate,[-5,5,-5,5],1000);
Te=-10:1/100:5;


y2=rtrig(Te-1);
plot(Te,y2);
axis([-5,5,-2,+2]);
grid on;
hold on;
y3=rtrig(-Te-1);
plot(Te,y3);
legend(["rtrig(x-1)" "rtrig(-x-1)"])

%{
y1=gate(-Te+1);
plot(Te,y1);
y4=rtrig(-Te-1);
plot(Te,y4);

fplot("gate(x)",[-5,5,0,2],1000);
hold on;
fplot("gate((x-3)/2)",[-5,5,0,2],1000);
hold on;
fplot("gate(-x+1)",[-5,5,0,2],1000);
%}
