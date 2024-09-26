## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-08-22


function ret = show_sample(Fe,json_str)

  ret = 0;

  json = jsondecode(json_str);

  if( strcmp(json.result.sensor,"ROG" ) )
    ret = show_rog(Fe,json.result.sample_xx_faible,
                   json.result.sample_xx_fort);

  elseif( strcmp(json.result.sensor,"PT" ) )
    ret = show_pt(Fe,json.result.sample_xx_faible,
                  json.result.sample_xx_fort);

  elseif( strcmp(json.result.sensor,"PREID" ) )
    ret = show_pid(Fe,json.result.sample_xx_faible,
                   json.result.sample_bl_faible,
                   json.result.sample_xx_fort,
                   json.result.sample_bl_fort);
  else ret=1;
  end

endfunction

function [psig,pline,pnoise] = sig_parts(Fe,Fmax,s_fft)

  SigSetFreqs=[410 440 470;520 560 590;610 640 670;710 740 770]';
   # all sig set frequencies with 1st harmonic
  AllFreqs   = [[SigSetFreqs(:,1);SigSetFreqs(:,1)*2] ...
                [SigSetFreqs(:,2);SigSetFreqs(:,2)*2] ...
                [SigSetFreqs(:,3);SigSetFreqs(:,3)*2] ...
                [SigSetFreqs(:,4);SigSetFreqs(:,4)*2] ];

  psig   = 0; # signal power
  pnoise = 0; # noise power ie not(sig+line)
  pline  = 0; # line power

  j=1;
  df = round(Fe/length(s_fft));
  for k=2:round(Fmax/df) # no dc
    if( (k-1)*df == AllFreqs(j) ) # sig frequency
      psig += abs(s_fft(k))^2;
      j++;
    elseif( rem((k-1)*df,50) == 0 || rem((k-1)*df,60) == 0 ) # power line frequency
      pline += abs(s_fft(k))^2;
      #printf("k=%d f=%d p=%.2f\n",k,(k-1)*df,abs(s_fft(k))^2)
    else
      pnoise += abs(s_fft(k))^2; # noise frequency
      #printf("k=%d f=%d p=%.2f\n",k,(k-1)*df,abs(s_fft(k))^2)
    end
  endfor

endfunction


#{
  Fe    : sampling frequency
  Fmax  : max frequency displayed by fft
  s     : signal column vector
  name  : label column vector for signals
#}
function disp_samples(Fe,Fmax,s,names)

  [rows,cols] = size(s);
  figure();
  for j=1:cols
    N  = rows;
    Te = (0:N-1)*1/Fe;
    fft_idx = 1:round(Fmax*N/Fe);
    Df = fft_idx*Fe/N;
    subplot(cols,2,2*(j-1)+1);
    plot(Te,s(:,j));
    title(names(j,:));
    subplot(cols,2,2*(j-1)+2);
    sfft = fft(s(:,j))/N;
    plot(Df,abs(sfft(fft_idx+1)))

    #[psig,pline,pnoise] = sig_parts(Fe,Fmax,sfft);
    [psig,pline,pnoise] = sig_parts(Fe,Fe/2,sfft);
    printf("<%s> psig=%10.2f pline=%10.2f pnoise=%10.2f psig/pnoise=%10.2f psig/(pnoise+pline)=%10.2f\n",
           names(j,:),psig,pline,pnoise,psig/pnoise,psig/(pline+pnoise));
  endfor

endfunction


function r = show_rog(Fe,lg_samples,hg_samples)

  disp_samples(Fe,3000,[lg_samples hg_samples],
                  ["ROG lgain";"ROG hgain"]);
  r=0;

endfunction

function r = show_pt(Fe,lg_samples,hg_samples)

  disp_samples(Fe,3000,[lg_samples hg_samples],
                  ["PT lgain";"PT hgain"]);
  r=0;

endfunction


function r = show_pid(Fe,lg_bp_samples,lg_bl_samples,hg_bl_samples,hg_bp_samples)

  disp_samples(Fe,3000,[lg_bp_samples lg_bl_samples hg_bl_samples hg_bp_samples],
                  ["PID bp lgain";"PID bl lgain";"PID bp hgain";"PID bl hgain"]);
  r=0;

endfunction


