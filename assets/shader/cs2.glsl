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
//:  "custom-ui" : "cs2-ui.qml"
//: }

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
uniform sampler2D uGrungeTex;
//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5], "group" : "Base Textures" }
uniform sampler2D uScratchesTex;

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

// General Parameters --------------------------------------------- //

//: param custom { "default": true, "group" : "General" }
uniform_specialization bool uLivePreview;
//: param custom { "default": false, "group" : "General" }
uniform_specialization bool uPBRValidation;

// Common Parameters ---------------------------------------------- //

//: param custom { "default": 0.00, "group" : "Common" }
uniform float uWearAmt;
//: param custom { "default": true, "group" : "Common" }
uniform bool uIgnoreWeaponSizeScale;
//: param custom { "default": [0.0, 0.0, 1.0, 0.0], "group" : "Common" }
uniform vec4 uTexTransform; // packed values: [offsetX, offsetY, scale, rotation]
#if FINISH_STYLE != CU
//: param custom { "default": 1.00, "group" : "Color" }
uniform vec3 uCol0;
//: param custom { "default": 1.00, "group" : "Color" }
uniform vec3 uCol1;
//: param custom { "default": 1.00, "group" : "Color" }
uniform vec3 uCol2;
//: param custom { "default": 1.00, "group" : "Color" }
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

#define uTexOffset uTexTransform.xy
#define uTexScale uTexTransform.z
#define uTexRotation uTexTransform.w

struct ShaderOutputs {
    LocalVectors vectors;
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
    hsl.x = mod(hsl.x + factor / (2.0 * 3.14159265359), 1.0);
    return hsl2rgb(hsl);
}

vec4 tex2D(sampler2D tex_sampler, V2F inputs) {
    return texture(tex_sampler, inputs.tex_coord);
}

vec4 tex2D(SamplerSparse tex_sampler, V2F inputs) {
    return textureSparse(tex_sampler, inputs.sparse_coord);
}

