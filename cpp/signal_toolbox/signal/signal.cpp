#ifdef __cplusplus
#include <cmath>
#include <cstdint>

template <typename T>
void Signal<T>::generate(T t0,T Fe,T v[],const unsigned n)
{   
    T t{t0};
    for( unsigned k=0 ; k<n ; ++k, t+=1/Fe )
        v[k] = k < this->n ? sample(t) : T{0.0};   
}

template <typename T>
void Signal<T>::mult(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)
{    
    T t{t0};
    for( unsigned k=0 ; k<n ; ++k, t+=1/Fe )            
        v[k] = (k < this->n ? sample(t) : T{0.0}) * 
               (k < s.n ? s.sample(t) : T{0.0});    
}

template <typename T>
void Signal<T>::add(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)
{     
    T t{t0};
    for( unsigned k=0 ; k<n ; ++k, t+=1/Fe )            
        v[k] = (k < this->n ? sample(t) : T{0.0}) + 
               (k < s.n ? s.sample(t) : T{0.0});   
}

template <typename T>
void Signal<T>::sub(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)
{   
    T t{t0};  
    for( unsigned k=0 ; k<n ; ++k, t+=1/Fe )            
        v[k] = (k < this->n ? sample(t) : T{0.0}) - 
               (k < s.n ? s.sample(t) : T{0.0});    
}

template <typename T>
void Signal<T>::div(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)
{ // TODO see how to handle div by zero, perhaps keeping Inf or NaN is right     
    T t{t0};
    for( unsigned k=0 ; k<n ; ++k, t+=1/Fe )            
        v[k] = (k < this->n ? sample(t) : T{0.0}) / 
               (k < s.n ? s.sample(t) : T{0.0});    
}

template <typename T>
void Signal<T>::compose(Signal<T>& s,T t0,T Fe,T v[],const unsigned n)
{   
    T t{t0};     
    for( unsigned k=0 ; k<n ; ++k, t+=1/Fe ) 
    {           
        T x  = k < s.n ? s.sample(t) : T{0.0};
        v[k] = k < this->n ? sample(x) : T{0.0}; 
    }
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
    U sx=0,sy=0,sx2=0,sy2=0,sxy=0;    

    for( unsigned i=0; i<n; ++i){
        sx  += U{x[i]};
        sy  += U{y[i]};
        sx2 += U{x[i]}*U{x[i]};
        sy2 += U{y[i]}*U{y[i]};
        sxy += sx*sy;
    }

    covxx = sx2/U{n} - pow(sx/U{n},U{2.0});
    covyy = sy2/U{n} - pow(sy/U{n},U{2.0});
    covxy = sxy/U{n} - (sx*sy) / pow(U{n},U{2.0});
}

#endif //__cplusplus