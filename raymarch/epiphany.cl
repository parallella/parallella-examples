//   epiphany.cl -- OpenCL routines, speed-optimized for Epiphany architecture.
//   Copyright (C) 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.
//
//   This software is released under the GPLv3.
//   See LICENSE for more info.

#ifdef E32_DRAM_ZEROPAGE
int e_dma_copy(void *, void *, unsigned long);
#else
#include <string.h>
#define e_dma_copy(x,y,z) memcpy(x,y,z)
#endif

#define PI   3.141592653589793f
#define PI_2 1.57079632679489661923f
#define PI_4 0.78539816339744830962f

// ------------------------------------------------------
// simple & fast (well, sort of ;) ) functions, 
// optimized with Epiphany core in mind.
//

#define f2(x) ((float2){x,x})
#define f4(x) ((float4){x,x,x,x})

/* returns 1/a */
float sfinv(float a)
{
	union fu32_u {
		float f;
		uint32_t u;
	};
	union fu32_u x;
	x.f = a;
	x.u = 0x7eeeeeee - x.u;
	x.f = x.f * (2.0f - a * x.f);
	return x.f;
}

/* returns a/b */
float sfdiv(float a, float b)
{
	return a * sfinv(b);
}

/* returns a/b (all float2) */
float2 sfdiv2(float2 a, float2 b)
{
	float2 r;
	r.x = a.x * sfinv(b.x);
	r.y = a.y * sfinv(b.y);
	return r;
}

/* you can guess this one */
float4 sfdiv3(float4 a, float4 b)
{
	float4 r;
	r.x = a.x * sfinv(b.x);
	r.y = a.y * sfinv(b.y);
	r.z = a.z * sfinv(b.z);
	return r;
}

/* returns minimum of 2 values */
float sfmin(float a, float b)
{
	float r;
	r = (a < b) ? a : b;
	return r;
}

/* returns maximum of 2 values */
float sfmax(float a, float b)
{
	float r;
	r = (a > b) ? a : b;
	return r;
}

/* returns maximum xyzw values of two float4s */
float4 sfmax4(float4 a, float4 b)
{
	float4 r;
	r.x = (a.x > b.x) ? a.x : b.x;
	r.y = (a.y > b.y) ? a.y : b.y;
	r.z = (a.z > b.z) ? a.z : b.z;
	r.w = (a.w > b.w) ? a.w : b.w;
	return r;
}

/* make a value fit within [minimum;maximum] */
float sfclamp(float val, float minimum, float maximum)
{
	return min(max(val, minimum), maximum);
}

/* returns the linear blend of two values */
float mix(float a, float b, float o)
{
	return a * (1.0f-o) + b * o;
}

/* returns the linear blend of two rgb values */
float4 sfmix(float4 a, float4 b, float o)
{
	float4 r;
	r.x = a.x * (1.0f-o) + b.x * o;
	r.y = a.y * (1.0f-o) + b.y * o;
	r.z = a.z * (1.0f-o) + b.z * o;
	return r;
}

/* returns the rounded-down integer portion of a value */
float sffloor(float x)
{
	return (float)((int) x);
}

/* returns the fractional part of a value */
float sffract(float x)
{
	return x - sffloor(x);
}

/* returns fractional part of each component of vector */
float4 sffract3(float4 a)
{
	float4 r;
	r.x = sffract(a.x);
	r.y = sffract(a.y);
	r.z = sffract(a.z);
	return r;
}

/* returns the modulus */
float sfmod(float x, float y)
{
	return x - y*sffloor(sfdiv(x,y));
}

/* returns the modulus of a 2D vector */
float2 sfmod2(float2 a, float y)
{
	float2 r;
	r.x = sfmod(a.x, y);
	r.y = sfmod(a.y, y);
	return r;
}

/* returns the modulus of a 3D vector */
float4 sfmod4(float4 a, float y)
{
	float4 r;
	r.x = sfmod(a.x, y);
	r.y = sfmod(a.y, y);
	r.z = sfmod(a.z, y);
	r.w = 0.f;
	return r;
}


