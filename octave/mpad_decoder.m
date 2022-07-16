global STRAME=40;

function v=read_corr_file(f)
  v=load("-ascii",f);
endfunction

% u64_k : 24 bits data to hash ( for mpad cpl packet )
% u64_h : 16 bits hash value u64_h = uint32(u64_h*A) >> 16
function u64_h=mpad_hash(u64_k)
  A     = uint64(0x9e377961); %2654435681 = (sqrt(5)-1)/2 * 2^32
  u64_h = bitand(bitshift(u64_k*A,-16),2^16-1);
endfunction

% data : 24 bits data to hash ( for mpad cpl packet )
% t    : 40 bits mpad cpl packet ( one complement )
function u64_t=trame_make(u64_data)
  u64_t=bitcmp(u64_data * 2^16 + mpad_hash(u64_data),40);
endfunction

function corrs=trame2corrs(u64_t)
  corrs = uint64(zeros(40,1));
  for i=0:39
    if bitand(u64_t,2^i) != 0
      corrs(i+1) = 100+rand(1,1)*50;
    else
      corrs(i+1) = rand(1,1)*30;
    endif
  endfor
endfunction

function [r,hc]=trame_check(u64_t)
  h  = bitand(u64_t,2^16-1);
  d  = bitshift(u64_t,-16);
  hc = mpad_hash(d);
  %printf("trame_check(): tr=%x d=%x h=%x h_c=%x\n",u64_t,d,h,hc);
  if hc == h
    r=0;
  else
    r=1;
  endif
endfunction

function [cmin,cmax,cavg,cvar]=trame_stat(t)
  cmin=min(t);
  cmax=max(t);
  cavg=mean(t);
  cvar=var(t,1);
endfunction

function [n_tr,tr,hash_c,test]=trame_decode(corrs,thr)

  ihash_ones  = find(corrs(1:16)  >= thr);
  idata_ones  = find(corrs(17:40) >= thr);

  %received data value
  data_v   = uint64(0);
  data_v  += sum( 2 .^ (idata_ones-1)); % set bit i to 1 if corrs(i) >= thr

  % received hash value
  hash_v   = uint64(0);
  hash_v  += sum( 2 .^ (ihash_ones-1)); % set bit i to 1 if corrs(i) >= thr
  n_tr     = bitshift(data_v,16) + hash_v; % transmited trame ie 1-complement

  data_v   = bitcmp(data_v,24);
  hash_v   = bitcmp(hash_v,16);

  tr       = bitshift(data_v,16) + hash_v;% real trame

  [test,hash_c]= trame_check(tr);
endfunction

function [MaxMin,MinMax,max_step,thr]=trame_find_threshold(corrs)
  [s_corrs,i_corrs] = sort(corrs);
  %disp(s_corrs);
  [max_step,i_max] = max(s_corrs(2:end)-s_corrs(1:end-1));% find greatest step
  MaxMin = s_corrs(i_max+1);
  MinMax = s_corrs(i_max);
  thr = (MaxMin+MinMax)/2;
endfunction


function parse_file(fname,debug)
global STRAME;
s=read_corr_file(fname);
  for k=1:length(s)-STRAME+1
    t_slice = s(k:k+STRAME-1);
    [MaxMin,MinMax,max_step,thr]=trame_find_threshold(t_slice);
    [n_tr,tr,hash_c,test]=trame_decode(t_slice,thr);
    %printf("Parse_file():  tr=%10x\n",tr);
    if (debug != 0 && thr >=10) || test==0
      %disp(t_slice');
      printf("neg_tr=%010x tr=%010x hash_c=%04x thr=%d max_step=%d MaxMin=%d MinMax=%d,\n",
              n_tr,tr,hash_c,thr,max_step,MinMax,MaxMin);
    endif
  endfor
endfunction


function test()
  t = trame_make(uint64(0x100001));
  r = trame_check(bitcmp(t,40));
  corrs=trame2corrs(t);
  disp(corrs');
  printf("***\n");
  [cmin,cmax,cavg,cvar]=trame_stat(corrs);
  [MaxMin,MinMax,max_step,thr]=trame_find_threshold(corrs);
  [n_tr,tr,hash_c,test]=trame_decode(corrs,thr);
  %[tr,data_v,hash_v,test,hc]=trame_decode(corrs,thr) ;
  if test == 0
    printf("neg_tr=%010x tr=%010x hash_c=%04x thr=%d max_step=%d MaxMin=%d,MinMax=%d\n",
           n_tr,tr,hash_c,thr,max_step,MinMax,MaxMin);
  endif
endfunction

%test();

parse_file("mesures/mpad-transfo.log",1);

