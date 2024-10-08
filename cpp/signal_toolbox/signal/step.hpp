#ifndef __step__
#define __step__

#ifdef __cplusplus
#include "signal.hpp"

template <typename T = float>
class Step : public Signal<T>
{
public:

    Step(Dom<T> dom) : Signal<T>{dom}{}        

    T sample(T t)
    {        
        if(t>=0 && Signal<T>::dom.is_in(t)) 
            return 1.0;                
        else 
            return 0;    
    } 
};

#endif //__cplusplus
#endif //  __step__