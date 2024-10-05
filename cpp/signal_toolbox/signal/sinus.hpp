#ifndef __sinus__
#define __sinus__
#include "signal.hpp"

template <typename T = float>
class Sinus : public Signal<T>
{
public:

    Sinus(unsigned n) : Signal<T>{n} {}    

    virtual void config(unsigned n,T tmin,T tmax,
                        T dilatation=T{1},T translation=T{0},T scale=T{1}) override
    {
        Signal<T>::config(n,tmin,tmax,dilatation,translation,scale);
        if(tmin == Signal<T>::MINUS_INF && tmax == Signal<T>::PLUS_INF)
            dom = false;
        else
            dom = true;    
    }

    T sample(T t)
    {
        T u = (t-Signal<T>::trate) / Signal<T>::dlate;

        if(dom == false || (u>=Signal<T>::tmin && u<=Signal<T>::tmax)) 
            return Signal<T>::scale * sin(u);                
        else 
            return 0;    
    }   

protected:    
    bool dom{false};    
};

#endif //__sinus__
