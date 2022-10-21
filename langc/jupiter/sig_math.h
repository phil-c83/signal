#ifndef SIGMATH
#define SIGMATH
#include "arm_math.h"

#ifndef M_PI
#    define M_PI (float32_t)3.14159265358979323846
#endif

void sigm_cexp(float32_t theta,float32_t *Re,float32_t *Im);
float32_t sigm_carg( float32_t Re, float32_t Im);
float32_t sigm_sinc(float32_t theta);


#endif //SIGMATH

