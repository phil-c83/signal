## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-03-02

function Test_UI_cos(Te,Fs,U1,I1,decimation,true_phi)

  phi  = [];
  phif = [];
  phi_t= [];
  for k=decimation
    idx = 1:k:length(Te);
    Fe  = 1/(Te(idx(2))-Te(idx(1)));

    [phi1,phi2,phiMC] = MCangle(I1(idx),U1(idx),Fs,Te(idx));
    cosMC   = cos(phiMC);

    cosCOV  = cov(U1(idx),I1(idx),1)/sqrt(cov(U1(idx),U1(idx),1)*cov(I1(idx),I1(idx),1));
    phiCOV  = acos(cosCOV);

    phi = [phi;phiMC,phiCOV,cosMC,cosCOV];

    b   = fir1(8,4*Fs/Fe);
    U1f = filter(b,1,U1(idx));
    I1f = filter(b,1,I1(idx));
    #{
    figure();
    subplot(2,1,1);
    plot(Te(idx),U1f);
    subplot(2,1,2);
    plot(Te(idx),I1f);
    #}

    [phi1,phi2,phiMC_f] = MCangle(I1f,U1f,Fs,Te(idx));
    cosMC_f   = cos(phiMC_f);

    cosCOV_f  = cov(U1f,I1f,1)/sqrt(cov(U1f,U1f,1)*cov(I1f,I1f,1));
    phiCOV_f  = acos(cosCOV_f);

    phif = [phif;phiMC_f,phiCOV_f,cosMC_f,cosCOV_f];

    if abs(true_phi) <= pi # test again true value of phi
      phi_t = [phi_t;Fe;abs(phiMC-true_phi)/true_phi;abs(phiCOV-true_phi)/true_phi;abs(phiMC_f-true_phi)/true_phi;abs(phiCOV_f-true_phi)/true_phi];
    endif
  endfor

  mean_cosMC   = mean(phi(:,3));
  mean_cosCOV  = mean(phi(:,4));
  mean_cosMC_f = mean(phif(:,3));
  mean_cosCOV_f= mean(phif(:,4));
  std_cosMC    = std(phi(:,3),1);
  std_cosCOV   = std(phi(:,4),1);
  std_cosMC_f  = std(phif(:,3),1);
  std_cosCOV_f = std(phif(:,4),1);
  printf("std/mean: MC=%5.4f COV=%5.4f MC_f=%5.4f COV_f=%5.4f\n",
        std_cosMC/mean_cosMC,std_cosCOV/mean_cosCOV,
        std_cosMC_f/mean_cosMC_f,std_cosCOV_f/mean_cosCOV_f);

  if abs(true_phi) <= pi # test again true value of phi
      printf("rel_error Fe=%7.1f phiMC=%5.4f phiCOV=%5.4f phiMC_f=%5.4f phiCOV_f=%5.4f\n",phi_t);
  endif

endfunction
