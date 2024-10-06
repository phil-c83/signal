#ifndef __signal__
#define __signal__

#ifdef __cplusplus
#include <cmath>


template <typename T>
class Dom
{
public:
    const T MINUS_INF{T {-1.0} / T {0.0}};
    const T PLUS_INF{T {1.0} / T {0.0}};   

    Dom(T tmin=MINUS_INF,T tmax=PLUS_INF) : tmin{tmin},tmax{tmax} {};
protected:
    T tmin; // TODO see {std::numeric_limits<T>::infinity};
    T tmax;     
};


template <typename T = float>
class Signal 
{
public:      

    explicit Signal(Dom<T> dom) : dom{dom} {};
    virtual T sample(T t)=0;
    virtual void config(Dom<T> dom,T dilatation=T{1.0},T translation=T{0.0},T scale=T{1.0})  //domain,translation,dilatation and scale for signals 
    { // signal_2(t) = signal_1((t-trate)/dlate) * scale
        Signal<T>::dom=dom;dlate=dilatation;trate=translation;scale=scale;
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
    Dom<T> dom;    
    
    T dlate {1.0};  // dilatation factor for t
    T trate {0.0};  // translation for t
    T scale {1.0};  // scale factor for f(t)

private:
    T combine(T& x,T& y,T (*op)(T& x,T& y)) {op(x,y);}
    void iter_combine(Signal<T>& s,T t0,T Fe,T v[],const unsigned n,T (*op)(T& x,T& y))
    {
        T t{t0};
        for( unsigned k=0 ; k<n ; ++k, t+=1/Fe )            
            v[k] = op(sample(t),s.sample(t)); 
    }
};

#include "signal.cpp"

#endif //__cplusplus

#endif // __signal__