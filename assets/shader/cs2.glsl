import lib-normal.glsl
import lib-vectors.glsl
import lib-pbr.glsl
import lib-sampler.glsl

// Constants ------------------------------------------------------ //

#define PI 3.1415926535897932384626433832795
#define TAU 6.2831853071795864769252867665590

struct CustomWeaponOutputs {
    LocalVectors vectors;
    vec4 color;
    vec4 metalness;
    float pearlFactor;
};

// PBR ------------------------------------------------------------ //

void shadePBR(CustomWeaponOutputs O) {
    float shadow = getShadowFactor();
    vec3 diffColor = generateDiffuseColor(O.color.rgb, O.metalness.y);
    vec3 specColor = generateSpecularColor(0.04, O.color.rgb, O.metalness.y);
    float specOcclusion = specularOcclusionCorrection(shadow, O.metalness.y, O.metalness.x);

    albedoOutput(diffColor);
    diffuseShadingOutput(O.metalness.w * shadow * envIrradiance(O.vectors.normal));
    specularShadingOutput(specOcclusion * pbrComputeSpecular(O.vectors, specColor, O.metalness.x));
}

void validatePBR(inout CustomWeaponOutputs O) {
    float L = dot(O.color.rgb, vec3(0.3, 0.59, 0.11));
    float b = step(0.90 + 0.08 * O.metalness.y, L);
    float d = step(L, 0.03 + 0.104 * O.metalness.y);

    vec3 valCol = mix(vec3(0.0), mix(vec3(1.0, 0.0, O.metalness.y), vec3(O.metalness.y, 0.0, 1.0), d), b + d);

    O.color.rgb = mix(O.color.rgb, vec3(0.0, 0.0, 0.0), b + d) + valCol;
    emissiveColorOutput(valCol);
}

// Utils ---------------------------------------------------------- //

float luma(vec3 c) { return dot(c, vec3(0.2125, 0.7154, 0.0721)); }

float saturate(float x) { return clamp(x, 0.0, 1.0); }
vec2 saturate(vec2 x) { return clamp(x, vec2(0.0), vec2(1.0)); }
vec3 saturate(vec3 x) { return clamp(x, vec3(0.0), vec3(1.0)); }
vec4 saturate(vec4 x) { return clamp(x, vec4(0.0), vec4(1.0)); }

void computePearlescence(inout CustomWeaponOutputs O) {
    // pearlescence
    const vec3 axis = vec3(0.5773500204);

    if (O.pearlFactor != 0.0) {
        O.pearlFactor *= (1.0 - dot(O.vectors.normal, O.vectors.eye)) * saturate(O.metalness.z);

        float cmax = max(O.color.rgb.r, max(O.color.rgb.g, O.color.rgb.b));
        float sat = cmax == 0.0 ? 0.0 : (cmax - min(O.color.rgb.r, min(O.color.rgb.g, O.color.rgb.b))) / cmax;
        float sat_w = pow(sat, 0.125);

        float ct = cos(O.pearlFactor), st = sin(O.pearlFactor);
        vec3 rotated =  O.color.rgb * ct + cross(axis, O.color.rgb) * st + axis * dot(axis, O.color.rgb) * (1.0 - ct);

        O.color.rgb = mix(vec3(luma(O.color.rgb)), rotated, sat_w);
    }

    // // glitter
    // float glitterIntensity = roughness * min(1.0, g_fGlitterIntensity);

    // vec3 glitterColor;
    // float metalness;
    // vec2 roughnessMap;
    // vec3 baseColor;
    // vec3 normalMap;

    // if (glitterIntensity != 0.0){
    //     // Calculate view direction
    //     vec3 viewDir = normalize(PerViewConstantBuffer_t._m0.xyz - worldPosition.xyz);
        
    //     // Setup glitter texture coordinates
    //     float glitterScale = notEqual(PerViewConstantBufferCsgo_t._m2, ivec4(0)).x ? 2.5 : 1.75;
    //     vec2 glitterUV = surfaceUV.xy * (glitterScale * g_fGlitterScale * g_flUvScale1);
        
    //     // Sample glitter normal map
    //     vec4 glitterNormal = texture(sampler2D(g_tGlitterNormal, AddressU_0_AddressV_0_Filter_0_AddressW_0), glitterUV);
        
    //     // Decode normal from texture
    //     vec3 decodedNormal = decodeNormal(glitterNormal.xy);
    //     vec3 glitterBump = decodedNormal * decodedNormal.z;
    //     vec3 blendedNormal = glitterBump.xyz + baseNormal.xyz;
        
    //     // Calculate glitter reflection
    //     vec3 reflectedDir = reflect(viewDir, normalize(transformToTangentSpace(blendedNormal)));
    //     vec3 rainbowEffect = sin(reflectedDir * mix(12.0, 5.6, g_fGlitterRainbowSpread));
        
    //     // Apply rainbow spectrum
    //     vec3 rainbowColor = calculateRainbowSpectrum(rainbowEffect);
        
    //     // Calculate glitter alpha
    //     float glitterAlpha = glitterNormal.w;
    //     float glitterMask = (glitterIntensity * glitterAlpha) * abs(1.0 - glitterBump.z);
        
    //     // Output values
    //     glitterColor = rainbowColor * glitterAlpha * dot(viewDir, tangentNormal) * g_fGlitterIntensity;
    //     roughnessMap = roughness * (1.0 - glitterMask * 0.25);
    //     baseColor = baseColorValue * mix(1.0 + glitterMask * 2.5, 1.0, luminance(baseColorValue));
    //     metalness = max(metallicValue, glitterMask * 0.5 * glitterIntensity);
    //     normalMap = baseNormal + (glitterBump * glitterIntensity * clamp(1.0 - mipLevel * 40.0, 0.0, 1.0));
    // }
}

