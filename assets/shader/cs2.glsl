import lib-pbr.glsl
import lib-utils.glsl
import lib-normal.glsl
import lib-defines.glsl
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

//: metadata {
//:  "custom-ui" : "cs2-ui.qml"
//: }

// General Parameters --------------------------------------------- //

//: param custom { "default": true }
uniform_specialization bool uLivePreview;
//: param custom { "default": 0 }
uniform_specialization int uDebugChannel;
//: param custom { "default": false }
uniform_specialization bool uPBRValidation;
//: param custom { "default": [50, 245, 106, 255] }
uniform vec4 uPBRRanges; // packed values: [non-metallic min:max, metallic min:max]

// Paint Textures ------------------------------------------------- //

//: param custom { "default": [1.0, 0.0, 0.0, 0.0] }
uniform vec4 uTexTransform; // packed values: [scale, translateX, translateY, rotation]
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

// Weapon Base Textures ------------------------------------------- //

//: param custom { "default": "1.0" }
uniform float uBaseScale;
//: param custom { "default": true }
uniform bool uIgnoreWeaponSizeScale;
//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D uBaseColor;
//: param custom { "default": "", "default_color": [1.0, 0.5, 0.5] }
uniform sampler2D uBaseRough;
//: param custom { "default": "", "default_color": [1.0, 0.0, 0.0] }
uniform sampler2D uBaseMasks;
//: param custom { "default": "", "default_color": [0.5, 0.5, 1.0] }
uniform sampler2D uBaseSurface;
//: param custom { "default": "", "default_color": [1.0, 0.5, 0.5] }
uniform sampler2D uBaseCavity;

// Grunge Textures ------------------------------------------------ //

//: param custom { "default": [1.5, 0.0, 0.0, 0.0] }
uniform vec4 uWearTransform; // packed values: [scale, translateX, translateY, rotation]
//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D uWearTex;
//: param custom { "default": [1.5, 0.0, 0.0, 0.0] }
uniform vec4 uGrungeTransform; // packed values: [scale, translateX, translateY, rotation]
//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D uGrungeTex;

// Common Parameters ---------------------------------------------- //

//: param custom { "default": 0.00 }
uniform float uWearAmt;

//: param custom { "default": 0.6 }
uniform float uPaintRough;
//: param custom { "default": 0.0 }
uniform float uPearlScale;
#if (FINISH_STYLE == SO || FINISH_STYLE == HY || FINISH_STYLE == SP)
//: param custom { "default": false }
uniform bool uUseRoughByColor;
//: param custom { "default": [0.6, 0.6, 0.6, 0.6] }
uniform vec4 uPaintRoughNum;
//: param custom { "default": [0.0, 0.0, 0.0, 0.0] }
uniform vec4 uPaintMetalNum;
//: param custom { "default": [0.0, 0.0, 0.0, 0.0] }
uniform vec4 uPaintDurabilityNum;
#if (FINISH_STYLE == SP)
//: param custom { "default": [0.5, 0.5] }
uniform vec2 uSprayBlend;
#endif
#endif

#if FINISH_STYLE != CU
//: param custom { "default": [1.0, 1.0, 1.0] }
uniform vec3 uCol0;
//: param custom { "default": [1.0, 1.0, 1.0] }
uniform vec3 uCol1;
//: param custom { "default": [1.0, 1.0, 1.0] }
uniform vec3 uCol2;
//: param custom { "default": [1.0, 1.0, 1.0] }
uniform vec3 uCol3;

