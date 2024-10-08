#ifndef __combine__
#define __combine__

#ifdef __cplusplus
#include "../signal.hpp"

template <typename T>
class Combine_signal:public Signal<T>
{
public:
    // compute (s1 op s2)(t)   
    Combine_signal(Signal<T>& s1,Signal<T>& s2,T op(Signal<T>& s1,Signal<T>& s2)): 
                     sig1{s1},sig2{s2},op{op} {}
     
    T sample(T t) {return op(sig1.sample(t),sig2.sample(t));}                     

protected:
    Signal<T>& sig1;
    Signal<T>& sig2;
    T (*op)(Signal<T>& s1,Signal<T>& s2);    
};


#endif // __cplusplus
#endif //__combine__