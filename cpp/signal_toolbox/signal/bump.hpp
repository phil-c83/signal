#ifndef __bump__
#define __bump__

#ifdef __cplusplus

#include "signal.hpp"

template <typename T = float>
class Bump : public Signal<T>
{
using Signal<T>::dom;
public:
    Bump(Dom<T>& dom) : Signal<T>{dom}
    { 
        Dom<T> ndom{dom};
        if (ndom.tmin == 0.0)
            ndom.tmin = std::numeric_limits<T>::epsilon();
        else if(ndom.tmax == 0.0)
            ndom.tmax = std::numeric_limits<T>::epsilon();
        
        Signal<T>::dom.tmin = ndom.tmin;
        Signal<T>::dom.tmax = ndom.tmax;
        // d/dt bump((a+b)/2) = 0, bump((a+b)/2) = exp(-1/((b-a)/2)^2)
        norm_factor = exp(1.0/pow((ndom.tmax - ndom.tmin)/2.0,2.0));
        std::cout << "norm =" << norm_factor << std::endl;
    }                                                   

    T sample(T t)
    {        
        if(dom.is_in_open(t))
            return  norm_factor * exp(1/((t-dom.tmin)*(t-dom.tmax))) ;
        else
            return 0.0;    
    }
protected:
    T norm_factor;    
};
#endif //__cplusplus
#endif //__bump__