//: param custom { "default": true }
uniform bool uUseCustomMasks;
#endif
//: param custom { "default": true }
uniform bool uUsePearlMask;
//: param custom { "default": true }
uniform bool uUseCustomRough;
//: param custom { "default": true }
uniform bool uUseCustomNormal;
//: param custom { "default": true }
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

    // colors
    vec3 col0 = sRGB2linear(uCol0);
    vec3 col1 = sRGB2linear(uCol1);
    vec3 col2 = sRGB2linear(uCol2);
    vec3 col3 = sRGB2linear(uCol3);

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
        outputs.color = col0;
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
    vec4 patternColor = vec4(texture(uPatternColor.tex, uv).rgb, texture(uPatternAlpha.tex, uv).r);

    float patternRough = uPaintRough;
    if (uUseCustomRough)
        patternRough = texture(uPatternRough.tex, uv).r;
    #if (FINISH_STYLE == SO || FINISH_STYLE == HY || FINISH_STYLE == SP)
        else if (uUseRoughByColor)
            patternRough = uPaintRoughNum[0];
    #endif

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

    // Solid Color
    #if FINISH_STYLE == SO
        // color
        outputs.color = mix(outputs.color, col1, masks.r);
        outputs.color = mix(outputs.color, col2, masks.g);
        outputs.color = mix(outputs.color, col3, masks.b);
        // durability
        float paintDurability = mix(uPaintDurabilityNum[0], uPaintDurabilityNum[1], masks.r);
        paintDurability = mix(paintDurability, uPaintDurabilityNum[2], masks.g);
        paintDurability = mix(paintDurability, uPaintDurabilityNum[3], masks.b);
        // metalness
        float patternMetal = mix(uPaintMetalNum[0], uPaintMetalNum[1], masks.r);
        patternMetal = mix(patternMetal, uPaintMetalNum[2], masks.g);
        patternMetal = mix(patternMetal, uPaintMetalNum[3], masks.b);
        // roughness
        if (uUseRoughByColor) {
            patternRough = mix(patternRough, uPaintRoughNum[1], masks.r);
            patternRough = mix(patternRough, uPaintRoughNum[2], masks.g);
            patternRough = mix(patternRough, uPaintRoughNum[3], masks.b);
        }
    #endif

    // Hydrographic / Anodized Multicolored
    #if FINISH_STYLE == HY || FINISH_STYLE == AM
        // color
        outputs.color = mix(mix(mix(col0, col1, patternColor.r), col2, patternColor.g), col3, patternColor.b);
        outputs.color = mix(outputs.color, col2, masks.g);
        outputs.color = mix(outputs.color, col3, masks.b);
        #if FINISH_STYLE == HY
            // durability
            float paintDurability = mix(mix(mix(uPaintDurabilityNum[0], uPaintDurabilityNum[1], patternColor.r), uPaintDurabilityNum[2], patternColor.g), uPaintDurabilityNum[3], patternColor.b);
            paintDurability = mix(paintDurability, uPaintDurabilityNum[2], masks.g);
            paintDurability = mix(paintDurability, uPaintDurabilityNum[3], masks.b);
            // metalness
            float patternMetal = mix(mix(mix(uPaintMetalNum[0], uPaintMetalNum[1], patternColor.r), uPaintMetalNum[2], patternColor.g), uPaintMetalNum[3], patternColor.b);
            patternMetal = mix(patternMetal, uPaintMetalNum[2], masks.g);
            patternMetal = mix(patternMetal, uPaintMetalNum[3], masks.b);
            // roughness
            if (uUseRoughByColor) {
                patternRough = mix(mix(mix(uPaintRoughNum[0], uPaintRoughNum[1], patternColor.r), uPaintRoughNum[2], patternColor.g), uPaintRoughNum[3], patternColor.b);
                patternRough = mix(patternRough, uPaintRoughNum[2], masks.g);
                patternRough = mix(patternRough, uPaintRoughNum[3], masks.b);
            }
        #endif
    #endif

    // Spraypaint / Anodized Airbrushed
    #if (FINISH_STYLE == SP || FINISH_STYLE == AA)
        vec3 texX = texture(uPatternColor.tex, transform(inputs.position.yz, patternScale, uTexTransform)).rgb;
        vec3 texY = texture(uPatternColor.tex, transform(inputs.position.xz, patternScale, uTexTransform)).rgb;
        vec3 texZ = texture(uPatternColor.tex, transform(inputs.position.yx, patternScale, uTexTransform)).rgb;

        vec3 normal = normalize(inputs.normal * 2.0 - 1.0);
        float yBlend = abs(dot(normal.xyz, vec3(0.0, 1.0, 0.0)));
        float zBlend = abs(dot(normal.xyz, vec3(0.0, 0.0, 1.0)));
        #if FINISH_STYLE == SP
            yBlend *= uSprayBlend[0];
            zBlend *= uSprayBlend[1];
        #endif

        vec3 patternMask = mix(mix(texX, texY, pow(yBlend, 7)), texZ, pow(zBlend, 7));

        #if FINISH_STYLE == SP
            patternMask.xyz *= patternEdges.xyz;
            // durability
            float paintDurability = mix(mix(mix(uPaintDurabilityNum[0], uPaintDurabilityNum[1], patternMask.r), uPaintDurabilityNum[2], patternMask.g), uPaintDurabilityNum[3], patternMask.b);
            // metalness
            float patternMetal = mix(mix(mix(uPaintMetalNum[0], uPaintMetalNum[1], patternMask.r), uPaintMetalNum[2], patternMask.g), uPaintMetalNum[3], patternMask.b);
            // roughness
            if (uUseRoughByColor)
                patternRough = mix(mix(mix(uPaintRoughNum[0], uPaintRoughNum[1], patternMask.r), uPaintRoughNum[2], patternMask.g), uPaintRoughNum[3], patternMask.b);
        #endif

        outputs.color = mix(mix(mix(col0, col1, patternMask.r), col2, patternMask.g), col3, patternMask.b);
    #endif

    // Paint Wear ----------------------------------------------------- //

    outputs.wear = baseCavity.a;

    #if FINISH_STYLE != AQ
        #if (FINISH_STYLE == SO || FINISH_STYLE == HY || FINISH_STYLE == SP)
            patternWear *= 1.0 - paintDurability;
        #endif

        outputs.wear += patternWear * baseCurv;
        outputs.wear *= uWearAmt * 6.0 + 1.0;

        #if (FINISH_STYLE == HY || FINISH_STYLE == AM || FINISH_STYLE == CU || FINISH_STYLE == GS)
            outputs.wear += smoothstep(0.5, 0.6, patternColor.a) * smoothstep(1.0, 0.9, patternColor.a);

            float cuttable = 1.0;
            #if (FINISH_STYLE == HY || FINISH_STYLE == AM)
                cuttable = 1.0 - clamp(masks.g + masks.b, 0.0, 1.0);
            #endif

            #if FINISH_STYLE == AM
                patternColor.a = clamp(patternColor.a * 2.0, 0.0, 1.0);
                float patternMetal = 1.0;
            #elif FINISH_STYLE == GS
                outputs.wear *= max(1.0 - cuttable, smoothstep(0.0, 0.5, patternColor.a));
                patternColor.a = mix(patternColor.a, clamp(patternColor.a * 2.0, 0.0, 1.0), masks.r);
                float patternMetal = masks.r;
            #elif FINISH_STYLE != HY
                outputs.wear *= max(1.0 - cuttable, smoothstep(0.0, 0.5, patternColor.a));
                float patternMetal = 0.0;
            #endif
        #elif (FINISH_STYLE != SO && FINISH_STYLE != SP)
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

    #if (FINISH_STYLE == HY || FINISH_STYLE == SP)
        vec3 spread = vec3(0.06 * uWearAmt);
        spread.y *= 2.0;
        spread.z *= 3.0;

        vec3 patternEdges = vec3(1.0);
        patternEdges.x = smoothstep(0.58, 0.56 - spread.x, outputs.wear);
        patternEdges.y = smoothstep(0.56 - spread.x, 0.54 - spread.y, outputs.wear);
        patternEdges.z = smoothstep(0.54 - spread.y, 0.52 - spread.z, outputs.wear);
    #endif

    #if (FINISH_STYLE == AN || FINISH_STYLE == AM || FINISH_STYLE == AA)
        float patternEdge = smoothstep(0.0, 0.01, outputs.wear);
    #endif

    #if (FINISH_STYLE == AQ || FINISH_STYLE == GS)
        float grunge = grungeColor.r * grungeColor.g * grungeColor.b;
    #endif

    grungeColor = mix(vec4(1.0), grungeColor, (pow((1.0 - baseCurv), 4.0) * 0.25 + 0.75 * uWearAmt));

    // Anodized
    #if (FINISH_STYLE == AN || FINISH_STYLE == AM || FINISH_STYLE == AA)
        #if FINISH_STYLE == AN
            outputs.color = col0;
        #endif
        outputs.color = mix(outputs.color, vec3(0.05), patternEdge);
        grungeColor.rgb = mix(grungeColor.rgb, vec3(1.0), patternEdge);
        outputs.wear = clamp(1.0 + outputs.wear - masks.r, 0.0, 1.0);
    #endif
    
    #if FINISH_STYLE == CU
        outputs.color = patternColor.rgb;
    #endif
    
    // Antiqued / Gunsmith
    #if (FINISH_STYLE == AQ || FINISH_STYLE == GS)
        float patinaBlend = patternWear * baseAO * baseCurv * baseCurv;
        patinaBlend = smoothstep(0.1, 0.2, patinaBlend * uWearAmt);

        float grimeBlend = clamp(baseCurv * baseAO - uWearAmt * 0.1, 0.0, 1.0) - grunge;
        grimeBlend = smoothstep(0.0, 0.15, grimeBlend + 0.08);

        float patternLum = dot(patternColor.rgb, vec3(0.3, 0.59, 0.11));
        vec3 scratchesCol = col0 * patternLum;

        patternLum = dot(patternColor.rgb * col1, vec3(0.3, 0.59, 0.11));
        vec3 patinaCol = mix(col1, col2 + patternLum, uWearAmt);
        vec3 grimeCol = mix(col1, col3 + patternLum, pow(uWearAmt, 0.5));
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
    #if (FINISH_STYLE == AN || FINISH_STYLE == AM || FINISH_STYLE == AA || FINISH_STYLE == AQ || FINISH_STYLE == GS)
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
