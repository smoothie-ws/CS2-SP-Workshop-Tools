import lib-pbr.glsl
import lib-vectors.glsl
import lib-utils.glsl
import lib-sampler.glsl
import lib-normal.glsl

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
//:  "custom-ui" : "cs2/main.qml"
//: }

// Grunge Textures

//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D uGrungeTex;
//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D uScratchesTex;

// Weapon Base Textures

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

// Paint Textures

//: param auto channel_specularlevel
uniform SamplerSparse uMatSpecLevel;
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

// General

//: param custom { "default": true }
uniform_specialization bool uLivePreview;
//: param custom { "default": true }
uniform_specialization bool uPBRValidation;
//: param custom { "default": 4 }
uniform_specialization int uFinishStyle;

// Common

//: param custom { "default": [90, 250] }
uniform vec2 uPBRRange;
//: param custom { "default": 0.00 }
uniform float uWearAmt;
//: param custom { "default": true }
uniform bool uIgnoreWeaponSizeScale;
//: param custom { "default": 1.00 }
uniform vec3 uCol0;
//: param custom { "default": 1.00 }
uniform vec3 uCol1;
//: param custom { "default": 1.00 }
uniform vec3 uCol2;
//: param custom { "default": 1.00 }
uniform vec3 uCol3;
//: param custom { "default": [0.0, 0.0, 1.0, 0.0] }
uniform vec4 uTexTransform; // packed values: [offsetX, offsetY, scale, rotation]
//: param custom { "default": 0.00 }
uniform float uPearlScale;
//: param custom { "default": true }
uniform bool uUsePearlMask;
//: param custom { "default": 0.60 }
uniform float uPaintRoughness;
//: param custom { "default": true }
uniform bool uUseCustomRough;
//: param custom { "default": true }
uniform bool uUseCustomNormal;
//: param custom { "default": true }
uniform bool uUseCustomMasks;
//: param custom { "default": true }
uniform bool uUseCustomAOTex;

#define uTexOffset uTexTransform.xy
#define uTexScale uTexTransform.z
#define uTexRotation uTexTransform.w

vec3 hueShift(vec3 col, float factor) {
    const vec3 w = vec3(0.5, 0.5, 0.5);
    float c = cos(factor);
    vec3 res = col;
    res *= c;
    res += cross(w, col) * sin(factor);
    res += w * dot(w, col) * (1.0 - c);
    return res;
}

vec3 valPBR(vec3 col, float l_min, float l_max) {
    float lum = dot(linear2sRGB(col), vec3(0.299, 0.587, 0.114)) * 255;
    if (lum < l_min)
        return vec3(0.0, 0.0, 1.0);
    else if (lum > l_max)
        return vec3(1.0, 0.0, 0.0);
    else
        return vec3(0.0);
}

vec4 tex2D(sampler2D tex_sampler, V2F inputs) {
    return texture(tex_sampler, inputs.tex_coord);
}

vec4 tex2D(SamplerSparse tex_sampler, V2F inputs) {
    return textureSparse(tex_sampler, inputs.sparse_coord);
}

