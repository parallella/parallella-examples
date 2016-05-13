//   foggy_ball.cl -- grafical OpenCL example that raymarches a ball with foggy lighting.
//   Copyright (C) 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.
//
//   This software is released under the GPLv3.
//   See LICENSE for more info.

#include "epiphany.cl"

#define EPSILON 1e-5f

float getorsettime(float time)
{
	static float iGlobalTime = 0.f;
	if( time > 0.01 ) iGlobalTime = time;
	return iGlobalTime;
}

float sphere(float4 pos, float radius, float4 sample)
{
	return sfdistance(pos, sample) - radius;
}

float plane(float4 pos, float4 normal, float4 sample)
{
	return sfdot(sample - pos, normal);
}

float map(float4 sample)
{
	float iGlobalTime = getorsettime(-1.f);
	float t = sffract(iGlobalTime * 0.5f);
	float h = (t - t * t) * 3.0f;

	return sfmin(
	sphere((float4) {0.0f, h, 0.0f, 0.0f}, 1.0f, sample), 
	plane((float4) {0.0f, -1.f, 0.f, 0.f}, (float4) {0.f, 1.f, 0.f, 0.f}, sample)
	    );
}

float4 normal(float4 sample)
{
	float RANGE = 0.01f;
	float c = map(sample);
	float x = map(sample + (float4) { RANGE, 0.f, 0.f, 0.f });
	float y = map(sample + (float4) { 0.f, RANGE, 0.f, 0.f });
	float z = map(sample + (float4) { 0.f, 0.f, RANGE, 0.f });
	return sfnormalize((float4){x, y, z, 0.f} - c);
}

float occlusion(float4 sample, float4 normal)
{
	float RANGE = 0.5f;
	return sfclamp( sfdiv( map(sample + normal * RANGE) , RANGE ), 0.0f, 1.0f);
}

float4 march(float4 origin, float4 direction)
{
	const int MAX_STEPS = 400;
	const float MAX_DIST = 200.0f;

	float4 pos = origin;
	float dist = 0.0f;

	for (int i = 0; i < MAX_STEPS; i++) {
		float m = map(pos);
		dist += m;
		pos = origin + direction * dist;

		if (m < EPSILON) {
			return pos;
		}

		if (dist > MAX_DIST) {
			break;
		}
	}

	return origin + direction * MAX_DIST;
}

float lightContribution(float4 pos, float4 normal, float4 lightDirection, float4 viewDirection)
{
	const float ROUGHNESS = 80.0f;
	const float FRESNEL_POWER = 20.0f;
	const float MIN_REFLECTANCE = 0.65f;
	const float MAX_REFLECTANCE = 0.99f;

	float diffuse = sfmax(sfdot(normal, lightDirection), 0.0f);
	float specular = sfpow(sfmax(sfdot(sfreflect(viewDirection, normal), lightDirection), 0.0f), ROUGHNESS);
	float fresnel = sfpow(sflength(sfcross(normal, viewDirection)), FRESNEL_POWER);
	float reflectance = mix(MIN_REFLECTANCE, MAX_REFLECTANCE, fresnel);

	return mix(diffuse, specular, reflectance);
}

float4 lighting(float4 pos, float4 normal, float4 viewDirection)
{
	const float4 LIGHT_1_DIRECTION = sfnormalize((float4){-0.5f, 1.0f, -0.7f, 0.f});
	const float4 LIGHT_2_DIRECTION = sfnormalize((float4){1.0f, 0.1f, 0.9f, 0.f});
	const float4 LIGHT_1_COLOR = (float4){0.90f, 0.85f, 0.80f, 0.f};
	const float4 LIGHT_2_COLOR = (float4){0.05f, 0.06f, 0.07f, 0.f};
	const float4 AMBIENT_COLOR = (float4){0.02f, 0.02f, 0.03f, 0.f};

	float ambient = occlusion(pos, normal);
	float light1 = lightContribution(pos, normal, LIGHT_1_DIRECTION, viewDirection);
	float light2 = lightContribution(pos, normal, LIGHT_2_DIRECTION, viewDirection);

	return ambient * AMBIENT_COLOR + light1 * LIGHT_1_COLOR + light2 * LIGHT_2_COLOR;
}

float4 fog(float4 c, float dist)
{
	const float FOG_DENSITY = 0.1f;
	const float4 FOG_COLOR = (float4){0.01f, 0.02f, 0.02f, 0.f};

	float fogAmount = 1.0f - sfexp(-dist * FOG_DENSITY);

	return sfmix(c, FOG_COLOR, fogAmount);
}

float4 render(float4 origin, float4 direction)
{
	float4 p = march(origin, direction);
	float4 n = normal(p);
	float4 c = lighting(p, n, direction);
	return sfclamp3(fog(c, sfdistance(origin, p)), f4(0.f), f4(1.f));
}

float4 gammaCorrect(float4 c)
{
	return sfpow3(c, 0.82f);
}

float4 camera(float4 origin, float4 lookAt, float4 up, float fov, float2 fragCoord, float2 iResolution)
{
	lookAt -= origin;
	float4 forward = sfnormalize(lookAt);
	float4 right = sfnormalize(cross(up, forward));
	up = sfnormalize(sfcross(forward, right));
	float2 screen = sfdiv2((fragCoord - iResolution * 0.5f) , f2(iResolution.y));
	float viewPlane = -sftan(fov * (PI / 360.0f) + (PI * 0.5f));
	return sfnormalize(right * screen.x + up * screen.y + forward * viewPlane);
}

float4 render_pixel(float2 fragCoord, float2 iResolution, float time)
{
	float4 origin = (float4){0.f, 0.f, -4.f, 0.f};
	float4 direction = camera(origin, 
				  (float4){0.f, 0.1f, 0.f, 0.f}, 
				  (float4){0.f, 1.f, 0.f, 0.f}, 
				  90.0f, fragCoord, iResolution);
	float4 color = render(origin, direction);

	return gammaCorrect(color);
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

