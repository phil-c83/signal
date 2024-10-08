#ifndef __gate__
#define __gate__

#ifdef __cplusplus
#include "signal.hpp"

template <typename T = float>
class Gate : public Signal<T>
{
public:

    Gate(Dom<T> dom) : Signal<T>{dom}{}        

    T sample(T t)
    {        
        if(Signal<T>::dom.is_in(t)) 
            return 1.0;                
        else 
            return 0;    
    }   

};

#endif //__cplusplus
#endif //  __gate__