// Texturing ------------------------------------------------------ //

struct BoxSample {
    vec4 tX;
    vec4 tY;
    vec4 tZ;
};

vec4 tex2D(sampler2D tex, vec2 uv) {
    return texture(tex, uv);
}

vec4 tex2D(SamplerSparse tex, vec2 uv) {
    return texture(tex.tex, uv);
}

BoxSample boxSample(sampler2D t, vec3 p, vec4 f0, vec4 f1) { 
    return BoxSample(
        tex2D(t, vec2(dot(p.yz, f0.xy) + f0.w, dot(p.yz, f1.xy) + f1.w)),
        tex2D(t, vec2(dot(p.xz, f0.xy) + f0.w, dot(p.xz, f1.xy) + f1.w)),
        tex2D(t, vec2(dot(p.yx, f0.xy) + f0.w, dot(p.yx, f1.xy) + f1.w))
    );
}

BoxSample boxSample(SamplerSparse t, vec3 p, vec4 f0, vec4 f1) { 
    return boxSample(t.tex, p, f0, f1);
}

// Custom Weapon -------------------------------------------------- //

#define SO PAINT_STYLE == 0 // Solid Color
#define HY PAINT_STYLE == 1 // Hydrographic
#define SP PAINT_STYLE == 2 // Spray-Paint
#define AN PAINT_STYLE == 3 // Anodized
#define AM PAINT_STYLE == 4 // Anodized Multicolored
#define AA PAINT_STYLE == 5 // Anodized Airbrushed
#define CU PAINT_STYLE == 6 // Custom Paint Job
#define AQ PAINT_STYLE == 7 // Patina
#define GS PAINT_STYLE == 8 // Gunsmith
#define CE PAINT_STYLE == 9 // Custom Paint Job Extended

// Paint Textures ------------------------------------------- //

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

// Common --------------------------------------------------------- //

//: param custom { "default": 0.0 }
uniform float g_flWearAmount;

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

// Colors ------------------------------------------------------- //

