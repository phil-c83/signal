#ifndef __ramp__
#define __ramp__

#ifdef __cplusplus

#include "signal.hpp"

template <typename T = float>
class Ramp : public Signal<T>
{
public:

    Ramp(Dom<T> dom,T slope=1.0, T intercept=0.0) : 
                Signal<T>{dom},slope{slope}, intercept{intercept} {}        

    T sample(T t)
    {        
        if(Signal<T>::dom.is_in(t)) 
            return (slope * t + intercept);                
        else 
            return 0;    
    }   

protected:        
    T slope;
    T intercept;    
};

#endif //  __cplusplus
#endif //  __ramp__