#ifndef __bump__
#include "signal.hpp"

template <typename T = float>
class Bump : public Signal
{
public:
    explicit Bump(T tmin,T tmax): Signal() { config(tmin,tmax);}    

    T   sample(T t)
    {
        T u = (t-trate) / dlate;
        if( t0>tmin && t0<tmax )
            return scale * exp(-1/tmin*tmax)*exp(1/((u-tmin)*(u-tmax)));
        else
            return 0;    
    };
    

private:
    T tmin;
    T tmax;

};

#endif //__bump__
