#ifndef __dc__
#define __dc__

#ifdef __cplusplus
#include "signal.hpp"

template <typename T = float>
class Dc : public Signal<T>
{
public:

    Dc(Dom<T> dom,T dc) : 
                Signal<T>{dom},dc{dc}{}        

    T sample(T t)
    {        
        if(Signal<T>::dom.is_in(t)) 
            return dc;                
        else 
            return 0;    
    }   

protected:        
    T dc;    
};

#endif //__cplusplus
#endif //  __dc__