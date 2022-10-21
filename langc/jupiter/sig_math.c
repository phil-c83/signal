#include "arm_math.h"

// z = Re + i*Im = cos(theta) + i*sin(theta) 
void sigm_cexp(float32_t theta,float32_t *Re,float32_t *Im)
{
    *Re = arm_cos_f32(theta);
    *Im = arm_sin_f32(theta);
}

float32_t sigm_carg( float32_t Re, float32_t Im)
{
    float32_t arg;
    arm_status arm_atan2_f32(float32_t Im,float32_t Re,&arg);
    return arg;	 		
}

float32_t sigm_sinc(float32_t theta)
{
    float32_t pitheta = M_PI * theta;
    return arm_sin_f32(pitheta)/pitheta;
} 



