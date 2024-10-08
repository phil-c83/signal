#ifndef __signal__
#define __signal__

#ifdef __cplusplus
#include <cmath>
#include <numbers>
#include <limits>


template <typename T>
class Dom
{
public:     

    Dom(T tmin=-std::numeric_limits<T>::infinity(),T tmax=std::numeric_limits<T>::infinity()) : 
            tmin{tmin},tmax{tmax} {};
    bool is_in(T t) {return t>=tmin && t<=tmax;}
    bool is_in_open(T t) {return t>tmin && t<tmax;}
    T tmin; 
    T tmax;     
};

template <typename T = float>
class Signal 
{
public:      

    Signal(const Dom<T>& dom) : dom{dom} {};
    Signal(const Signal<T>& s) : dom{s.dom} {};
    virtual T sample(T t)=0; //  each signal vanish out of his domain     
    void generate(T t0,T Fe,T v[],const unsigned n);  // generate a signal vector in v  
    void generate_debug(T t0,T Fe,T v[],T Te[],const unsigned n);  // generate a signal vector in v    
    ~Signal() {};

protected:    
    Dom<T> dom;            
};

template <typename T>
void Signal<T>::generate(T t0,T Fe,T v[],const unsigned n)
{   
    T t{t0};
    for( unsigned k=0 ; k<n ; ++k, t+=1/Fe )
        v[k] = sample(t); 
}

template <typename T>
void Signal<T>::generate_debug(T t0,T Fe,T Te[],T v[],const unsigned n)
{   
    T t{t0};
    for( unsigned k=0 ; k<n ; ++k, t+=1/Fe )
    {
        v[k] = sample(t);
        Te[k] = t;
    }
}

#endif //__cplusplus

#endif // __signal__