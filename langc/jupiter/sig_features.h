#ifndef SIGFEATURES
#define SIGFEATURES

#include "arm_math.h"

#define NFREQS     3U    // frequencies by set
#define NFREQSETS  4U    // number of frequency sets
#define NCHANNELS  4U    //  

typedef enum
{
    SENS_DIRECT;
    SENS_REVERSE;
    SENS_UNKNOWN;
} Sens_t;


typedef struct
{
    unsigned freqs    [NFREQS*2];    // frequencies for this set
    unsigned idx_fft  [NFREQS*2];    // index into FFT for this set
    float    dsp      [NFREQS*2];    // spectral power density
    float    snr      [NFREQS*2];    // local signal/noise for each frequency ie 2*n*abs(fft(f))^2/sum(abs(fft(f +/- n*df))^2)
    float    idx_power[NFREQS]  ;    // ascending power by frequency
    float    fft_arg  [NFREQS*2];    // arg of each fft bins
    float    phase_lag[NFREQS]  ;    // phase lag compared to reference signal
    float    time_lag [NFREQS]  ;    // time lag   
    float    arg_gap  [NFREQS]  ;    // arg gap between CFT(2*f) and FFT(2*f) 
    Sens_t   sens     [NFREQS]  ;    
} SigSetFeatures_t;

typedef struct
{
    SigSetFeatures_t ssf          [NFREQSETS]; // sig features for each set
    float            sig_power               ; // power for all sets
    float            noise_power             ; // total noise
    float            snr                     ; // SNR for
    unsigned         idx_set_power[NFREQSETS]; // ascending power by set
} SigFeatures_t;

extern SigFeatures_t sig_channel[NCHANNELS]; 

#endif //SIGFEATURES