import lib-sampler.glsl

#include "std/utils.glsl"
#include "std/texturing.glsl"

#define SO PAINT_STYLE == 0 // Solid Color
#define HY PAINT_STYLE == 1 // Hydrographic
#define SP PAINT_STYLE == 2 // Spray-Paint
#define AN PAINT_STYLE == 3 // Anodized
#define AM PAINT_STYLE == 4 // Anodized Multicolored
#define AA PAINT_STYLE == 5 // Anodized Airbrushed
#define CU PAINT_STYLE == 6 // Custom Paint Job
#define AQ PAINT_STYLE == 7 // Patina
#define GS PAINT_STYLE == 8 // Gunsmith

//: param custom { "default": [1.0, 0.0, 0.0, 0.0] }
uniform vec4 g_vPatternTexCoordXform0;
//: param custom { "default": [0.0, 1.0, 0.0, 0.0] }
uniform vec4 g_vPatternTexCoordXform1;
//: param custom { "default": [1.0, 0.0, 0.0, 0.0] }
uniform vec4 g_vWearTexCoordXform0;
//: param custom { "default": [0.0, 1.0, 0.0, 0.0] }
uniform vec4 g_vWearTexCoordXform1;
//: param custom { "default": [1.0, 0.0, 0.0, 0.0] }
uniform vec4 g_vGrungeTexCoordXform0;
//: param custom { "default": [0.0, 1.0, 0.0, 0.0] }
uniform vec4 g_vGrungeTexCoordXform1;

//: param custom { "default": true }
uniform bool g_bOverrideDefaultMasks;
//: param custom { "default": true }
uniform bool g_bOverrideAmbientOcclusion;
//: param custom { "default": true }
uniform bool g_bUseNormalMap;
//: param custom { "default": true }
uniform bool g_bUseRoughness;
//: param custom { "default": true }
uniform bool g_bUsePearlescenceMask;

//: param custom { "default": 0.0 }
uniform float g_flWearAmount;
//: param custom { "default": 0.6 }
uniform float g_flPaintRoughness;
//: param custom { "default": 0.0 }
uniform float g_flPearlescentScale;
#if !AQ
//: param custom { "default": 0.0 }
    uniform float g_fWearSoftness;
#endif
#if !CU
//: param custom { "default": [0.50, 0.50, 0.50] }
    uniform vec3 g_vColor0;
    #if !AN
//: param custom { "default": [0.59, 0.59, 0.59] }
        uniform vec3 g_vColor1;
//: param custom { "default": [0.38, 0.38, 0.38] }
        uniform vec3 g_vColor2;
//: param custom { "default": [0.42, 0.42, 0.42] }
        uniform vec3 g_vColor3;
    #endif
#endif
#if !CU && !AQ && !GS
//: param custom { "default": [0.0, 0.0, 0.0, 0.0] }
    uniform vec4 g_vPaintDurability;
    #if SO || HY || SP
//: param custom { "default": false }
        uniform bool g_bRoughnessPerColor;
//: param custom { "default": [0.6, 0.6, 0.6, 0.6] }
        uniform vec4 g_vPaintRoughness;
//: param custom { "default": [0.0, 0.0, 0.0, 0.0] }
        uniform vec4 g_vPaintMetalness;
    #endif
#else
    #if !CU
//: param custom { "default": 1 }
        uniform int g_nColorAdjustmentMode;
    #endif
    #if !AQ
//: param custom { "default": 0.0 }
        uniform float g_flPaintMetalness;
    #endif
    #if GS
//: param custom { "default": 0 }
        uniform int g_bPearlescentOnMetallicOnly;
    #endif
#endif
#if !SO
//: param custom { "default": 1.0 }
    uniform float g_flColorBrightness;
    #if SP || AA
//: param custom { "default": [1.0, 0.0, 0.0, 0.0] }
        uniform vec4 g_vPatternTexCoordXformHalftoneA0;
//: param custom { "default": [0.0, 1.0, 0.0, 0.0] }
        uniform vec4 g_vPatternTexCoordXformHalftoneA1;
//: param custom { "default": [1.0, 0.0, 0.0, 0.0] }
        uniform vec4 g_vPatternTexCoordXformHalftoneB0;
//: param custom { "default": [0.0, 1.0, 0.0, 0.0] }
        uniform vec4 g_vPatternTexCoordXformHalftoneB1;
