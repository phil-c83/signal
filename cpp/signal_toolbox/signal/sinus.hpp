#ifndef __sinus__
#include "signal.hpp"

template <typename T = float>
class Sinus : public Signal<T>
{
public:
    explicit Sinus(): Signal<T>() {}    

    void config(T tmin,T tmax,T dilatation=T{1},T translation=T{0},T scale=T{1})
    {
        Signal<T>::config(tmin,tmax);
        if(tmin == - std::numeric_limits<T>::infinity && tmax == + std::numeric_limits<T>::infinity)
            dom = false;
        else
            dom = true;    
    }

    T sample(T t)
    {
        T u = (t-Signal<T>::trate) / Signal<T>::dlate;

        if(dom && t>=Signal<T>::tmin && t<=Signal<T>::tmax)
            return sin(u);        
        if(t>tmin && t<tmax)
            return Signal<T>::scale * exp(-1/a*b)*exp(1/((u-tmin)*(u-tmax)));
        else
            return 0;    
    };

    void generate(T t0,T Fe,T v[],const unsigned n) { Signal<T>::generate(t0,Fe,v,n); }

protected:
    T tmin = T{- std::numeric_limits<T>::infinity};
    T tmax = T{+ std::numeric_limits<T>::infinity};
    bool dom = false;    
};

#endif //__bump__
