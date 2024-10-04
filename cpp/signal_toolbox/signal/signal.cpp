#ifdef __cplusplus
#include <cmath>
#include <cstdint>
#include "signal.hpp"


template <typename T>
void Signal<T>::generate(T t0,T Fe,T v[],const unsigned n)
{
    iter.init(t0,Fe,n);
    for( unsigned k=0 ; iter.next() == true; ++k)
        v[k] = iter.get();    
}

template <typename T>
void Signal<T>::mult(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)
{
    iter.init(t0,Fe,n);
    s.iter.init(t0,Fe,n);

    for( unsigned k=0 ; s.iter.next() == true && iter.next() == true; ++k)
        v[k] = iter.get() * s.iter.get(); 
}

template <typename T>
void Signal<T>::add(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)
{
    iter.init(t0,Fe,n);
    s.iter.init(t0,Fe,n);

    for( unsigned k=0 ; s.iter.next() == true && iter.next() == true; ++k)
        v[k] = iter.get() + s.iter.get(); 
}

template <typename T>
void Signal<T>::sub(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)
{
    iter.init(t0,Fe,n);
    s.iter.init(t0,Fe,n);

    for( unsigned k=0 ; s.iter.next() == true && iter.next() == true; ++k)
        v[k] = iter.get() - s.iter.get(); 
}

template <typename T>
void Signal<T>::div(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)
{
    iter.init(t0,Fe,n);
    s.iter.init(t0,Fe,n);

    for( unsigned k=0 ; s.iter.next() == true && iter.next() == true; ++k)
        v[k] = iter.get() / s.iter.get(); 
}

template <typename T>
void Signal<T>::compose(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)
{    
    s.iter.init(t0,Fe,n);

    for( unsigned k=0 ; s.iter.next() == true ; ++k)
        v[k] =  sample(s.iter.get()); 
}

template <typename T>
void Signal<T>::config(T tmin,T tmax,T dilatation=T{1},T translation=T{0},T scale=T{1})
{    
    dlate{dilatation};
    trate{translation};
    scale{scale};
    tmin{tmin};
    tmax{tmax};             
}



/**
 * @brief compute covariance(x,y), or cov(x,x) if y=x.   
 * 
 * @param[in] x  
 * @param[in] y data values
 * @param[in] n number of data values.
 * @param[out] covxx var(x).
 * @param[out] covyy var(y).
 * @param[out] covxy cov(x,y)
 * @return void.
 */
template <typename T,typename U>
void cov(T x[],T y[],const unsigned n,U& covxx,U& covyy,U& covxy)
{
    uint64_t sx=0,sy=0,sx2=0,sy2=0,sxy=0;
    float nf = (float)n;

    for( uint32_t i=0; i<n; ++i){
        sx  += x[i];
        sy  += y[i];
        sx2 += x[i]*x[i];
        sy2 += y[i]*y[i];
        sxy += sx*sy;
    }

    covxx = sx2/nf - pow(sx/nf,2.0f);
    covyy = sy2/nf - pow(sy/nf,2.0f);
    covxy = sxy/nf - (sx*sy) / pow(nf,2.0f);
}

#endif //__cplusplus