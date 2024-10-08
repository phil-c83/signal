#ifndef __sinsweep__
#define __sinsweep__
#include "signal.hpp"

template <typename T = float>
class Sinsweep : public Signal<T>
{
public:
using Signal<T>::dom;

    Sinsweep(Dom<T> dom,T f0, T f1) : Signal<T>{dom},f0{f0},f1{f1}, a{(f1-f0) /(dom.tmax-dom.tmin)} {}        

    T sample(T t)
    {   // f(t) = sin(pi*(a*t + 2*f0)*t) 
        if(Signal<T>::dom.is_in(t))
            return sin(std::numbers::pi_v<T> * (a*t+2*f0)*t);                
        else 
            return 0.0;    
    }    
    protected:
    T f0; // start frequency
    T f1; // stop frequency
    T a ; // f1-f0/dom ie time frequency change
};

#endif //__sinsweep__