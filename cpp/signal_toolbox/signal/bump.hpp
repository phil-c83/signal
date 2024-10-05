#ifndef __bump__
#define __bump__
#include "signal.hpp"


template <typename T = float>
class Bump : public Signal<T>
{
public:
    explicit Bump(T tmin,T tmax,unsigned n) : 
            Signal<T>{n} {Signal<T>::tmin=tmin ; Signal<T>::tmax=tmax; } 
                                                  

    T sample(T t)
    {
        T u = (t-Signal<T>::trate) / Signal<T>::dlate;
        if( u>Signal<T>::tmin && u<Signal<T>::tmax )
            return Signal<T>::scale * exp( -1/(Signal<T>::tmin*Signal<T>::tmax) * exp(1/((u-Signal<T>::tmin)*(u-Signal<T>::tmax))));
        else
            return 0;    
    }
};

#endif //__bump__
