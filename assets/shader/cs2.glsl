import lib-pbr.glsl
import lib-utils.glsl
import lib-normal.glsl
import lib-defines.glsl
import lib-vectors.glsl
import lib-sampler.glsl

#define CU 0 // Custom Paint Job
#define AQ 1 // Patina
#define GS 2 // Gunsmith

//: metadata {
//:  "custom-ui" : "cs2-ui.qml"
//: }

// General Parameters --------------------------------------------- //

//: param custom { "default": true, "group" : "General" }
uniform_specialization bool uLivePreview;
//: param custom { "default": 0, "group" : "General" }
uniform_specialization int uDebugChannel;
//: param custom { "default": false, "group" : "General" }
uniform_specialization bool uPBRValidation;
//: param custom { "default": [50, 245, 106, 255], "group" : "General" }
uniform vec4 uPBRRanges; // packed values: [non-metallic min:max, metallic min:max]

// Paint Textures ------------------------------------------------- //

//: param auto channel_basecolor
uniform SamplerSparse uPatternColor;
//: param auto channel_roughness
uniform SamplerSparse uPatternRough;
//: param auto channel_user0
uniform SamplerSparse uPatternMasks;
//: param auto channel_user1
uniform SamplerSparse uPatternAlpha;
//: param auto channel_user2
uniform SamplerSparse uPatternPearl;

// Grunge Textures ------------------------------------------------ //

//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5], "group" : "Base Textures" }
uniform sampler2D uWearTex;
//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5], "group" : "Base Textures" }
uniform sampler2D uGrungeTex;

//: param custom { "default": [1.5, 0.0, 0.0, 0.0], "group" : "Base Textures" }
uniform vec4 uWearTransform; // packed values: [scale, translateX, translateY, rotation]
//: param custom { "default": [1.5, 0.0, 0.0, 0.0], "group" : "Base Textures" }
uniform vec4 uGrungeTransform; // packed values: [scale, translateX, translateY, rotation]

// Weapon Base Textures ------------------------------------------- //

//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5], "group" : "Base Textures" }
uniform sampler2D uBaseColor;
//: param custom { "default": "", "default_color": [1.0, 0.5, 0.5], "group" : "Base Textures" }
uniform sampler2D uBaseRough;
//: param custom { "default": "", "default_color": [1.0, 0.0, 0.0], "group" : "Base Textures" }
uniform sampler2D uBaseMasks;
//: param custom { "default": "", "default_color": [0.5, 0.5, 1.0], "group" : "Base Textures" }
uniform sampler2D uBaseSurface;
//: param custom { "default": "", "default_color": [1.0, 0.5, 0.5], "group" : "Base Textures" }
uniform sampler2D uBaseCavity;

//: param custom { "default": "1.0", "group" : "Base Textures" }
uniform float uBaseScale;

// Common Parameters ---------------------------------------------- //

//: param custom { "default": 0.00, "group" : "Common" }
uniform float uWearAmt;
//: param custom { "default": true, "group" : "Common" }
uniform bool uIgnoreWeaponSizeScale;
//: param custom { "default": [1.0, 0.0, 0.0, 0.0], "group" : "Common" }
uniform vec4 uTexTransform; // packed values: [scale, translateX, translateY, rotation]
#if FINISH_STYLE != CU
//: param custom { "default": [1.0, 1.0, 1.0], "group" : "Color" }
uniform vec3 uCol0;
//: param custom { "default": [1.0, 1.0, 1.0], "group" : "Color" }
uniform vec3 uCol1;
//: param custom { "default": [1.0, 1.0, 1.0], "group" : "Color" }
uniform vec3 uCol2;
//: param custom { "default": [1.0, 1.0, 1.0], "group" : "Color" }
uniform vec3 uCol3;
#endif
//: param custom { "default": true, "group" : "Effects" }
uniform bool uUsePearlMask;
//: param custom { "default": 0.00, "group" : "Effects" }
uniform float uPearlScale;
//: param custom { "default": true, "group" : "Effects" }
uniform bool uUseCustomRough;
//: param custom { "default": 0.60, "group" : "Effects" }
uniform float uPaintRough;
//: param custom { "default": true, "group" : "Advanced" }
uniform bool uUseCustomNormal;
#if FINISH_STYLE != CU
//: param custom { "default": true, "group" : "Advanced" }
uniform bool uUseCustomMasks;
#endif
//: param custom { "default": true, "group" : "Advanced" }
uniform bool uUseCustomAOTex;