#if !CU
    #if AQ || GS
        //: param custom { "default": [0.50, 0.50, 0.50], "group": "CS2:Colors", "control": "ColorButton", "text": "Base Metal" }
    #else
        //: param custom { "default": [0.50, 0.50, 0.50], "group": "CS2:Colors", "control": "ColorButton", "text": "Base Coat" }
    #endif
    uniform vec3 g_vColor0;
    #if !AN
        #if AQ || GS
            //: param custom { "default": [0.59, 0.59, 0.59], "group": "CS2:Colors", "control": "ColorButton", "text": "Patina Tint" }
        #else
            //: param custom { "default": [0.59, 0.59, 0.59], "group": "CS2:Colors", "control": "ColorButton", "text": "Red Mask" }
        #endif
        uniform vec3 g_vColor1;
        #if AQ || GS
            //: param custom { "default": [0.38, 0.38, 0.38], "group": "CS2:Colors", "control": "ColorButton", "text": "Patina Wear" }
        #else
            //: param custom { "default": [0.38, 0.38, 0.38], "group": "CS2:Colors", "control": "ColorButton", "text": "Green Mask" }
        #endif
        uniform vec3 g_vColor2;
        #if AQ || GS
            //: param custom { "default": [0.42, 0.42, 0.42], "group": "CS2:Colors", "control": "ColorButton", "text": "Grime" }
        #else
            //: param custom { "default": [0.42, 0.42, 0.42], "group": "CS2:Colors", "control": "ColorButton", "text": "Blue Mask" }
        #endif
        uniform vec3 g_vColor3;
    #endif
#endif

// Materials ------------------------------------------------------- //

//: param custom { "default": 0.6, "group": "CS2:Materials", "control": "Slider", "text": "Paint Roughness" }
uniform float g_flPaintRoughness;
//: param custom { "default": true, "group": "CS2:Materials", "control": "Button", "text": "Use Roughness Texture" }
uniform bool g_bUseRoughness;
//: param custom { "default": true, "group": "CS2:Materials", "control": "Button", "text": "Use Material Mask" }
uniform bool g_bOverrideDefaultMasks;
#if SO || HY || SP
    //: param custom { "default": false, "group": "CS2:Materials", "control": "Button", "text": "Use Roughness By Color" }
    uniform bool g_bRoughnessPerColor;
    //: param custom { "default": [0.6, 0.6, 0.6, 0.6], "group": "CS2:Materials", "control": "MultiSlider", "text": "Paint Roughness" }
    uniform vec4 g_vPaintRoughness;
    //: param custom { "default": [0.0, 0.0, 0.0, 0.0], "group": "CS2:Materials", "control": "MultiSlider", "text": "Paint Metalness" }
    uniform vec4 g_vPaintMetalness;
#endif

// Normals ------------------------------------------------------- //

//: param custom { "default": true, "group": "CS2:Normals", "control": "Button", "text": "Use Normal Map" }
uniform bool g_bUseNormalMap;
//: param custom { "default": true, "group": "CS2:Normals", "control": "Button", "text": "Use Ambient Occlusion" }
uniform bool g_bOverrideAmbientOcclusion;

// Effects ------------------------------------------------------- //

//: param custom { "default": 0.0, "group": "CS2:Effects", "control": "Slider", "text": "Pearlescent Scale", "min": -6.0, "max": 6.0 }
uniform float g_flPearlescentScale;
//: param custom { "default": true, "group": "CS2:Effects", "control": "Button", "text": "Use Pearlescence Mask" }
uniform bool g_bUsePearlescenceMask;

// Wear and Grunge ------------------------------------------------------- //

#if !CU && !AQ && !GS
    //: param custom { "default": [0.0, 0.0, 0.0, 0.0], "group": "CS2:Wear and Grunge", "control": "MultiSlider", "text": "Paint Durability" }
    uniform vec4 g_vPaintDurability;
#endif
#if !AQ
    //: param custom { "default": 0.0, "group": "CS2:Wear and Grunge", "control": "Slider", "text": "Wear Softness" }
    uniform float g_fWearSoftness;
#endif

// Unspecified ------------------------------------------------------- //

#if CU || AQ || GS
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
#endif

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