void applyFinish(V2F inputs, out ShaderOutputs outputs) {
    // coord transformation
    float s = sin(uTexRotation);
    float c = cos(uTexRotation);
    inputs.sparse_coord.tex_coord *= mat2(c, -s, s, c);
    inputs.sparse_coord.tex_coord *= uTexScale;
    inputs.sparse_coord.tex_coord += uTexOffset;

    // grunge textures
    vec2 co = inputs.tex_coord;
    inputs.tex_coord *= 1.5;
    inputs.tex_coord += 1.5;
    vec4 grungeCol = sRGB2linear(tex2D(uGrungeTex, inputs));
    float paintWear = tex2D(uScratchesTex, inputs).r;
    inputs.tex_coord = co;

    // material textures
    vec4 matColor = tex2D(uMatColor, inputs);
    matColor.a = tex2D(uMatAlpha, inputs).r;
    float matRough = uUseCustomRough ? (tex2D(uMatRough, inputs).r) : uPaintRoughness;

    // base textures
    vec4 baseColor = sRGB2linear(tex2D(uBaseColor, inputs));
    vec4 baseCavity = sRGB2linear(tex2D(uBaseCavity, inputs));
    vec3 baseMasks = tex2D(uBaseMasks, inputs).rgb;
    float baseRough = tex2D(uBaseRough, inputs).r;
    float baseMetal = baseMasks.r;

    float curv = baseCavity.r;
    float ao = baseCavity.g;

    // masks & colors
    #if FINISH_STYLE != CU
        vec3 matMasks;
        if (uUseCustomMasks)
            matMasks = tex2D(uMatMasks, inputs).rgb;
        else
            matMasks = baseMasks;
        vec3 col0 = sRGB2linear(uCol0);
        vec3 col1 = sRGB2linear(uCol1);
        vec3 col2 = sRGB2linear(uCol2);
        vec3 col3 = sRGB2linear(uCol3);
        vec3 paintCol = col0;
    #else
        vec3 matMasks = baseMasks;
        vec3 paintCol = matColor.rgb;
        matMasks.r = 0.0;
    #endif

    float pearlFactor = uPearlScale;
    if (uUsePearlMask)
        pearlFactor *= tex2D(uMatPearl, inputs).r;

    // Paint Wear ----------------------------------------------------- //

    float paintBlend = baseCavity.a;
    #if FINISH_STYLE != AQ 
        paintBlend += paintWear * curv;
        paintBlend *= uWearAmt * 6.0 + 1.0;

        #if (FINISH_STYLE == HY || FINISH_STYLE == AM || FINISH_STYLE == CU || FINISH_STYLE == GS)
            paintBlend += smoothstep(0.5, 0.6, matColor.a) * smoothstep(1.0, 0.9, matColor.a);

            float cuttable = 1.0;
            #if (FINISH_STYLE == HY || FINISH_STYLE == AM)
                cuttable = 1.0 - clamp(matMasks.g + matMasks.b, 0.0, 1.0);
            #endif

            #if FINISH_STYLE == AM
                matColor.a = clamp(matColor.a * 2.0, 0.0, 1.0);
                float matMetal = 1.0;
            #elif FINISH_STYLE == GS
                paintBlend *= max(1.0 - cuttable, smoothstep(0.0, 0.5, matColor.a));
                matColor.a = mix(matColor.a, clamp(matColor.a * 2.0, 0.0, 1.0), matMasks.r);
                float matMetal = matMasks.r;
            #else
                paintBlend *= max(1.0 - cuttable, smoothstep(0.0, 0.5, matColor.a));
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
        paintEdges.x = smoothstep(0.58, 0.56 - spread.x, paintBlend);
        paintEdges.y = smoothstep(0.56 - spread.x, 0.54 - spread.y, paintBlend);
        paintEdges.z = smoothstep(0.54 - spread.y, 0.52 - spread.z, paintBlend);
    #endif

    #if FINISH_STYLE == GS
        paintBlend = mix(smoothstep(0.58, 0.68, paintBlend), paintBlend, matMasks.r);
    #elif FINISH_STYLE != AQ
        paintBlend = smoothstep(0.58, 0.68, paintBlend);
    #endif

    #if (FINISH_STYLE == AN || FINISH_STYLE == AM || FINISH_STYLE == AA)
        float paintEdge = smoothstep(0.0, 0.01, paintBlend);
    #endif

    #if (FINISH_STYLE == AQ || FINISH_STYLE == GS)
        float grunge = grungeCol.r * grungeCol.g * grungeCol.b;
    #endif

    grungeCol = mix(vec4(1.0), grungeCol, (pow((1.0 - curv), 4.0) * 0.25 + 0.75 * uWearAmt));

    // Paint Color  --------------------------------------------------- //

    // Solid Color
    #if FINISH_STYLE == SO
        paintCol = mix(paintCol, col1, matMasks.r);
        paintCol = mix(paintCol, col2, matMasks.g);
        paintCol = mix(paintCol, col3, matMasks.b);
    #endif

    // Hydrographic / Anodized Multicolored
    #if FINISH_STYLE == HY || FINISH_STYLE == AM
        paintCol = mix(mix(mix(col0, col1, matColor.r), col2, matColor.g), col3, matColor.b);
        paintCol = mix(paintCol, col2, matMasks.g);
        paintCol = mix(paintCol, col3, matMasks.b);
    #endif

    // TODO: Spraypaint / Anodized Airbrushed

    // Anodized
    #if (FINISH_STYLE == AN || FINISH_STYLE == AM || FINISH_STYLE == AA)
        #if FINISH_STYLE == AN
            paintCol.rgb = col0.rgb;
        #endif
        paintCol = mix(paintCol, vec3(0.05), paintEdge);
        grungeCol.rgb = mix(grungeCol.rgb, vec3(1.0), paintEdge);
        paintBlend = clamp(1.0 + paintBlend - matMasks.r, 0.0, 1.0);
        // dirtMask *= mix(0.48, 1.0, paintEdge);
    #endif

    float dirtMask = 0.0;

    // Antiqued / Gunsmith
    #if (FINISH_STYLE == AQ || FINISH_STYLE == GS)
        float patinaBlend = paintWear * ao * curv * curv;
        patinaBlend = smoothstep(0.2, 0.05, patinaBlend * uWearAmt);

        float grimeBlend = clamp(curv * ao - uWearAmt * 0.1, 0.0, 1.0) - grunge * 0.15;
        grimeBlend = smoothstep(0.15, 0.0, grimeBlend + 0.08);

        vec3 patinaCol = mix(col1, col2, uWearAmt);
        vec3 grimeCol = mix(col1, col3, pow(uWearAmt, 0.5));
        patinaCol = mix(patinaCol, grimeCol, grimeBlend) * matColor.rgb;
        patinaCol += (max(col1.r, max(col1.g, col1.b)) - max(patinaCol.r, max(patinaCol.g, patinaCol.b))) * 0.1;

        float patternLum = dot(matColor.rgb, vec3(0.3, 0.59, 0.11));
        patinaCol = mix(col0, patinaCol, patinaBlend) * smoothstep(0.0, 0.1, patternLum);

        #if FINISH_STYLE == AQ
            paintCol = patinaCol;
            paintBlend = 1.0 - matMasks.r;
            pearlFactor *= step(0.0, patinaBlend);
        #else
            paintCol = mix(matColor.rgb, patinaCol, matMasks.r);
            paintBlend *= 1.0 - matMasks.r;
            pearlFactor *= step(0.0, patinaBlend) * matMasks.r + 1.0 - matMasks.r;
        #endif

        dirtMask += mix(0.0, mix(0.0, grimeBlend * patinaBlend * uWearAmt, patinaBlend), matMasks.r);
    #endif

    dirtMask += ao * (0.5 - grungeCol.a * 0.5);
    #if (FINISH_STYLE == SO || FINISH_STYLE == HY || FINISH_STYLE == SP || FINISH_STYLE == CU)
        dirtMask *= smoothstep(0.01, 0.0, paintBlend);
    #elif (FINISH_STYLE == GS)
        dirtMask *= mix(smoothstep(0.01, 0.0, paintBlend), 1.0, matMasks.r);
    #endif

    float dirtAmt = dirtMask * uWearAmt;
    matRough += dirtAmt * mix(0.48, 0.16, matMasks.r);
    matMetal -= dirtAmt;

    // Outputs -------------------------------------------------------- //

    // Occlusion
    outputs.orm.r = uUseCustomAOTex ? getAO(inputs.sparse_coord, true) : ao;
    // Roughness
    outputs.orm.g = mix(matRough, baseRough, paintBlend);
    // Metallic
    outputs.orm.b = mix(matMetal, baseMetal, paintBlend);

    // Normal
    if (uUseCustomNormal)
        outputs.vectors = computeLocalFrame(inputs);
    else {
        vec3 baseNormal = tex2D(uBaseSurface, inputs).rgb;
        // swap channels
        baseNormal.yz = vec2(
            baseNormal.z,
            1.0 - baseNormal.y
        ); 
        inputs.normal = normalize(baseNormal * 2.0 - 1.0);
        outputs.vectors = computeLocalFrame(inputs, inputs.normal, 0.0);
    }
    
    // Color
    paintCol *= grungeCol.rgb;

    // pearlescence
    float NdV = max(0.0, dot(outputs.vectors.normal, outputs.vectors.eye));
    paintCol = hueShift(paintCol, pearlFactor * (1.0 - NdV));

    outputs.color = mix(paintCol, baseColor.rgb, paintBlend);

    // pbr validation
    if (uPBRValidation) {
        float g = dot(paintCol, vec3(0.3, 0.59, 0.11));
        vec3 valCol = mix(
                vec3(step(0.91, g), 0.0, step(g, 0.02)), // non-metallic
                vec3(step(0.97, g), 0.0, step(g, 0.12)), // metalic
                step(0.75, matMetal)
            );
        valCol = mix(valCol, vec3(0.0), paintBlend);
        outputs.color = outputs.color * (1.0 - length(valCol));
        emissiveColorOutput(valCol);
    }
}

void shadePBR(ShaderOutputs outputs) {
    float shadow = outputs.orm.r * getShadowFactor();
    vec3 diffColor = generateDiffuseColor(outputs.color, outputs.orm.b);
    vec3 specColor = generateSpecularColor(0.5, outputs.color, outputs.orm.b);
    float specOcclusion = specularOcclusionCorrection(shadow, outputs.orm.b, outputs.orm.g);

    albedoOutput(diffColor);
    diffuseShadingOutput(shadow * envIrradiance(outputs.vectors.normal));
    specularShadingOutput(specOcclusion * pbrComputeSpecular(outputs.vectors, specColor, outputs.orm.g));
}

void shade(V2F inputs) {
    ShaderOutputs outputs;

    if (uLivePreview)
        applyFinish(inputs, outputs);
    else {
        outputs.vectors = computeLocalFrame(inputs);
        outputs.color = tex2D(uMatColor, inputs).rgb;
        outputs.orm.r = getAO(inputs.sparse_coord, true);
        outputs.orm.g = tex2D(uMatRough, inputs).r;
        outputs.orm.b = tex2D(uMatMasks, inputs).r;
    }

    shadePBR(outputs);
}