//: param custom { "default": [1.0, 0.0, 0.0, 0.0] }
        uniform vec4 g_vPatternTexCoordXformHalftoneC0;
//: param custom { "default": [0.0, 1.0, 0.0, 0.0] }
        uniform vec4 g_vPatternTexCoordXformHalftoneC1;
//: param custom { "default": false }
        uniform int bSpraypaintHalftone;
//: param custom { "default": [0.0, 1.0, 1.0] }
        uniform vec3 g_vSprayBiasBlend;
//: param custom { "default": 1.0 }
        uniform float g_fHalftoneCavityCutoff;
        uniform vec3 g_vHalftonePatternLevels;
        uniform vec2 g_vHalftoneThresholds;
//: param custom { "default": 1 }
        uniform int g_bHalftoneInCavity;
    #endif
#endif

// Weapon Base Textures ------------------------------------------- //

//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D g_tColor;
//: param custom { "default": "", "default_color": [1.0, 0.5, 0.5] }
uniform sampler2D g_tMetalness;
//: param custom { "default": "", "default_color": [0.5, 0.5, 1.0] }
uniform sampler2D g_tSurface;
//: param custom { "default": "", "default_color": [1.0, 0.5, 0.5] }
uniform sampler2D g_tAmbientOcclusion;
#if !SP && !CU
//: param custom { "default": "", "default_color": [1.0, 0.0, 0.0] }
    uniform sampler2D g_tMasks;
#endif

// Grunge Textures ------------------------------------------------ //

//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D g_tWear;
//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D g_tGrunge;

#if EXTERN_MODE
//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
    uniform sampler2D g_tPattern;
//: param custom { "default": "", "default_color": [1.0, 0.5, 0.5] }
    uniform sampler2D g_tPaintRoughness;
//: param custom { "default": "", "default_color": [1.0, 0.0, 0.0] }
    uniform sampler2D g_tPaintMasks;
//: param custom { "default": "", "default_color": [0.0, 0.0, 0.0] }
    uniform sampler2D g_tPearlescenceMask;
//: param custom { "default": "", "default_color": [0.5, 0.5, 1.0] }
    uniform sampler2D g_tPaintNormal;
//: param custom { "default": "", "default_color": [1.0, 1.0, 1.0] }
    uniform sampler2D g_tPaintAO;
#else
//: param auto channel_basecolor
    uniform SamplerSparse g_tPattern;
//: param auto channel_roughness
    uniform SamplerSparse g_tPaintRoughness;
//: param auto channel_user0
    uniform SamplerSparse g_tPaintMasks;
//: param auto channel_user1
    uniform SamplerSparse g_tPaintAlpha;
//: param auto channel_user2
    uniform SamplerSparse g_tPearlescenceMask;
#endif

#if SO || HY || SP
    float mixSOHYSP(vec4 v
        #if !SP
            , vec3 m 
        #endif
        #if !SO
            , vec3 e
        #endif
    ) {
        float f = v.x;
        #if SO
            f = mix(f, v.y, m.x);
        #else
            f = mix(f, v.y, e.x);
            f = mix(f, v.z, e.y);
            f = mix(f, v.w, e.z);
        #endif
        #if !SP
            f = mix(f, v.z, m.y);
            f = mix(f, v.w, m.z);
        #endif
        return f;
    }
#endif

#if !AN && !AM && !AA
    const vec3 g_vPaintAlbedoLevels = vec3(0.045, 1.32193264, 1.00);
#endif
const vec3 g_vMetallicPaintAlbedoLevels = vec3(0.080, 1.32193264, 1.00);

