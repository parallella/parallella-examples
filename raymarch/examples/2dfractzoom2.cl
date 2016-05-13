//   2dfractzoom2.cl -- Another example that zooms a mandelbrot fractal.
//   Copyright (C) 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.
//
//   This software is released under the GPLv3.
//   See LICENSE for more info.
//
// Original GLSL by https://www.shadertoy.com/view/4scSDf

#include "epiphany.cl"

#define ITER 128

float4 render_pixel(float2 fragCoord, float2 iResolution, float iGlobalTime )
{
	float2 uv = sfdiv2(fragCoord, iResolution);
	uv -= f2(0.5f);
	uv.x *= sfdiv(iResolution.x , iResolution.y);

	uv.x -= 0.0101f*(exp(iGlobalTime)); 
	uv.y -= 0.3556f*(exp(iGlobalTime)); 
	uv = uv * (2.f/(exp(iGlobalTime)));

	float2 zn = f2(0.f);
	float2 z0 = f2(0.f);
	float j = 0.f;
	for(int i = 0; i < ITER; i++){
		z0 = zn;
		zn.x = z0.x * z0.x - z0.y * z0.y + uv.x;
		zn.y = 2.0f * z0.x * z0.y + uv.y; 
		if(sflength2(zn) > 2.0f){
			j = float(i);
			break;
		}
	}

	if(j > 0.0) j = sfdiv(j, 40.f);

	return (float4){j*.3f, j*.4f, j*.7f, 1.0f};
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
