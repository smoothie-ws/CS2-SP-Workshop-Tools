// SPIR-V reflection failed for backend HLSL:
// cbuffer ID 5618 (name: _Globals_), member index 2 (name: g_vColor0) cannot be expressed with either HLSL packing layout or packoffset.
// 
// Re-attempting reflection with the GLSL backend.

// SPIR-V source (9832 bytes), GLSL reflection with SPIRV-Cross by KhronosGroup
// Source 2 Viewer 15.0.0.0 - https://valveresourceformat.github.io

#version 460

vec4 _2;

struct _2210
{
    int bRoughnessMode;
    float g_fWearSoftness;
    vec3 g_vColor0;
    vec3 g_vColor1;
    vec3 g_vColor2;
    vec3 g_vColor3;
    float g_flColorBrightness;
    int g_nColorAdjustmentMode;
    float g_flPaintRoughness;
    float g_flPearlescentScale;
    int g_bPearlescentOnMetallicOnly;
    float g_flPaintMetalness;
    float g_flWearAmount;
    vec3 g_vPaintAlbedoLevels;
    vec3 g_vMetallicPaintAlbedoLevels;
};

layout(set = 1) uniform _2210 _Globals_;

layout(set = 1, binding = 30) uniform texture2D g_tAmbientOcclusion;
layout(set = 1, binding = 14) uniform sampler undetermined;
layout(set = 1, binding = 31) uniform texture2D g_tMasks;
layout(set = 1, binding = 15) uniform sampler undetermined_1;
layout(set = 1, binding = 38) uniform texture2D g_tWear;
layout(set = 1, binding = 29) uniform sampler undetermined_2;
layout(set = 1, binding = 37) uniform texture2D g_tPattern;
layout(set = 1, binding = 28) uniform sampler undetermined_3;
layout(set = 1, binding = 39) uniform texture2D g_tGrunge;
layout(set = 1, binding = 16) uniform sampler undetermined_4;
layout(set = 1, binding = 35) uniform texture2D g_tMetalness;
layout(set = 1, binding = 19) uniform sampler undetermined_5;
layout(set = 1, binding = 34) uniform texture2D g_tColor;
layout(set = 1, binding = 18) uniform sampler undetermined_6;
layout(set = 1, binding = 36) uniform texture2D g_tGlitterNormal;
layout(set = 1, binding = 22) uniform sampler undetermined_7;

layout(location = 1) in vec4 input_0;
layout(location = 2) in vec4 input_1;
layout(location = 0) out vec4 output_0;