#if GS
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
            fvPattern.a = tex2D(g_tPaintAlpha, vBaseUV_PatternUV.zw).x;
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
            BoxSample fvAlphaTex = boxSample(g_tPaintAlpha, fvPos.xyz, g_vPatternTexCoordXform0, g_vPatternTexCoordXform1);
            fvTex.tX.w = fvAlphaTex.tX.x;
            fvTex.tY.w = fvAlphaTex.tY.x;
            fvTex.tZ.w = fvAlphaTex.tZ.x;
            vec4 fvPatternMask = mix(mix(fvTex.tX, fvTex.tY, sprayBlend.x), fvTex.tZ, sprayBlend.y);
            
            vec4 fvPattern;
            if (bSpraypaintHalftone != 0) {
                BoxSample fvATex = boxSample(g_tPattern, fvPos.xyz, g_vPatternTexCoordXformHalftoneA0, g_vPatternTexCoordXformHalftoneA1);
                BoxSample fvBTex = boxSample(g_tPattern, fvPos.xyz, g_vPatternTexCoordXformHalftoneB0, g_vPatternTexCoordXformHalftoneB1);
                BoxSample fvCTex = boxSample(g_tPattern, fvPos.xyz, g_vPatternTexCoordXformHalftoneC0, g_vPatternTexCoordXformHalftoneC1);
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
        fvPattern.a = tex2D(g_tPaintAlpha, vBaseUV_PatternUV.zw).x;
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

        float flGrungeLum = luma(cGrunge.xyz);
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

        float flGrungeLum = luma(cGrunge.xyz);
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

    O.pearlFactor = g_flPearlescentScale;
    
    // ----- COLOR -----

    vec3 cBase = sRGB2linear(tex2D(g_tColor, vBaseUV_PatternUV.xy).xyz);
    
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
        cPaint *= mix(cGrunge.xyz, vec3(1.0), flPaintBlend);
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

            float flPatternLum = luma(cPattern);
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

    #if !GS
        vec3 fvAlbedoLevels = g_vMetallicPaintAlbedoLevels;
    #else
        vec3 fvAlbedoLevels = mix(g_vPaintAlbedoLevels, g_vMetallicPaintAlbedoLevels, mix(g_flPaintMetalness, 1.0, fvMasks.x));
    #endif

    vec3 cPaintN = normalize(max(vec3(0.0003), cPaint));
    float nMax = max(cPaintN.x, max(cPaintN.y, cPaintN.z));
    float lum =  min(fvAlbedoLevels.x, luma(
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

    O.color = vec4(mix(cPaint, cBase, flPaintBlend), 1.0 - flPaintBlend);

    // ----- NORMAL -----

    O.metalness.w = g_bOverrideAmbientOcclusion ? getAO(inputs.sparse_coord) : flAo;

    if (!g_bUseNormalMap) {
        vec3 n = tex2D(g_tSurface, vBaseUV_PatternUV.xy).rgb * 2.0 - 1.0;
        inputs.normal = tangentSpaceToWorldSpace(normalize(n), inputs);
    }
    
    O.vectors = computeLocalFrame(inputs);
}

//: metadata {
//:  "custom-ui" : "cs2-workshop-tools-ui.qml"
//: }

// General ------------------------------------------------------- //

//: param custom { "default": true }
uniform_specialization bool g_bLivePreview;
//: param custom { "default": 0 }
uniform_specialization int g_bDebugChannel;
//: param custom { "default": false }
uniform_specialization bool g_bPBRValidation;

void shade(V2F inputs) {
    CustomWeaponOutputs O;

    if (g_bLivePreview) {
        composeCustomWeapon(inputs, O);
        computePearlescence(O);
        
        if (g_bPBRValidation)
            validatePBR(O);

        switch (g_bDebugChannel) {
            case 1:
                emissiveColorOutput(vec3(O.color.a));
                break;
            case 2:
                emissiveColorOutput(O.color.rgb);
                break;
            case 3:
                emissiveColorOutput(sRGB2linear(O.metalness.xyz));
                break;
            case 4:
                emissiveColorOutput(vec3(O.pearlFactor + 0.5));
                break;
            default:
                shadePBR(O);
        }
    } else {
        O.color.rgb = tex2D(g_tPattern, inputs.tex_coord).rgb;
        O.metalness.x = tex2D(g_tPaintRoughness, inputs.tex_coord).x;
        O.metalness.y = tex2D(g_tPaintMasks, inputs.tex_coord).x;
        O.metalness.w = getAO(inputs.tex_coord, true);
        O.vectors = computeLocalFrame(inputs);

        shadePBR(O);
    }
}
