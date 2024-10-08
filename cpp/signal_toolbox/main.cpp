#include <fstream>
#include <iostream>
#include "signal/dc.hpp"
#include "signal/sinus.hpp"
#include "signal/bump.hpp"
#include "signal/ramp.hpp"
#include "signal/sinsweep.hpp"
#include "signal/gate.hpp"
#include "signal/combine/mult.hpp"
#include "signal/combine/compose.hpp"
#include "signal/tranform/scaled.hpp"
#include "signal/tranform/quantified.hpp"

const float Fe = 100.0f;
const float t0 = 0.0f; 

template <typename T>
static void print_mfile(const char *fname,const T Te[],const T v[], const unsigned n)
{
    std::ofstream ost {fname}; 
    if (!ost) 
        std::cerr << "can't open output file " << fname;

    for(unsigned i=0 ; i<n ; ++i)
    { 
        ost << Te[i] << " " << v[i] << std::endl;    
    }
    ost << std::endl;    
}


int main()
{
    const unsigned nitems{1000U};
    float v[nitems];
    float Te[nitems];
    
    /*
    Dom<float> dom1{-std::numeric_limits<float>::infinity(),std::numeric_limits<float>::infinity()};


    Dc<float> dc(dom1,5.0);
    dc.generate_debug(t0,Fe,Te,v,nitems);
    print_mfile("dc.m",Te,v,nitems);

    Dom<float> dom5{-0.5,0.5};
    Gate<float> gate(dom5);
    gate.generate_debug(-1.0,Fe,Te,v,nitems);
    print_mfile("gate.m",Te,v,nitems);

    Sinus<float> sig_sin(dom1);   
    sig_sin.generate_debug(t0,Fe,Te,v,nitems);
    print_mfile("sinus.m",Te,v,nitems);
    

    Dom<float> dom3 = dom1;
    Ramp<float> sig_ramp(dom3);
    sig_ramp.generate_debug(t0,Fe,Te,v,nitems);
    print_mfile("ramp.m",Te,v,nitems);

    
    Dom<float> dom2{0.0,2.0};

    Bump<float> bump(dom2);
    bump.generate_debug(0.0,1000.0,Te,v,nitems);
    print_mfile("bump.m",Te,v,nitems);

    Scaled_signal<float> sbump(bump,2.0,1.0,0.0);
    sbump.generate_debug(0.0,500.0,Te,v,nitems);
    print_mfile("sbump.m",Te,v,nitems);

    Quantified_signal<float> qbump(bump,12U);
    qbump.generate_debug(0.0,1000.0,Te,v,nitems);
    print_mfile("qbump.m",Te,v,nitems);
    

    Dom<float> dom{0.0,1.0};

    Bump<float> bump(dom);
    bump.generate_debug(0.0,1000.0,Te,v,nitems);
    print_mfile("bump.m",Te,v,nitems);

    Sinsweep<float> ssw(dom,1.0,10.0);
    ssw.generate_debug(0.0,1000.0,Te,v,nitems);
    print_mfile("ssw.m",Te,v,nitems);

    Mult_signal<float> swbump(ssw,bump);
    swbump.generate_debug(0.0,1000.0,Te,v,nitems);
    print_mfile("swbump.m",Te,v,nitems);
    
    Quantified_signal<float> qswbump(swbump,12U);
    qswbump.generate_debug(0.0,1000.0,Te,v,nitems);
    print_mfile("qswbump.m",Te,v,nitems);
    */

  // signal mpad
    const unsigned mpad_items = 100U;
    const float    mpad_Fe    = 50e3;

    Dom<float> dom_mpad{0.0,2e-3};
    Ramp<float> ramp_mpad(dom_mpad,1.0/2e-3,0.0);
    ramp_mpad.generate_debug(0.0,mpad_Fe,Te,v,mpad_items);
    print_mfile("ramp_mpad.m",Te,v,mpad_items);   

    Dom<float> dom{0.0,1.0};
    Bump<float> bump_mpad(dom);
    bump_mpad.generate_debug(0.0,mpad_Fe,Te,v,mpad_items);
    print_mfile("bump_mpad.m",Te,v,mpad_items);   

    Sinsweep<float> sw_mpad(dom,1.0,5.0);
    sw_mpad.generate_debug(0.0,mpad_Fe,Te,v,mpad_items);
    print_mfile("sw_mpad.m",Te,v,mpad_items);   

    Mult_signal<float> swbump_mpad(sw_mpad,bump_mpad);
    Compose_signal<float> dilated_swbump_mapd(swbump_mpad,ramp_mpad);
    Quantified_signal<float> qdilated_swbump_mapd(dilated_swbump_mapd,12U);

    

    swbump_mpad.generate_debug(0.0,mpad_Fe,Te,v,mpad_items); 
    print_mfile("swbump_mpad.m",Te,v,mpad_items);   

    dilated_swbump_mapd.generate_debug(0.0,mpad_Fe,Te,v,mpad_items);
    print_mfile("dssw_mpad.m",Te,v,mpad_items);    
    
    qdilated_swbump_mapd.generate_debug(0.0,mpad_Fe,Te,v,mpad_items);    
    print_mfile("qdssw_mpad.m",Te,v,mpad_items);    
      
}