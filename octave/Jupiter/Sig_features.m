## Author: philippe coste <phil@phil-debian-pc>
## Created: 2022-09-29

function SigSetFeatures = Sig_features(s,FFT,Fe,SigSetFreqs,tol,dbg)
  [nFreqs,nSet] = size(SigSetFreqs); 
  SigSetFeatures.nFreqs = nFreqs;
  SigSetFeatures.nSets  = nSet;
  N = length(FFT); 
  NoiseIdx = 1:N/2;
  % all frequency signal indexes 
  SigFreqs = reshape(SigSetFreqs,nFreqs*nSet,1);
  % all frequency signals with harmonique 1  
  SigFreqs = [SigFreqs;2*SigFreqs];
  SigIdx   = Sig_FFT_index(SigFreqs,Fe,N);
  % all non signal indexes ie noise indexes
  NoiseIdx = setdiff(NoiseIdx,SigIdx);
  for i=1:nSet
    % index f_i and 2*f_i
    FreqSet = [ SigSetFreqs(:,i);2*SigSetFreqs(:,i) ];
    FreqIdx = Sig_FFT_index(FreqSet,Fe,N);  
    % power and S/N 
    [dsp,SN]=Sig_dsp_SN(FFT,FreqIdx,1);
    SigSetFeatures.SigSets(i).Idx       = FreqIdx;
    SigSetFeatures.SigSets(i).Freqs     = FreqSet;
    SigSetFeatures.SigSets(i).Dsp       = dsp;
    SigSetFeatures.SigSets(i).SetPower  = sum(dsp);
    SigSetFeatures.SigSets(i).FreqSN    = SN;
    % sort with increasing power for fondamentals
    [sv,iv] = sort(SigSetFeatures.SigSets(i).Dsp(1:nFreqs));     
    SigSetFeatures.SigSets(i).iSortH0   = iv;
    % sort with increasing power for harmonics 1
    [sv,iv] = sort(SigSetFeatures.SigSets(i).Dsp(nFreqs+1:nFreqs*2));     
    SigSetFeatures.SigSets(i).iSortH1   = iv+nFreqs;    
    % seek signals sens
    T  = 1 ./ SigSetFeatures.SigSets(i).Freqs(1:nFreqs,1);
    T1 = 2 * T/5;
    FFT_arg_f   = arg(FFT(FreqIdx(1:nFreqs)));
    FFT_arg_2f  = arg(FFT(FreqIdx(nFreqs+1:end)));
    [sens,gap,lag,phi,CFT_arg_2f]=Sig_sens(FFT_arg_f,FFT_arg_2f,
                                           SigSetFeatures.SigSets(i).Freqs(1:nFreqs,1),
                                           Fe,T,T1,tol);                                        
    SigSetFeatures.SigSets(i).Gap       = gap;
    SigSetFeatures.SigSets(i).Sens      = sens;
    SigSetFeatures.SigSets(i).Lag       = lag;
    SigSetFeatures.SigSets(i).Phi       = phi;   
  endfor
  % global signal/noise power and S/N
  SigSetFeatures.SigPower      = sum(Sig_dsp(FFT,SigIdx));
  SigSetFeatures.NoisePower    = sum(Sig_dsp(FFT,NoiseIdx));
  SigSetFeatures.SN            = SigSetFeatures.SigPower / SigSetFeatures.NoisePower;  
  [sp,ip]                      = sort([SigSetFeatures.SigSets(1:nSet).SetPower]);  
  SigSetFeatures.SetPoweriSort = ip;  
  
  if(dbg)
     Sig_plot(s,0,FFT,Fe,2000);  
     Sig_print_Sig(SigSetFeatures);
     for i=1:nSet  
        Sig_print_SigSetFeatures(SigSetFeatures.SigSets(i));
     endfor      
  endif
endfunction

function Sig_print_Sig(sig)
  printf("SigPower : %7.3f NoisePower : %7.3f S/N : %7.3f (%5.2fdB)\n",
          sig.SigPower,sig.NoisePower,sig.SN,20*log10(sig.SN));           
  printf("SetPower :%7d %7d %7d %7d\n",sig.SetPoweriSort);
  printf("nSets    :%7d\n",sig.nSets);
  printf("nFreq    :%7d\n\n",sig.nFreqs);
          
endfunction      

function Sig_print_SigSetFeatures(ssf)    
  printf("SetFreqs : %7.1f %7.1f %7.1f %7.1f %7.1f %7.1f\n",ssf.Freqs);
  printf("FreqIdx  : %7d %7d %7d %7d %7d %7d\n",ssf.Idx);
  printf("Powers   : %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\n",ssf.Dsp);
  printf("FreqSN   : %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f\n",ssf.FreqSN);
  printf("OrderH0  : %7d %7d %7d\n",ssf.iSortH0);
  printf("OrderH1  : %7d %7d %7d\n",ssf.iSortH1);
  printf("PhaseLag : %7.2f %7.2f %7.2f\n",ssf.Phi);
  printf("TimeLag  : %7.5f %7.5f %7.5f\n",ssf.Lag);  
  printf("CFTGap   : %7.2f %7.2f %7.2f\n",ssf.Gap);
  printf("Sens     : %7d %7d %7d\n",ssf.Sens); 
  printf("SetPower : %7.3f\n\n",ssf.SetPower); 
endfunction

