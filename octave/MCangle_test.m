clear all;

function phi12=test_MCangle(Fe,f,N,phi1,phi2,var_noise)
  Te = (0:N-1)'*1/Fe;
  ns1= randn(N,1)*var_noise;
  ns2= randn(N,1)*var_noise;
  s1 = sin(2*pi*f*Te+phi1) + ns1;
  s2 = sin(2*pi*f*Te+phi2) + ns2 ;

  [phi1,phi2,phi12] = MCangle(s1,s2,f,Te);
  printf("Phi1=%1.4f phi2=%1.4f phi12=%1.4f cos=%1.4f\n",phi1,phi2,phi12,cos(phi12));
endfunction

test_MCangle(48000,480,1024,pi/2,pi/3,0.1);
