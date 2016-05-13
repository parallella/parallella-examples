//   tunnel.cl -- grafical OpenCL example that raymarches a tunnel with a ribbon.
//   Copyright (C) 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.
//
//   This software is released under the GPLv3.
//   See LICENSE for more info.

#include "epiphany.cl"

#define ITER 32

float tunnel(float4 p)
{
	return sfcos(p.x)+sfcos(p.y*1.5f)+sfcos(p.z)+sfcos(p.y*20.f)*.05f;
}

float ribbon(float4 p, float iGlobalTime)
{
	float4 a = (float4){sfcos(p.z*1.5f)*.3f,-.5f+sfcos(p.z)*.2f,.0f,.0f};
	float4 b = (float4){.125f,.02f,iGlobalTime+3.f,0.f};
	float4 c = f4(0.f);
	return sflength(sfmax4(sfabs4(p-a)-b,c));
}

float scene(float4 p, float iGlobalTime)
{
	return sfmin(tunnel(p),ribbon(p,iGlobalTime));
}

float4 getNormal(float4 p, float iGlobalTime)
{
	float4 eps1= p + (float4){0.1f,0.0f,0.0f,0.f};
	float4 eps2= p + (float4){0.0f,0.1f,0.0f,0.f};
	float4 eps3= p + (float4){0.0f,0.0f,0.1f,0.f};
	float4 t = (float4) {scene(eps1,iGlobalTime),scene(eps2,iGlobalTime),scene(eps3,iGlobalTime),.0f};
	return sfnormalize(t);
}

float4 render_pixel(float2 fragCoord, float2 iResolution, float iGlobalTime )
{
	float4 t0, t1, t2, t3;
	float2 v = f2(-1.0f) + 2.0f * sfdiv2(fragCoord,iResolution);
	// adjust for aspect ratio.
	v.x *= sfdiv(iResolution.x,iResolution.y);
 
	float4 color;
	float4 org   = (float4){sfsin(iGlobalTime)*.5f,sfcos(iGlobalTime*.5f)*.25f+.25f,iGlobalTime,0.f};
	float4 p   = org,pp;
	t0         = (float4){v.x*1.6f,v.y,1.0f,0.f};
	float4 dir = sfnormalize(t0);
	float d; 

	//First raymarching
	for(int i=0;i<ITER;i++)
	{
	  	d = scene(p,iGlobalTime);
		p = p + (d*dir);
	}
	pp = p;
	float f = sflength(p-org)*0.02f;

	//Second raymarching (reflection)
	// less raymarching needed here, therefore ITER/4.
	t0 = getNormal(p,iGlobalTime);
	dir = sfreflect(dir,t0);
	p+=dir;
	for(int i=0;i<ITER/4;i++)
	{
		d = scene(p,iGlobalTime);
		p = p + (d*dir);
	}
	t0 = (float4){.1f,.1f,.0f,.0f};
	t1 = (float4){.3,sfcos(iGlobalTime*.5f)*.5f+.5f,sfsin(iGlobalTime*.5f)*.5f+.5f,1.f};
	color = sfmax(sfdot(getNormal(p,iGlobalTime),t0), .0f) + t1 * sfmin(sflength(p-org)*.04f, 1.f);

	//Ribbon Color
	if(tunnel(pp)>ribbon(pp,iGlobalTime)) {
		t0 =  (float4) { sfcos(iGlobalTime*.3f)*.5f+.5f, 
                                sfcos(iGlobalTime*.2f)*.5f+.5f,
                                sfsin(iGlobalTime*.3f)*.5f+.5f,
                                1.f };
		color = sfmix(color, t0, .3f);
	}

	//Final Color
	t0 = f4(f);
	t1 = (float4){1.f,.8f,.7f,1.f};
	float4 fcolor = color +
			t0 +
			(1. - sfmin(pp.y + 1.9f, 1.f)) * sfmin(iGlobalTime*.5f, 1.f) * t1;
	return sfclamp3(fcolor, f4(0.f),f4(1.0f));
}


__kernel void raymarch_kern( 
	float time,
	uint pitch,
	uint xres,
	uint yres,
	__global uint* frame 
) 
{
	uint line[xres];
	int i;
	float2 fres = (float2) { (float) xres, (float) yres };
	int y = get_global_id(0);
	uint* dst = frame + ((yres-y)*xres);
	float2 c = (float2) {0, y};
	float4 color;
	for(i=0;i<xres;i++) {
		c.x = (float)i;
		color = render_pixel(c, fres, time);
		line[i] = 0xff000000 +
			 ((uint) (color.x * 255.0f) << 16) + 
			 ((uint) (color.y * 255.0f) <<  8) + 
			 ((uint) (color.z * 255.0f));
	}
	e_dma_copy(dst,line,pitch);			
}

