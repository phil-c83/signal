#ifndef __add__
#define __add__

#ifdef __cplusplus
#include "../signal.hpp"

template <typename T>
class Add_signal:public Signal<T>
{
public:
    // compute s1*s2(t)   
    Add_signal(Signal<T>& s1,Signal<T>& s2): Signal<T>::Signal{s1},sig1{s1},sig2{s2} {}
                
     
    T sample(T t) {return sig1.sample(t) + sig2.sample(t);}
    
protected:
    Signal<T>& sig1;
    Signal<T>& sig2;       
};

#endif // __cplusplus
#endif //__add__