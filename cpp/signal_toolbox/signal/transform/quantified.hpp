#ifndef __quantified__
#define __quantified__

#ifdef __cplusplus
#include "../signal.hpp"

template <typename T>
class Quantified_signal:public Signal<T>
{
public:
    Quantified_signal(Signal<T>& s,unsigned nbits): 
                     Signal<T>::Signal{s},s{s},qmax{1U<<(nbits-1)} {}
     
    T sample(T t) {return s.sample(t)*(qmax-1)+qmax;}                     

protected:
    Signal<T>& s;    
    unsigned qmax;    
};

#endif // __cplusplus
#endif //__quantified__