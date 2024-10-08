#ifndef __scaled__
#define __scaled__

#ifdef __cplusplus
#include "../signal.hpp"

template <typename T>
class Scaled_signal:public Signal<T>
{
public:
    Scaled_signal(Signal<T>& s,T scale=1.0,T dilate=1.0,T translate=0.0): 
                     Signal<T>::Signal{s},s{s},scale{scale},dilate{dilate},trans{translate} {}
     
    T sample(T t) {return scale * s.sample((t-trans)/dilate);}                     

protected:
    Signal<T>& s;    
    T scale;
    T dilate;
    T trans;
};


#endif // __cplusplus
#endif //__rescale__