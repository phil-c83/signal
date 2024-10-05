#ifndef __signal__
#define __signal__

#ifdef __cplusplus
#include <cmath>


template <typename T = float>
class Signal 
{
public:  
    const T MINUS_INF{T {-1.0} / T {0.0}};
    const T PLUS_INF{T {1.0} / T {0.0}};  

    explicit Signal(unsigned k) {n=k;}
    virtual T    sample(T t)=0;
    virtual void config(unsigned n,T tmin,T tmax,T dilatation=T{1.0},T translation=T{0.0},T scale=T{1.0})  //non zero samples number,domain,translation,dilatation and scale for signals 
    { // signal_2(t) = signal_1((t-trate)/dlate) * scale
        Signal<T>::n=n;Signal<T>::tmin=tmin;Signal<T>::tmax=tmax;dlate=dilatation;trate=translation;scale=scale;
    };    
    void generate(T t0,T Fe,T v[],const unsigned n);             // generate a signal vector in v
    void mult(Signal<T>& s,T t0,T Fe,T v[],const unsigned n);    // multiply with s and store result in v
    void add(Signal<T>& s,T t0,T Fe,T v[],const unsigned n);     // add s and store result in v
    void sub(Signal<T>& s,T t0,T Fe,T v[],const unsigned n);     // subtract s and store result in v
    void div(Signal<T>& s,T t0,T Fe,T v[],const unsigned n);     // div with s and store result in v
    void compose(Signal<T>& s,T t0,T Fe,T v[],const unsigned n); // compose with s ie this->sample(s.sample(t))
    
    //virtual void conv(Signal<T>& s,T t0,T Fe,T v[],const unsigned n);    // convolution with s
    ~Signal() {};

protected:    
    unsigned n; // max non zero samples generate() yield 
    T tmin {MINUS_INF}; // TODO see {std::numeric_limits<T>::infinity};
    T tmax {PLUS_INF} ; 
    T dlate {1.0};  // dilatation factor for t
    T trate {0.0};  // translation for t
    T scale {1.0};  // scale factor for f(t)
};

#include "signal.cpp"

#endif //__cplusplus

#endif // __signal__