void main()
{
    vec4 fvAoSrc = texture(sampler2D(g_tAmbientOcclusion, undetermined), input_0.xy);
    float flCavity = fvAoSrc.x;
    float flAo = fvAoSrc.y;

    vec4 fvMasks = texture(sampler2D(g_tMasks, undetermined_1), input_0.xy);
    vec4 fvPaintWear = texture(sampler2D(g_tWear, undetermined_2), input_1.xy);
    
    vec4 fvPattern = texture(sampler2D(g_tPattern, undetermined_3), input_0.zw);
    float flPatternAlpha = smoothstep(0.5, 0.6, fvPattern.a) * smoothstep(1.0, 0.9, fvPattern.a);

    float flDurability = max(0.0, smoothstep(0.0, 0.5, fvPattern.w));

    float flPaintWear = (((min(fvAoSrc.w, 1.0 - fvMasks.x) + (fvPaintWear.x * flCavity)) * ((g_flWearAmount * 6.0) + 1.0)) + flPatternAlpha) * flDurability;
    float flWearSoftness = g_fWearSoftness * flDurability;

    bool _18318 = fvMasks.x > 0.99;
    float flPaintBlend = mix(smoothstep(0.58 - flWearSoftness, 0.68 + flWearSoftness, flPaintWear), flPaintWear, float(_18318));
    
    vec4 cGrunge = texture(sampler2D(g_tGrunge, undetermined_4), input_1.zw);
    float flGrunge = saturate(cGrunge.x * cGrunge.y * cGrunge.z);

    cGrunge = mix(vec4(1.0), cGrunge, vec4((pow(1.0 - flCavity, 4.0) * 0.25) + (0.75 * g_flWearAmount)));
    
    float flPatinaBlend = smoothstep(0.1, 0.2, ((fvPaintWear.x * flAo) * (flCavity * flCavity)) * g_flWearAmount);
    float flOilRubBlend = smoothstep(0.0, 0.15, (saturate((flCavity * flAo) - (g_flWearAmount * 0.1)) - (flGrunge * 0.23)) + 0.08);
    
    float flMetalness;
    vec4 _11673;

    if (bRoughnessMode != 0) {
        vec4 fvMetalness = texture(sampler2D(g_tMetalness, undetermined_5), input_0.xy);

        float flInvPaintBlend = 1.0 - flPaintBlend;
        float _24500 = 1.0 - min(1.0, fvPattern.w * 2.0);
        float flGrungeLum = luminance(cGrunge.xyz);

        float wearTerm = (1.0 - cGrunge.w) * g_flWearAmount;

        float flRoughness = mix(_24500 * _24500 * 0.85 + 0.15, g_flPaintRoughness, float(fvPattern.w >= 0.5));
        flRoughness = mix(g_flPaintRoughness, flRoughness, fvMasks.x) * mix(1.0, 0.9, flPatinaBlend);
        flRoughness += (1.0 - flGrungeLum) * g_flWearAmount * 0.05;
        flRoughness += (1.0 - flOilRubBlend) * 0.15 * g_flWearAmount;

        flRoughness = saturate(flRoughness + wearTerm * 0.15);
        flMetalness = mix(mix(1.0, pow((flOilRubBlend * cGrunge.w) * flGrungeLum, 0.5), g_flWearAmount), 1.0, flPatinaBlend);

        fvMetalness.x = mix(fvMetalness.x, mix(min(1.0, flRoughness + ((wearTerm * g_flWearAmount) * 0.5)), flRoughness, fvMasks.x), float(max(int(_18318), int(max(0.0, flInvPaintBlend)))));
        fvMetalness.y = mix(mix(g_flPaintMetalness, fvMetalness.y, flPaintBlend), flMetalness, fvMasks.x);
        fvMetalness.z = flInvPaintBlend;

        if (g_bPearlescentOnMetallicOnly != 0)
        {
            vec4 _21219 = _13436;
            _21219.z = flInvPaintBlend * fvMasks.x;
            _21709 = _21219;
        }
        else
        {
            _21709 = _13436;
        }
        
        vec3 _18043 = _21709.xyz * vec3(0.077399380505084991455078125);
        vec3 _7676 = pow((_21709.xyz * vec3(0.947867333889007568359375)) + vec3(0.052132703363895416259765625), vec3(2.400000095367431640625));
        float _21354;
        if (_21709.x <= 0.040449999272823333740234375)
        {
            _21354 = _18043.x;
        }
        else
        {
            _21354 = _7676.x;
        }
        float _21355;
        if (_21709.y <= 0.040449999272823333740234375)
        {
            _21355 = _18043.y;
        }
        else
        {
            _21355 = _7676.y;
        }
        float _22686;
        if (_21709.z <= 0.040449999272823333740234375)
        {
            _22686 = _18043.z;
        }
        else
        {
            _22686 = _7676.z;
        }
        _11673 = vec4(_21354, _21355, _22686, min(1.0, g_flPearlescentScale));
        flMetalness = flMetalness;
    }
    else
    {
        _11673 = vec4(input_0.xy, 0.0, 1.0);
        flMetalness = 1.0;
    }
    vec4 _22401;
    if (!bRoughnessMode != 0)
    {
        vec3 flColorBrightness = fvPattern.xyz * mix(1.0, g_flColorBrightness, vec3(max(fvMasks.x, float(g_nColorAdjustmentMode))));

        vec3 cPatina = mix(g_vColor1, g_vColor2, g_flWearAmount);
        vec3 cOilRubColor = mix(g_vColor1, g_vColor3, pow(g_flWearAmount, 0.5));
        cPatina = mix(cOilRubColor, cPatina, flOilRubBlend) * flColorBrightness;

        float flPatternLum = luminance(flColorBrightness);
        vec3 cScratches = g_vColor0 * flPatternLum;

        vec3 cPaint = mix(cPatina, cScratches, flPatinaBlend);
        cPaint = mix(flColorBrightness, cPaint, fvMasks.x) * cGrunge.xyz;
        cPaint *= cGrunge.xyz;
        
        vec3 cPaintN = normalize(max(vec3(0.0003), cPaint));
        float nMax  = max(cPaintN.x, max(cPaintN.y, cPaintN.z));

        // 2) Уровни альбедо для paint/metallic
        vec3  vAlbedo  = mix(g_vPaintAlbedoLevels.xyz,
                            g_vMetallicPaintAlbedoLevels.xyz,
                            vec3(mix(g_flPaintMetalness, _10593, fvMasks.x)));

        // 3) Luma от смешанного brightness (с колормаской)
        float lum = luminance(mix(flColorBrightness, flColorBrightness * g_vColor1, fvMasks.x));

        float toneT = saturate(pow(max(cPaint.x, max(cPaint.y, cPaint.z)), vAlbedo.y));
        float target = mix(min(vAlbedo.x, lum), vAlbedo.z, toneT);
        vec3 painted = (cPaintN * target) / vec3(max(nMax, 1e-6));
        cPaint = mix(cPaint, painted, g_flWearAmount);

        // 8) База из текстуры
        vec3 cBase = texture(sampler2D(g_tColor, undetermined_6), input_0.xy).xyz;

        // 9) Финальный mix с базой
        vec3 outRGB = mix(cPaint, cBase, vec3(flPaintBlend * _13255));
        _22401 = vec4(outRGB, 1.0);
}
    else
    {
        _22401 = _11673;
    }
    vec4 _3401 = texture(sampler2D(g_tGlitterNormal, undetermined_7), input_0.xy);
    vec4 _6805;
    if (_3401.w < 0.0)
    {
        vec4 _23135 = _22401;
        _23135.x = _3401.x;
        _23135.y = _3401.y;
        _23135.z = _3401.z;
        _6805 = _23135;
    }
    else
    {
        _6805 = _22401;
    }
    output_0 = _6805;
}


