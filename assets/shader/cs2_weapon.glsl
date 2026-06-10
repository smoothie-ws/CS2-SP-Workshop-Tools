// SPIR-V reflection failed for backend HLSL:
// cbuffer ID 5538 (name: PerViewLightingConstantBufferGpu_t), member index 17 (name: _m17) cannot be expressed with either HLSL packing layout or packoffset.
// 
// Re-attempting reflection with the GLSL backend.

// SPIR-V source (70460 bytes), GLSL reflection with SPIRV-Cross by KhronosGroup
// Source 2 Viewer 17.0.0.0 - https://valveresourceformat.github.io

#version 460
#extension GL_KHR_shader_subgroup_arithmetic : require
#extension GL_EXT_samplerless_texture_functions : require
layout(early_fragment_tests) in;

struct _533
{
    vec4 _m0[4];
};

struct _1457
{
    vec4 _m0[3];
};

struct _534
{
    vec4 _m0[4];
};

struct _1458
{
    vec4 _m0[3];
};

struct _1408
{
    _1458 _m0;
    vec3 _m1;
    uint _m2;
    vec3 _m3;
    vec4 _m4;
    vec3 _m5;
    vec4 _m6;
};

struct _2932
{
    _1408 _m0[128];
};

struct _2009
{
    _533 _m0[4];
};

struct _2249
{
    _533 _m0;
    _533 _m1;
    vec4 _m2;
    vec4 _m3;
    vec4 _m4;
    vec4 _m5;
    vec3 _m6;
    uint _m7;
    vec4 _m8;
    vec4 _m9;
    vec4 _m10;
    float _m11;
    float _m12;
    uint _m13;
    uint _m14;
    _1458 _m15;
    vec4 _m16;
    vec4 _m17;
    vec4 _m18;
    vec4 _m19;
    vec4 _m20;
    vec3 _m21;
    float _m22;
};

vec2 _4;
vec4 _5;
vec3 _6;

struct _2800
{
    float g_flFogModificationAmount;
    int g_bFogEnabled;
    int g_bDontFlipBackfaceNormals;
    int g_bRenderBackfaceNormals;
    vec2 g_vMetalnessRemapRange;
    float g_flMetalnessTransitionBias;
    float g_flRainExposureToSkyWetness;
    float g_flRainExposureLocalTimer;
    float g_fGlitterScale;
    float g_fGlitterIntensity;
    float g_fGlitterRainbowSpread;
    float g_fGlitterRainbowBalance;
    float g_flUvScale1;
    int bIridescence;
    float g_flIridescentScale;
    float g_flIridescentStrength;
    float g_flIridescentHueShift;
    float g_flSpawnInvulnerability;
    vec3 g_cInvulnerabilityColor;
    vec4 g_vKeychainGhostHandData;
    float g_flPearlescentScale;
};

layout(set = 1) uniform _2800 _Globals_;

struct _1462
{
    ivec4 _m0;
    ivec4 _m1;
    ivec4 _m2;
    ivec4 _m3;
    float _m4;
    float _m5;
    ivec2 _m6;
    _533 _m7;
    vec2 _m8;
    float _m9;
    vec4 _m10;
    vec4 _m11;
    vec4 _m12;
    vec4 _m13;
    vec4 _m14;
    vec4 _m15;
    _533 _m16;
    vec4 _m17;
    vec4 _m18;
    vec4 _m19;
    float _m20;
    float _m21;
    vec4 _m22;
};

layout(set = 1) uniform _1462 PerViewConstantBufferCsgo_t;

struct _1552
{
    vec3 _m0;
    vec3 _m1;
    float _m2;
    vec4 _m3;
    vec2 _m4;
    vec2 _m5;
    float _m6;
    vec4 _m7;
};

layout(set = 1) uniform _1552 PerViewConstantBuffer_t;

struct _2206
{
    vec4 _m0;
    vec4 _m1;
    vec4 _m2;
    vec4 _m3;
    vec4 _m4;
    _1457 _m5;
    _534 _m6;
    vec4 _m7;
    vec4 _m8;
    vec4 _m9;
    vec4 _m10;
    vec4 _m11;
    uvec4 _m12;
    uvec4 _m13;
    uvec4 _m14;
    vec4 _m15;
    vec4 _m16;
    _2932 _m17;
    int _m18;
    float _m19;
    vec4 _m20;
    float _m21;
    float _m22;
    float _m23;
    float _m24;
    _2009 _m25;
    _534 _m26;
};

layout(set = 3) uniform _2206 PerViewLightingConstantBufferGpu_t;

layout(set = 3, binding = 30, std430) readonly buffer g_CullBits
{
    uint _m0[];
} g_CullBits_1;

layout(set = 3, binding = 31, std430) readonly buffer g_BarnLights
{
    _2249 _m0[];
} g_BarnLights_1;

layout(set = 1, binding = 58) uniform texture2D g_tDroplets;
layout(set = 1, binding = 14) uniform sampler Filter_85_MaxAniso_8_AllowGlobalMipBiasOverride_0;
layout(set = 1, binding = 43) uniform texture2D g_tColor;
layout(set = 1, binding = 20) uniform sampler Filter_255_MaxAniso_1_AddressU_dynamic_AddressV_dynamic;
layout(set = 1, binding = 57) uniform texture2D g_tAmbientOcclusion;
layout(set = 1, binding = 19) uniform sampler AllowGlobalMipBiasOverride_0_Filter_255_MaxAniso_1_AddressU_dynamic_AddressV_dynamic;
layout(set = 1, binding = 44) uniform texture2D g_tMetalness;
layout(set = 1, binding = 55) uniform texture2D g_tNormal;
layout(set = 1, binding = 60) uniform texture2D g_tGlitterNormal;
layout(set = 1, binding = 25) uniform sampler AddressU_0_AddressV_0_Filter_0_AddressW_0;
layout(set = 1, binding = 38) uniform texture2D g_tDynamicAmbientOcclusionDepth;
layout(set = 1, binding = 22) uniform sampler Filter_20_AddressU_3_AddressV_3_AddressW_3_BorderColor_0;
layout(set = 1, binding = 37) uniform texture2D g_tDynamicAmbientOcclusion;
layout(set = 1, binding = 18) uniform sampler AllowGlobalMipBiasOverride_0_AddressU_2_AddressV_2_AddressW_2_Filter_0;
layout(set = 1, binding = 39) uniform texture2D g_tSsao;
layout(set = 1, binding = 23) uniform samplerShadow AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3;
layout(set = 1, binding = 36) uniform texture2D g_tShadowDepthBufferDepth;
layout(set = 1, binding = 53) uniform texture2D g_tParticleShadowBuffer;
layout(set = 1, binding = 17) uniform sampler AllowGlobalMipBiasOverride_0_AddressU_2_AddressV_2_Filter_21;
layout(set = 1, binding = 34) uniform texture3D g_tLightCookieTexture;
layout(set = 1, binding = 16) uniform sampler AllowGlobalMipBiasOverride_0_Filter_21_AddressU_0_AddressV_0;
layout(set = 1, binding = 40) uniform textureCubeArray g_tEnvironmentMap;
layout(set = 1, binding = 15) uniform sampler AllowGlobalMipBiasOverride_0_Filter_20_AddressU_2_AddressV_2_AddressW_2;
layout(set = 1, binding = 35) uniform texture2DArray g_tBRDFLookup_unexpectedTypeId470_1107;
layout(set = 1, binding = 42) uniform textureCube g_tFogCubeTexture;
layout(set = 1, binding = 30) uniform texture2D g_tBlueNoise;

layout(location = 0) in vec3 input_0;
layout(location = 1) in vec3 input_1;
layout(location = 2) in vec3 input_2;
layout(location = 3) in vec4 input_3;
layout(location = 4) centroid in vec4 input_4;
layout(location = 5) centroid in vec3 input_5;
layout(location = 6) in vec4 input_6;
layout(location = 0) out vec4 output_0;