% index for a given frequency
function idx=Sig_FFT_index(f,Fe,N)
  k = round(abs(N*f ./ Fe));
  if ( f>=0 )
    idx = k+1;
  else % f<0 
    idx = N-k+1;  
  endif
endfunction

%{
Reference signal :
x(t) = A*(rect((t-T1/2)/T1)-T1/(T-T1)*rect((t-(T+T1)/2)/(T-T1)))
sinc = sin(pi*x)/(pi*x)
CFT{x(t)}(f)   = A*T1*{exp(-i*pi*T1*f)*sinc(T1*f) - 
                       exp(-i*pi*(T+T1)*f)*sinc((T-T1)*f)}
CFT{x(t-a)}(f) = exp(-i*2*pi*a*f) * CFT{x(t)}(f)
   
     2*pi*f*a  = arg(CFT{x(t)}(f)) - arg(CFT{x(t-a)}(f));    
%}
% analytic expr of X(f) ie CFT(x(t-a))
function z=Sig_ref_CFT(a,T1,T,f)
  z = exp(-i*2*pi*(a.*f)) .* (
        exp(-i*pi*(T1.*f)) .* sinc(T1.*f) - 
        exp(-i*pi*((T+T1).*f)) .* sinc((T-T1).*f) );  
endfunction 

% return time lag a (0 <= a <= 1/f) for phase lag phi   
function a=Sig_Phase2Lag(phi,f)  
  i_n = find(phi <  0);
  i_p = find(phi >= 0);
  a   = zeros(size(f));
  a(i_n) = (2*pi+phi(i_n)) ./ (2*pi*f(i_n));
  a(i_p) = phi(i_p) ./ (2*pi*f(i_p));  
endfunction 

% Phase shift 'phi" and lag 'a' computed from CFT    
function [a,phi]=Sig_lag(T1,T,f,FFT_arg_f)     
  phi = arg(Sig_ref_CFT(0,T1,T,f))-FFT_arg_f;    
  a   = Sig_Phase2Lag(phi,f);  
endfunction


%{
compute power,S/B for all frequencies signal index 'idx'
S/B(f_i) = 2*n*power(f_i)/sum(power(f_k))
for abs(f_k - f_i) < n*df ,  f_k != f_i
FFT   : signal fft
idx   : frequency index col vector around which compute S/N
n     : index span for noise computation
SN    : col vector S/N  
Pa    : col vector power for fft(idx)
%}
function [Pa,SN]=Sig_dsp_SN(FFT,idx,n)
  [rows,cols] = size(idx);  
  N           = length(FFT);
  for k=1:2*n+1  
    % index matrix where each row has index 
    % for 2*n+1 signal frequencies around f_i for S/B computation
    % idx_SB(i,k) for f_k=f_i+(idx+k-(n+1))*df, abs(f_k - f_i) < n*df 
    idx_SB(1:rows,k) = idx+k-(n+1);     
  endfor  
  for k=1:rows % compute power for all f_k  
    ix     = idx_SB(k,:)';
    P      = Sig_dsp(FFT,ix);        
    Pnoise = 1/(2*n)*(sum(P(1:n))+sum(P(n+2:2*n+1)));% power noise around f_i
    SN(k,1)= P(n+1) / Pnoise; % S/B for f_i  
    Pa(k,1)= P(n+1);
  endfor    
endfunction

% power for FFT(idx)
function P=Sig_dsp(FFT,idx)
  N = length(FFT);
  P = 2/N^2 * abs((FFT(idx) .* conj(FFT(idx))));    
endfunction


function [sens,gap,lag,phi,CFT_arg_2f]=Sig_sens(FFT_arg_f,FFT_arg_2f,f,Fe,T,T1,tol)    
  % lag computation 'a' for s(t-a)  
  [lag,phi] = Sig_lag(T1,T,f,FFT_arg_f);   
  % arg(CFT{s(t-a)}(2*f)) computation with lag 'a'
  z = Sig_ref_CFT(lag,T1,T,2*f);  
  CFT_arg_2f = arg(z); % CFT predicted arg for 2*f
  % compare with FFT arg :  -2*pi <= e2f <= 2*pi
  e2f = FFT_arg_2f - CFT_arg_2f;
  gap = e2f;  
  in  = find(e2f < 0); 
  e2f(in) += 2*pi; % 0 <= e2f <= 2*pi
  % direct sens
  id0 = find(e2f < tol);
  id1 = find(e2f > 2*pi-tol);
  % reverse sens
  ir1 = find(abs(e2f-pi) < tol);  
  sens = zeros(size(f));
  sens(id0) = 1;
  sens(id1) = 1;
  sens(ir1) = -1;  
endfunction  

% plot s(t) and abs/arg(FFT(s(t))) s(0)=f(t-T0)
function Sig_plot(s,T0,FFT,Fe,FMAX)  
  N  = length(FFT);  
  dF = Fe/N;
  idx_max=round(FMAX/dF);
  idx=(0:idx_max);
  ndF = idx*dF;
  nTe = T0:1/Fe:T0+1/Fe*(N-1);
  
  figure;
  subplot(3,1,1);
  plot(nTe,s,"--pk;sig;");
  subplot(3,1,2);
  plot(ndF,2*abs(FFT(idx+1))/N,"--pb;mods;");
  subplot(3,1,3);
  plot(ndF,arg(FFT(idx+1)),"--pg;args;");  
  %figure;
  %plot3(ndF,FFT);  
endfunction

%function Sig_trace();