void applyFinish(V2F inputs) {
    // replace normals if needed
    if (!uUseCustomNormal) 
        inputs.normal = normalize(tex2D(uBaseSurface, inputs).rgb * 2.0 - 1.0);

    // coord transformation
    float s = sin(uTexRotation);
    float c = cos(uTexRotation);
    inputs.sparse_coord.tex_coord *= mat2(c, -s, s, c);
    inputs.sparse_coord.tex_coord *= uTexScale;
    inputs.sparse_coord.tex_coord += uTexOffset;

    // grunge textures
    vec4 grungeCol = tex2D(uGrungeTex, inputs);
    float paintWear = tex2D(uScratchesTex, inputs).r;

    // material textures
    vec4 matColor = tex2D(uMatColor, inputs);
    matColor.a = tex2D(uMatAlpha, inputs).r;
    float matRough = uUseCustomRough ? tex2D(uMatRough, inputs).r : uPaintRoughness;
    float matPearl = uUsePearlMask ? tex2D(uMatPearl, inputs).r : 1.0;

    // base textures
    vec3 baseColor = sRGB2linear(tex2D(uBaseColor, inputs).rgb);
    vec2 baseCavity = tex2D(uBaseCavity, inputs).rg;
    float baseRough = tex2D(uBaseRough, inputs).r;

    vec3 masks = (uUseCustomMasks ? tex2D(uMatMasks, inputs) : tex2D(uBaseMasks, inputs)).rgb;

    float curv = baseCavity.r;
    float ao = baseCavity.g;

    // Wear

    float paintBlend = 0.0;
    if (uFinishStyle != AQ) {
        paintBlend = paintWear * curv;
        paintBlend *= uWearAmt * 6.0 + 1.0;

        if (uFinishStyle == HY || uFinishStyle == AM || uFinishStyle == CU || uFinishStyle == GS) {
            paintBlend += smoothstep(0.5, 0.6, matColor.a) * smoothstep(1.0, 0.9, matColor.a);

            float cuttable = 1.0;
            if (uFinishStyle == HY || uFinishStyle == AM)
                cuttable = 1.0 - clamp(masks.g + masks.b, 0.0, 1.0);

            if (uFinishStyle == AM)
                matColor.a = clamp(matColor.a * 2.0, 0.0, 1.0);
            else if (uFinishStyle == GS) {
                paintBlend *= max(1.0 - cuttable, smoothstep(0.0, 0.5, matColor.a));
                matColor.a = mix(matColor.a, clamp(matColor.a * 2.0, 0.0, 1.0), masks.r);
            } else
                paintBlend *= max(1.0 - cuttable, smoothstep(0.0, 0.5, matColor.a));
        }
    }

    vec3 paintEdges = vec3(1.0);
    if (uFinishStyle == HY || uFinishStyle == SP) {
        vec3 spread = vec3(0.06 * uWearAmt);
        spread.y *= 2.0;
        spread.z *= 3.0;

        paintEdges.x = smoothstep(0.58, 0.56 - spread.x, paintBlend);
        paintEdges.y = smoothstep(0.56 - spread.x, 0.54 - spread.y, paintBlend);
        paintEdges.z = smoothstep(0.54 - spread.y, 0.52 - spread.z, paintBlend);
    }

    if (uFinishStyle == GS)
        paintBlend = mix(smoothstep(0.58, 0.68, paintBlend), paintBlend, masks.r);
    else if (uFinishStyle != AQ)
        paintBlend = smoothstep(0.58, 0.68, paintBlend);

    float paintEdge;
    if (uFinishStyle == AN || uFinishStyle == AM || uFinishStyle == AA)
        paintEdge = smoothstep(0.0, 0.01, paintBlend);

    float grunge;
    if (uFinishStyle == AQ || uFinishStyle == GS)
        grunge = grungeCol.r * grungeCol.g * grungeCol.b;

    grungeCol = mix(vec4(1.0), grungeCol, (pow((1.0 - curv), 4.0) * 0.25 + 0.75 * uWearAmt));

    // Paint Color

    vec3 paintCol = uCol0;

    // Solid Color
    if (uFinishStyle == SO) {
        paintCol = mix(paintCol, uCol1, masks.r);
        paintCol = mix(paintCol, uCol2, masks.g);
        paintCol = mix(paintCol, uCol3, masks.b);
    }

    // Hydrographic / Anodized Multicolored
    if (uFinishStyle == HY || uFinishStyle == AM) {
        paintCol = mix(mix(mix(uCol0, uCol1, matColor.r), uCol2, matColor.g), uCol3, matColor.b);
        paintCol = mix(paintCol, uCol2, masks.g);
        paintCol = mix(paintCol, uCol3, masks.b);
    }

    // TODO: pattern mapping

    // Anodized
    if (uFinishStyle == AN || uFinishStyle == AM || uFinishStyle == AA) {
        if (uFinishStyle == AN)
            paintCol.rgb = uCol0.rgb;
        paintCol = mix(paintCol, vec3(0.05), paintEdge);
        grungeCol.rgb = mix(grungeCol.rgb, vec3(1.0), paintEdge);
        paintBlend = clamp(1.0 + paintBlend - masks.r, 0.0, 1.0);
    }

    // Custom painted
    if (uFinishStyle == CU)
        paintCol = matColor.rgb;

    // Antiqued / Gunsmith
    if (uFinishStyle == AQ || uFinishStyle == GS) {
        float patinaBlend = paintWear * ao * curv * curv;
        patinaBlend = smoothstep(0.1, 0.2, patinaBlend * uWearAmt);

        float grimeBlend = clamp(curv * ao - uWearAmt * 0.1, 0.0, 1.0) - grunge;
        grimeBlend = smoothstep(0.0, 0.15, grimeBlend + 0.08);

        vec3 patina = mix(uCol1, uCol2, uWearAmt);
        vec3 grimeCol = mix(uCol1, uCol3, pow(uWearAmt, 0.5));
        patina = mix(grimeCol, patina, grimeBlend) * matColor.rgb;
        float paintLum = dot(matColor.rgb, vec3(0.3, 0.59, 0.11));
        patina = mix(patina, uCol0 * paintLum, patinaBlend);

        if (uFinishStyle == AQ) {
            paintCol = patina;
            paintBlend = 1.0 - masks.r;
        } else {
            paintCol = mix(matColor.rgb, patina, masks.r);
            paintBlend *= 1.0 - masks.r;
        }
    }

    vec3 outCol = mix(paintCol, baseColor, paintBlend);
    float outRough = mix(matRough, baseRough, paintBlend);
    float specLevel = tex2D(uMatSpecLevel, inputs).r;

    vec3 diffColor = generateDiffuseColor(outCol, masks.r);
    vec3 specColor = generateSpecularColor(specLevel, outCol, masks.r);
    LocalVectors vectors = computeLocalFrame(inputs);

    float shadow = getShadowFactor();
    if (uUseCustomAOTex)
        ao = getAO(inputs.sparse_coord, true);
    float specOcclusion = specularOcclusionCorrection(ao * shadow, masks.r, outRough);

    albedoOutput(diffColor);
    diffuseShadingOutput(ao * shadow * envIrradiance(vectors.normal));
    specularShadingOutput(specOcclusion * pbrComputeSpecular(vectors, specColor, outRough));
}

void shade(V2F inputs) {
    if (uLivePreview)
        applyFinish(inputs);
    else {
        vec3 baseColor = tex2D(uMatColor, inputs).rgb;
        float roughness = tex2D(uMatRough, inputs).r;
        float metallic = tex2D(uMatMasks, inputs).r;
        float specLevel = tex2D(uMatSpecLevel, inputs).r;

        vec3 diffColor = generateDiffuseColor(baseColor, metallic);
        vec3 specColor = generateSpecularColor(specLevel, baseColor, metallic);
        LocalVectors vectors = computeLocalFrame(inputs);

        float shadow = getShadowFactor();
        float ao = getAO(inputs.sparse_coord, true);
        float specOcclusion = specularOcclusionCorrection(ao * shadow, metallic, roughness);

        albedoOutput(diffColor);
        diffuseShadingOutput(ao * shadow * envIrradiance(vectors.normal));
        specularShadingOutput(specOcclusion * pbrComputeSpecular(vectors, specColor, roughness));
    }
}
