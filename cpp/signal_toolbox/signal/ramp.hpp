#ifndef __ramp__
#define __ramp__

#include "signal.hpp"

template <typename T = float>
class Ramp : public Signal<T>
{
public:

    explicit Ramp(T slope, T intercept,unsigned n) : Signal<T>{n} 
    {
        Ramp::slope = slope;
        Ramp::intercept = intercept;
    }    

    void config(T slope,T intercept,unsigned n,T tmin,
                T tmax,T dilatation=T{1},T translation=T{0},T scale=T{1}) 
    {
        Signal<T>::config(n,tmin,tmax,dilatation,translation,scale);
        Ramp<T>::slope = slope;
        Ramp<T>::intercept = intercept;
        if(tmin == Signal<T>::MINUS_INF && tmax == Signal<T>::PLUS_INF)
            dom = false;
        else
            dom = true;    
    }

    T sample(T t)
    {
        T u = (t-Signal<T>::trate) / Signal<T>::dlate;

        if(dom == false || (u>=Signal<T>::tmin && u<=Signal<T>::tmax)) 
            return Signal<T>::scale * (slope * u + intercept);                
        else 
            return 0;    
    }   

protected:    
    bool dom{false};
    T slope{1.0};
    T intercept{0.0};    
};


#endif //  __ramp__