void main()
{
    vec4 _11408 = gl_FragCoord;
    _11408.w = 1.0 / _11408.w;
    float _12497 = g_flRainExposureToSkyWetness * PerViewConstantBufferCsgo_t._m5;
    bool _15436 = _12497 > 0.0;
    float _13136;
    vec2 _13998;
    float _16305;
    float _17114;
    vec4 _23261;
    if (_15436)
    {
        vec3 _10413 = input_1 + PerViewConstantBufferCsgo_t._m19.xyz;
        vec2 _20603 = input_3.xy * 2.5;
        vec2 _20826;
        if (float((length(cross(vec3(dFdx(input_3.xy), 0.0), vec3(dFdy(input_3.xy), 0.0))) / max(9.9999997473787516355514526367188e-05, length(cross(dFdx(_10413), dFdy(_10413))))) < 0.00200000009499490261077880859375) != 0.0)
        {
            _20826 = _20603 * 3.0;
        }
        else
        {
            _20826 = _20603;
        }
        vec4 _20877 = texture(sampler2D(g_tDroplets, Filter_85_MaxAniso_8_AllowGlobalMipBiasOverride_0), (_20826 + (_10413.xy * 9.9999997473787516355514526367188e-05)).xy);
        vec2 _8562 = (_20877.xy * 2.0) - vec2(1.0);
        _8562.y = -_8562.y;
        float _7729 = _20877.w;
        float _12471 = _20877.z + (input_0.x * 0.00999999977648258209228515625);
        float _10538 = clamp((((_12497 * 0.25) - fract(_12471 + (((g_flRainExposureLocalTimer * 0.100000001490116119384765625) * PerViewConstantBufferCsgo_t._m4) * PerViewConstantBufferCsgo_t._m4))) * 5.0) / (PerViewConstantBufferCsgo_t._m5 + 0.001000000047497451305389404296875), 0.0, 1.0) * clamp((input_2.z + 0.75) * 4.0, 0.0, 1.0);
        vec2 _13861 = input_3.xy + (((_8562.xy * (-0.0199999995529651641845703125)) * _10538) * _7729);
        vec4 _20488;
        _20488.x = _13861.x;
        _20488.y = _13861.y;
        _13136 = _10538;
        _16305 = _7729;
        _17114 = _12471;
        _13998 = _8562;
        _23261 = _20488;
    }
    else
    {
        _13136 = 0.0;
        _16305 = 0.0;
        _17114 = 0.0;
        _13998 = vec2(0.0);
        _23261 = input_3;
    }
    vec3 _21709;
    if (dot(input_2.xyz, input_2.xyz) >= 1.0099999904632568359375)
    {
        _21709 = input_5.xyz;
    }
    else
    {
        _21709 = input_2.xyz;
    }
    bool _14874 = g_bRenderBackfaceNormals != 0;
    bool _12885;
    if (_14874)
    {
        _12885 = !(g_bDontFlipBackfaceNormals != 0);
    }
    else
    {
        _12885 = false;
    }
    vec3 _10251;
    if (_12885)
    {
        _10251 = _21709 * (gl_FrontFacing ? 1.0 : (-1.0));
    }
    else
    {
        _10251 = _21709;
    }
    vec3 _24347 = normalize(_10251);
    vec3 _7639 = input_1 + PerViewConstantBufferCsgo_t._m19.xyz;
    vec4 _19680 = texture(sampler2D(g_tColor, Filter_255_MaxAniso_1_AddressU_dynamic_AddressV_dynamic), _23261.xy);
    vec3 _21103 = _19680.xyz * input_4.xyz;
    vec4 _18992 = texture(sampler2D(g_tAmbientOcclusion, AllowGlobalMipBiasOverride_0_Filter_255_MaxAniso_1_AddressU_dynamic_AddressV_dynamic), vec2(_23261.xy).xy);
    float _18168 = _18992.x;
    vec4 _21760 = texture(sampler2D(g_tMetalness, AllowGlobalMipBiasOverride_0_Filter_255_MaxAniso_1_AddressU_dynamic_AddressV_dynamic), _23261.xy);
    float _20079 = mix(g_vMetalnessRemapRange.x, g_vMetalnessRemapRange.y, _21760.y);
    float _24590 = _21760.z;
    float _6738 = _21760.x;
    vec2 _14437 = vec2(_6738);
    vec4 _19372 = texture(sampler2D(g_tNormal, AllowGlobalMipBiasOverride_0_Filter_255_MaxAniso_1_AddressU_dynamic_AddressV_dynamic), _23261.xy);
    float _16000 = _19372.x;
    float _19720 = _19372.y;
    float _16783 = (_16000 + _19720) - 1.00392162799835205078125;
    float _11176 = _16000 - _19720;
    vec3 _8418 = normalize(vec3(vec2(_16783, _11176), (1.0 - abs(_16783)) - abs(_11176)));
    bool _12886;
    if (_14874)
    {
        _12886 = !(g_bDontFlipBackfaceNormals != 0);
    }
    else
    {
        _12886 = false;
    }
    bool _24327;
    if (_12886)
    {
        _24327 = (gl_FrontFacing ? 1.0 : (-1.0)) < 0.0;
    }
    else
    {
        _24327 = false;
    }
    vec3 _12631 = input_2.xyz * (_24327 ? (-1.0) : 1.0);
    float _23240 = (input_6.w > 0.0) ? 1.0 : (-1.0);
    vec3 _14435 = cross(_12631.xyz, input_6.xyz) * _23240;
    bvec4 _24464 = notEqual(PerViewConstantBufferCsgo_t._m3, ivec4(0));
    bool _20058 = _24464.w;
    vec3 _7424;
    if (_20058)
    {
        _7424 = -_14435;
    }
    else
    {
        _7424 = _14435;
    }
    vec3 _20480;
    if (!_24327)
    {
        vec3 _7482 = _8418;
        _7482.y = -_8418.y;
        _20480 = _7482;
    }
    else
    {
        _20480 = _8418;
    }
    vec3 _7054 = normalize((((input_6.xyz * _20480.x).xyz + (_7424.xyz * _20480.y)).xyz + (_12631.xyz * _20480.z)).xyz);
    vec3 _6616;
    vec3 _13137;
    float _13694;
    vec2 _16306;
    vec3 _17115;
    if (_15436)
    {
        float _21270 = clamp((_6738 - 0.75) * 4.0, 0.0, 1.0);
        float _8927 = sqrt(1.0 - clamp(dot(_13998.xy, _13998.xy), 0.0, 1.0));
        float _20709 = saturate(_12497);
        float _23650 = (clamp((_13136 * _16305) + (_20709 * 0.5), 0.0, 1.0) * ((_21270 * 0.75) + 0.25)) * _20709;
        float _18483 = _13136 * saturate(1.0 - _21270);
        float _22907 = _18483 * _16305;
        _13137 = mix(_21103, pow(_21103, vec3(1.60000002384185791015625)) * 0.60000002384185791015625, vec3(_23650));
        _16306 = mix(_14437.xy, vec2(0.100000001490116119384765625), vec2(_18168 * clamp(((_22907 * 4.0) + ((((cos((_17114 + (g_flRainExposureLocalTimer * 0.20000000298023223876953125)) * 6.28318500518798828125) * 0.5) + 0.5) * _20709) * 0.20000000298023223876953125)) + (_12497 * 0.4000000059604644775390625), 0.0, 1.0)));
        _17115 = mix(normalize(mix(_24347, _7054, vec3(1.0 + (_23650 * 1.5)))), normalize((((input_6.xyz * _13998.x).xyz + (_7424.xyz * _13998.y)).xyz + (_24347.xyz * _8927)).xyz), vec3(_18483));
        _13694 = saturate(_22907 * 2.0);
        _6616 = mix(_20480, vec3(_13998.xy, _8927) * vec3(-1.0, -1.0, 1.0), vec3(_18483 * 0.25));
    }
    else
    {
        _13137 = _21103;
        _16306 = _14437;
        _17115 = vec3(1.0);
        _13694 = 0.0;
        _6616 = _20480;
    }
    vec3 _21710;
    if (g_flPearlescentScale != 0.0)
    {
        float _21433 = (g_flPearlescentScale * (1.0 - dot(normalize(PerViewConstantBuffer_t._m0.xyz - _7639.xyz), _7054))) * _24590;
        float _15271 = cos(_21433);
        float _12935;
        do
        {
            float _18473 = max(_13137.x, max(_13137.y, _13137.z));
            if (_18473 == 0.0)
            {
                _12935 = 0.0;
                break;
            }
            _12935 = (_18473 - min(_13137.x, min(_13137.y, _13137.z))) / _18473;
            break;
        } while(false);
        _21710 = mix(vec3(dot(_13137.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), ((_13137.xyz * _15271) + (cross(vec3(0.57735002040863037109375), _13137.xyz) * sin(_21433))) + ((vec3(0.57735002040863037109375) * dot(vec3(0.57735002040863037109375), _13137.xyz)) * (1.0 - _15271)), vec3(pow(_12935, 0.125)));
    }
    else
    {
        _21710 = _13137;
    }
    
    // GLITTER EFFECT
    float glitterIntensity = roughness * min(1.0, g_fGlitterIntensity);

    vec3 glitterColor;
    float metalness;
    vec2 roughnessMap;
    vec3 baseColor;
    vec3 normalMap;

    if (glitterIntensity != 0.0)
    {
        // Calculate view direction
        vec3 viewDir = normalize(PerViewConstantBuffer_t._m0.xyz - worldPosition.xyz);
        
        // Setup glitter texture coordinates
        float glitterScale = notEqual(PerViewConstantBufferCsgo_t._m2, ivec4(0)).x ? 2.5 : 1.75;
        vec2 glitterUV = surfaceUV.xy * (glitterScale * g_fGlitterScale * g_flUvScale1);
        
        // Sample glitter normal map
        vec4 glitterNormal = texture(sampler2D(g_tGlitterNormal, AddressU_0_AddressV_0_Filter_0_AddressW_0), glitterUV);
        
        // Decode normal from texture
        vec3 decodedNormal = decodeNormal(glitterNormal.xy);
        vec3 glitterBump = decodedNormal * decodedNormal.z;
        vec3 blendedNormal = glitterBump.xyz + baseNormal.xyz;
        
        // Calculate glitter reflection
        vec3 reflectedDir = reflect(viewDir, normalize(transformToTangentSpace(blendedNormal)));
        vec3 rainbowEffect = sin(reflectedDir * mix(12.0, 5.6, g_fGlitterRainbowSpread));
        
        // Apply rainbow spectrum
        vec3 rainbowColor = calculateRainbowSpectrum(rainbowEffect);
        
        // Calculate glitter alpha
        float glitterAlpha = glitterNormal.w;
        float glitterMask = (glitterIntensity * glitterAlpha) * abs(1.0 - glitterBump.z);
        
        // Output values
        glitterColor = rainbowColor * glitterAlpha * dot(viewDir, tangentNormal) * g_fGlitterIntensity;
        roughnessMap = roughness * (1.0 - glitterMask * 0.25);
        baseColor = baseColorValue * mix(1.0 + glitterMask * 2.5, 1.0, luminance(baseColorValue));
        metalness = max(metallicValue, glitterMask * 0.5 * glitterIntensity);
        normalMap = baseNormal + (glitterBump * glitterIntensity * clamp(1.0 - mipLevel * 40.0, 0.0, 1.0));
    }
    else
    {
        // No glitter effect
        glitterColor = vec3(0.0);
        roughnessMap = roughness;
        baseColor = baseColorValue;
        metalness = metallicValue;
        normalMap = baseNormal;
    }

    vec3 _7866 = _24173;
    _7866.y = -_24173.y;
    bool _12887;
    if (_14874)
    {
        _12887 = !(g_bDontFlipBackfaceNormals != 0);
    }
    else
    {
        _12887 = false;
    }
    bool _24328;
    if (_12887)
    {
        _24328 = (gl_FrontFacing ? 1.0 : (-1.0)) < 0.0;
    }
    else
    {
        _24328 = false;
    }
    vec3 _9739 = input_2.xyz * (_24328 ? (-1.0) : 1.0);
    vec3 _24682 = cross(_9739.xyz, input_6.xyz) * _23240;
    vec3 _7425;
    if (_20058)
    {
        _7425 = -_24682;
    }
    else
    {
        _7425 = _24682;
    }
    vec3 _20481;
    if (!_24328)
    {
        vec3 _23482 = _7866;
        _23482.y = _24173.y;
        _20481 = _23482;
    }
    else
    {
        _20481 = _7866;
    }
    vec3 _14786 = normalize((((input_6.xyz * _20481.x).xyz + (_7425.xyz * _20481.y)).xyz + (_9739.xyz * _20481.z)).xyz);
    vec3 _17328 = mix(vec3(0.0199999995529651641845703125), _17116.xyz, vec3(_13999));

    // IRIDESCENCE
    vec3 _22671;
    if (bIridescence != 0)
    {
        // Calculate view direction and iridescence angle
        vec3 viewDir = normalize(PerViewConstantBuffer_t._m0.xyz - _7639.xyz);
        float hueAngle = fract(
            ((dot(viewDir, _24347) + dot(viewDir, PerViewLightingConstantBufferGpu_t._m10.xyz)) 
             * g_flIridescentScale) 
            + g_flIridescentHueShift
        ) * 6.0;
        
        // Determine hue color based on angle (0-6 range for spectrum)
        float hueIndex = floor(hueAngle);
        float hueFraction = hueAngle - hueIndex;
        float hueFractionInverse = 1.0 - hueFraction;
        
        vec3 hueColor;
        if (hueIndex == 0.0)
            hueColor = vec3(1.0, hueFraction, 0.0);  // Red to Yellow
        else if (hueIndex == 1.0)
            hueColor = vec3(hueFractionInverse, 1.0, 0.0);  // Yellow to Green
        else if (hueIndex == 2.0)
            hueColor = vec3(0.0, 1.0, hueFraction);  // Green to Cyan
        else if (hueIndex == 3.0)
            hueColor = vec3(0.0, hueFractionInverse, 1.0);  // Cyan to Blue
        else if (hueIndex == 4.0)
            hueColor = vec3(hueFraction, 0.0, 1.0);  // Blue to Magenta
        else
            hueColor = vec3(1.0, 0.0, hueFractionInverse);  // Magenta to Red
        
        // Calculate luminance of base color
        vec4 baseColor = vec4(_17328.xyz, 1.0);
        float luminance = dot(baseColor.xyz, vec3(0.212500, 0.715400, 0.072100));
        
        // Normalize hue color and calculate iridescent color
        vec3 normalizedHue = normalize(max(hueColor.xyz, vec3(0.001)));
        vec3 iridescentColor = (_normalizedHue * min(
            luminance / dot(normalizedHue.xyz, vec3(0.212500, 0.715400, 0.072100)),
            (3.0 * luminance) * max(hueColor.x, max(hueColor.y, hueColor.z))
        )).xyz;
        
        // Blend base color with iridescent color
        _22671 = clamp(
            mix(baseColor.xyz, iridescentColor, vec3(g_flIridescentStrength * _24590)),
            vec3(0.0),
            vec3(1.0)
        );
    }
    else
    {
        _22671 = _17328;
    }

    vec3 _17892 = mix(_17115, _14786, bvec3(all(equal(_17115, vec3(1.0)))));
    vec3 _10560 = _24347.xyz;
    vec3 _11100 = dFdx(_10560);
    vec3 _9175 = dFdy(_10560);
    vec3 _10347 = _11100.xyz;
    vec3 _12420 = _9175.xyz;
    vec2 _11004 = max(_16308.xy, vec2(pow(clamp(max(dot(_10347, _10347), dot(_12420, _12420)), 0.0, 1.0), 0.333000004291534423828125)));
    bvec4 _24465 = notEqual(PerViewConstantBufferCsgo_t._m1, ivec4(0));
    float _21711;
    if (_24465.x)
    {
        vec3 _11394 = _24347.xyz;
        vec2 _10548 = ((floor(_11408.xy * PerViewConstantBufferCsgo_t._m9) * PerViewConstantBufferCsgo_t._m8.xy) + (PerViewConstantBufferCsgo_t._m8.xy * 0.5)).xy;
        vec4 _18418 = textureGather(sampler2D(g_tDynamicAmbientOcclusionDepth, Filter_20_AddressU_3_AddressV_3_AddressW_3_BorderColor_0), _10548).xyzw - _11408.zzzz;
        float _18579 = _18418.w;
        float _12013 = _18418.z;
        bool _12285 = abs(_12013) < _18579;
        vec2 _23168;
        if (_12285)
        {
            _23168 = vec2(PerViewConstantBufferCsgo_t._m8.x, 0.0);
        }
        else
        {
            _23168 = vec2(0.0);
        }
        float _20965 = _12285 ? _12013 : _18579;
        float _15372 = _18418.x;
        bool _12286 = abs(_15372) < _20965;
        vec2 _23169;
        if (_12286)
        {
            _23169 = vec2(0.0, PerViewConstantBufferCsgo_t._m8.y);
        }
        else
        {
            _23169 = _23168;
        }
        vec4 _17422 = (max(vec4(dot(PerViewLightingConstantBufferGpu_t._m6._m0[0].xyz, _11394), dot(PerViewLightingConstantBufferGpu_t._m6._m0[1].xyz, _11394), dot(PerViewLightingConstantBufferGpu_t._m6._m0[2].xyz, _11394), dot(PerViewLightingConstantBufferGpu_t._m6._m0[3].xyz, _11394)).xyzw, vec4(0.0)).xyzw * PerViewLightingConstantBufferGpu_t._m7.xyzw).xyzw;
        _21711 = (1.0 / (dot(_17422, vec4(1.0)) + PerViewLightingConstantBufferGpu_t._m8.x)) * (PerViewLightingConstantBufferGpu_t._m8.x + dot(_17422, textureLod(sampler2D(g_tDynamicAmbientOcclusion, AllowGlobalMipBiasOverride_0_AddressU_2_AddressV_2_AddressW_2_Filter_0), (_10548 + mix(_23169, PerViewConstantBufferCsgo_t._m8.xy, bvec2(abs(_18418.y) < (_12286 ? _15372 : _20965))).xy).xy, 0.0).xyzw));
    }
    else
    {
        _21711 = 1.0;
    }
    float _21785;
    if (notEqual(PerViewConstantBufferCsgo_t._m0, ivec4(0)).w)
    {
        _21785 = _21711 * textureLod(sampler2D(g_tSsao, AllowGlobalMipBiasOverride_0_Filter_255_MaxAniso_1_AddressU_dynamic_AddressV_dynamic), (_11408.xy * PerViewConstantBuffer_t._m3.xy).xy, 0.0).x;
    }
    else
    {
        _21785 = _21711;
    }
    vec3 _24735 = _14786.xyz;
    vec4 _23875 = vec4(_24735, 1.0);
    vec3 _18708 = vec3(dot(PerViewLightingConstantBufferGpu_t._m5._m0[0].xyzw, _23875), dot(PerViewLightingConstantBufferGpu_t._m5._m0[1].xyzw, _23875), dot(PerViewLightingConstantBufferGpu_t._m5._m0[2].xyzw, _23875));
    float _21712;
    if (PerViewLightingConstantBufferGpu_t._m18 != 0)
    {
        int _23989;
        int _10191;
        float _13139;
        vec3 _14975;
        int _13039 = 0;
        for (;;)
        {
            if (!(_13039 < PerViewLightingConstantBufferGpu_t._m18))
            {
                _13139 = 1.0;
                _14975 = vec3(0.0);
                _10191 = -1;
                break;
            }
            vec4 _18322 = vec4(input_1.xyz, 1.0) * mat4(vec4(PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[0].x, PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[1].x, PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[2].x, PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[3].x), vec4(PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[0].y, PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[1].y, PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[2].y, PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[3].y), vec4(PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[0].z, PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[1].z, PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[2].z, PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[3].z), vec4(PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[0].w, PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[1].w, PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[2].w, PerViewLightingConstantBufferGpu_t._m25._m0[_13039]._m0[3].w));
            float _12779 = _18322.x;
            if (max(abs(_12779), abs(_18322.y)) < PerViewLightingConstantBufferGpu_t._m20[_13039])
            {
                vec3 _19470 = vec3(_12779, _18322.yz);
                vec2 _24804 = _19470.xy;
                vec2 _22193 = vec2(1.0) - clamp((abs(_24804) * vec2(PerViewLightingConstantBufferGpu_t._m22)) + vec2(PerViewLightingConstantBufferGpu_t._m21), vec2(0.0), vec2(1.0));
                vec2 _20561 = (_24804 * PerViewLightingConstantBufferGpu_t._m26._m0[_13039].zw) + PerViewLightingConstantBufferGpu_t._m26._m0[_13039].xy;
                vec3 _20489 = _19470;
                _20489.x = _20561.x;
                _20489.y = _20561.y;
                _13139 = saturate(_22193.x * _22193.y);
                _14975 = _20489;
                _10191 = _13039;
                break;
            }
            _23989 = _13039 + 1;
            _13039 = _23989;
            continue;
        }
        float _19363;
        if (_10191 >= 0)
        {
            vec2 _7045;
            vec2 _7046;
            vec2 _7735;
            float _8969;
            float _8970;
            float _15996;
            float _17299;
            vec2 _18870;
            vec4 _20581;
            vec4 _22023;
            float _23727;
            do
            {
                float _21452 = saturate(_14975.z + PerViewLightingConstantBufferGpu_t._m19);
                _20581 = PerViewLightingConstantBufferGpu_t._m0;
                _22023 = PerViewLightingConstantBufferGpu_t._m1;
                _17299 = PerViewLightingConstantBufferGpu_t._m2.z;
                _15996 = PerViewLightingConstantBufferGpu_t._m3.z;
                _18870 = vec2(_17299, _15996);
                _8969 = PerViewLightingConstantBufferGpu_t._m2.y;
                _7045 = vec2(_8969, _15996);
                _8970 = PerViewLightingConstantBufferGpu_t._m3.y;
                _7046 = vec2(_17299, _8970);
                _7735 = vec2(_8969, _8970);
                float _15310 = dot(vec4(textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14975.xy + _18870).xy, _21452), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14975.xy + _7045).xy, _21452), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14975.xy + _7046).xy, _21452), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14975.xy + _7735).xy, _21452), 0.0)).xyzw, vec4(0.25));
                bool _12888;
                if (_15310 == 0.0)
                {
                    _12888 = true;
                }
                else
                {
                    _12888 = _15310 == 1.0;
                }
                if (_12888)
                {
                    _23727 = _15310;
                    break;
                }
                _23727 = ((_15310 * (_20581.w * 4.0)) + dot(vec4(textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14975.xy + vec2(_17299, 0.0)).xy, _21452), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14975.xy + vec2(_8969, 0.0)).xy, _21452), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14975.xy + vec2(0.0, _8970)).xy, _21452), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14975.xy + vec2(0.0, _15996)).xy, _21452), 0.0)).xyzw, _22023.xxxx)) + (textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3(_14975.xy, _21452), 0.0) * _22023.y);
                break;
            } while(false);
            float _12506;
            if (_13139 < 1.0)
            {
                float _7934;
                if (_10191 < (PerViewLightingConstantBufferGpu_t._m18 - 1))
                {
                    int _15335 = _10191 + 1;
                    vec4 _19671 = vec4(input_1.xyz, 1.0) * mat4(vec4(PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[0].x, PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[1].x, PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[2].x, PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[3].x), vec4(PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[0].y, PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[1].y, PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[2].y, PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[3].y), vec4(PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[0].z, PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[1].z, PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[2].z, PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[3].z), vec4(PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[0].w, PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[1].w, PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[2].w, PerViewLightingConstantBufferGpu_t._m25._m0[_15335]._m0[3].w));
                    vec2 _20562 = (_19671.xy * PerViewLightingConstantBufferGpu_t._m26._m0[_15335].zw) + PerViewLightingConstantBufferGpu_t._m26._m0[_15335].xy;
                    vec3 _20490;
                    _20490.x = _20562.x;
                    _20490.y = _20562.y;
                    float _12505;
                    do
                    {
                        float _20322 = saturate(_19671.z + PerViewLightingConstantBufferGpu_t._m19);
                        float _15311 = dot(vec4(textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_20490.xy + _18870).xy, _20322), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_20490.xy + _7045).xy, _20322), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_20490.xy + _7046).xy, _20322), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_20490.xy + _7735).xy, _20322), 0.0)).xyzw, vec4(0.25));
                        bool _12889;
                        if (_15311 == 0.0)
                        {
                            _12889 = true;
                        }
                        else
                        {
                            _12889 = _15311 == 1.0;
                        }
                        if (_12889)
                        {
                            _12505 = _15311;
                            break;
                        }
                        _12505 = ((_15311 * (_20581.w * 4.0)) + dot(vec4(textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_20490.xy + vec2(_17299, 0.0)).xy, _20322), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_20490.xy + vec2(_8969, 0.0)).xy, _20322), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_20490.xy + vec2(0.0, _8970)).xy, _20322), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_20490.xy + vec2(0.0, _15996)).xy, _20322), 0.0)).xyzw, _22023.xxxx)) + (textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3(_20490.xy, _20322), 0.0) * _22023.y);
                        break;
                    } while(false);
                    _7934 = _12505;
                }
                else
                {
                    _7934 = 1.0;
                }
                _12506 = mix(_7934, _23727, _13139);
            }
            else
            {
                _12506 = _23727;
            }
            _19363 = _12506;
        }
        else
        {
            _19363 = 1.0;
        }
        float _13279 = mix(_19363, 1.0, clamp((distance(_7639.xyz, PerViewConstantBuffer_t._m0) * PerViewLightingConstantBufferGpu_t._m24) + PerViewLightingConstantBufferGpu_t._m23, 0.0, 1.0));
        float _12507;
        if (_24465.y)
        {
            _12507 = min(_13279, textureLod(sampler2D(g_tParticleShadowBuffer, AllowGlobalMipBiasOverride_0_AddressU_2_AddressV_2_Filter_21), (_11408.xy * PerViewConstantBuffer_t._m3.xy).xy, 0.0).z);
        }
        else
        {
            _12507 = _13279;
        }
        _21712 = _12507;
    }
    else
    {
        _21712 = 1.0;
    }
    vec3 _9716;
    vec3 _24878;
    if ((dot(PerViewLightingConstantBufferGpu_t._m10.xyz, _24735) * _21712) > 0.0)
    {
        vec3 _15460 = mix(_17892, _24735, bvec3(all(equal(_17892, vec3(1.0)))));
        float _13811 = max(0.0, dot(_14786.xyz, PerViewLightingConstantBufferGpu_t._m10.xyz));
        vec3 _17874 = vec3(_13811);
        vec3 _18223;
        if (_13694 > 0.0)
        {
            float _8780 = dot(_15460, PerViewLightingConstantBufferGpu_t._m10.xyz);
            float _8124 = saturate(_13694);
            _18223 = mix(_17874.xyz, vec3((((0.5 + (_13811 * 0.5)) + pow(1.0 - saturate(_8780), 4.0)) * clamp((_8780 + 0.20000000298023223876953125) * 4.0, 0.0, 1.0)) * clamp(mix(dot(mix(_24735, _15460, vec3(10.0)), PerViewLightingConstantBufferGpu_t._m10.xyz), 1.0, _8124), 0.0, 1.0)), vec3(_8124));
        }
        else
        {
            _18223 = _17874;
        }
        vec2 _17301 = max(_11004, vec2(PerViewLightingConstantBufferGpu_t._m10.w));
        vec3 _21889 = (-normalize(_7639.xyz - PerViewConstantBuffer_t._m0.xyz)).xyz;
        vec3 _12281 = normalize(PerViewLightingConstantBufferGpu_t._m10.xyz + _21889).xyz;
        vec3 _19012 = _15460.xyz;
        float _12386 = dot(_12281, _19012);
        float _9850 = _17301.x;
        float _25211 = _9850 * _9850;
        float _24198 = _25211 / (((_12386 * _12386) * ((_25211 * _25211) - 1.0)) + 1.0);
        float _16150 = _9850 + 1.0;
        float _6835 = (_16150 * _16150) * 0.125;
        float _19569 = 1.0 - _6835;
        vec3 _16808 = (PerViewLightingConstantBufferGpu_t._m11.xyz * _21712).xyz;
        _9716 = PerViewLightingConstantBufferGpu_t._m9.xyz + (_18223.xyz * _16808);
        _24878 = (((_22671.xyz + ((vec3(1.0) - _22671.xyz) * pow(max(9.9999999747524270787835121154785e-07, 1.0 - max(0.0, dot(PerViewLightingConstantBufferGpu_t._m10.xyz, _12281))), 5.0))) * ((_24198 * _24198) / ((4.0 * ((_13811 * _19569) + _6835)) * ((max(0.0, dot(_19012, _21889)) * _19569) + _6835)))).xyz * _13811).xyz * _16808;
    }
    else
    {
        _9716 = PerViewLightingConstantBufferGpu_t._m9.xyz;
        _24878 = vec3(0.0);
    }
    bvec4 _24467 = notEqual(PerViewConstantBufferCsgo_t._m2, ivec4(0));
    bool _20061 = _24467.x;
    vec4 _19364;
    if (_20061)
    {
        vec4 _24259 = vec4(_7639.xyz, 1.0).xyzw * mat4(vec4(PerViewConstantBufferCsgo_t._m7._m0[0].x, PerViewConstantBufferCsgo_t._m7._m0[1].x, PerViewConstantBufferCsgo_t._m7._m0[2].x, PerViewConstantBufferCsgo_t._m7._m0[3].x), vec4(PerViewConstantBufferCsgo_t._m7._m0[0].y, PerViewConstantBufferCsgo_t._m7._m0[1].y, PerViewConstantBufferCsgo_t._m7._m0[2].y, PerViewConstantBufferCsgo_t._m7._m0[3].y), vec4(PerViewConstantBufferCsgo_t._m7._m0[0].z, PerViewConstantBufferCsgo_t._m7._m0[1].z, PerViewConstantBufferCsgo_t._m7._m0[2].z, PerViewConstantBufferCsgo_t._m7._m0[3].z), vec4(PerViewConstantBufferCsgo_t._m7._m0[0].w, PerViewConstantBufferCsgo_t._m7._m0[1].w, PerViewConstantBufferCsgo_t._m7._m0[2].w, PerViewConstantBufferCsgo_t._m7._m0[3].w));
        float _20176 = _24259.w;
        vec2 _11414 = _24259.xy / vec2(_20176);
        vec4 _6651;
        _6651.x = clamp(((_11414.x + 1.0) * PerViewConstantBuffer_t._m5.x) * 0.5, 0.0, PerViewConstantBuffer_t._m5.x - 1.0);
        _6651.y = clamp(((1.0 - _11414.y) * PerViewConstantBuffer_t._m5.y) * 0.5, 0.0, PerViewConstantBuffer_t._m5.y - 1.0);
        _6651.w = _20176;
        _19364 = _6651;
    }
    else
    {
        _19364 = _11408;
    }
    uvec2 _7663 = uvec2(PerViewLightingConstantBufferGpu_t._m14.x);
    uvec2 _12083 = uvec2(_19364.xy - PerViewConstantBuffer_t._m4.xy) >> _7663;
    uint _10838 = PerViewLightingConstantBufferGpu_t._m12.y + (((_12083.y * PerViewLightingConstantBufferGpu_t._m14.y) + _12083.x) * PerViewLightingConstantBufferGpu_t._m12.z);
    uint _23393 = PerViewLightingConstantBufferGpu_t._m12.x + (uint(clamp(_19364.w * PerViewLightingConstantBufferGpu_t._m15.x, 0.0, PerViewLightingConstantBufferGpu_t._m15.y)) * PerViewLightingConstantBufferGpu_t._m12.z);
    vec3 _13140;
    vec3 _16324;
    _13140 = _9716;
    _16324 = _24878;
    uint _21567;
    vec3 _13141;
    vec3 _16325;
    uint _17017 = 0u;
    for (;;)
    {
        if (!(_17017 < PerViewLightingConstantBufferGpu_t._m12.z))
        {
            break;
        }
        uint _14475 = subgroupOr(g_CullBits_1._m0[_10838 + _17017] & g_CullBits_1._m0[_23393 + _17017]);
        _13141 = _16324;
        _16325 = _13140;
        uint _20344;
        vec3 _13212;
        vec3 _15670;
        uint _17018 = _14475;
        for (;;)
        {
            if (!(_17018 != 0u))
            {
                break;
            }
            int _12608 = int(uint(findLSB(_17018)) + (_17017 * 32u));
            _20344 = _17018 & (_17018 - 1u);
            do
            {
                vec4 _15817 = mat4(vec4(g_BarnLights_1._m0[_12608]._m0._m0[0].x, g_BarnLights_1._m0[_12608]._m0._m0[1].x, g_BarnLights_1._m0[_12608]._m0._m0[2].x, g_BarnLights_1._m0[_12608]._m0._m0[3].x), vec4(g_BarnLights_1._m0[_12608]._m0._m0[0].y, g_BarnLights_1._m0[_12608]._m0._m0[1].y, g_BarnLights_1._m0[_12608]._m0._m0[2].y, g_BarnLights_1._m0[_12608]._m0._m0[3].y), vec4(g_BarnLights_1._m0[_12608]._m0._m0[0].z, g_BarnLights_1._m0[_12608]._m0._m0[1].z, g_BarnLights_1._m0[_12608]._m0._m0[2].z, g_BarnLights_1._m0[_12608]._m0._m0[3].z), vec4(g_BarnLights_1._m0[_12608]._m0._m0[0].w, g_BarnLights_1._m0[_12608]._m0._m0[1].w, g_BarnLights_1._m0[_12608]._m0._m0[2].w, g_BarnLights_1._m0[_12608]._m0._m0[3].w)) * vec4(input_1.xyz, 1.0);
                vec3 _10521 = _15817.xyz / vec3(_15817.w);
                vec4 _22905;
                _22905.x = _10521.x;
                _22905.y = _10521.y;
                float _21775 = _10521.z;
                _22905.z = _21775;
                vec3 _21642 = _22905.xyz;
                bool _7426;
                if (all(greaterThan(_22905.xyz, vec3(-1.0, -1.0, 0.0))))
                {
                    _7426 = all(lessThan(_22905.xyz, vec3(1.0)));
                }
                else
                {
                    _7426 = false;
                }
                bool _12890;
                if (!_7426)
                {
                    _12890 = true;
                }
                else
                {
                    _12890 = !all(lessThanEqual(abs((mat4x3(vec3(g_BarnLights_1._m0[_12608]._m15._m0[0].x, g_BarnLights_1._m0[_12608]._m15._m0[1].x, g_BarnLights_1._m0[_12608]._m15._m0[2].x), vec3(g_BarnLights_1._m0[_12608]._m15._m0[0].y, g_BarnLights_1._m0[_12608]._m15._m0[1].y, g_BarnLights_1._m0[_12608]._m15._m0[2].y), vec3(g_BarnLights_1._m0[_12608]._m15._m0[0].z, g_BarnLights_1._m0[_12608]._m15._m0[1].z, g_BarnLights_1._m0[_12608]._m15._m0[2].z), vec3(g_BarnLights_1._m0[_12608]._m15._m0[0].w, g_BarnLights_1._m0[_12608]._m15._m0[1].w, g_BarnLights_1._m0[_12608]._m15._m0[2].w)) * vec4(input_1.xyz, 1.0)).xyz), vec3(1.0)));
                }
                if (_12890)
                {
                    _13212 = _13141;
                    _15670 = _16325;
                    break;
                }
                float _23571 = 2.0 * g_BarnLights_1._m0[_12608]._m5.y;
                float _18492 = (2.0 * g_BarnLights_1._m0[_12608]._m5.z) * g_BarnLights_1._m0[_12608]._m5.z;
                float _14805 = 2.0 * g_BarnLights_1._m0[_12608]._m5.x;
                float _9058 = _14805 * g_BarnLights_1._m0[_12608]._m5.y;
                float _17330 = 2.0 * g_BarnLights_1._m0[_12608]._m5.w;
                float _19825 = _17330 * g_BarnLights_1._m0[_12608]._m5.z;
                vec3 _16268 = vec3(_9058 - _19825, (1.0 - (_14805 * g_BarnLights_1._m0[_12608]._m5.x)) - _18492, (_23571 * g_BarnLights_1._m0[_12608]._m5.z) + (_17330 * g_BarnLights_1._m0[_12608]._m5.x)) * g_BarnLights_1._m0[_12608]._m6.z;
                float _21316;
                if (g_BarnLights_1._m0[_12608]._m3.z > 0.0)
                {
                    _21316 = smoothstep(0.0, 1.0, _21775 * g_BarnLights_1._m0[_12608]._m3.z);
                }
                else
                {
                    _21316 = 1.0;
                }
                float _19667;
                if (g_BarnLights_1._m0[_12608]._m3.w > 0.0)
                {
                    _19667 = _21316 * smoothstep(0.0, 1.0, (1.0 - _21775) * g_BarnLights_1._m0[_12608]._m3.w);
                }
                else
                {
                    _19667 = _21316;
                }
                vec3 _11179;
                float _11633;
                if (g_BarnLights_1._m0[_12608]._m2.w != 0.0)
                {
                    vec3 _10017 = g_BarnLights_1._m0[_12608]._m2.xyz - input_1.xyz;
                    float _18345 = dot(_10017, _10017);
                    float _17647 = sqrt(_18345);
                    vec3 _20958 = _10017 - _16268;
                    vec3 _10210;
                    do
                    {
                        vec3 _20229 = (_10017 + _16268) - _20958;
                        float _25105 = dot(-_20958, _20229);
                        if (_25105 <= 0.0)
                        {
                            _10210 = _20958;
                            break;
                        }
                        else
                        {
                            _10210 = _20958 + (_20229 * min(1.0, _25105 / dot(_20229, _20229)));
                            break;
                        }
                        break; // unreachable workaround
                    } while(false);
                    _11179 = _10017 / vec3(_17647);
                    _11633 = ((_19667 * (g_BarnLights_1._m0[_12608]._m2.w / max(_18345, g_BarnLights_1._m0[_12608]._m2.w))) * smoothstep(0.0, 1.0, g_BarnLights_1._m0[_12608]._m3.x + (g_BarnLights_1._m0[_12608]._m3.y * _17647))) * clamp(g_BarnLights_1._m0[_12608]._m6.x + (g_BarnLights_1._m0[_12608]._m6.y * dot(vec3((1.0 - (_23571 * g_BarnLights_1._m0[_12608]._m5.y)) - _18492, _9058 + _19825, (_14805 * g_BarnLights_1._m0[_12608]._m5.z) - (_17330 * g_BarnLights_1._m0[_12608]._m5.y)), normalize(_10210))), 0.0, 1.0);
                }
                else
                {
                    _11179 = g_BarnLights_1._m0[_12608]._m2.xyz;
                    _11633 = _19667;
                }
                vec3 _17828 = (g_BarnLights_1._m0[_12608]._m4.xyz * 1.0).xyz * _11633;
                bool _24419;
                if (g_BarnLights_1._m0[_12608]._m8.z > 0.0)
                {
                    _24419 = !_20061;
                }
                else
                {
                    _24419 = false;
                }
                vec3 _21548;
                if (g_BarnLights_1._m0[_12608]._m4.w == 0.0)
                {
                    float _10342;
                    do
                    {
                        vec2 _22155 = abs(_22905.xy);
                        if (g_BarnLights_1._m0[_12608]._m9.z == 0.0)
                        {
                            _10342 = smoothstep(1.0, g_BarnLights_1._m0[_12608]._m9.x, _22155.x) * smoothstep(1.0, g_BarnLights_1._m0[_12608]._m9.y, _22155.y);
                            break;
                        }
                        else
                        {
                            float _11473 = _22155.x;
                            float _15267 = 2.0 / g_BarnLights_1._m0[_12608]._m9.z;
                            float _15017 = _22155.y;
                            float _23041 = (-0.5) * g_BarnLights_1._m0[_12608]._m9.z;
                            float _11981 = (g_BarnLights_1._m0[_12608]._m9.x * g_BarnLights_1._m0[_12608]._m9.y) * pow(max(pow(g_BarnLights_1._m0[_12608]._m9.y * _11473, _15267) + pow(g_BarnLights_1._m0[_12608]._m9.x * _15017, _15267), 1.1754943508222875079687365372222e-38), _23041);
                            float _16524 = pow(max(pow(_11473, _15267) + pow(_15017, _15267), 1.1754943508222875079687365372222e-38), _23041);
                            if (_11981 < _16524)
                            {
                                _10342 = smoothstep(_16524, _11981, 1.0);
                                break;
                            }
                            else
                            {
                                _10342 = float(_16524 > 1.0);
                                break;
                            }
                            break; // unreachable workaround
                        }
                        break; // unreachable workaround
                    } while(false);
                    _21548 = _17828.xyz * _10342;
                }
                else
                {
                    vec3 _12508;
                    if (g_BarnLights_1._m0[_12608]._m4.w < 0.0)
                    {
                        vec4 _17795 = vec4(-g_BarnLights_1._m0[_12608]._m5.xyz, g_BarnLights_1._m0[_12608]._m5.w);
                        vec4 _19008 = _17795.xyzw * vec4(-1.0, -1.0, -1.0, 1.0);
                        vec3 _24989 = _19008.xyz;
                        vec3 _23629 = vec4((-_11179).xyz, 0.0).xyz;
                        float _15156 = -dot(_23629, _24989);
                        vec3 _20479 = vec4((_23629 * _19008.w) + cross(_23629, _24989), _15156).xyz;
                        vec3 _23593 = _17795.xyz;
                        vec3 _12170 = ((_20479 * g_BarnLights_1._m0[_12608]._m5.w) + (_23593 * _15156)) + cross(_23593, _20479);
                        vec3 _14081 = vec3(vec2(atan(_12170.y, -_12170.x) * 0.15915493667125701904296875, acos(_12170.z) * 0.3183098733425140380859375), -g_BarnLights_1._m0[_12608]._m4.w);
                        vec2 _20564 = (_14081.xy * g_BarnLights_1._m0[_12608]._m9.zw) + g_BarnLights_1._m0[_12608]._m9.xy;
                        vec3 _20492 = _14081;
                        _20492.x = _20564.x;
                        _20492.y = _20564.y;
                        _12508 = _17828.xyz * textureLod(sampler3D(g_tLightCookieTexture, AllowGlobalMipBiasOverride_0_Filter_21_AddressU_0_AddressV_0), _20492.xyz, 0.0).xyz;
                    }
                    else
                    {
                        vec3 _13791 = vec3(fma(_22905.xy, vec2(0.5, -0.5), vec2(0.5)), g_BarnLights_1._m0[_12608]._m4.w);
                        vec2 _20563 = (_13791.xy * g_BarnLights_1._m0[_12608]._m9.zw) + g_BarnLights_1._m0[_12608]._m9.xy;
                        vec3 _20491 = _13791;
                        _20491.x = _20563.x;
                        _20491.y = _20563.y;
                        _12508 = _17828.xyz * textureLod(sampler3D(g_tLightCookieTexture, Filter_20_AddressU_3_AddressV_3_AddressW_3_BorderColor_0), _20491.xyz, 0.0).xyz;
                    }
                    _21548 = _12508;
                }
                if (all(equal(_21548.xyz, vec3(0.0))))
                {
                    _13212 = _13141;
                    _15670 = _16325;
                    break;
                }
                vec3 _21549;
                if (_24419)
                {
                    vec3 _19629;
                    if ((g_BarnLights_1._m0[_12608]._m13 & 4u) != 0u)
                    {
                        vec2 _6281 = _22905.yx * vec2(1.0, -1.0);
                        vec3 _23715 = _21642;
                        _23715.x = _6281.x;
                        _23715.y = _6281.y;
                        _19629 = _23715;
                    }
                    else
                    {
                        _19629 = _21642;
                    }
                    float _24972;
                    do
                    {
                        float _11455 = saturate(_19629.z + PerViewLightingConstantBufferGpu_t._m19);
                        vec2 _14616 = vec3(fma(_19629.xy, g_BarnLights_1._m0[_12608]._m8.zw, g_BarnLights_1._m0[_12608]._m8.xy), _19629.z).xy;
                        float _15313 = dot(vec4(textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14616 + vec2(PerViewLightingConstantBufferGpu_t._m2.z, PerViewLightingConstantBufferGpu_t._m3.z)).xy, _11455), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14616 + vec2(PerViewLightingConstantBufferGpu_t._m2.y, PerViewLightingConstantBufferGpu_t._m3.z)).xy, _11455), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14616 + vec2(PerViewLightingConstantBufferGpu_t._m2.z, PerViewLightingConstantBufferGpu_t._m3.y)).xy, _11455), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14616 + vec2(PerViewLightingConstantBufferGpu_t._m2.y, PerViewLightingConstantBufferGpu_t._m3.y)).xy, _11455), 0.0)).xyzw, vec4(0.25));
                        bool _12891;
                        if (_15313 == 0.0)
                        {
                            _12891 = true;
                        }
                        else
                        {
                            _12891 = _15313 == 1.0;
                        }
                        if (_12891)
                        {
                            _24972 = _15313;
                            break;
                        }
                        _24972 = ((_15313 * (PerViewLightingConstantBufferGpu_t._m0.w * 4.0)) + dot(vec4(textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14616 + vec2(PerViewLightingConstantBufferGpu_t._m2.z, 0.0)).xy, _11455), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14616 + vec2(PerViewLightingConstantBufferGpu_t._m2.y, 0.0)).xy, _11455), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14616 + vec2(0.0, PerViewLightingConstantBufferGpu_t._m3.y)).xy, _11455), 0.0), textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3((_14616 + vec2(0.0, PerViewLightingConstantBufferGpu_t._m3.z)).xy, _11455), 0.0)).xyzw, PerViewLightingConstantBufferGpu_t._m1.xxxx)) + (textureLod(sampler2DShadow(g_tShadowDepthBufferDepth, AddressU_2_AddressV_2_Filter_149_ComparisonFunc_3), vec3(_14616, _11455), 0.0) * PerViewLightingConstantBufferGpu_t._m1.y);
                        break;
                    } while(false);
                    vec3 _19878 = _21548.xyz * mix(1.0, _24972, g_BarnLights_1._m0[_12608]._m12);
                    if (all(equal(_19878.xyz, vec3(0.0))))
                    {
                        _13212 = _13141;
                        _15670 = _16325;
                        break;
                    }
                    _21549 = _19878;
                }
                else
                {
                    _21549 = _21548;
                }
                vec3 _15462 = mix(_17892, _24735, bvec3(all(equal(_17892, vec3(1.0)))));
                float _13812 = max(0.0, dot(_14786.xyz, _11179.xyz));
                vec3 _17875 = vec3(_13812);
                vec3 _18224;
                if (_13694 > 0.0)
                {
                    float _8781 = dot(_15462, _11179.xyz);
                    float _8125 = saturate(_13694);
                    _18224 = mix(_17875.xyz, vec3((((0.5 + (_13812 * 0.5)) + pow(1.0 - saturate(_8781), 4.0)) * clamp((_8781 + 0.20000000298023223876953125) * 4.0, 0.0, 1.0)) * clamp(mix(dot(mix(_24735, _15462, vec3(10.0)), _11179.xyz), 1.0, _8125), 0.0, 1.0)), vec3(_8125));
                }
                else
                {
                    _18224 = _17875;
                }
                vec2 _17302 = max(_11004, vec2(g_BarnLights_1._m0[_12608]._m11));
                vec3 _21890 = (-normalize(_7639.xyz - PerViewConstantBuffer_t._m0.xyz)).xyz;
                vec3 _12282 = normalize(_11179.xyz + _21890).xyz;
                vec3 _19014 = _15462.xyz;
                float _12387 = dot(_12282, _19014);
                float _9851 = _17302.x;
                float _25213 = _9851 * _9851;
                float _24199 = _25213 / (((_12387 * _12387) * ((_25213 * _25213) - 1.0)) + 1.0);
                float _16151 = _9851 + 1.0;
                float _6836 = (_16151 * _16151) * 0.125;
                float _19571 = 1.0 - _6836;
                _13212 = _13141.xyz + ((((_22671.xyz + ((vec3(1.0) - _22671.xyz) * pow(max(9.9999999747524270787835121154785e-07, 1.0 - max(0.0, dot(_11179.xyz, _12282))), 5.0))) * ((_24199 * _24199) / ((4.0 * ((_13812 * _19571) + _6836)) * ((max(0.0, dot(_19014, _21890)) * _19571) + _6836)))).xyz * _13812).xyz * _21549.xyz);
                _15670 = _16325.xyz + (_18224.xyz * _21549.xyz);
                break;
            } while(false);
            _13141 = _13212;
            _16325 = _15670;
            _17018 = _20344;
            continue;
        }
        _21567 = _17017 + 1u;
        _13140 = _16325;
        _16324 = _13141;
        _17017 = _21567;
        continue;
    }
    vec3 _10145 = normalize(_7639.xyz - PerViewConstantBuffer_t._m0.xyz);
    vec3 _19257 = -_10145;
    float _19582 = (_11004.x + _11004.y) * 0.5;
    float _6489 = _19582 * _19582;
    float _17751 = dot(_11004.xy, vec2(0.5));
    vec3 _6519 = _17892.xyz;
    vec3 _19081 = _17892.xyz;
    float _12853 = PerViewLightingConstantBufferGpu_t._m16.y * sqrt(_17751);
    vec3 _11901 = _7639.xyz;
    vec3 _11008;
    vec4 _14444;
    if (PerViewConstantBufferCsgo_t._m21 != 0.0)
    {
        float _9642 = dot(vec4(((_11901 + PerViewConstantBuffer_t._m7.xyz) + ((-PerViewConstantBuffer_t._m1) * PerViewConstantBufferCsgo_t._m21)).xyz, 1.0), vec4(PerViewConstantBuffer_t._m1.xyz, dot((PerViewConstantBuffer_t._m7.xyz + PerViewConstantBuffer_t._m0.xyz).xyz + (PerViewConstantBuffer_t._m1.xyz * PerViewConstantBuffer_t._m2), PerViewConstantBuffer_t._m1.xyz)));
        vec3 _21713;
        if (_9642 <= 0.0)
        {
            _21713 = _7639;
        }
        else
        {
            _21713 = _11901 + ((-PerViewConstantBuffer_t._m1.xyz) * _9642);
        }
        vec4 _19975 = vec4(_21713.xyz, 1.0) * mat4(vec4(PerViewConstantBufferCsgo_t._m7._m0[0].x, PerViewConstantBufferCsgo_t._m7._m0[1].x, PerViewConstantBufferCsgo_t._m7._m0[2].x, PerViewConstantBufferCsgo_t._m7._m0[3].x), vec4(PerViewConstantBufferCsgo_t._m7._m0[0].y, PerViewConstantBufferCsgo_t._m7._m0[1].y, PerViewConstantBufferCsgo_t._m7._m0[2].y, PerViewConstantBufferCsgo_t._m7._m0[3].y), vec4(PerViewConstantBufferCsgo_t._m7._m0[0].z, PerViewConstantBufferCsgo_t._m7._m0[1].z, PerViewConstantBufferCsgo_t._m7._m0[2].z, PerViewConstantBufferCsgo_t._m7._m0[3].z), vec4(PerViewConstantBufferCsgo_t._m7._m0[0].w, PerViewConstantBufferCsgo_t._m7._m0[1].w, PerViewConstantBufferCsgo_t._m7._m0[2].w, PerViewConstantBufferCsgo_t._m7._m0[3].w));
        float _20177 = _19975.w;
        vec2 _11415 = _19975.xy / vec2(_20177);
        vec4 _6652;
        _6652.x = clamp(((_11415.x + 1.0) * PerViewConstantBuffer_t._m5.x) * 0.5, 0.0, PerViewConstantBuffer_t._m5.x - 1.0);
        _6652.y = clamp(((1.0 - _11415.y) * PerViewConstantBuffer_t._m5.y) * 0.5, 0.0, PerViewConstantBuffer_t._m5.y - 1.0);
        _6652.w = _20177;
        _11008 = _21713;
        _14444 = _6652;
    }
    else
    {
        _11008 = _11901;
        _14444 = _11408.xyzw;
    }
    float _22047 = _17751 * _17751;
    float _20711 = saturate(1.0 - _22047);
    vec3 _25271 = normalize(mix(_6519, reflect(_10145.xyz, _19081).xyz, vec3(_20711 * (sqrt(_20711) + _22047))));
    uvec2 _6814 = uvec2(_14444.xy - PerViewConstantBuffer_t._m4.xy) >> _7663;
    uint _12130 = PerViewLightingConstantBufferGpu_t._m13.y + (((_6814.y * PerViewLightingConstantBufferGpu_t._m14.y) + _6814.x) * PerViewLightingConstantBufferGpu_t._m13.z);
    uint _23394 = PerViewLightingConstantBufferGpu_t._m13.x + (uint(clamp(_14444.w * PerViewLightingConstantBufferGpu_t._m15.x, 0.0, PerViewLightingConstantBufferGpu_t._m15.y)) * PerViewLightingConstantBufferGpu_t._m13.z);
    vec4 _13142;
    float _16309;
    vec3 _17117;
    _13142 = vec4(0.0);
    _16309 = 0.00999999977648258209228515625;
    _17117 = vec3(0.0);
    uint _8896;
    vec4 _13145;
    vec3 _14891;
    float _16311;
    bool _18379;
    uint _17020 = 0u;
    bool _17133 = false;
    for (;;)
    {
        bool _12892;
        if (_17020 < PerViewLightingConstantBufferGpu_t._m13.z)
        {
            _12892 = !_17133;
        }
        else
        {
            _12892 = false;
        }
        if (!_12892)
        {
            break;
        }
        uint _14476 = subgroupOr(g_CullBits_1._m0[_12130 + _17020] & g_CullBits_1._m0[_23394 + _17020]);
        vec3 _13143;
        vec4 _16310;
        _13143 = _17117;
        _16310 = _13142;
        uint _10156;
        vec3 _13144;
        vec4 _16381;
        float _16479;
        uint _17021 = _14476;
        float _17134 = _16309;
        for (;;)
        {
            bool _7956_ladder_break = false;
            do
            {
                if (!(_17021 != 0u))
                {
                    _13145 = _16310;
                    _16311 = _17134;
                    _14891 = _13143;
                    _18379 = _17133;
                    _7956_ladder_break = true;
                    break;
                }
                int _12609 = int(uint(findLSB(_17021)) + (_17020 * 32u));
                _10156 = _17021 & (_17021 - 1u);
                mat4x3 _16416 = mat4x3(vec3(PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m0._m0[0].x, PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m0._m0[1].x, PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m0._m0[2].x), vec3(PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m0._m0[0].y, PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m0._m0[1].y, PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m0._m0[2].y), vec3(PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m0._m0[0].z, PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m0._m0[1].z, PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m0._m0[2].z), vec3(PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m0._m0[0].w, PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m0._m0[1].w, PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m0._m0[2].w));
                vec3 _21376 = (_16416 * vec4(_11008.xyz, 1.0)).xyz;
                vec3 _8793 = clamp((_21376 - PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m1) * PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m4.xyz, vec3(0.0), vec3(1.0));
                vec3 _19651 = clamp((PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m3 - _21376) * PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m4.xyz, vec3(0.0), vec3(1.0));
                float _17265 = min(min(_8793.x, min(_8793.y, _8793.z)), min(_19651.x, min(_19651.y, _19651.z)));
                if (_17265 == 0.0)
                {
                    _13144 = _13143;
                    _16381 = _16310;
                    _16479 = _17134;
                    break;
                }
                vec3 _19630;
                if (PerViewConstantBufferCsgo_t._m20 != 0.0)
                {
                    vec3 _19779 = PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m1 + ((PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m3 - PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m1) * 0.5);
                    _19630 = ((_21376 - _19779) * PerViewConstantBufferCsgo_t._m20) + _19779;
                }
                else
                {
                    _19630 = _21376;
                }
                vec3 _7648 = (_16416 * vec4(_25271.xyz, 0.0)).xyz;
                vec3 _11253 = max(((PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m3.xyz - _19630.xyz) / _7648).xyz, ((PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m1.xyz - _19630.xyz) / _7648).xyz);
                float _11076 = ((_17265 * _17265) * (((-2.0) * _17265) + 3.0)) * (1.0 - _17134);
                float _13713 = _17134 + _11076;
                vec3 _22473 = _13143 + ((textureLod(samplerCubeArray(g_tEnvironmentMap, AllowGlobalMipBiasOverride_0_Filter_21_AddressU_0_AddressV_0), vec4(mix(_19630.xyz + (_7648 * abs(min(_11253.x, min(_11253.y, _11253.z)))), _7648, vec3(_17751)).xyz, float(PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m2)), _12853).xyz * PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m5) * _11076);
                vec4 _17103 = _16310 + (PerViewLightingConstantBufferGpu_t._m17._m0[_12609]._m6 * _11076);
                if (_13713 > 0.9900000095367431640625)
                {
                    _13145 = _17103;
                    _16311 = _13713;
                    _14891 = _22473;
                    _18379 = true;
                    _7956_ladder_break = true;
                    break;
                }
                _13144 = _22473;
                _16381 = _17103;
                _16479 = _13713;
                break;
            } while(false);
            if (_7956_ladder_break)
            {
                break;
            }
            _13143 = _13144;
            _16310 = _16381;
            _17134 = _16479;
            _17021 = _10156;
            continue;
        }
        _8896 = _17020 + 1u;
        _13142 = _13145;
        _16309 = _16311;
        _17117 = _14891;
        _17133 = _18379;
        _17020 = _8896;
        continue;
    }
    vec4 _11487 = textureLod(sampler2DArray(g_tBRDFLookup_unexpectedTypeId470_1107, AllowGlobalMipBiasOverride_0_Filter_20_AddressU_2_AddressV_2_AddressW_2), vec3((vec2(_17751, sqrt(1.0 - max(0.0, dot(_19257.xyz, _6519)))) * 0.984375) + vec2(0.0078125), 1.0).xyz, 0.0);
    vec3 _7300 = mix(_11487.xxx, _11487.yyy, _22671);
    float _21809 = 1.0 - _11487.y;
    vec3 _15517 = _22671 + ((vec3(1.0) - _22671) * vec3(0.0476190485060214996337890625));
    vec3 _23208 = ((_7300 * _15517) / (vec3(1.0) - (_15517 * _21809))) * _21809;
    vec3 _13438 = vec3(_18168 * _21785).xyz;
    vec3 _17067 = (_13140.xyz * vec3(_21785)).xyz + ((_18708 * (vec3(1.0) - (_7300 + _23208))).xyz * vec3(_21785 * _18168).xyz).xyz;
    vec3 _22686 = _17067 * (_17116.xyz * pow(1.0 - _13999, g_flMetalnessTransitionBias)).xyz;
    float _12931 = _22686.x;
    vec4 _11203 = vec4(_12931, _22686.yz, input_4.w);
    _11203.x = _12931;
    _11203.y = _22686.y;
    _11203.z = _22686.z;
    vec3 _15752 = _11203.xyz + ((_16324 * (vec3(1.0) + (_22671 * (((2.0 * _6489) * _6489) * clamp(dot(_17892, _19257), 0.0, 1.0))))).xyz * _13438).xyz;
    vec4 _20493 = _11203;
    _20493.x = _15752.x;
    _20493.y = _15752.y;
    _20493.z = _15752.z;
    vec3 _15733 = _20493.xyz + ((((_17117 / vec3(_16309)).xyz * min(dot(_18708.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125)) / dot(vec4(_19081, 1.0), (_13142 / vec4(_16309)).xyzw), max((_17751 * PerViewLightingConstantBufferGpu_t._m4.x) + PerViewLightingConstantBufferGpu_t._m4.y, 1.0))).xyz * (_7300 + _23208)).xyz * _13438).xyz;
    vec4 _13888 = _20493;
    _13888.x = _15733.x;
    _13888.y = _15733.y;
    _13888.z = _15733.z;
    vec3 _20178 = _13888.xyz + (_17067 * _13138.xyz);
    vec4 _20494 = _13888;
    _20494.x = _20178.x;
    _20494.y = _20178.y;
    _20494.z = _20178.z;
    vec4 _19366;
    if (g_bFogEnabled != 0)
    {
        vec3 _21493;
        vec3 _6538 = _11901 - PerViewConstantBuffer_t._m0.xyz;
        vec3 _9057 = _6538.xyz;
        vec3 _19340;
        do
        {
            _21493 = _6538.xyz;
            bool _12893;
            if (dot(_21493, _21493) > PerViewConstantBufferCsgo_t._m13.x)
            {
                _12893 = (_7639.z * PerViewConstantBufferCsgo_t._m13.z) < PerViewConstantBufferCsgo_t._m13.y;
            }
            else
            {
                _12893 = false;
            }
            if (_12893)
            {
                float _17979 = length(_21493);
                vec2 _9342 = clamp(PerViewConstantBufferCsgo_t._m10.xy + (PerViewConstantBufferCsgo_t._m10.zw * vec2(mix(_17979, _17979 * PerViewConstantBufferCsgo_t._m22.y, g_flFogModificationAmount), _7639.z)), vec2(0.0), vec2(1.0));
                float _13533 = (pow(_9342.x, PerViewConstantBufferCsgo_t._m11.x) * pow(_9342.y, PerViewConstantBufferCsgo_t._m11.y)) * PerViewConstantBufferCsgo_t._m12.w;
                float _12715 = mix(_13533, _13533 * PerViewConstantBufferCsgo_t._m22.z, g_flFogModificationAmount);
                _19340 = mix(_20494.xyz, vec4(PerViewConstantBufferCsgo_t._m12.xyz, _12715).xyz, vec3(_12715));
                break;
            }
            _19340 = _20494.xyz;
            break;
        } while(false);
        vec4 _23944 = _20494;
        _23944.x = _19340.x;
        _23944.y = _19340.y;
        _23944.z = _19340.z;
        vec3 _19341;
        do
        {
            bool _12894;
            if (dot(_9057, _9057) > PerViewConstantBufferCsgo_t._m17.x)
            {
                _12894 = (PerViewConstantBufferCsgo_t._m17.z * _7639.z) < PerViewConstantBufferCsgo_t._m17.y;
            }
            else
            {
                _12894 = false;
            }
            if (_12894)
            {
                float _17980 = length(_21493);
                float _14602 = clamp(pow(max(0.0, (mix(_17980, _17980 * PerViewConstantBufferCsgo_t._m22.y, g_flFogModificationAmount) * PerViewConstantBufferCsgo_t._m14.y) + PerViewConstantBufferCsgo_t._m14.x), PerViewConstantBufferCsgo_t._m14.w), 0.0, 1.0) * clamp(pow(max(0.0, (_7639.z * PerViewConstantBufferCsgo_t._m15.y) + PerViewConstantBufferCsgo_t._m15.x), PerViewConstantBufferCsgo_t._m15.z), 0.0, 1.0);
                float _16973 = saturate(_14602) * mix(PerViewConstantBufferCsgo_t._m17.w, PerViewConstantBufferCsgo_t._m17.w * PerViewConstantBufferCsgo_t._m22.z, g_flFogModificationAmount);
                _19341 = mix(_23944.xyz, vec4((textureLod(samplerCube(g_tFogCubeTexture, AllowGlobalMipBiasOverride_0_AddressU_2_AddressV_2_Filter_21), normalize((mat4(vec4(PerViewConstantBufferCsgo_t._m16._m0[0].x, PerViewConstantBufferCsgo_t._m16._m0[1].x, PerViewConstantBufferCsgo_t._m16._m0[2].x, PerViewConstantBufferCsgo_t._m16._m0[3].x), vec4(PerViewConstantBufferCsgo_t._m16._m0[0].y, PerViewConstantBufferCsgo_t._m16._m0[1].y, PerViewConstantBufferCsgo_t._m16._m0[2].y, PerViewConstantBufferCsgo_t._m16._m0[3].y), vec4(PerViewConstantBufferCsgo_t._m16._m0[0].z, PerViewConstantBufferCsgo_t._m16._m0[1].z, PerViewConstantBufferCsgo_t._m16._m0[2].z, PerViewConstantBufferCsgo_t._m16._m0[3].z), vec4(PerViewConstantBufferCsgo_t._m16._m0[0].w, PerViewConstantBufferCsgo_t._m16._m0[1].w, PerViewConstantBufferCsgo_t._m16._m0[2].w, PerViewConstantBufferCsgo_t._m16._m0[3].w)) * vec4(_9057, 0.0)).xyz).xyz, PerViewConstantBufferCsgo_t._m15.w * clamp(1.0 - (_14602 * PerViewConstantBufferCsgo_t._m14.z), 0.0, 1.0)) * PerViewConstantBufferCsgo_t._m18.x).xyz, _16973).xyz, vec3(_16973));
                break;
            }
            _19341 = _23944.xyz;
            break;
        } while(false);
        _23944.x = _19341.x;
        _23944.y = _19341.y;
        _23944.z = _19341.z;
        _19366 = _23944;
    }
    else
    {
        _19366 = _20494;
    }
    vec3 _19342;
    if (g_flSpawnInvulnerability > 0.0)
    {
        float _9657 = 1.0 - clamp(dot(_19257, _24735), 0.0, 1.0);
        _19342 = mix(_19366.xyz, g_cInvulnerabilityColor * (mix(dot(_19366.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125)), 0.5, 0.5) + (4.0 * pow(mix(_9657 * texelFetch(g_tBlueNoise, ivec3(ivec2(_11408.xy) & PerViewConstantBufferCsgo_t._m6, 0).xy, 0).y, 1.0, _9657), mix(3.0, 6.0, 1.0 + (sin(PerViewConstantBuffer_t._m6 * 20.0) * 0.5))))), vec3(g_flSpawnInvulnerability));
    }
    else
    {
        _19342 = _19366.xyz;
    }
    vec4 _23946 = _19366;
    _23946.x = _19342.x;
    _23946.y = _19342.y;
    _23946.z = _19342.z;
    if (g_vKeychainGhostHandData.w > 0.0)
    {
        float _11567 = clamp((smoothstep(6.0, 2.0, distance(g_vKeychainGhostHandData.xyz, _11901)) - 1.0) * (-1.0), 0.0, 1.0);
        if ((texelFetch(g_tBlueNoise, ivec3(ivec2(_11408.xy) & PerViewConstantBufferCsgo_t._m6, 0).xy, 0).y - mix((_11567 * 0.5099999904632568359375) + 0.5, (_11567 * 0.90999996662139892578125) + 0.100000001490116119384765625, smoothstep(0.100000001490116119384765625, 1.0, g_vKeychainGhostHandData.w))) < 0.0)
        {
            discard;
        }
    }
    output_0 = _23946;
}


