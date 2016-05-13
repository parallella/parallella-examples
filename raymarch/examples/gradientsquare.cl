//   gradientsquare.cl -- simpel grafical OpenCL example that calculates a color gradient square.
//   Copyright (C) 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.
//
//   This software is released under the GPLv3.
//   See LICENSE for more info.

#include "epiphany.cl"

__kernel void raymarch_kern(float time, uint pitch, uint xres, uint yres, __global uint * frame)
{
	uint line[xres];
	int i, j;
	float2 fres;
	fres.x = (float)xres;
	fres.y = (float)yres;
	int y = get_global_id(0);
	uint *dst = frame + ((yres - y) * xres);
	float2 c = (float2) { 0, y };
	float4 color;
	uint fcolor;
	for (i = 0; i < xres; i++) {
		c.x = (float)i;
		color = (float4) { sfdiv(c.x, fres.x),
				   sfdiv(c.y, fres.y), 
				  0.5f + 0.5f * sfsin(time), 
				  1.f};
		fcolor = 0xff000000 +
			((uint) (color.x * 255.0f) << 16) + 
			((uint) (color.y * 255.0f) << 8) + 
			((uint) (color.z * 255.0f));
		line[i] = fcolor;
	}
	e_dma_copy(dst, line, pitch);
}

