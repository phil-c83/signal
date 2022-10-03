## Copyright (C) 2022 philippe coste
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{retval} =} Sig_features (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: philippe coste <phil@phil-debian-pc>
## Created: 2022-09-29

function SigSetFeatures = Sig_features(s,FFT,Fe,SigSetFreqs,tol,dbg)
  [nFreqs,nSet] = size(SigSetFreqs); 
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
    [Pa,SN]=Sig_Pa_SN(FFT,FreqIdx,1);
    SigSetFeatures.SigSets(i).Idx    = FreqIdx;
    SigSetFeatures.SigSets(i).Freqs  = FreqSet;
    SigSetFeatures.SigSets(i).Pa     = Pa;
    SigSetFeatures.SigSets(i).FreqSN = SN;
    % sort with decreasing power (pb with 'ascend')
    [sv,iv] = sort(SigSetFeatures.SigSets(i).Pa);    
    SigSetFeatures.SigSets(i).iSort = iv;    
    % seek signals sens
    T  = 1 ./ SigSetFeatures.SigSets(i).Freqs(1:nFreqs,1);
    T1 = 2 * T/5;
    FFT_arg_f   = arg(FFT(FreqIdx(1:nFreqs)));
    FFT_arg_2f  = arg(FFT(FreqIdx(nFreqs+1:end)));
    [sens,gap,lag,phi,CFT_arg_2f]=Sig_sens(FFT_arg_f,FFT_arg_2f,
                                           SigSetFeatures.SigSets(i).Freqs(1:nFreqs,1),
                                           Fe,T,T1,tol);                                        
    SigSetFeatures.SigSets(i).gap  = gap;
    SigSetFeatures.SigSets(i).sens = sens;
    SigSetFeatures.SigSets(i).lag  = lag;
    SigSetFeatures.SigSets(i).phi  = phi;   
  endfor
  
  SigSetFeatures.SigPower   = 2/N^2 * sum(FFT(SigIdx) .* conj(FFT(SigIdx)) );
  SigSetFeatures.NoisePower = 2/N^2 * sum(FFT(NoiseIdx) .* FFT(NoiseIdx));
  SigSetFeatures.SN         = SigSetFeatures.SigPower / SigSetFeatures.NoisePower;  
  
  if(dbg)
     Sig_plot(s,0,FFT,Fe,2000);  
     Sig_print_Sig(SigSetFeatures);
     for i=1:nSet  
        Sig_print_SigSetFeatures(SigSetFeatures.SigSets(i));
     endfor      
  endif
endfunction

function Sig_print_Sig(sig)
  printf("SigPower=%7.3f NoisePower=%7.3f SigS/N=%7.3f (%5.2fdB)\n",
          sig.SigPower,sig.NoisePower,sig.SN,20*log10(sig.SN));  
endfunction      
function Sig_print_SigSetFeatures(ssf)    
  printf("SigSet : %7.1f %7.1f %7.1f %7.1f %7.1f %7.1f\n",ssf.Freqs);
  printf("FreqIdx: %7d %7d %7d %7d %7d %7d\n",ssf.Idx);
  printf("Powers : %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\n",ssf.Pa);
  printf("FreqSN : %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f\n",ssf.FreqSN);
  printf("Order  : %7d %7d %7d %7d %7d %7d\n",ssf.iSort);
  printf("Lag    : %7.5f %7.5f %7.5f\n",ssf.lag);
  printf("Phase  : %7.2f %7.2f %7.2f\n",ssf.phi);
  printf("Gap    : %7.2f %7.2f %7.2f\n",ssf.gap);
  printf("Sens   : %7d %7d %7d\n\n",ssf.sens);  
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

% return a, lag for phase shift phi, 0 <= a <= 1/f   
function a=Sig_Phase2Lag(phi,f)
  if(phi<0)
    a  = (2*pi+phi) ./ (2*pi*f);     
  else
    a  = phi ./ (2*pi*f);
  endif   
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
function [Pa,SN]=Sig_Pa_SN(FFT,idx,n)
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
    P      = Sig_power(FFT,ix);        
    Pnoise = 1/(2*n)*(sum(P(1:n))+sum(P(n+2:2*n+1)));% power noise around f_i
    SN(k,1)= P(n+1) / Pnoise; % S/B for f_i  
    Pa(k,1)= P(n+1);
  endfor    
endfunction

% power for FFT(idx)
function P=Sig_power(FFT,idx)
  N = length(FFT);
  P = 2/N^2 * (FFT(idx) .* conj(FFT(idx)));    
endfunction


function [sens,gap,lag,phi,CFT_arg_2f]=Sig_sens(FFT_arg_f,FFT_arg_2f,f,Fe,T,T1,tol)    
  % lag computation 'a' for s(t-a)  
  [lag,phi] = Sig_lag(T1,T,f,FFT_arg_f);   
  % arg(CFT{s(t-a)}(2*f)) computation with lag 'a'
  z = Sig_ref_CFT(lag,T1,T,2*f);  
  CFT_arg_2f = arg(z); % predicted arg for 2*f
  % compare with ...
  e2f = FFT_arg_2f - CFT_arg_2f;
  % direct sens
  i0 = find(abs(e2f) < tol);
  % reverse sens
  i1 = find(abs(abs(e2f)-pi) < tol);
  sens = zeros(length(f),1);
  sens(i0) = 1;
  sens(i1) = -1;
  gap = e2f;  
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
