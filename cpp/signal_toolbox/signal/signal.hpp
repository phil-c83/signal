#ifndef __signal__
#define __signal__

#ifdef __cplusplus
#include <cmath>

template <typename T>
class Signal;

template <typename T = float>
class Signal_iterator
{
public:

    explicit Signal_iterator(T t0,T Fe,unsigned n,Signal<T>& s) 
    {
        sig=s;
        init(t0,Fe,n); 
    }

    void init(T t0,T Fe,unsigned n) {t=t0-1/Fe;Fe=Fe;count=n;cur=0;}

    bool next() 
    {
        if( cur < count )
        {
            t += 1/Fe;
            cur ++;
            return true;
        }
        else
            return false;
    }

    T get()
    {
        return sig.sample(t); 
    }

private:

    unsigned count;
    unsigned cur;
    T Fe;
    T t;
    Signal<T>& sig;

};



template <typename T = float>
class Signal 
{
public:  
    virtual T    sample(T t)=0;
    virtual void config(T tmin,T tmax,T dilatation,T translation,T scale)  // domain,translation,dilatation and scale for signals 
    { // signal_2(t) = signal_1((t-trate)/dlate) * scale
        dlate=dilatation;trate=translation;scale=scale;
    };    
    virtual void generate(T t0,T Fe,T v[],const unsigned n);             // generate a signal vector in v
    virtual void mult(Signal<T>& s,T t0,T Fe,T v[],const unsigned n);    // multiply with s and store result in v
    virtual void add(Signal<T>& s,T t0,T Fe,T v[],const unsigned n);     // add s and store result in v
    virtual void sub(Signal<T>& s,T t0,T Fe,T v[],const unsigned n);     // subtract s and store result in v
    virtual void div(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)=0;     // div with s and store result in v
    virtual void compose(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)=0; // compose with s ie this->sample(s.sample(t))
    virtual T    cov(Signal<T>& s,T t0,T Fe,const unsigned n)=0;           // covariance with s 
    virtual void conv(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)=0;    // convolution with s
    ~Signal() {};

protected:
    Signal_iterator<T> iter;
    T tmin  = T{- std::numeric_limits<T>::infinity};
    T tmax  = T{+ std::numeric_limits<T>::infinity};      
    T dlate = T{1};  // dilatation factor
    T trate = T{0};  // translation
    T scale = T{1};  // scale factor 

};



#endif //__cplusplus

#endif // __signal__