close all;
clear all;


function print_sig(name,sig)

  printf("const int16_t %s[]={\n",name);

  for k=1:length(sig)

    if(k == length(sig))
      printf("% 5d\n",int16(sig(k)));
      puts("};\n");
      break;
    endif
    if(mod(k,16)==0 && k!=0)
      printf("%05d,\n",int16(sig(k)));
    else
      printf("%05d,",int16(sig(k)));
    endif
  endfor

endfunction

[Te,sig_l]=trg_sig_gen(40e-3,40e-3,45.454e3,4.5454e3,32767,0);
sig_lr   =zeros(1,2*length(sig_l));
sig_lr(1:2:2*length(sig_l)) = sig_l;
plot(Te,sig_l);
print_sig("sig_trg",sig_lr);
printf("size sig_trg %d\n",length(sig_lr));
