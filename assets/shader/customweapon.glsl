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
//: param custom { "default": false }
        uniform bool g_bPearlescentOnMetallicOnly;
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

void composeCustomWeapon(V2F inputs, out CustomWeaponOutputs O) {
    // ----- VS ----- 

    vec2 uv = inputs.tex_coord;
    vec2 uvYup = vec2(uv.x, 1.0 - uv.y);

    vec2 p  = vec2(dot(uvYup, g_vPatternTexCoordXform0.xy) + g_vPatternTexCoordXform0.w,
                    dot(uvYup, g_vPatternTexCoordXform1.xy) + g_vPatternTexCoordXform1.w);
    p.y  = 1.0 - p.y;

    vec2 w = vec2(dot(uvYup, g_vWearTexCoordXform0.xy) + g_vWearTexCoordXform0.w,
                    dot(uvYup, g_vWearTexCoordXform1.xy) + g_vWearTexCoordXform1.w);
    w.y = 1.0 - w.y;

    vec2 g  = vec2(dot(uvYup, g_vGrungeTexCoordXform0.xy) + g_vGrungeTexCoordXform0.w,
                    dot(uvYup, g_vGrungeTexCoordXform1.xy) + g_vGrungeTexCoordXform1.w);
    g.y  = 1.0 - g.y;

    vec4 vBaseUV_PatternUV = vec4(uv, p);
    vec4 vWearUV_GrungeUV  = vec4(w, g);

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
            vec3 fvPos = inputs.position * 2.0;
            if (bSpraypaintHalftone != 0)
                fvPos.z *= -1.0;

            vec4 fvSurface = tex2D(g_tSurface, vBaseUV_PatternUV.xy);
            vec4 fvNormalSrc = g_vSprayBiasBlend.x != 0 ? linear2sRGB(fvSurface) : fvSurface;
            vec3 fvNormal = normalize(fvNormalSrc.xyz * 2.0 - 1.0);
            vec2 sprayBlend = g_vSprayBiasBlend.yz * pow(abs(fvNormal.yz), vec2(7.0));

            BoxSample fvTex = boxSample(g_tPattern, fvPos.xyz, g_vPatternTexCoordXform0, g_vPatternTexCoordXform1);
            #if !EXTERN_MODE
                BoxSample fvAlphaTex = boxSample(g_tPaintAlpha, fvPos.xyz, g_vPatternTexCoordXform0, g_vPatternTexCoordXform1);
                fvTex.tX.w = fvAlphaTex.tX.x;
                fvTex.tY.w = fvAlphaTex.tY.x;
                fvTex.tZ.w = fvAlphaTex.tZ.x;
            #endif
            vec4 fvPatternMask = mix(mix(fvTex.tX, fvTex.tY, sprayBlend.x), fvTex.tZ, sprayBlend.y);
            
            vec4 fvPattern;
            if (bSpraypaintHalftone != 0) {
                BoxSample fvATex = boxSample(g_tPattern, fvPos.xyz, g_vPatternTexCoordXformHalftoneA0, g_vPatternTexCoordXformHalftoneA1);
                BoxSample fvBTex = boxSample(g_tPattern, fvPos.xyz, g_vPatternTexCoordXformHalftoneB0, g_vPatternTexCoordXformHalftoneB1);
                BoxSample fvCTex = boxSample(g_tPattern, fvPos.xyz, g_vPatternTexCoordXformHalftoneC0, g_vPatternTexCoordXformHalftoneC1);
                #if !EXTERN_MODE
                    BoxSample fvAlphaATex = boxSample(g_tPaintAlpha, fvPos.xyz, g_vPatternTexCoordXformHalftoneA0, g_vPatternTexCoordXformHalftoneA1);
                    fvATex.tX.w = fvAlphaATex.tX.x;
                    fvATex.tY.w = fvAlphaATex.tY.x;
                    fvATex.tZ.w = fvAlphaATex.tZ.x;
                    BoxSample fvAlphaBTex = boxSample(g_tPaintAlpha, fvPos.xyz, g_vPatternTexCoordXformHalftoneB0, g_vPatternTexCoordXformHalftoneB1);
                    fvBTex.tX.w = fvAlphaBTex.tX.x;
                    fvBTex.tY.w = fvAlphaBTex.tY.x;
                    fvBTex.tZ.w = fvAlphaBTex.tZ.x;
                    BoxSample fvAlphaCTex = boxSample(g_tPaintAlpha, fvPos.xyz, g_vPatternTexCoordXformHalftoneC0, g_vPatternTexCoordXformHalftoneC1);
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

        float flPaintBlend = fvAoSrc.w;
        #if GS
            flPaintBlend = min(flPaintBlend, 1.0 - fvMasks.x);
        #endif
        flPaintBlend += fvPaintWear.x * flCavity;
        flPaintBlend *= g_flWearAmount * 6.0 + 1.0;
        #if HY || AM || CU || GS
            flPaintBlend += flPatternAlpha;
            #if HY
                flPaintBlend *= max(saturate(fvMasks.y + fvMasks.z), smoothstep(0.0, 0.5, fvPattern.a));
            #endif
        #endif
        flPaintBlend *= flDurability;

        #if HY || SP
            vec3 spread = vec3(0.06 * g_flWearAmount);
            spread.y *= 2.0;
            spread.z *= 3.0;

            vec3 fvPaintEdges = fvPattern.xyz * vec3(
                smoothstep(0.58 + flWearSoftness, 0.56 - spread.x - flWearSoftness, flPaintBlend), 
                smoothstep(0.56 - spread.x + flWearSoftness, 0.54 - spread.y - flWearSoftness, flPaintBlend), 
                smoothstep(0.54 - spread.y + flWearSoftness, 0.52 - spread.z - flWearSoftness, flPaintBlend)
            );
        #endif

        #if GS
            bool bIsMetallic = fvMasks.x > 0.99;
            flPaintBlend = mix(smoothstep(0.58 - flWearSoftness, 0.68 + flWearSoftness, flPaintBlend), flPaintBlend, float(bIsMetallic));
        #else
            flPaintBlend = smoothstep(0.58 - flWearSoftness, 0.68 + flWearSoftness, flPaintBlend);
        #endif

        #if AN || AM || AA
            flPaintBlend = max(1.0 - fvMasks.x, flPaintBlend);

            flPaintBlend = smoothstep(0.53 - flWearSoftness, 0.72 + flWearSoftness, flPaintBlend);
            #if AN
                flPaintBlend *= smoothstep(0.5, 0.6, 1.0) * smoothstep(1.0, 0.9, 1.0);
            #elif AM || AA
                flPaintBlend *= flPatternAlpha;
            #endif
            flPaintBlend *= fvMasks.x;
        #endif
        
        float flInvPaintBlend = 1.0 - flPaintBlend;

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
    
    // ----- ROUGHNESS -----

    O.metalness = tex2D(g_tMetalness, vBaseUV_PatternUV.xy);
    float gflRoughness = g_bUseRoughness ? tex2D(g_tPaintRoughness, vBaseUV_PatternUV.zw).r : g_flPaintRoughness;

    #if SO || HY || SP
        float flRoughness = g_bRoughnessPerColor ? 
            mixSOHYSP(g_vPaintRoughness
                #if !SP
                    , fvMasks.xyz
                #endif
                #if !SO
                    , fvPaintEdges
                #endif
            ) : gflRoughness;

        float flMetalness = mixSOHYSP(g_vPaintMetalness
            #if !SP
                , fvMasks.xyz
            #endif
            #if !SO
                , fvPaintEdges
            #endif
        );

        O.metalness = mix(
            vec4(min(
                1.0, flRoughness + ((1.0 - cGrunge.w) * g_flWearAmount * g_flWearAmount * 0.5)
            ), flMetalness, 0.0, 1.0), 
            O.metalness, 
            vec4(flPaintBlend)
        );
        #if SO || SP
            O.metalness.z = flInvPaintBlend;
        #endif

    #elif AN || AM || AA
        O.metalness.z = flInvPaintBlend;

        float flGrungeLum = luminance(cGrunge.xyz);
        float grungeBoost = (1.0 - flGrungeLum) * 0.2;

        #if AM
            float flRoughness = 1.0 - min(1.0, fvPattern.a * 2.0);
            flRoughness = mix(((flRoughness * flRoughness) * 0.85) + 0.15, gflRoughness, float(fvPattern.a >= 0.5));
        #else
            float flRoughness = gflRoughness;
        #endif
        #if AM || AA
            flRoughness = mix(flRoughness, gflRoughness, max(max(fvMasks.y, fvMasks.z), flPaintBlend));
        #endif

        flRoughness = min(1.0, mix(gflRoughness, 0.35, flPaintBlend) + grungeBoost);

        O.metalness.x = mix(O.metalness.x, flRoughness, max(0.0, O.metalness.z));
        O.metalness.y = mix(fvMasks.x, O.metalness.y, flPaintBlend);

    #elif CU
        float flRoughness = gflRoughness;
        flRoughness += (1.0 - cGrunge.w) * g_flWearAmount * g_flWearAmount * 0.5;
        flRoughness = min(1.0, flRoughness);
        float flMetalness = g_flPaintMetalness;

        O.metalness = mix(vec4(flRoughness, flMetalness, 0.0, 1.0), O.metalness, flPaintBlend);
        O.metalness.z = flInvPaintBlend;
    
    #elif AQ || GS
        float flPatinaBlend = fvPaintWear.x * flAo * flCavity * flCavity;
        flPatinaBlend = smoothstep(0.1, 0.2, flPatinaBlend * g_flWearAmount);
        
        float flOilRubBlend = saturate(flCavity * flAo - g_flWearAmount * 0.1) - flGrunge * 0.23;
        flOilRubBlend = smoothstep(0.0, 0.15, flOilRubBlend + 0.08);

        float flGrungeLum = luminance(cGrunge.xyz);
        float flWear = (1.0 - cGrunge.w) * g_flWearAmount;

        float flRoughness = gflRoughness;
        // #if GS
        //     float flPatA = 1.0 - min(1.0, fvPattern.a * 2.0);
        //     flRoughness = mix(flRoughness, mix(flPatA * flPatA * 0.85 + 0.15, flRoughness, float(fvPattern.w >= 0.5)), fvMasks.x);
        // #endif

        flRoughness *= mix(1.0, 0.9, flPatinaBlend);
        flRoughness += (1.0 - flGrungeLum) * g_flWearAmount * 0.05;
        flRoughness += (1.0 - flOilRubBlend) * 0.15 * g_flWearAmount;
        flRoughness = saturate(flRoughness + flWear * 0.15);
        
        flRoughness = mix(min(1.0, flRoughness + flWear * g_flWearAmount * 0.5), flRoughness, fvMasks.x);
        float flMetalness = mix(mix(1.0, pow(flOilRubBlend * cGrunge.w * flGrungeLum, 0.5), g_flWearAmount), 1.0, flPatinaBlend);
        
        #if AQ
            O.metalness.x = mix(O.metalness.x, flRoughness, step(fvAoSrc.w, 0.996) * fvMasks.x);
            O.metalness.y = mix(O.metalness.y, flMetalness, fvMasks.x);
            O.metalness.z = 1.0 - fvAoSrc.w;
        #elif GS
            O.metalness.x = mix(O.metalness.x, flRoughness, float(max(int(bIsMetallic), int(max(0.0, flInvPaintBlend)))));
            O.metalness.y = mix(mix(g_flPaintMetalness, O.metalness.y, flPaintBlend), flMetalness, fvMasks.x);
            O.metalness.z = flInvPaintBlend;
            if (g_bPearlescentOnMetallicOnly)
                O.metalness.z *= fvMasks.x;
        #endif
    #endif

    if (g_bUsePearlescenceMask)
        O.metalness.z *= tex2D(g_tPearlescenceMask, vBaseUV_PatternUV.zw).r;

    O.pearlFactor = g_flPearlescentScale * O.metalness.z;

    // ----- COLOR -----

    #if !CU && !AQ && !GS
        vec3 cPaint = g_vColor0;
    #endif
    
    #if AN || AM || AA
        float cPattern = mix(g_flColorBrightness, 1.0, flPaintBlend);

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

        cPaint = mix(mix(cBase, cPaint, fvMasks.x), vec3(0.38, 0.37, 0.35), flPaintBlend);
        cPaint = saturate(saturate(cPaint * cPattern) * cPattern);
        cPaint *= mix(cGrunge.xyz, vec3(1.0), vec3(flPaintBlend));
    #else
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
        
            float tWear = smoothstep(0.53 - flWearSoftness, 0.72 + flWearSoftness, flPaintBlend);
            cPaint = saturate(cPaint * mix(g_flColorBrightness, 1.0, tWear * (1.0 - flPatternAlpha)));

        #elif CU
            vec3 cPaint = saturate(fvPattern.xyz * g_flColorBrightness);

        #elif AQ || GS
            vec3 cPattern = fvPattern.xyz * mix(1.0, g_flColorBrightness, max(fvMasks.x, float(g_nColorAdjustmentMode)));
            
            vec3 cPatina = mix(g_vColor1, g_vColor2, g_flWearAmount);
            vec3 cOilRubColor = mix(g_vColor1, g_vColor3, pow(g_flWearAmount, 0.5));
            cPatina = mix(cOilRubColor, cPatina, flOilRubBlend) * cPattern;

            float flPatternLum = luminance(cPattern);
            vec3 cScratches = g_vColor0 * flPatternLum;

            vec3 cPaint = mix(cPatina, cScratches, flPatinaBlend);
            #if GS
                cPaint = mix(cPattern, cPaint, fvMasks.x);
                flPaintBlend *= 1.0 - fvMasks.x;
            #else
                float flPaintBlend = 1.0 - fvMasks.x;
            #endif
        #endif

        cPaint *= cGrunge.xyz;
    #endif

    vec3 fvAlbedoLevels = mix(
        g_vPaintAlbedoLevels, 
        g_vMetallicPaintAlbedoLevels, 
        #if GS
            mix(g_flPaintMetalness, 1.0, fvMasks.x) // flMetalness ?
        #else
            1.0 // flMetalness ?
        #endif
    );

    vec3 cPaintN = normalize(max(vec3(0.0003), cPaint));
    float nMax = max(cPaintN.x, max(cPaintN.y, cPaintN.z));
    float lum =  min(fvAlbedoLevels.x, luminance(
        #if AQ
            cPattern * g_vColor1
        #elif GS
            cPattern * mix(vec3(1.0), g_vColor1, fvMasks.x)
        #else
            cPaint
        #endif
    ));
    float toneT = saturate(pow(max(cPaint.x, max(cPaint.y, cPaint.z)), fvAlbedoLevels.y));
    float target = mix(lum, fvAlbedoLevels.z, toneT);
    vec3 painted = (cPaintN * target) / nMax;
    cPaint = mix(cPaint, painted, g_flWearAmount);

    vec3 cBase = sRGB2linear(tex2D(g_tColor, vBaseUV_PatternUV.xy).xyz);
    O.color = vec4(mix(cPaint, cBase, flPaintBlend), 1.0 - flPaintBlend);

    // ----- NORMAL -----

    O.metalness.w = g_bOverrideAmbientOcclusion ? getAO(inputs.sparse_coord) : flAo;

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
    O.vectors = computeLocalFrame(inputs);
}