struct ShaderOutputs {
    LocalVectors vectors;
    float wear, pearlFactor;
    vec3 color, orm;
};

vec3 rgb2hsl(vec3 color) {
    float maxC = max(max(color.r, color.g), color.b);
    float minC = min(min(color.r, color.g), color.b);
    float l = (maxC + minC) * 0.5;

    float h = 0.0;
    float s = 0.0;

    if (maxC != minC) {
        float d = maxC - minC;
        s = l > 0.5 ? d / (2.0 - maxC - minC) : d / (maxC + minC);
        if (maxC == color.r)
            h = (color.g - color.b) / d + (color.g < color.b ? 6.0 : 0.0);
        else if (maxC == color.g)
            h = (color.b - color.r) / d + 2.0;
        else
            h = (color.r - color.g) / d + 4.0;
        h /= 6.0;
    }

    return vec3(h, s, l);
}

float hue2rgb(float p, float q, float t) {
    if (t < 0.0) t += 1.0;
    if (t > 1.0) t -= 1.0;
    if (t < 1.0 / 6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0 / 2.0) return q;
    if (t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
    return p;
}

vec3 hsl2rgb(vec3 hsl) {
    float r, g, b;

    if (hsl.y == 0.0) {
        r = g = b = hsl.z;
    } else {
        float q = hsl.z < 0.5 ? hsl.z * (1.0 + hsl.y) : hsl.z + hsl.y - hsl.z * hsl.y;
        float p = 2.0 * hsl.z - q;
        r = hue2rgb(p, q, hsl.x + 1.0 / 3.0);
        g = hue2rgb(p, q, hsl.x);
        b = hue2rgb(p, q, hsl.x - 1.0 / 3.0);
    }

    return vec3(r, g, b);
}

vec3 hueShift(vec3 col, float factor) {
    vec3 hsl = rgb2hsl(col);
    hsl.x = mod(hsl.x + factor / M_2PI, 1.0);
    return hsl2rgb(hsl);
}

vec2 transform(vec2 uv, float scale, vec4 T) {
    float t = radians(T.w);
    float s = sin(t), c = cos(t);
    mat2 R = mat2(c, s, -s, c);

    float E = t - M_PI;
    float k = 1.0 / E - 0.1 * E + 0.5;
    vec2 o = vec2(s, c) * (k * s * s);

    uv.y = 1.0 - uv.y;
    uv = R * uv * T.x * scale + T.yz;
    uv.y = 1.0 - uv.y;

    return uv + o;
}

void applyFinish(V2F inputs, out ShaderOutputs outputs) {
    vec2 uv = inputs.tex_coord;

    // base textures
    vec4 baseColor = sRGB2linear(texture(uBaseColor, uv));
    vec4 baseCavity = sRGB2linear(texture(uBaseCavity, uv));
    vec3 baseMasks = texture(uBaseMasks, uv).rgb;
    vec3 baseNormal = texture(uBaseSurface, uv).rgb;
    float baseRough = texture(uBaseRough, uv).r;
    float baseCurv = baseCavity.r;
    float baseAO = baseCavity.g;

    #if FINISH_STYLE != CU
        vec3 masks;
        if (uUseCustomMasks)
            masks = texture(uPatternMasks.tex, uv).rgb;
        else
            masks = baseMasks;
        outputs.color = uCol0;
    #else
        vec3 masks = baseMasks;
        masks.r = 0.0;
    #endif

    // grunge textures
    float patternWear = texture(uWearTex, transform(uv, uBaseScale, uWearTransform)).r;
    vec4 grungeColor = texture(uGrungeTex, transform(uv, uBaseScale, uGrungeTransform));
    
    // pattern textures
    float patternScale = uIgnoreWeaponSizeScale ? 1.0 : uBaseScale;
    uv = transform(uv, patternScale, uTexTransform);
    float patternRough = uUseCustomRough ? texture(uPatternRough.tex, uv).r : uPaintRough;

    // normal
    if (uUseCustomNormal)
        outputs.vectors = computeLocalFrame(inputs);
    else {
        baseNormal.yz = vec2(baseNormal.z, 1.0 - baseNormal.y); 
        inputs.normal = normalize(baseNormal * 2.0 - 1.0);
        outputs.vectors = computeLocalFrame(inputs, inputs.normal, 0.0);
    }

    outputs.pearlFactor = uPearlScale;
    if (uUsePearlMask)
        outputs.pearlFactor *= texture(uPatternPearl.tex, uv).r;

    // Paint Wear ----------------------------------------------------- //

    outputs.wear = baseCavity.a;

    #if FINISH_STYLE != AQ 
        outputs.wear += patternWear * baseCurv;
        outputs.wear *= uWearAmt * 6.0 + 1.0;

        #if (FINISH_STYLE == CU || FINISH_STYLE == GS)
            vec4 patternColor = vec4(texture(uPatternColor.tex, uv).rgb, texture(uPatternAlpha.tex, uv).r);
            outputs.wear += smoothstep(0.5, 0.6, patternColor.a) * smoothstep(1.0, 0.9, patternColor.a);

            float cuttable = 1.0;

            #if FINISH_STYLE == GS
                outputs.wear *= max(1.0 - cuttable, smoothstep(0.0, 0.5, patternColor.a));
                patternColor.a = mix(patternColor.a, clamp(patternColor.a * 2.0, 0.0, 1.0), masks.r);
                float patternMetal = masks.r;
            #else
                outputs.wear *= max(1.0 - cuttable, smoothstep(0.0, 0.5, patternColor.a));
                float patternMetal = 0.0;
            #endif
        #else
            float patternMetal = 0.0;
        #endif
    #else
        float patternMetal = 1.0;
    #endif

    #if (FINISH_STYLE != AQ && FINISH_STYLE != GS)
        outputs.wear = smoothstep(0.58, 0.68, outputs.wear);
    #elif FINISH_STYLE == GS
        outputs.wear = mix(smoothstep(0.58, 0.68, outputs.wear), outputs.wear, masks.r);
    #endif

    #if (FINISH_STYLE == AQ || FINISH_STYLE == GS)
        float grunge = grungeColor.r * grungeColor.g * grungeColor.b;
    #endif

    grungeColor = mix(vec4(1.0), grungeColor, (pow((1.0 - baseCurv), 4.0) * 0.25 + 0.75 * uWearAmt));

    // Paint Color  --------------------------------------------------- //

    #if FINISH_STYLE == CU
        outputs.color = patternColor.rgb;
    #endif

    #if FINISH_STYLE == AQ
        vec4 patternColor = vec4(texture(uPatternColor.tex, uv).rgb, texture(uPatternAlpha.tex, uv).r);
    #endif

    // Antiqued / Gunsmith
    #if (FINISH_STYLE == AQ || FINISH_STYLE == GS)
        float patinaBlend = patternWear * baseAO * baseCurv * baseCurv;
        patinaBlend = smoothstep(0.1, 0.2, patinaBlend * uWearAmt);

        float grimeBlend = clamp(baseCurv * baseAO - uWearAmt * 0.1, 0.0, 1.0) - grunge;
        grimeBlend = smoothstep(0.0, 0.15, grimeBlend + 0.08);

        float patternLum = dot(patternColor.rgb, vec3(0.3, 0.59, 0.11));
        vec3 scratchesCol = uCol0 * patternLum;

        patternLum = dot(patternColor.rgb * uCol1, vec3(0.3, 0.59, 0.11));
        vec3 patinaCol = mix(uCol1, uCol2 + patternLum, uWearAmt);
        vec3 grimeCol = mix(uCol1, uCol3 + patternLum, pow(uWearAmt, 0.5));
        patinaCol = mix(grimeCol, patinaCol, grimeBlend) * patternColor.rgb;

        patinaCol = mix(patinaCol, scratchesCol, patinaBlend);

        #if FINISH_STYLE == AQ
            outputs.color = patinaCol;
            outputs.wear = 1.0 - masks.r;
        #else
            outputs.color = mix(patternColor.rgb, patinaCol, masks.r);
            outputs.wear *= 1.0 - masks.r;
        #endif
    #endif

    // Outputs -------------------------------------------------------- //

    // color
    outputs.color *= grungeColor.rgb;
    // pearlescence
    outputs.pearlFactor *= 1.0 - max(0.0, dot(outputs.vectors.normal, outputs.vectors.eye));
    outputs.color = hueShift(outputs.color, outputs.pearlFactor);
    outputs.color = mix(outputs.color, baseColor.rgb, outputs.wear);

    // dirt
    float dirtMask = grungeColor.a;
    #if (FINISH_STYLE == AQ || FINISH_STYLE == GS)
        #if FINISH_STYLE == AQ
            dirtMask *= mix(grimeBlend * (1.0 - patinaBlend * uWearAmt), 1.0, patinaBlend);
        #elif FINISH_STYLE == GS
            float patternSpecBlend = smoothstep(0.9, 1.0, outputs.wear) * masks.r;
            dirtMask *= mix(smoothstep(0.01, 0.0, outputs.wear), mix(grimeBlend * (1.0 - patinaBlend * uWearAmt), 1.0, patinaBlend), masks.r);
        #else
            dirtMask *= mix(0.6, 0.5, patternEdge);
        #endif

        #if FINISH_STYLE == GS
            float dirt = mix(dirtMask, baseColor.a, patternSpecBlend);
            float dirtMult = mix(0.6, 0.2, masks.r);
        #else
            float dirt = mix(dirtMask, baseColor.a, outputs.wear);
            float dirtMult = 0.2;
        #endif
    #else
        float patternSpecBlend = smoothstep(0.9, 1.0, outputs.wear);
        dirtMask *= smoothstep(0.01, 0.0, outputs.wear);
        float dirt = mix(dirtMask, baseColor.a, patternSpecBlend);
        float dirtMult = 0.6;
    #endif

    // occlusion
    outputs.orm.r = uUseCustomAOTex ? getAO(inputs.sparse_coord, true) : baseAO;
    // roughness
    outputs.orm.g = mix(patternRough + (1.0 - dirt) * dirtMult * uWearAmt, baseRough, outputs.wear);
    // metallic
    outputs.orm.b = mix(patternMetal * mix(1.0, dirt * 0.75 + 0.25, uWearAmt), baseMasks.r, outputs.wear);
}

void shadePBR(ShaderOutputs outputs) {
    float shadow = getShadowFactor();
    vec3 diffColor = generateDiffuseColor(outputs.color, outputs.orm.b);
    vec3 specColor = generateSpecularColor(0.04, outputs.color, outputs.orm.b);
    float specOcclusion = specularOcclusionCorrection(shadow, outputs.orm.b, outputs.orm.g);

    albedoOutput(diffColor);
    diffuseShadingOutput(outputs.orm.r * shadow * envIrradiance(outputs.vectors.normal));
    specularShadingOutput(specOcclusion * pbrComputeSpecular(outputs.vectors, specColor, outputs.orm.g));
}

void shade(V2F inputs) {
    ShaderOutputs outputs;

    if (uLivePreview) {
        applyFinish(inputs, outputs);
        // pbr validation
        if (uPBRValidation) {
            float g = dot(linear2sRGB(outputs.color), vec3(0.2126, 0.7152, 0.0722));

            vec3 valCol = mix(
                vec3(step(uPBRRanges[1] / 255, g), 0.0, step(g, uPBRRanges[0] / 255)), // non-metallic
                vec3(step(uPBRRanges[3] / 255, g), 0.0, step(g, uPBRRanges[2] / 255)), // metallic
                step(0.5, outputs.orm.b)
            );

            valCol = mix(valCol, vec3(0.0), outputs.wear);
            outputs.color = clamp(outputs.color - length(valCol), 0.0, 1.0) + valCol;

            emissiveColorOutput(valCol);
        }

        switch (uDebugChannel) {
            case 1:
                emissiveColorOutput(vec3(1.0 - outputs.wear));
                break;
            case 2:
                emissiveColorOutput(outputs.color);
                break;
            case 3:
                emissiveColorOutput(sRGB2linear(vec3(outputs.orm.g)));
                break;
            case 4:
                emissiveColorOutput(sRGB2linear(vec3(outputs.pearlFactor / M_2PI + 0.5)));
                break;
            default:
                shadePBR(outputs);
        }
    } else {
        outputs.vectors = computeLocalFrame(inputs);
        outputs.color = textureSparse(uPatternColor, inputs.sparse_coord).rgb;
        outputs.orm.r = getAO(inputs.sparse_coord, true);
        outputs.orm.g = textureSparse(uPatternRough, inputs.sparse_coord).r;
        outputs.orm.b = textureSparse(uPatternMasks, inputs.sparse_coord).r;
        shadePBR(outputs);
    }
}