/* returns 1 / sqrt(a) */
float sfrsqrt(float a)
{
	union fi32_u {
		float f;
		int32_t i;
	};
	union fi32_u x;
	x.f = a;
	x.i = 0x5f3759df - (x.i >> 1);
	x.f = x.f * (1.5f - x.f * x.f * 0.5f * a);
	x.f = x.f * (1.5f - x.f * x.f * 0.5f * a);
	return x.f;
}

/* returns the square root of a value */
float sfsqrt(float a)
{
	union fu32_u {
		float f;
		uint32_t u;
	};
	union fu32_u x;
	x.f = a;
	x.u += 0x7f << 23;
	x.u >>= 1;
	return x.f;
}

/* minimum components of 2 vectors */
float4 sfmin3(float4 a, float4 b)
{
	float4 r;
	r.x = (a.x < b.x) ? a.x : b.x;
	r.y = (a.y < b.y) ? a.y : b.y;
	r.z = (a.z < b.z) ? a.z : b.z;
	return r;
}

/* maximum components of 2 vectors */
float4 sfmax3(float4 a, float4 b)
{
	float4 r;
	r.x = (a.x > b.x) ? a.x : b.x;
	r.y = (a.y > b.y) ? a.y : b.y;
	r.z = (a.z > b.z) ? a.z : b.z;
	return r;
}

/* same as clamp, but vectors */
float4 sfclamp3(float4 a, float4 minimum, float4 maximum)
{
	return sfmin3(sfmax3(a, minimum), maximum);
}

/* dot product of two vectors */
float sfdot(float4 a, float4 b)
{
	return a.x * b.x + a.y * b.y + a.z * b.z;
}

float sfdot2(float2 a, float2 b)
{
	return a.x * b.x + a.y * b.y;
}

/* reflection vector from incidence and normal vector */
float4 sfreflect(float4 i, float4 n)
{
	return i - ((2.f * sfdot(n,i)) * n);
}

/* return length of a 2D vector */
float sflength2(float2 a)
{
	return sfsqrt(a.x * a.x + a.y * a.y);
}

/* return length of a 3D vector */
float sflength(float4 a)
{
	return sfsqrt(a.x * a.x + a.y * a.y + a.z * a.z);
}

/* return the normalized vector with length=1.0f of a vector */
float4 sfnormalize(const float4 a)
{
	float4 r;
	float b = sfrsqrt(a.x * a.x + a.y * a.y + a.z * a.z);
	r.x = a.x * b;
	r.y = a.y * b;
	r.z = a.z * b;
	return r;
}

float sfdistance(float4 p0, float4 p1)
{
	return sflength(p0-p1);
}

/* cross product of 2 vectors */
float4 sfcross(float4 a, float4 b)
{
	float4 r;
	r.x = a.y * b.z - a.z * b.y;
	r.y = a.z * b.x - a.x * b.z;
	r.z = a.x * b.y - a.y * b.x;
	return r;
}

/* returns 1, 0 or -1 depending on sign of a */
float sfsign(const float a)
{
	union {
		float f;
		uint32_t u;
	} tmp;
	tmp.f = a;
	tmp.u >>= 31;
	return (float)(1 - (tmp.u+tmp.u));
}

/* fast approx function of sinus */	
float sfsin(const float a)
{
	float val = 1.0f;
	float theta = sfmod(a, 2.0f*PI);
	val = 1.0f - theta * theta * 0.083333333f * 0.076923077f * val;
	val = 1.0f - theta * theta * 0.1f * 0.090909091f * val;
	val = 1.0f - theta * theta * 0.125f * 0.111111111f * val;
	val = 1.0f - theta * theta * 0.166666667f * 0.142857143f * val;
	val = 1.0f - theta * theta * 0.25f * 0.2f * val;
	val = 1.0f - theta * theta * 0.5f * 0.333333333f * val;
	return theta * val;
}

