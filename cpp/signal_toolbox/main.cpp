#include <fstream>
#include <iostream>
#include "signal/sinus.hpp"
#include "signal/bump.hpp"
#include "signal/ramp.hpp"

const float Fe = 100.0f;
const float t0=0.0f;
const float f0=1e3f;
const float f1=5e3f; 

template <typename T>
static void print_mfile(const char *fname,const T v[], const unsigned n)
{
    std::ofstream ost {fname}; 
    if (!ost) 
        std::cerr << "can't open output file " << fname;

    for(unsigned i=0 ; i<n ; ++i)
    { 
        ost << v[i] << " ";    
    }
    ost << "\n";    
}


int main()
{
    const unsigned nitems{1000U};
    float v1[nitems];
    float v2[nitems];
    float v3[nitems];

    Sinus<float> sig_sin(nitems);   
    sig_sin.generate(t0,Fe,v1,nitems);
    print_mfile("sinus.m",v1,nitems);

    Bump<float> sig_bump(0.1f,0.5f,nitems);
    sig_bump.generate(t0,Fe,v2,nitems);
    print_mfile("bump.m",v2,nitems);

    Ramp<float> sig_ramp(0.5,-1.0,nitems);
    sig_ramp.generate(t0,Fe,v3,nitems);
    print_mfile("ramp.m",v3,nitems);






    /*

    bump_u16(v1,t0,t1,Fe);
    FILE *fid = fopen("bump_16.m","w");
    if( fid == NULL )
        return(1);
    print_u16_mfile(fid,v1,nitems);
    fclose(fid);

    linear_sweep(v2,f0,f1,t0,t1,Fe);
    fid = fopen("sweep_16.m","w");
    if( fid == NULL )
        return(1);
    print_u16_mfile(fid,v2,nitems);
    fclose(fid);

    prod_u16(v1,v2,v3,nitems);
    fid = fopen("sig_16.m","w");
    if( fid == NULL )
        return(1);
    print_u16_mfile(fid,v3,nitems);
    */

    
}