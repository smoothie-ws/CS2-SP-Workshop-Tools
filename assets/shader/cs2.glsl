import lib-pbr.glsl
import lib-utils.glsl
import lib-normal.glsl
import lib-vectors.glsl
import lib-sampler.glsl

#define SO 0 // Solid Color
#define HY 1 // Hydrographic
#define SP 2 // Spray-Paint
#define AN 3 // Anodized
#define AM 4 // Anodized Multicolored
#define AA 5 // Anodized Airbrushed
#define CU 6 // Custom Paint Job
#define AQ 7 // Patina
#define GS 8 // Gunsmith

#define PI2 6.28318530718

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
uniform SamplerSparse uMatColor;
//: param auto channel_roughness
uniform SamplerSparse uMatRough;
//: param auto channel_user0
uniform SamplerSparse uMatMasks;
//: param auto channel_user1
uniform SamplerSparse uMatAlpha;
//: param auto channel_user2
uniform SamplerSparse uMatPearl;

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

//: param custom { "default": "[1.0, 1.0]", "group" : "Base Textures" }
uniform vec2 uWeaponSize; // packed values: [length, uv scale]

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
uniform float uPaintRoughness;
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
    hsl.x = mod(hsl.x + factor / PI2, 1.0);
    return hsl2rgb(hsl);
}

vec2 transform(vec2 uv, float baseScale, vec4 t) {
    const vec2 center = vec2(0.5);

    float s = sin(t.w);
    float c = cos(t.w);

    uv -= center;
    uv *= baseScale * t.x;
    uv *= mat2(c, -s, s, c);
    uv += center;
    uv += t.yz;

    return uv;
}