/* fast approx function of cosinus */	
float sfcos(const float a)
{
	float val = 1;
	float theta = sfmod(a, 2.0*PI);
	val = 1.0f - theta * theta * 0.083333333f * 0.090909090f * val;
	val = 1.0f - theta * theta * 0.10000000f * 0.11111111f * val;
	val = 1.0f - theta * theta * 0.12500000f * 0.14285714f * val;
	val = 1.0f - theta * theta * 0.16666667f * 0.20000000f * val;
	val = 1.0f - theta * theta * 0.25000000f * 0.33333333f * val;
	val = 1.0f - theta * theta * 0.50000000f * 1.00000000f * val;
	return val;
}

/* tan = sin/cos */
float sftan(float a)
{
	return sfsin(a) * sfinv(sfcos(a));
}

/* return absolute value */
float sfabs(const float a)
{
	union {
		float f;
		uint32_t u;
	} tmp;
	tmp.f = a;
	tmp.u &= 0x7fffffff;
	return tmp.f;
}

/* you can guess this one too */
float4 sfabs4(const float4 a)
{
	float4 r;
	r.x = sfabs(a.x);
	r.y = sfabs(a.y);
	r.z = sfabs(a.z);
	r.w = sfabs(a.w);
	return r;
}

/* fast approximate atan function (a = radians) */
float sfatan(const float a)
{
	return PI_4*a - a*(sfabs(a) - 1.f)*(0.2447f + 0.0663f*sfabs(a));
}

/* fast approximate atan function (x,y are cart. coords) */
float sfatan2(const float x, const float y)
{
	if (x > 0.)
		return sfatan(sfdiv(y,x));
	else if (x == 0.f) {
		if (y > 0.f) return PI_2;
		else if (y < 0.f) return -PI_2;
		else return 0.f;
	} else if (y >= 0.f) return (sfatan(sfdiv(y,x)) + PI);
		else return (sfatan((sfdiv(y,x)) - PI));
}

/* fast approx. power function (high error for b > 8.0f) 
*/
float sfpow(float a, float b)
{
	union {
		double d;
		int x[2];
	} u = { (double)a };
	u.x[1] = (int)(b * (u.x[1] - 1072632447) + 1072632447);
	u.x[0] = 0;
	return (float)u.d;
}
/*
float sfpow(float a, float b)
{
	float r = 1.0f;
	float base = a;
	int expo = (int)b;
	while (expo) {
		if (expo & 1)
			r *= base;
		expo >>= 1;
		base *= base;
	}
	return r;
}
*/

/* pow function of vector */
float4 sfpow3(float4 a, float b)
{
	float4 r;
	r.x = sfpow(a.x,b);
	r.y = sfpow(a.y,b);
	r.z = sfpow(a.z,b);
	return r;
}

/* fast approx. e^a function */
float sfexp(float a)
{
	const float ln2 = 0.69314718055994530942f;
	const float a1 = -0.9998684f;
	const float a2 =  0.4982926f;
	const float a3 = -0.1595332f;
	const float a4 =  0.0293641f;
	long int k, twok;
	float x_;
	float exp_x;

	k = sfdiv(a, ln2);
	twok = 1U << k;
	x_ = a - (float) k * ln2;

	exp_x = 1.f +
		a1 * x_ +
		a2 * x_ * x_ +
		a3 * x_ * x_ * x_ +
		a4 * x_ * x_ * x_ * x_;

	exp_x = (float) twok * (sfinv(exp_x));

    	if (x_ >= 0.f)
		return exp_x;
	else
		return sfinv(exp_x);
}

float sflog2(float a)
{
	union fu32_u {
		float f;
		uint32_t u;
	};
	union fu32_u x;
	x.f = a;
	int log_2 = ((x.u >> 23) & 255) - 128;
	x.u &= ~(255 << 23);
	x.u += 127 << 23;

	x.f = ( -0.3333333333f * x.f + 2.0f) * x.f - 0.66666666666f;   // (1)

	return (x.f + (float)log_2);
} 

float sflog (const float a)
{
	/* log2(a) * ln(2) */
	return (sflog2(a) * 0.69314718f);
}	

/* scale/map x to within [a;b] */
float sfsmoothstep(float a, float b, float x)
{
	float s = sfdiv( (x-a), (b-a) );
	float t = sfmax(0, sfmin(1, s));
	return t*t*(3.0f - (2.0f*t));
}

