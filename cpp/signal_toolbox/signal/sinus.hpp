#ifndef __sinus__
#define __sinus__

#ifdef __cplusplus
#include "signal.hpp"

template <typename T = float>
class Sinus : public Signal<T>
{
public:

    Sinus(Dom<T> dom) : Signal<T>{dom} {}        

    T sample(T t)
    {
        if(Signal<T>::dom.is_in(t))
            return sin(t);                
        else 
            return 0.0;    
    }    
};

#endif //__cplusplus
#endif //__sinus__