void applyFinish(V2F inputs, out ShaderOutputs outputs) {
    vec2 uv = inputs.tex_coord;

    #if (FINISH_STYLE == SP || FINISH_STYLE == AA)
        float baseScale = uWeaponSize.x / 36;
    #else 
        float baseScale = uWeaponSize.y;
    #endif

    // base textures
    vec4 baseCol = sRGB2linear(texture(uBaseColor, uv));
    vec4 baseCavity = sRGB2linear(texture(uBaseCavity, uv));
    vec3 baseMasks = texture(uBaseMasks, uv).rgb;
    vec3 baseNormal = texture(uBaseSurface, uv).rgb;
    float baseRough = texture(uBaseRough, uv).r;
    float baseCurv = baseCavity.r;
    float baseAO = baseCavity.g;

    // grunge textures
    float paintWear = texture(uWearTex, transform(uv, baseScale, uWearTransform)).r;
    vec4 grungeCol = texture(uGrungeTex, transform(uv, baseScale, uGrungeTransform));
    
    // pattern textures
    uv = transform(uv, uIgnoreWeaponSizeScale ? 1.0 : baseScale, uTexTransform);
    vec4 matCol = vec4(texture(uMatColor.tex, uv).rgb, texture(uMatAlpha.tex, uv).r);
    float matRough = uUseCustomRough ? texture(uMatRough.tex, uv).r : uPaintRoughness;

    // normal
    if (uUseCustomNormal)
        outputs.vectors = computeLocalFrame(inputs);
    else {
        baseNormal.yz = vec2(baseNormal.z, 1.0 - baseNormal.y); 
        inputs.normal = normalize(baseNormal * 2.0 - 1.0);
        outputs.vectors = computeLocalFrame(inputs, inputs.normal, 0.0);
    }

    // masks & colors
    #if FINISH_STYLE != CU
        vec3 matMasks;
        if (uUseCustomMasks)
            matMasks = texture(uMatMasks.tex, uv).rgb;
        else
            matMasks = baseMasks;
        outputs.color = uCol0;
    #else
        vec3 matMasks = baseMasks;
        outputs.color = matCol.rgb;
        matMasks.r = 0.0;
    #endif

    outputs.pearlFactor = uPearlScale;
    if (uUsePearlMask)
        outputs.pearlFactor *= texture(uMatPearl.tex, uv).r;

    // Paint Wear ----------------------------------------------------- //

    outputs.wear = baseCavity.a;

    #if FINISH_STYLE != AQ 
        outputs.wear += paintWear * baseCurv;
        outputs.wear *= uWearAmt * 6.0 + 1.0;

        #if (FINISH_STYLE == HY || FINISH_STYLE == AM || FINISH_STYLE == CU || FINISH_STYLE == GS)
            outputs.wear += smoothstep(0.5, 0.6, matCol.a) * smoothstep(1.0, 0.9, matCol.a);

            float cuttable = 1.0;
            #if (FINISH_STYLE == HY || FINISH_STYLE == AM)
                cuttable = 1.0 - clamp(matMasks.g + matMasks.b, 0.0, 1.0);
            #endif

            #if FINISH_STYLE == AM
                matCol.a = clamp(matCol.a * 2.0, 0.0, 1.0);
                float matMetal = 1.0;
            #elif FINISH_STYLE == GS
                outputs.wear *= max(1.0 - cuttable, smoothstep(0.0, 0.5, matCol.a));
                matCol.a = mix(matCol.a, clamp(matCol.a * 2.0, 0.0, 1.0), matMasks.r);
                float matMetal = matMasks.r;
            #else
                outputs.wear *= max(1.0 - cuttable, smoothstep(0.0, 0.5, matCol.a));
                float matMetal = 0.0;
            #endif
        #else
            float matMetal = 0.0;
        #endif
    #else
        float matMetal = 1.0;
    #endif

    #if (FINISH_STYLE == HY || FINISH_STYLE == SP)
        vec3 spread = vec3(0.06 * uWearAmt);
        spread.y *= 2.0;
        spread.z *= 3.0;

        vec3 paintEdges = vec3(1.0);
        paintEdges.x = smoothstep(0.58, 0.56 - spread.x, outputs.wear);
        paintEdges.y = smoothstep(0.56 - spread.x, 0.54 - spread.y, outputs.wear);
        paintEdges.z = smoothstep(0.54 - spread.y, 0.52 - spread.z, outputs.wear);
    #endif

    #if (FINISH_STYLE != AQ && FINISH_STYLE != GS)
        outputs.wear = smoothstep(0.58, 0.68, outputs.wear);
    #elif FINISH_STYLE == GS
        outputs.wear = mix(smoothstep(0.58, 0.68, outputs.wear), outputs.wear, matMasks.r);
    #endif

    #if (FINISH_STYLE == AN || FINISH_STYLE == AM || FINISH_STYLE == AA)
        float paintEdge = smoothstep(0.0, 0.01, outputs.wear);
    #endif

    #if (FINISH_STYLE == AQ || FINISH_STYLE == GS)
        float grunge = grungeCol.r * grungeCol.g * grungeCol.b;
    #endif
    grungeCol = mix(vec4(1.0), grungeCol, (pow((1.0 - baseCurv), 4.0) * 0.25 + 0.75 * uWearAmt));

    // Paint Color  --------------------------------------------------- //

    // Solid Color
    #if FINISH_STYLE == SO
        outputs.color = mix(outputs.color, uCol1, matMasks.r);
        outputs.color = mix(outputs.color, uCol2, matMasks.g);
        outputs.color = mix(outputs.color, uCol3, matMasks.b);
    #endif

    // Hydrographic / Anodized Multicolored
    #if FINISH_STYLE == HY || FINISH_STYLE == AM
        outputs.color = mix(mix(mix(uCol0, uCol1, matCol.r), uCol2, matCol.g), uCol3, matCol.b);
        outputs.color = mix(outputs.color, uCol2, matMasks.g);
        outputs.color = mix(outputs.color, uCol3, matMasks.b);
    #endif

    // TODO: Spraypaint / Anodized Airbrushed

    // Anodized
    #if (FINISH_STYLE == AN || FINISH_STYLE == AM || FINISH_STYLE == AA)
        #if FINISH_STYLE == AN
            outputs.color = uCol0;
        #endif
        outputs.color = mix(outputs.color, vec3(0.05), paintEdge);
        grungeCol.rgb = mix(grungeCol.rgb, vec3(1.0), paintEdge);
        outputs.wear = clamp(1.0 + outputs.wear - matMasks.r, 0.0, 1.0);
    #endif

    // Antiqued / Gunsmith
    #if (FINISH_STYLE == AQ || FINISH_STYLE == GS)
        float patinaBlend = paintWear * baseAO * baseCurv * baseCurv;
        patinaBlend = smoothstep(0.1, 0.2, patinaBlend * uWearAmt);

        float grimeBlend = clamp(baseCurv * baseAO - uWearAmt * 0.1, 0.0, 1.0) - grunge;
        grimeBlend = smoothstep(0.0, 0.15, grimeBlend + 0.08);

        vec3 patinaCol = mix(uCol1, uCol2, uWearAmt);
        vec3 grimeCol = mix(uCol1, uCol3, pow(uWearAmt, 0.5));
        patinaCol = mix(grimeCol, patinaCol, grimeBlend) * matCol.rgb;
        patinaCol += (max(uCol1.r, max(uCol1.g, uCol1.b)) - max(patinaCol.r, max(patinaCol.g, patinaCol.b))) * 0.1;

        float patternLum = dot(matCol.rgb, vec3(0.3, 0.59, 0.11));
        vec3 scratchesCol = uCol0 * patternLum;

        patinaCol = mix(patinaCol, scratchesCol, patinaBlend);

        #if FINISH_STYLE == AQ
            outputs.color = patinaCol;
            outputs.wear = 1.0 - matMasks.r;
        #else
            outputs.color = mix(matCol.rgb, patinaCol, matMasks.r);
            outputs.wear *= 1.0 - matMasks.r;
        #endif
    #endif

    // Outputs -------------------------------------------------------- //

    // color
    outputs.color *= grungeCol.rgb;
    // pearlescence
    outputs.pearlFactor *= 1.0 - max(0.0, dot(outputs.vectors.normal, outputs.vectors.eye));
    outputs.color = hueShift(outputs.color, outputs.pearlFactor);
    outputs.color = mix(outputs.color, baseCol.rgb, outputs.wear);

    #define PAINT_PHONG_INTENSITY 0.6
    #define PHONG_ALBEDO_FACTOR 0.2
    #define ANODIZED_BASE_PHONG_INTENSITY 0.5
    
    // dirt
    float dirtMask = grungeCol.a;
    #if (FINISH_STYLE == AN || FINISH_STYLE == AM || FINISH_STYLE == AA || FINISH_STYLE == AQ || FINISH_STYLE == GS)
        #if FINISH_STYLE == AQ
            dirtMask *= mix(grimeBlend * (1.0 - patinaBlend * uWearAmt), 1.0, patinaBlend);
        #elif FINISH_STYLE == GS
            float paintSpecBlend = smoothstep(0.9, 1.0, outputs.wear) * matMasks.r;
            dirtMask *= mix(smoothstep(0.01, 0.0, outputs.wear), mix(grimeBlend * (1.0 - patinaBlend * uWearAmt), 1.0, patinaBlend), matMasks.r);
        #else
            dirtMask *= mix(PAINT_PHONG_INTENSITY, ANODIZED_BASE_PHONG_INTENSITY, paintEdge);
        #endif

        #if FINISH_STYLE == GS
            float dirt = mix(dirtMask, baseCol.a, paintSpecBlend);
            float dirtMult = mix(PAINT_PHONG_INTENSITY, PHONG_ALBEDO_FACTOR, matMasks.r);
        #else
            float dirt = mix(dirtMask, baseCol.a, outputs.wear);
            float dirtMult = PHONG_ALBEDO_FACTOR;
        #endif
    #else
        float paintSpecBlend = smoothstep(0.9, 1.0, outputs.wear);
        dirtMask *= smoothstep(0.01, 0.0, outputs.wear);
        float dirt = mix(dirtMask, baseCol.a, paintSpecBlend);
        float dirtMult = PAINT_PHONG_INTENSITY;
    #endif

    // occlusion
    outputs.orm.r = uUseCustomAOTex ? getAO(inputs.sparse_coord, true) : baseAO;
    // roughness
    outputs.orm.g = mix(matRough + (1.0 - dirt) * dirtMult * uWearAmt, baseRough, outputs.wear);
    // metallic
    outputs.orm.b = mix(matMetal * mix(1.0, dirt * 0.75 + 0.25, uWearAmt), baseMasks.r, outputs.wear);
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
            float g = dot(outputs.color, vec3(0.2126, 0.7152, 0.0722));

            vec3 valCol = mix(
                vec3(step(uPBRRanges[1], g), 0.0, step(g, uPBRRanges[0])), // non-metallic
                vec3(step(uPBRRanges[3], g), 0.0, step(g, uPBRRanges[2])), // metallic
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
                emissiveColorOutput(sRGB2linear(vec3(outputs.pearlFactor / PI2 + 0.5)));
                break;
            default:
                shadePBR(outputs);
        }
    } else {
        outputs.vectors = computeLocalFrame(inputs);
        outputs.color = textureSparse(uMatColor, inputs.sparse_coord).rgb;
        outputs.orm.r = getAO(inputs.sparse_coord, true);
        outputs.orm.g = textureSparse(uMatRough, inputs.sparse_coord).r;
        outputs.orm.b = textureSparse(uMatMasks, inputs.sparse_coord).r;
        shadePBR(outputs);
    }
}
