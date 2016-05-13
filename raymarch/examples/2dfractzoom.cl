//   2dfractzoom.cl -- simpel grafical OpenCL example that zooms a mandelbrot fractal.
//   Copyright (C) 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.
//
//   This software is released under the GPLv3.
//   See LICENSE for more info.
//
// Original GLSL by inigo quilez - iq/2015 
// ( https://www.shadertoy.com/view/lllGWH )
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#include "epiphany.cl"

#define ITER 128

float4 render_pixel(float2 p, float2 iResolution, float iGlobalTime)
{
	float n = 0.;
	float2 c = (float2) { -.745f, .186f } +
		   3.f * (sfdiv2(p, f2(iResolution.y)) - f2(.5)) * 
			 sfpow(.01f, 1.f + sfcos(.2f * iGlobalTime));
	float2 z = c * n;

	for (int i = 0; i < ITER; i++) {
		z = (float2) {z.x * z.x - z.y * z.y, 2.f * z.x * z.y} + c;

		if (sfdot2(z, z) > 1e4f)
			break;

		n++;
	}

	float4 t = (float4) { 3.f, 4.f, 11.f, 0.f } +
		   f4(.05f * (n - sflog2(sflog2(sfdot2(z, z))))); 

	return sfclamp3(f4(.5f) + 
			.5f * (float4) {sfcos(t.x), sfcos(t.y), sfcos(t.z), sfcos(t.w)}, 
			f4(0.f), f4(1.f));
}

__kernel void raymarch_kern(float time, uint pitch, uint xres, uint yres, __global uint * frame) 
{
	uint line[xres];
	int i, j;

	float2 fres = (float2) {(float)xres, (float)yres};
	int y = get_global_id(0); 
	uint * dst = frame + ((yres - y) * xres); 
	float2 c = (float2) {0, y}; 
	float4 color; 
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
