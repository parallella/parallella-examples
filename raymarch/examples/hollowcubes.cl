//   hollowcubes.cl -- grafical OpenCL example that raymarches an infinite floor with hollow cubes.
//   Copyright (C) 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.
//
//   This software is released under the GPLv3.
//   See LICENSE for more info.

#include "epiphany.cl"

#define ITER 16

#define add(a,b)    sfmin((a),(b))
#define com(a,b)    sfmax((a),(b))
#define neg(a)        (-(a))
#define sub(a,b)    com((a),neg(b))
#define inf(a,v)    ((a)+(v))

#define pi2            (2.f*3.141593f)
#define R(plane,a)  (plane=(float2){sfcos((a)*pi2)*plane.x+sfsin((a)*pi2)*plane.y,sfcos((a)*pi2)*plane.y-sfsin((a)*pi2)*plane.x})

#define pmod(a,b)    ( sfmod(sfmod((a),(b))+(b),(b)) )
#define rep(a,r)    ( pmod(((a)+(r)*.5f),(r))-(r)*.5f )

#define pmod2(a,b)    ( sfmod2(sfmod2((a),(b))+(b),(b)) )
#define rep2(a,r)    ( pmod2(((a)+(r)*.5f),(r))-(r)*.5f )

#define repx(a,r)    (float4){ rep((a).x,(r)), (a).yz, 0.f }
#define repy(a,r)    (float4){ (a).x, rep((a).y,(r)), (a).z, 0.f }
#define repz(a,r)    (float4){ (a).xy,rep((a).z,(r)), 0.f }
#define repxy(a,r)   (float4){ rep2((a).xy,(r)), (a).z, 0.f }
#define repyz(a,r)   (float4){ (a).x, rep2((a).yz,(r)), 0.f }
#define repxz(a,r)   (float4){ rep((a).x,(r)), (a).y, rep((a).z,(r)), 0f. }

float getorsettime(float time)
{
	static float mytime = 10.f;
	if(time > 0.01f) mytime = time;
	return mytime;
}

float qla(float4 pos, float r)
{
	return sflength(pos) - r;
}

float szescian(float4 pos, float4 s)
{
	pos = sfabs4(pos) - s;
	return sfmax(pos.x, sfmax(pos.y, pos.z));
}

float fn(float4 pos)
{
	float iGlobalTime = getorsettime(-1.f);
	R(pos.xy, sfdiv(iGlobalTime , 8.f));
	float2 t = rep2(pos.xy, 3.f);
	pos = (float4){t.x, t.y, pos.z, 0.f};
	float q = qla(pos, 1.2f);
	float s = szescian(pos, (float4){1.f, 1.f, 1.f, 0.f});
	return sub(s, q);
}

float light(float4 n, float4 pos, float4 ldir)
{
	ldir = sfnormalize(ldir);

	pos += n * .02f;
	float4 spos = pos;
	for (int i = 0; i < ITER; i++)
		pos += ldir * fn(pos);
	if (sflength(pos - spos) < 50.f)
		return 0.;

	return sfclamp(sfdot(n, ldir), 0.f, 1.f);
}

float4 render_pixel(float2 fragCoord, float2 iResolution, float iGlobalTime)
{
	float4 fragColor;
	float2 uv = sfdiv2(fragCoord, iResolution);
	float2 vpos = uv * 2.f - f2(1.f);
	vpos.x *= sfdiv(iResolution.x , iResolution.y);
	vpos = vpos * .65f;

	float t = iGlobalTime;
//    float4 front = normalize((float4){sfsin(t),sfcos(t),0.f,0.f});
	float4 front = sfnormalize((float4){1.f, 0.f, -0.5f, 0.f});
	float4 up = (float4){0.f, 0.f, 1.f, 0.f};
	float4 right = sfcross(up, front);
	float4 pos = f4(0.f) - (front * 8.0f);

	float4 rdir = sfnormalize(front + vpos.x * right + vpos.y * up);

	float4 rpos = pos;
	float d;

	for (int i = 0; i < ITER; i++) {
		d = fn(rpos);
		rpos += d * rdir;
		if (d < 0.01f)
			break;
	}

	if (d > 0.05f) {
		fragColor = (float4){.5f, .8f, .9f, 0.f} * (pow(1.f - sfabs(rdir.z), 1.5f));
	} else {
		float2 e = (float2){0.01f, 0.f};	// delta (epsilon)
		float4 n = sfnormalize(
(float4){ fn((float4){rpos.x + e.x, rpos.y, rpos.z, 0.f}) - fn((float4){rpos.x - e.x, rpos.y, rpos.z, 0.f}),
	  fn((float4){rpos.x, rpos.y + e.x, rpos.z, 0.f}) - fn((float4){rpos.x, rpos.y - e.x, rpos.z, 0.f}),
	  fn((float4){rpos.x, rpos.y, rpos.z + e.x, 0.f}) - fn((float4){rpos.x, rpos.y, rpos.z - e.x, 0.f})
      }
);

		float4 col = f4(0.f);
		float sunh = (sfsin(iGlobalTime) * .5f + .5f) * .5f + .2f;
		col += light(n, rpos, (float4){-1.f, -1.f, sunh, 0.f}) * (float4){1.f, .8f, .7f, 0.f};	// sun light
		col += (f4(1.f) - col) * (n.z * .5f + .5f) * (float4){.2f, .6f, .9f, 0.f};	// sky light; *(1-col) - soft swiatlo

		fragColor = (float4){sfsqrt(col.z),sfsqrt(col.z),sfsqrt(col.z),0.f};
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