void composeCustomWeapon(V2F inputs, out ShaderOutputs outputs) {
    // ----- VS ----- 

    vec4 vBaseUV_PatternUV = vec4(inputs.tex_coord, 
        dot(inputs.tex_coord, g_vPatternTexCoordXform0.xy) + g_vPatternTexCoordXform0.w, 
        dot(inputs.tex_coord, g_vPatternTexCoordXform1.xy) + g_vPatternTexCoordXform1.w
    );
    vec4 vWearUV_GrungeUV = vec4(
        dot(inputs.tex_coord, g_vWearTexCoordXform0.xy) + g_vWearTexCoordXform0.w, 
        dot(inputs.tex_coord, g_vWearTexCoordXform1.xy) + g_vWearTexCoordXform1.w, 
        dot(inputs.tex_coord, g_vGrungeTexCoordXform0.xy) + g_vGrungeTexCoordXform0.w, 
        dot(inputs.tex_coord, g_vGrungeTexCoordXform1.xy) + g_vGrungeTexCoordXform1.w
    );
    
    // ----- PS ----- 
    
    vec4 fvAoSrc = sRGB2linear(tex2D(g_tAmbientOcclusion, vBaseUV_PatternUV.xy));
    float flCavity = fvAoSrc.x;
    float flAo = fvAoSrc.y;

    #if !SP && !CU
        vec4 fvMasks = g_bOverrideDefaultMasks ? tex2D(g_tPaintMasks, vBaseUV_PatternUV.zw) : tex2D(g_tMasks, vBaseUV_PatternUV.xy);
    #endif
    vec4 fvPaintWear = tex2D(g_tWear, vWearUV_GrungeUV.xy);

    #if !AQ
        #if HY || AM || CU || GS
            vec4 fvPattern = tex2D(g_tPattern, vBaseUV_PatternUV.zw);
            #if !EXTERN_MODE
                fvPattern.a = tex2D(g_tPaintAlpha, vBaseUV_PatternUV.zw).x;
            #endif
            float flPatternAlpha = smoothstep(0.5, 0.6, fvPattern.a) * smoothstep(1.0, 0.9, fvPattern.a);
        #elif SP || AA
            inputs.position *= 2.0;
            if (bSpraypaintHalftone != 0)
                inputs.position.z *= -1.0;

            vec4 fvSurface = tex2D(g_tSurface, vBaseUV_PatternUV.xy);
            vec4 fvNormalSrc = g_vSprayBiasBlend.x != 0 ? linear2sRGB(fvSurface) : fvSurface;
            vec3 fvNormal = normalize(fvNormalSrc.xyz * 2.0 - 1.0);
            vec2 sprayBlend = g_vSprayBiasBlend.yz * pow(abs(fvNormal.yz), vec2(7.0));

            BoxSample fvTex = boxSample(g_tPattern, inputs.position.xyz, g_vPatternTexCoordXform0, g_vPatternTexCoordXform1);
            #if !EXTERN_MODE
                BoxSample fvAlphaTex = boxSample(g_tPaintAlpha, inputs.position.xyz, g_vPatternTexCoordXform0, g_vPatternTexCoordXform1);
                fvTex.tX.w = fvAlphaTex.tX.x;
                fvTex.tY.w = fvAlphaTex.tY.x;
                fvTex.tZ.w = fvAlphaTex.tZ.x;
            #endif
            vec4 fvPatternMask = mix(mix(fvTex.tX, fvTex.tY, sprayBlend.x), fvTex.tZ, sprayBlend.y);
            
            vec4 fvPattern;
            if (bSpraypaintHalftone != 0) {
                BoxSample fvATex = boxSample(g_tPattern, inputs.position.xyz, g_vPatternTexCoordXformHalftoneA0, g_vPatternTexCoordXformHalftoneA1);
                BoxSample fvBTex = boxSample(g_tPattern, inputs.position.xyz, g_vPatternTexCoordXformHalftoneB0, g_vPatternTexCoordXformHalftoneB1);
                BoxSample fvCTex = boxSample(g_tPattern, inputs.position.xyz, g_vPatternTexCoordXformHalftoneC0, g_vPatternTexCoordXformHalftoneC1);
                #if !EXTERN_MODE
                    BoxSample fvAlphaATex = boxSample(g_tPaintAlpha, inputs.position.xyz, g_vPatternTexCoordXformHalftoneA0, g_vPatternTexCoordXformHalftoneA1);
                    fvATex.tX.w = fvAlphaATex.tX.x;
                    fvATex.tY.w = fvAlphaATex.tY.x;
                    fvATex.tZ.w = fvAlphaATex.tZ.x;
                    BoxSample fvAlphaBTex = boxSample(g_tPaintAlpha, inputs.position.xyz, g_vPatternTexCoordXformHalftoneB0, g_vPatternTexCoordXformHalftoneB1);
                    fvBTex.tX.w = fvAlphaBTex.tX.x;
                    fvBTex.tY.w = fvAlphaBTex.tY.x;
                    fvBTex.tZ.w = fvAlphaBTex.tZ.x;
                    BoxSample fvAlphaCTex = boxSample(g_tPaintAlpha, inputs.position.xyz, g_vPatternTexCoordXformHalftoneC0, g_vPatternTexCoordXformHalftoneC1);
                    fvCTex.tX.w = fvAlphaCTex.tX.x;
                    fvCTex.tY.w = fvAlphaCTex.tY.x;
                    fvCTex.tZ.w = fvAlphaCTex.tZ.x;
                #endif
                
                float c = flCavity;
                if (g_bHalftoneInCavity != 0)
                    c = min(c, g_fHalftoneCavityCutoff);
                c = pow(c * 2.0 * flAo, g_vHalftonePatternLevels.y);

                float halftoneCavityWeight = smoothstep(g_vHalftonePatternLevels.x, g_vHalftonePatternLevels.z, c);
                halftoneCavityWeight = mix(
                    halftoneCavityWeight, 
                    1.0 - halftoneCavityWeight, 
                    float((g_vHalftoneThresholds.x > g_vHalftoneThresholds.y) != (g_bHalftoneInCavity != 0))
                );

                vec3 halftoneWeight = vec3(
                    mix(mix(fvATex.tX.w, fvATex.tY.w, sprayBlend.x), fvATex.tZ.w, sprayBlend.y), 
                    mix(mix(fvBTex.tX.w, fvBTex.tY.w, sprayBlend.x), fvBTex.tZ.w, sprayBlend.y), 
                    mix(mix(fvCTex.tX.w, fvCTex.tY.w, sprayBlend.x), fvCTex.tZ.w, sprayBlend.y)
                );
                vec4 cavityT = vec4(fvPatternMask.xyz * halftoneCavityWeight, fvPatternMask.w);

                fvPattern = vec4(smoothstep(g_vHalftoneThresholds.xxx, g_vHalftoneThresholds.yyy, cavityT.xyz * halftoneWeight), cavityT.w);
            } else
                fvPattern = fvPatternMask;
            float flPatternAlpha = fvPattern.a;
        #endif

        #if SO || HY || SP
            float flDurability = mixSOHYSP(g_vPaintDurability
                #if !SP
                    , fvMasks.xyz
                #endif
                #if !SO
                    , fvPattern.xyz
                #endif
            );
        #elif AN
            float flDurability = 1.0;
        #elif AM || AA
            float flDurability = g_vPaintDurability.x;
            flDurability = mix(flDurability, g_vPaintDurability.y, fvPattern.x);
            flDurability = mix(flDurability, g_vPaintDurability.z, fvPattern.y);
            flDurability = mix(flDurability, g_vPaintDurability.w, fvPattern.z);
            flDurability = mix(flDurability, g_vPaintDurability.z, fvMasks.y);
            flDurability = mix(flDurability, g_vPaintDurability.w, fvMasks.z);
        #elif CU || GS
            float flDurability = max(0.0, smoothstep(0.0, 0.5, fvPattern.a));
        #endif

        float flWearSoftness = g_fWearSoftness * flDurability;

        float flPaintWear = fvAoSrc.w;
        #if GS
            flPaintWear = min(flPaintWear, 1.0 - fvMasks.x);
        #endif
        flPaintWear += fvPaintWear.x * flCavity;
        flPaintWear *= g_flWearAmount * 6.0 + 1.0;
        #if HY || AM || CU
            flPaintWear += flPatternAlpha;
            #if HY
                flPaintWear *= max(saturate(fvMasks.y + fvMasks.z), smoothstep(0.0, 0.5, fvPattern.a));
            #endif
        #endif
        flPaintWear *= flDurability;

        #if HY || SP
            vec3 spread = vec3(0.06 * g_flWearAmount);
            spread.y *= 2.0;
            spread.z *= 3.0;

            vec3 fvPaintEdges = fvPattern.xyz * vec3(
                smoothstep(0.58 + flWearSoftness, 0.56 - spread.x - flWearSoftness, flPaintWear), 
                smoothstep(0.56 - spread.x + flWearSoftness, 0.54 - spread.y - flWearSoftness, flPaintWear), 
                smoothstep(0.54 - spread.y + flWearSoftness, 0.52 - spread.z - flWearSoftness, flPaintWear)
            );
        #endif

        #if GS
            bool bIsMetallic = fvMasks.x > 0.99;
            float flPaintBlend = smoothstep(0.58 - flWearSoftness, 0.68 + flWearSoftness, flPaintWear);
            flPaintBlend = mix(flPaintBlend, flPaintWear, float(bIsMetallic));
        #else
            float flPaintBlend = smoothstep(0.56 - flWearSoftness, 0.74 + flWearSoftness, flPaintWear);
        #endif

        #if AN || AM || AA
            flPaintBlend = max(1.0 - fvMasks.x, flPaintBlend);

            flPaintWear = smoothstep(0.53 - flWearSoftness, 0.72 + flWearSoftness, flPaintWear);
            #if AN
                flPaintWear *= smoothstep(0.5, 0.6, 1.0) * smoothstep(1.0, 0.9, 1.0);
            #elif AM || AA
                flPaintWear *= flPatternAlpha;
            #endif
            flPaintWear *= fvMasks.x;
        #endif
    #else
        vec4 fvPattern = tex2D(g_tPattern, vBaseUV_PatternUV.zw);
        #if !EXTERN_MODE
            fvPattern.a = tex2D(g_tPaintAlpha, vBaseUV_PatternUV.zw).x;
        #endif
    #endif
    
    vec4 cGrunge = sRGB2linear(tex2D(g_tGrunge, vWearUV_GrungeUV.zw));
    #if AQ || GS
        float flGrunge = saturate(cGrunge.x * cGrunge.y * cGrunge.z);
    #endif
    cGrunge = mix(vec4(1.0), cGrunge, pow(1.0 - flCavity, 4.0) * 0.25 + 0.75 * g_flWearAmount);
    
    #if SO || HY || SP
        float flMetalness = mixSOHYSP(g_vPaintMetalness
            #if !SP
                , fvMasks.xyz
            #endif
            #if !SO
                , fvPaintEdges
            #endif
        );
    #elif CU || AQ || GS
        #if !CU
            float flPatinaBlend = fvPaintWear.x * flAo * flCavity * flCavity;
            flPatinaBlend = smoothstep(0.1, 0.2, flPatinaBlend * g_flWearAmount);
            
            float flOilRubBlend = saturate(flCavity * flAo - g_flWearAmount * 0.1) - flGrunge * 0.23;
            flOilRubBlend = smoothstep(0.0, 0.15, flOilRubBlend + 0.08);
        #endif
        float flMetalness;
    #endif
    
    // ----- ROUGHNESS -----

    vec4 fvMetalness = tex2D(g_tMetalness, vBaseUV_PatternUV.xy);
    float flRoughness = g_bUseRoughness ? tex2D(g_tPaintRoughness, vBaseUV_PatternUV.zw).r : g_flPaintRoughness;

    #if SO || HY || SP
        if (g_bRoughnessPerColor)
            flRoughness = mixSOHYSP(g_vPaintRoughness
                #if !SP
                    , fvMasks.xyz
                #endif
                #if !SO
                    , fvPaintEdges
                #endif
            );

        fvMetalness = mix(
            vec4(min(
                1.0, flRoughness + ((1.0 - cGrunge.w) * g_flWearAmount * g_flWearAmount * 0.5)
            ), flMetalness, 0.0, 1.0), 
            fvMetalness, 
            vec4(flPaintBlend)
        );
        #if SO || SP
            fvMetalness.z = 1.0 - flPaintBlend;
        #endif

    #elif AN || AM || AA
        fvMetalness.z = 1.0 - flPaintBlend;

        float flGrungeLum = luminance(cGrunge.xyz);
        float grungeBoost = (1.0 - flGrungeLum) * 0.2;

        float t;
        #if AM || AA
            #if AM
                float _24500 = 1.0 - min(1.0, fvPattern.a * 2.0);
                t = mix(((_24500 * _24500) * 0.85) + 0.15, flRoughness, float(fvPattern.a >= 0.5));
            #else
                t = flRoughness;
            #endif
            t = mix(t, flRoughness, max(max(fvMasks.y, fvMasks.z), flPaintBlend));
        #endif

        float roughBase = mix(t, 0.35, flPaintWear);
        float roughCandidate = min(1.0, roughBase + grungeBoost);
        float blendT = max(0.0, fvMetalness.z);

        fvMetalness.x = mix(fvMetalness.x, roughCandidate, blendT);
        fvMetalness.y = mix(fvMasks.x, fvMetalness.y, flPaintBlend);

    #elif CU
        float wearTerm = (1.0 - cGrunge.w) * g_flWearAmount;
        fvMetalness.x = mix(min(1.0, flRoughness + wearTerm * g_flWearAmount * 0.5), fvMetalness.x, flPaintBlend);
        fvMetalness.y = mix(g_flPaintMetalness, fvMetalness.y, flPaintBlend);
        fvMetalness.z = 1.0 - flPaintBlend;
    
    #elif AQ || GS
        #if GS
            float flInvPaintBlend = 1.0 - flPaintBlend;
            float _24500 = 1.0 - min(1.0, fvPattern.w * 2.0);

            flRoughness = mix(_24500 * _24500 * 0.85 + 0.15, g_flPaintRoughness, float(fvPattern.w >= 0.5));
            flRoughness = mix(g_flPaintRoughness, flRoughness, fvMasks.x);
        #endif

        float flGrungeLum = luminance(cGrunge.xyz);
        float wearTerm = (1.0 - cGrunge.w) * g_flWearAmount;

        flRoughness *= mix(1.0, 0.9, flPatinaBlend);
        flRoughness += (1.0 - flGrungeLum) * g_flWearAmount * 0.05;
        flRoughness += (1.0 - flOilRubBlend) * 0.15 * g_flWearAmount;
        flRoughness = saturate(flRoughness + wearTerm * 0.15);
        
        flRoughness = mix(min(1.0, flRoughness + wearTerm * g_flWearAmount * 0.5), flRoughness, fvMasks.x);
        flMetalness = mix(mix(1.0, pow(flOilRubBlend * cGrunge.w * flGrungeLum, 0.5), g_flWearAmount), 1.0, flPatinaBlend);
        
        #if AQ
            fvMetalness.x = mix(fvMetalness.x, flRoughness, step(fvAoSrc.w, 0.996) * fvMasks.x);
            fvMetalness.y = mix(fvMetalness.y, flMetalness, fvMasks.x);
            fvMetalness.z = 1.0 - fvAoSrc.w;
        #elif GS
            fvMetalness.x = mix(fvMetalness.x, flRoughness, float(max(int(bIsMetallic), int(max(0.0, flInvPaintBlend)))));
            fvMetalness.y = mix(mix(g_flPaintMetalness, fvMetalness.y, flPaintBlend), flMetalness, fvMasks.x);
            fvMetalness.z = flInvPaintBlend;
        #endif
    #endif

    outputs.metalness = vec4(fvMetalness.xyz, g_flPearlescentScale);
    if (g_bUsePearlescenceMask)
        outputs.metalness.w *= tex2D(g_tPearlescenceMask, vBaseUV_PatternUV.zw).r;

    // ----- COLOR -----

    vec3 cBase = sRGB2linear(tex2D(g_tColor, vBaseUV_PatternUV.xy).xyz);
    vec3 vAlbedoLevels = g_vMetallicPaintAlbedoLevels.xyz;

    #if !CU && !AQ && !GS
        vec3 cPaint = g_vColor0;
    #endif
    
    #if AN || AM || AA
        float flColorBrightness = mix(g_flColorBrightness, 1.0, flPaintWear);

        #if AM || AA
            vec3 m = fvPattern.xyz;
            #if AM
                m *= fvMasks.x;
            #endif
            cPaint = mix(cPaint, g_vColor1, m.x);
            cPaint = mix(cPaint, g_vColor2, m.y);
            cPaint = mix(cPaint, g_vColor3, m.z);
            cPaint = mix(cPaint, g_vColor2, fvMasks.y);
            cPaint = mix(cPaint, g_vColor3, fvMasks.z);
        #endif

        cPaint = mix(mix(cBase, cPaint, vec3(fvMasks.x)), vec3(0.38, 0.37, 0.35), vec3(flPaintWear));
        cPaint = saturate(saturate(cPaint * flColorBrightness) * flColorBrightness);
        cPaint *= mix(cGrunge.xyz, vec3(1.0), vec3(flPaintWear));
    #else
        vAlbedoLevels = mix(
            g_vPaintAlbedoLevels.xyz, 
            vAlbedoLevels, 
            #if GS
                vec3(mix(g_flPaintMetalness, flMetalness, fvMasks.x))
            #else
                vec3(flMetalness)
            #endif
        );

        #if SO
            cPaint = mix(cPaint, g_vColor1, fvMasks.x);
            cPaint = mix(cPaint, g_vColor2, fvMasks.y);
            cPaint = mix(cPaint, g_vColor3, fvMasks.z);
        #elif HY || SP
            #if HY
                cPaint = mix(cPaint, g_vColor1, fvPaintEdges.x);
                cPaint = mix(cPaint, g_vColor2, fvPaintEdges.y);
                cPaint = mix(cPaint, g_vColor3, fvPaintEdges.z);
                cPaint = mix(cPaint, g_vColor2, fvMasks.y);
                cPaint = mix(cPaint, g_vColor3, fvMasks.z);
            #elif SP
                cPaint = mix(cPaint, g_vColor1, fvPaintEdges.x);
                cPaint = mix(cPaint, g_vColor2, fvPaintEdges.y);
                cPaint = mix(cPaint, g_vColor3, fvPaintEdges.z);
            #endif
        
            float tWear = smoothstep(0.53 - flWearSoftness, 0.72 + flWearSoftness, flPaintWear);
            cPaint = saturate(cPaint * mix(g_flColorBrightness, 1.0, tWear * (1.0 - flPatternAlpha)));

        #elif CU
            vec3 cPaint = saturate(fvPattern.xyz * g_flColorBrightness);

        #elif AQ || GS
            vec3 flColorBrightness = fvPattern.xyz * mix(1.0, g_flColorBrightness, max(fvMasks.x, float(g_nColorAdjustmentMode)));
            
            vec3 cPatina = mix(g_vColor1, g_vColor2, g_flWearAmount);
            vec3 cOilRubColor = mix(g_vColor1, g_vColor3, pow(g_flWearAmount, 0.5));
            cPatina = mix(cOilRubColor, cPatina, flOilRubBlend) * flColorBrightness;

            float flPatternLum = luminance(flColorBrightness);
            vec3 cScratches = g_vColor0 * flPatternLum;

            vec3 cPaint = mix(cPatina, cScratches, flPatinaBlend);
            #if GS
                cPaint = mix(flColorBrightness, cPaint, fvMasks.x);
                flPaintBlend = flPaintBlend * (1.0 - fvMasks.x);
            #else
                float flPaintBlend = 1.0 - fvMasks.x;
            #endif
        #endif

        cPaint *= cGrunge.xyz;
    #endif

    vec3 cPaintN = normalize(max(vec3(0.0003), cPaint));
    float nMax = max(cPaintN.x, max(cPaintN.y, cPaintN.z));
    float lum = min(vAlbedoLevels.x, luminance(
        #if AQ
            flColorBrightness * g_vColor1
        #elif GS
            mix(flColorBrightness, flColorBrightness * g_vColor1, fvMasks.x)
        #else
            cPaint
        #endif
    ));
    float toneT = saturate(pow(max(cPaint.x, max(cPaint.y, cPaint.z)), vAlbedoLevels.y));
    float target = mix(min(vAlbedoLevels.x, lum), vAlbedoLevels.z, toneT);
    vec3 painted = (cPaintN * target) / vec3(max(nMax, 1e-6));
    cPaint = mix(cPaint, painted, g_flWearAmount);

    // ----- NORMAL -----

    if (!g_bUseNormalMap) {
        vec3 n = tex2D(g_tSurface, vBaseUV_PatternUV.xy).rgb * 2.0 - 1.0;
        inputs.normal = tangentSpaceToWorldSpace(normalize(n), inputs);
    }
    #if EXTERN_MODE
    else {
        vec3 n = tex2D(g_tPaintNormal, vBaseUV_PatternUV.xy).rgb * 2.0 - 1.0;
        inputs.normal = tangentSpaceToWorldSpace(normalize(n), inputs);
    }
    #endif
    outputs.vectors = computeLocalFrame(inputs);
    outputs.color.a = g_bOverrideAmbientOcclusion ? getAO(inputs.sparse_coord) : flAo;

    // ----- EFFECTS -----

    outputs.metalness.z = 1.0 - flPaintBlend;
    outputs.metalness.w *= 1.0 - max(0.0, dot(outputs.vectors.normal, outputs.vectors.eye));
    cPaint = mix(hueShift(cPaint, outputs.metalness.w), cBase, flPaintBlend);

    outputs.color.rgb = mix(cPaint, cBase, flPaintBlend);
}
