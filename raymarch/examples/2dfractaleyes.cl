//   2dfractaleyes.cl -- mandelbrot zoom with eyes.
//   Copyright (C) 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.
//
//   This software is released under the GPLv3.
//   See LICENSE for more info.
//
//   Original GLSL code by David Hoskins
//   https://www.shadertoy.com/view/Md2GDy
//   License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#include "epiphany.cl"

#define ITER 32

/* variables outside functions crashes the compiler :(
__private float iGlobalTime;
__private float gTime;
*/

/* workaround for global vars */
float getorsettime(float time)
{
	static float mytime = 0.f;
	if(time > 0.1f)
		mytime = sfpow(sfabs((.57f+sfcos(time*.2f)*.55f)), 3.0f);
	return mytime;
}

/* the result is weirdly inverted than the original shadertoy example,
   cant find the cause .. :(
*/
float4 Fractal(float2 uv, float2 iResolution, float iGlobalTime)
{
	float gTime = getorsettime(-1.f);
	float2 p = gTime * sfdiv2((iResolution-uv),f2(iResolution.y)) - gTime * 0.5f + 0.363f - (sfsmoothstep(0.05f, 1.5f, gTime)*(float2){.5f, .365f});
	float2 z = p;
	float g = 4.f, f = 4.0f;
	for( int i = 0; i < ITER; i++ ) 
	{
		float w = ((float)i)*22.4231f+iGlobalTime*2.0f;
		float2 z1 = (float2){2.f*sfcos(w),2.f*sfsin(w)};		   
		z = (float2){ z.x*z.x-z.y*z.y, 2.0f *z.x*z.y } + p;
		g = sfmin( g, sfdot2(z-z1,z-z1));
		f = sfmin( f, sfdot2(z,z) );
	}
	g =  sfmin(sfpow(sfmax(1.0f-g, 0.0f), .15f), 1.0f);
	// Eye colours...
	float4 col = sfmix(f4(g), (float4){.3f, .5f, .1f, 0.f}, sfsmoothstep(.89f, .91f, g));
	col = sfmix(col, f4(.0f), sfsmoothstep(.98f, .99f, g));
	float c = sfabs(sfdiv(sflog(f),25.0f));
	col = sfmix(col, (float4){f*.03f, c*.4f, c, 0.f}, 1.0f-g);
	return sfclamp3(col, f4(0.0f), f4(1.0f));
}

float4 render_pixel(float2 fragCoord, float2 iResolution, float time)
{
	float gTime = getorsettime(-1.f);
	float expand = sfsmoothstep(1.2f, 1.6f, gTime)*32.0f+.5f;
	// Anti-aliasing...
	float4 col = f4(0.f);
	for (float y = 0.f; y < 2.f; y++)
	{
		for (float x = 0.f; x < 2.f; x++)
		{
			col += Fractal(fragCoord + (float2){x,y} * expand, iResolution, time);
		}
	}
	
	return (float4) { sfsqrt(sfdiv(col.x,4.0f)), 
			  sfsqrt(sfdiv(col.y,4.0f)), 
			  sfsqrt(sfdiv(col.z,4.0f))};
}

__kernel void raymarch_kern(float time, uint pitch, uint xres, uint yres, __global uint * frame)
{
	uint line[xres];
	int i, j;
	float4 color;
	
	float2 fres = (float2){(float) xres, (float) yres};
	int y = get_global_id(0);
	uint *dst = frame + ((yres - y) * xres);
	float2 c = (float2) { 0, y };
	float t = getorsettime(time);

	for (i = 0; i < xres; i++) {
		c.x = (float)i;
		color = render_pixel(c, fres, time);
		line[i] = 0xff000000 +
			((uint) (color.x * 255.0f) << 16) + 
			((uint) (color.y * 255.0f) << 8) + 
			((uint) (color.z * 255.0f));
	}
	e_dma_copy(dst, line, pitch);
}

