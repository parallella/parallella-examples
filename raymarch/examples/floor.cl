//   floor.cl -- grafical OpenCL example that raymarches a reflecting moving floor.
//   Copyright (C) 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.
//
//   This software is released under the GPLv3.
//   See LICENSE for more info.

#include "epiphany.cl"

float4 calcColor(float4 ambient, float4 view, float4 normal, float4 light, float lightintensity)
{
	ambient = ambient * 0.2f;

	float4 nview = sfnormalize(view);
	float4 nnormal = sfnormalize(normal);
	float4 nlight = sfnormalize(light);
	float4 nhalf = sfnormalize(nview + nlight);
	float4 reflected = sfreflect(nnormal * -1.0f, nlight);
	float temp = lightintensity * ( (sfmax(sfdot(nnormal, nlight), 0.0f) * 0.6f) + (0.3f * sfmax(sfdot(reflected, nview), 0.0f) * (sfmax(sfdot(reflected, nview), 0.0f))));

	return ambient + f4(temp);
}

float4 render_pixel(float2 fragCoord, float2 iResolution, float iGlobalTime)
{
	/* scene is from -.5f to +.5f on both x,y. (0,0) = middle */
	float2 uv = sfdiv2(fragCoord , iResolution) + f2(-0.5f);

	float4 chessBlack = (float4){0.2f, 0.23f, 0.3f};
	float4 chessWhite = (float4){0.93f, 0.9f, 0.98f};
	float4 pixel;

	if (uv.y > -0.1f) {
		pixel = f4((sfsmoothstep(-0.1f, 1.f, uv.y) * 0.2f) + 0.8f);
	} 
	else {

		float de = 0.5f;
		float scale = 0.4f;
		float speed = 0.1f;
		float2 textCoord = (float2){sfdiv(uv.x, uv.y), sfdiv(de , uv.y)} * scale - (float2){0.0f, (iGlobalTime * speed)};
		float cube = sfsign((sfmod(textCoord.x, 0.1f) - 0.05f) * (sfmod(textCoord.y, 0.1f) - 0.05f));
		if (0.0f < cube) {
			pixel = chessBlack;
		} else {
			pixel = chessWhite;
		}
		float4 nd;
		if (sfabs(cube) < 0.1f) 
			nd = f4(1.0f);
		else
			nd = f4(0.0f);
		
		pixel =
		    calcColor(pixel, 
			(float4){textCoord.x, -1.0f, textCoord.y, 1.f} + nd, 
			(float4){0.0f + sfdiv(uv.x , uv.y) * 2.0f, 1.0f, 0.0f, 1.f},
			(float4){0.0f, 1.53f, 2.0f - (iGlobalTime * speed), 1.f},
			sfdiv(sflength2(textCoord) , 3.f));
	}
	
	return pixel;
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

