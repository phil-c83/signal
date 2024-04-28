close all;
Fe=100e3;
t=(-2:1/Fe:2);

#fplot("Rect(2*t)",[-1,1],100);

#plot(t,Transpose(@Rect,t,-1e-3,1e-3));

dom=[0,2e-3];
figure;
plot(t,Sig(t,dom,1,1,1));
figure;
plot(t,Sig(t,dom,0.8,0.2,0.33));

#plot(t,Transpose(@Triangle,t,dom(1),dom(2)));


