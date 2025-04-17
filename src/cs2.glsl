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
//: param custom { "default": "", "default_color": [0.0, 0.0, 0.0] }
uniform sampler2D uBaseMasks;
//: param custom { "default": "", "default_color": [0.5, 0.5, 1.0] }
uniform sampler2D uBaseNormal;
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
uniform_specialization bool uLivePreview;
//: param custom { "default": true }
uniform_specialization bool uPBRValidation;
uniform_specialization bool uPBRValidation;
//: param custom { "default": 4 }
uniform_specialization int uFinishStyle;

// Common

//: param custom { "default": [90, 250] }
uniform vec2 uPBRRange;
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
uniform vec4 uTexTransform; // packed values: [offsetX, offsetY, scale, rotation]
//: param custom { "default": 0.00 }
uniform float uPearlScale;
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
    float c = cos(factor);
    vec3 res = col;
    res *= c;
    res *= c;
    res += cross(w, col) * sin(factor);
    res += w * dot(w, col) * (1.0 - c);
    res += w * dot(w, col) * (1.0 - c);
    return res;
}

float computeCutoffMask(float curvature, float alpha, float grunge) {
    float m = grunge * pow(curvature, 2.4);
    m *= uWearAmt * 6.0 + 1.0;
    m *= smoothstep(0.0, 0.5, alpha);
    m += smoothstep(0.5, 0.6, alpha) * smoothstep(1.0, 0.9, alpha);
    return smoothstep(0.58, 0.68, m);
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

void applyFinish(V2F inputs) {
    LocalVectors vectors = computeLocalFrame(inputs);
    // Fetch textures

    // grunge
    vec4 grungeCol = texture(uGrungeTex, inputs.tex_coord);
    float paintWear = texture(uScratchesTex, inputs.tex_coord).r;
    // material
    vec3 matCol = getBaseColor(uMatColor, inputs.sparse_coord);
    float alpha = textureSparse(uMatAlpha, inputs.sparse_coord).r;
    // base
    vec4 baseCol = texture(uBaseColor, inputs.tex_coord);
    vec4 cavity = texture(uBaseCavity, inputs.tex_coord);

    if (!uUseCustomNormal) {
        vec3 normal = texture(uBaseNormal, inputs.tex_coord).rgb;
        vectors.normal = tangentSpaceToWorldSpace(normalize(normal * 2.0 - 1.0), inputs);
        emissiveColorOutput(normal);
    }
    vec4 masks = uUseCustomMasks ? textureSparse(uMatMasks, inputs.sparse_coord) : texture(uBaseMasks, inputs.tex_coord); // ?

    float curv = cavity.r;
    float ao = cavity.g;
    float paintBlend = cavity.a;

    float paintEdge;
    float grunge;

    if (uFinishStyle != AQ) {
        paintBlend += paintWear * curv;
        paintBlend *= uWearAmt * 6.0 + 1.0;
        // Paint matCols and durability
        if (uFinishStyle == HY || uFinishStyle == AM || uFinishStyle == CU || uFinishStyle == GS) {
            float flCuttableArea = 1.0;
            if (uFinishStyle == HY || uFinishStyle == AM)
                flCuttableArea = 1.0 - clamp(masks.g + masks.b, 0.0, 1.0);

            // cut through
            paintBlend += smoothstep(0.5, 0.6, alpha) * smoothstep(1.0, 0.9, alpha);
            // rescale the alpha to represent exponent in the range of 0-255 and let the cutout mask area fall off the top end
            if (uFinishStyle == AM)
                alpha = clamp(alpha * 2.0, 0.0, 1.0);
            // rescale the alpha to represent exponent in the range of 0-255 and let the cutout mask area fall off the top end
            else if (uFinishStyle == GS) {
                paintBlend *= max(1.0 - flCuttableArea, smoothstep(0.0, 0.5, alpha));
                alpha = mix(alpha, clamp(alpha * 2.0, 0.0, 1.0), masks.r);
            }
            // indestructible paintCol
            else
                paintBlend *= max(1.0 - flCuttableArea, smoothstep(0.0, 0.5, alpha));
        }
    }

    if (uFinishStyle == HY || uFinishStyle == SP) { // paintCol wears off in layers
        vec3 paintEdges = vec3(1.0, 1.0, 1.0);
        vec3 spread = 0.06 * uWearAmt; // spread of partially worn paintCol increases as the gun becomes more worn
        spread.y *= 2.0;
        spread.z *= 3.0;

        paintEdges.x = smoothstep(0.58, 0.56 - spread.x, paintBlend);
        paintEdges.y = smoothstep(0.56 - spread.x, 0.54 - spread.y, paintBlend);
        paintEdges.z = smoothstep(0.54 - spread.y, 0.52 - spread.z, paintBlend);
    }

    if (uFinishStyle != AQ && uFinishStyle != GS)
        paintBlend = smoothstep(0.58, 0.68, paintBlend);
    else if (uFinishStyle == GS)
        paintBlend = mix(smoothstep(0.58, 0.68, paintBlend), paintBlend, masks.r);

    if (uFinishStyle == AN || uFinishStyle == AM || uFinishStyle == AA) // Anodized paintCol scratches through uncolored baseCol coat
        paintEdge = smoothstep(0.0, 0.01, paintBlend);

    // Diffuse texture

    vec3 paintCol = uCol0;

    // apply grunge to paintCol only in creases
    if (uFinishStyle == AQ || uFinishStyle == GS)
        grunge = grungeCol.r * grungeCol.g * grungeCol.b;

    grungeCol = mix(1.0, grungeCol, (pow((1.0 - curv), 4.0) * 0.25 + 0.75 * uWearAmt));

    // Solid style
    if (uFinishStyle == SO) {
        // apply color in solid blocks using masking from the part kit MasksSampler
        paintCol = mix(paintCol, uCol1, masks.r);
        paintCol = mix(paintCol, uCol2, masks.g);
        paintCol = mix(paintCol, uCol3, masks.b);
    }

    // Hydrographic/anodized multicolored style
    if (uFinishStyle == HY || uFinishStyle == AM) {
        // create camo using matCol
        paintCol = mix(mix(mix(uCol0, uCol1, matCol.r), uCol2, matCol.g), uCol3, matCol.b);

        // apply any masking from the last two masks from MasksSampler, allowing some areas to be solid color
        paintCol = mix(paintCol, uCol2, masks.g);
        paintCol = mix(paintCol, uCol3, masks.b);
    }

    // Spraypaint/anodized airbrushed style
    if (uFinishStyle == SP || uFinishStyle == AA) {
        // apply spraypaint via box map baseCold on mesh's object-space position as stored in the position pmap
        vec2 posCoord = vec2(inputs.tex_coord.x, 1.0 - inputs.tex_coord.y);
        vec4 pos = vec4(0.0, 0.0, 0.0, 0.0);

        if (CHEAPMODE == 0) { // if supersampling is not disabled
            //super sampling of position map
            vec2 offsets[17] = {
                    vec2(-0.00107234, -0.00400203),
                    vec2(0.00195312, -0.00338291),
                    vec2(0.00400203, -0.00107234),
                    vec2(-0.000714896, -0.00266802),
                    vec2(0.000976565, -0.00169146),
                    vec2(0.00266802, -0.000714896),
                    vec2(-0.00338291, -0.00195312),
                    vec2(-0.00169146, -0.000976565),
                    vec2(0.0, 0.0),
                    vec2(0.00169146, 0.000976565),
                    vec2(0.00338291, 0.00195312),
                    vec2(-0.00266802, 0.000714896),
                    vec2(-0.000976565, 0.00169146),
                    vec2(0.000714896, 0.00266802),
                    vec2(-0.00400203, 0.00107234),
                    vec2(-0.00195312, 0.00338291),
                    vec2(0.00107234, 0.00400203)
                };
            for (int k = 0; k < 17; k++)
                pos += texture(OSPosSampler, posCoord + offsets[k]) * 0.05882353;
        } else
            pos = texture(OSPosSampler, posCoord);

        // extract integer HDR values out from the RGBA vtf
        // developer.valvesoftware.com/wiki/Valve_Texture_Format#HDR_compression
        pos.rgb *= pos.a * 16.0;

        // Project the mask in object-space
        vec2 coord;
        // apply the preview matCol scale to only the scale portion of the matCol transform.
        mat2 t = mat2(
                g_PreviewPatternScale, 0,
                0, g_PreviewPatternScale
            );
        mat2 t2 = mat2(
                g_matColTexCoordTransform[0].xy,
                g_matColTexCoordTransform[1].xy
            );
        t *= 2;

        coord.x = dot(pos.yz, t[0]) + g_matColTexCoordTransform[0].w;
        coord.y = dot(pos.yz, t[1]) + g_matColTexCoordTransform[1].w;
        vec3 fvTexX = texture(uMatColor, coord).rgb;

        coord.x = dot(pos.xz, t[0]) + g_matColTexCoordTransform[0].w;
        coord.y = dot(pos.xz, t[1]) + g_matColTexCoordTransform[1].w;
        vec3 fvTexY = texture(uMatColor, coord).rgb;

        coord.x = dot(pos.yx, t[0]) + g_matColTexCoordTransform[0].w;
        coord.y = dot(pos.yx, t[1]) + g_matColTexCoordTransform[1].w;
        vec3 fvTexZ = texture(uMatColor, coord).rgb;

        // smooth blend the three projections across the object-space surface normals
        float yBlend = abs(dot(normal.xyz, vec3(0.0, 1.0, 0.0)));
        yBlend = pow(yBlend, g_flBlendYPow);

        float zBlend = abs(dot(normal.xyz, vec3(0.0, 0.0, 1.0)));
        zBlend = pow(zBlend, g_flBlendZPow);

        vec3 patternMask = mix(mix(fvTexX, fvTexY, yBlend), fvTexZ, zBlend);

        if (uFinishStyle == SP) // paintCol wears off in layers
            patternMask.xyz *= paintEdges.xyz;

        paintCol = mix(mix(mix(uCol0, uCol1, patternMask.r), uCol2, patternMask.g), uCol3, patternMask.b);
        if (uFinishStyle == AA) {
            paintCol = mix(paintCol, uCol2, masks.g);
            paintCol = mix(paintCol, uCol3, masks.b);
        }
    }

    // Anodized style
    if (uFinishStyle == AN || uFinishStyle == AM || uFinishStyle == AA) {
        if (uFinishStyle == AN)
            paintCol.rgb = uCol0.rgb;

        // chipped edges of anodized dye
        paintCol = mix(paintCol, g_cAnodizedBase, paintEdge);
        grungeCol.rgb = mix(grungeCol.rgb, vec3(1.0, 1.0, 1.0), paintEdge);

        // anodize only in areas specified by the masks texture
        paintBlend = clamp(1.0 + paintBlend - masks.r, 0.0, 1.0);
    }

    // Custom painted style
    if (uFinishStyle == CU)
        paintCol = matCol.rgb;

    // Antiqued or Gunsmith style
    if (uFinishStyle == AQ || uFinishStyle == GS) {
        float patinaBlend = paintWear * ao * curv * curv;
        patinaBlend = smoothstep(0.1, 0.2, patinaBlend * uWearAmt);

        float grimeBlend = clamp(curv * ao - uWearAmt * 0.1, 0.0, 1.0) - grunge;
        grimeBlend = smoothstep(0.0, 0.15, grimeBlend + 0.08);

        vec3 patina = mix(uCol1, uCol2, uWearAmt);
        vec3 grimeCol = mix(uCol1, uCol3, pow(uWearAmt, 0.5));
        patina = mix(grimeCol, patina, grimeBlend) * matCol.rgb;
        float patternLum = dot(matCol.rgb, vec3(0.3, 0.59, 0.11));
        vec3 scratches = uCol0 * patternLum;
        patina = mix(patina, scratches, patinaBlend);

        if (uFinishStyle == AQ) {
            paintCol = patina;
            paintBlend = 1.0 - masks.r;
        } else if (uFinishStyle == GS) {
            paintCol = mix(matCol.rgb, patina, masks.r);
            paintBlend = paintBlend * (1.0 - masks.r);
        }
    }

    
    // Specular Intensity Mask
    
    if (uFinishStyle == GS) {
        if (PHONGALBEDOFACTORMODE == 1)
            float flSpecMask = mix(g_flPaintPhongIntensity, 1.0, masks.r) * ao * grungeCol.a;
        else
            float flSpecMask = mix(g_flPaintPhongIntensity, g_flPhongAlbedoFactor, masks.r) * ao * grungeCol.a;
    } else
        float flSpecMask = g_flPaintPhongIntensity * ao * grungeCol.a;

    if (uFinishStyle == AN || uFinishStyle == AM || uFinishStyle == AA || uFinishStyle == AQ || uFinishStyle == GS) { // anodized/metallic
        // phongalbedoboost must be increased in the material for the anodized look, so in areas that are
        // already using phongalbedo the specular intensity must be reduced in order to retain approximately
        // the same intensity as the originally authored texture
        float flInvPaintBlend = 1.0 - paintBlend;

        vec4 cOrigExp = texture(ExponentSampler, inputs.tex_coord);
        if ((PREVIEW == 1) && (PREVIEWPHONGALBEDOTINT == 0))
            cOrigExp.g = 0.0;

        if (uFinishStyle == AQ)
            flSpecMask *= mix(grimeBlend * (1.0 - patinaBlend * uWearAmt), 1.0, patinaBlend);
        else if (uFinishStyle == GS) {
            float flPaintSpecBlend = smoothstep(0.9, 1.0, paintBlend) * masks.r;
            flSpecMask *= mix(smoothstep(0.01, 0.0, paintBlend), mix(grimeBlend * (1.0 - patinaBlend * uWearAmt), 1.0, patinaBlend), masks.r);
            flSpecMask = mix(flSpecMask, baseCol.a, flPaintSpecBlend);
            flPaintSpecBlend = smoothstep(0.9, 1.0, paintBlend) * (1.0 - masks.r);
        } else
            flSpecMask *= mix(g_flPaintPhongIntensity, g_flAnodizedBasePhongIntensity, paintEdge);

        float flPhongAlbedoBlend = paintBlend;

        float flAdjustedBase = 1.0;
        if (PHONGALBEDOFACTORMODE == 1) {
            flAdjustedBase = mix(1.0, g_flPhongAlbedoFactor, cOrigExp.g * flPhongAlbedoBlend);
            color.a = mix(flSpecMask, baseCol.a * flAdjustedBase, paintBlend);
        } else
            color.a = mix(flSpecMask * g_flPhongAlbedoFactor, baseCol.a, flPhongAlbedoBlend);

        if (uFinishStyle == GS)
            color.a = mix(flSpecMask, baseCol.a * flAdjustedBase, flPaintSpecBlend);
    }
    // everything else
    else {
        float flPaintSpecBlend = smoothstep(0.9, 1.0, paintBlend);
        flSpecMask *= smoothstep(0.01, 0.0, paintBlend);
        color.a = mix(flSpecMask, baseCol.a, flPaintSpecBlend);
    }
}

void shade(V2F inputs) {
    if (uLivePreview)
        applyFinish(inputs);
    else {
        LocalVectors vectors = computeLocalFrame(inputs);

        vec3 baseColor = getBaseColor(uMatColor, inputs.sparse_coord);
        float roughness = getRoughness(uMatRough, inputs.sparse_coord);
        float metallic = textureSparse(uMatMasks, inputs.sparse_coord).r;
        float specLevel = getSpecularLevel(uMatSpecLevel, inputs.sparse_coord);

        vec3 diffColor = generateDiffuseColor(baseColor, metallic);
        vec3 specColor = generateSpecularColor(specLevel, baseColor, metallic);

        float shadowFactor = getShadowFactor();
        float occlusion = getAO(inputs.sparse_coord, true);
        float specOcclusion = specularOcclusionCorrection(occlusion * shadowFactor, metallic, roughness);

        albedoOutput(diffColor);
        diffuseShadingOutput(occlusion * shadowFactor * envIrradiance(vectors.normal));
        specularShadingOutput(specOcclusion * pbrComputeSpecular(vectors, specColor, roughness));
    }
}
