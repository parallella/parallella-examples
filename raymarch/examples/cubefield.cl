//   cubefield.cl -- grafical OpenCL example that raymarches an infinite cube field
//   Copyright (C) 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.
//
//   This software is released under the GPLv3.
//   See LICENSE for more info.

#include <epiphany.cl>

#define ITER 64

float sdBox(float4 p, float4 b)
{
	float4 d = sfabs4(p) - b;
	return sfmin(sfmax(d.x, sfmax(d.y, d.z)), 0.0f) + sflength(sfmax4(d, f4(0.0f)));
}

float opU(float d1, float d2)
{
	return sfmin(d1, d2);
}

float sdGrid(float4 p)
{
	return opU(opU(sdBox(p, (float4){5.f, .8f, .3f,0.f}), sdBox(p, (float4){1.31f, 55.2f, .3f,0.f})), sdBox(p, f4(0.f)));
}

float sdCross(float4 p)
{
	return opU(sdBox(p, f4(0.f)), sdBox(p, f4(2.6f)));
}

float smin(float a, float b, float k)
{
	float res = sfexp(-k * a) + sfexp(-k * b);
	return -sflog(res) / k;
}

float sdCrossedGrid(float4 p)
{
	float d1 = sdCross(p);
	float d2 = sdGrid(p);
	return smin(d1, d1, d1);
}

float2 distance_to_obj(float4 p)
{

	p = sfmod4(p, 10.f) - f4(5.f);	// Repeat space.

// Unsigned rounded box.
// float4(2.) - Box dimensions, and the last term for roundness.

	float rBox = sflength(sfmax4(sfabs4(p) - f4(2.f), f4(0.0f))) - 0.2f;

	return (float2){rBox, 1.f};
}

// primitive color
float4 prim_c(float4 p)
{
	//return float4(0.6,0.6,0.8);
	return (float4){sfsin(p.x * p.y * p.z / 10.f), sfcos(p.x * p.y * p.z / 5.f), .5f, 0.f};
}

float4 render_pixel(float2 fragCoord, float2 iResolution, float iGlobalTime)
{
	float4 fragColor;
	float4 cam_pos = (float4){sfcos(sfdiv(iGlobalTime, 5.f)) * 20.0f, sfsin(sfdiv(iGlobalTime, 5.f)) * 40.0f, 20.0f, 0.f};

	float2 tx = sfdiv2(fragCoord, iResolution);
	float2 vPos = f2(-1.0f) + 2.0f * tx;

	//camera up vector
	float4 vuv = (float4){0.f, 1.f, 1.f, 0.f};

	//camera lookat
	float4 vrp = (float4){0.f, 1.f, 0.f, 0.f};

	float4 prp = cam_pos;
	float4 vpn = sfnormalize(vrp - prp);
	float4 u = sfnormalize(cross(vuv, vpn));
	float4 v = sfcross(vpn, u);
	float4 vcv = (prp + vpn);
	float4 scrCoord = vcv + vPos.x * u * 1.0f + vPos.y * v * 1.0f;
	float4 scp = sfnormalize(scrCoord - prp);

	//Raymarching
	const float4 e0 = (float4){0.04f, 0.00f, 0.00f, 0.f};
	const float4 e1 = (float4){0.00f, 0.04f, 0.00f, 0.f};
	const float4 e2 = (float4){0.00f, 0.00f, 0.04f, 0.f};
	const float maxd = 200.0f;
	float2 d = (float2){1.02f, 1.0f};
	float4 c, p, N;

	float f = 1.0f;
	for (int i = 0; i < ITER; i++) {	// Change i value to 256 for 3D-ness and 2 for coolness
		if ((sfabs(d.x) < .001f) || (f > maxd))
			break;

		f += d.x * 0.8f;
		p = prp + scp * f;
		d = distance_to_obj(p);
	}
	if (f < maxd) {
		c = prim_c(p);
		float4 n = (float4){d.x - distance_to_obj(p - e0).x,
			      d.x - distance_to_obj(p - e1).x,
			      d.x - distance_to_obj(p - e2).x, 0.f};
		N = sfnormalize(n);

		float b = sfdot(N, sfnormalize(prp - p));
		float2 xy = sfdiv2(fragCoord, iResolution);	//Condensing this into one line
		xy.y = 1.0 - xy.y;

		float2 uv = sfdiv2(fragCoord, iResolution);
		fragColor = f4(b);

		//fragColor = float4(b, 0.1, b, cos(iGlobalTime));//Set the screen pixel to that color
	} else {
		fragColor = (float4){0.f, 0.f, 0.f, 1.f};
	}
	return fragColor;
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

