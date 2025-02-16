//
// Noise Shader Library for Unity - https://github.com/keijiro/NoiseShader
//
// Original work (webgl-noise) Copyright (C) 2011 Ashima Arts.
// Translation and modification was made by Keijiro Takahashi.
//
// This shader is based on the webgl-noise GLSL shader. For further details
// of the original shader, please see the following description from the
// original source code.
//

//
// Description : Array and textureless GLSL 2D/3D/4D simplex
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//

float wglnoise_mod(float x, float y)
{
    return x - y * floor(x / y);
}

float2 wglnoise_mod(float2 x, float2 y)
{
    return x - y * floor(x / y);
}

float3 wglnoise_mod(float3 x, float3 y)
{
    return x - y * floor(x / y);
}

float4 wglnoise_mod(float4 x, float4 y)
{
    return x - y * floor(x / y);
}

float2 wglnoise_fade(float2 t)
{
    return t * t * t * (t * (t * 6 - 15) + 10);
}

float3 wglnoise_fade(float3 t)
{
    return t * t * t * (t * (t * 6 - 15) + 10);
}

float wglnoise_mod289(float x)
{
    return x - floor(x / 289) * 289;
}

float2 wglnoise_mod289(float2 x)
{
    return x - floor(x / 289) * 289;
}

float3 wglnoise_mod289(float3 x)
{
    return x - floor(x / 289) * 289;
}

float4 wglnoise_mod289(float4 x)
{
    return x - floor(x / 289) * 289;
}

float3 wglnoise_permute(float3 x)
{
    return wglnoise_mod289((x * 34 + 1) * x);
}

float4 wglnoise_permute(float4 x)
{
    return wglnoise_mod289((x * 34 + 1) * x);
}

//Simplex noise gradient
float4 SimplexNoiseGradient(float3 v)
{
    // First corner
    float3 i = floor(v + dot(v, 1.0 / 3));
    float3 x0 = v - i + dot(i, 1.0 / 6);

    // Other corners
    float3 g = x0.yzx <= x0.xyz;
    float3 l = 1 - g;
    float3 i1 = min(g.xyz, l.zxy);
    float3 i2 = max(g.xyz, l.zxy);

    float3 x1 = x0 - i1 + 1.0 / 6;
    float3 x2 = x0 - i2 + 1.0 / 3;
    float3 x3 = x0 - 0.5;

    // Permutations
    i = wglnoise_mod289(i); // Avoid truncation effects in permutation
    float4 p = wglnoise_permute(i.z + float4(0, i1.z, i2.z, 1));
    p = wglnoise_permute(p + i.y + float4(0, i1.y, i2.y, 1));
    p = wglnoise_permute(p + i.x + float4(0, i1.x, i2.x, 1));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float4 gx = lerp(-1, 1, frac(floor(p / 7) / 7));
    float4 gy = lerp(-1, 1, frac(floor(p % 7) / 7));
    float4 gz = 1 - abs(gx) - abs(gy);

    bool4 zn = gz < -0.01;
    gx += zn * (gx < -0.01 ? 1 : -1);
    gy += zn * (gy < -0.01 ? 1 : -1);

    float3 g0 = normalize(float3(gx.x, gy.x, gz.x));
    float3 g1 = normalize(float3(gx.y, gy.y, gz.y));
    float3 g2 = normalize(float3(gx.z, gy.z, gz.z));
    float3 g3 = normalize(float3(gx.w, gy.w, gz.w));

    // Compute noise and gradient at P
    float4 m = float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3));
    float4 px = float4(dot(g0, x0), dot(g1, x1), dot(g2, x2), dot(g3, x3));

    m = max(0.5 - m, 0);
    float4 m3 = m * m * m;
    float4 m4 = m * m3;

    float4 temp = -8 * m3 * px;
    float3 grad = m4.x * g0 + temp.x * x0 +
        m4.y * g1 + temp.y * x1 +
        m4.z * g2 + temp.z * x2 +
        m4.w * g3 + temp.w * x3;

    return 107 * float4(grad, dot(m4, px));
}

//Simplex noise gradient with octaves
float4 SimplexNoiseGradient_Octaves(float3 inCoord, float scale, float3 offset, uint octaveNumber, float octaveScale, float octaveAttenuation) {

	float4 output = 0.0f;
	float weight = 1.0f;

	for (uint i = 0; i < octaveNumber; i++)
	{
		float3 coord = inCoord * scale + offset;

		output += SimplexNoiseGradient(coord) * weight;

		scale *= octaveScale;
		weight *= 1.0f - octaveAttenuation;
	}

	return output;
}

//Simplex noise
float SimplexNoise(float3 v)
{
    return SimplexNoiseGradient(v).w;
}

//Simplex noise with octaves
float SimplexNoise_Octaves(float3 inCoord, float scale, float3 offset, uint octaveNumber, float octaveScale, float octaveAttenuation) {

    float output = 0.0f;
    float weight = 1.0f;

    for (uint i = 0; i < octaveNumber; i++)
    {
        float3 coord = inCoord * scale + offset;

        output += SimplexNoise(coord) * weight;

        scale *= octaveScale;
        weight *= 1.0f - octaveAttenuation;
    }

    return output;
}
