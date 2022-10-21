#include "sig_features.h"
#include "sig_math.h"
/*
  Reference signal :
  x(t) = A*(rect((t-T1/2)/T1)-T1/(T-T1)*rect((t-(T+T1)/2)/(T-T1)))
  sinc = sin(pi*x)/(pi*x)
  CFT{x(t)}(f)   = A*T1*{exp(-i*pi*T1*f)*sinc(T1*f) - 
                         exp(-i*pi*(T+T1)*f)*sinc((T-T1)*f)}
  CFT{x(t-a)}(f) = exp(-i*2*pi*a*f) * CFT{x(t)}(f)
    
  2*pi*f*a  = arg(CFT{x(t)}(f)) - arg(CFT{x(t-a)}(f));    
*/
static unsigned sig_rfft_index(unsigned f, unsigned Fe,unsigned N)
{
    return (N*f)/Fe;
}

/*
    analytic expr of X(f) ie CFT(x(t-a))
    z = exp(-i*2*pi*(a.*f)) .* (
        exp(-i*pi*(T1.*f)) .* sinc(T1.*f) - 
        exp(-i*pi*((T+T1).*f)) .* sinc((T-T1).*f) ); 
*/
void sig_ref_CFT(float32_t a,float32_t T1,float32_t T, float32_t f, 
                 float32_t *Re,float32_t *Im)
{
    float32_t re1_z,im1_z,re2_z,im2_z,re3_z,im3_z,sc;
    sigm_cexp(-2*M_PI*a*f,&re_z,&im_z);
    sigm_cexp(-M_PI*T1*f,&re2_z,&im2_z);
    sc = sinc(T1*f);
    re2_z *= sc;
    im2_z *= sc;
    sigm_cexp(-M_PI*(T+T1)*f,&re3_z,&im3_z);
    sc = sigm_sinc((T-T1)*f);
    re3_z *= sc;
    im3_z *= sc;

    *Re  = re1_z * (re2_z - re3_z);
    *Im  = im1_z * (im2_z - im2_z);
}

// time lag 'a' (0 <= a < 1/f) for phase lag 
float32_t sig_time_lag(float32_t phase_lag,float32_t f)
{
    if( phase_lag < 0.0 )
        return (2*M_PI + phase_lag) / (2*M_PI*f);
    else
        return phase_lag / (2*M_PI*f);
}

// evaluate time lag ie 'a' and corresponding phase lag with CFT(sig_ref(t-a)) 
// knowing arg(fft(f)).
void sig_lags(float32_t T1,float32_t T,float32_t f,float32_t fft_arg,
              float32_t *phase_lag,float32_t *time_lag)
{
    float32_t z_re,z_im;
    sig_ref_CFT(0.0,T1,T,f,&z_re,&z_im);
    *phase_lag = sigm_carg(z_re,z_im);
    *time_lag  = sig_time_lag(*phase_lag,f);
}

/*
* compute global sig power/noise power/snr; dsp, snr around each rfft frequencies 
* designed par indexes 'idx' 
* rfft: real/imag vector ie 2 floats for a complex value
* idx         : indexes of signal components
* dsp         : dsp for each signal components
* l_snr       : local SNR for each signal components
* n           : size of each vector
* ndf         : band width aroound f_i
* sig_power   : total power for signal 
* noise_power : total noise power
* g_snr       : global SNR  
*/
void sig_dsp_snr(float32_t *rfft,unsigned idx[],float32_t dsp[],float32_t l_snr[],
                 unsigned n,unsigned ndf,float32_t *sig_power,float32_t *noise_power, 
                 float32_t *g_snr)
{
    unsigned i=0;
    float32_t np,fp1,fp2;
    *sig_power = *noise_power = 0.0;

    for(unsigned k=0 ; k<n ; ++k)
    {
        if( k == idx[i] ) // signal component
        {
          fp1 = rfft[2*k];   // real part
          fp2 = rfft[2*k+1]; // imag part
          dsp[i] = fp1*fp1 + fp2*fp2; 
          *sig_power += dsp[i];

          np = 0.0;
          for( unsigned j=1 ; j<=ndf ; ++j)
          { // noise power around f_i
              fp1 = rfft[2*(k+j)];
              fp2 = rfft[2*(k+j)+1]
              np += fp1*fp1 + fp2*fp2; 
              fp1 = rfft[2*(k-j)];
              fp2 = rfft[2*(k-j)+1]
              np += fp1*fp1 + fp2*fp2; 
          }
          l_snr[i] = 2*ndf*dsp[i] / np;
          ++i; // next signal component
        }  
        else  // noise component
        {
            fp1 = rfft[2*k];
            fp2 = rfft[2*k+1];
            *noise_power += fp1*fp1 + fp2*dp2;
        } 
    }

    *g_snr = *sig_power / *noise_power;
}

