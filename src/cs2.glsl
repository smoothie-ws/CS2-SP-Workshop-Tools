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

//: param auto channel_basecolor
uniform SamplerSparse baseChannel;
//: param auto channel_roughness
uniform SamplerSparse roughChannel;
//: param auto channel_metallic
uniform SamplerSparse metalChannel;
//: param auto channel_specularlevel
uniform SamplerSparse specChannel;
//: param auto channel_user0
uniform SamplerSparse pearlChannel;
//: param auto channel_user1
uniform SamplerSparse alphaChannel;

//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D dGrungeTex;
//: param custom { "default": "", "default_color": [0.2, 0.2, 0.2] }
uniform sampler2D dBaseTex;
//: param custom { "default": "", "default_color": [0.5, 0.5, 1.0] }
uniform sampler2D dNormalTex;
//: param custom { "default": "", "default_color": [1.0, 0.3, 1.0] }
uniform sampler2D dORMTex;
//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D dCurvTex;

//: param custom { "default": true }
uniform_specialization bool uLivePreview;
//: param custom { "default": true }
uniform_specialization bool uPBRValidation;
//: param custom { "default": 4 }
uniform_specialization int uFinishStyle;

//: param custom { "default": [90, 250] }
uniform vec2 uPBRRange;
//: param custom { "default": 0.00 }
uniform float uWearAmount;
//: param custom { "default": true }
uniform bool uIgnoreWeaponSizeScale;
//: param custom { "default": 1 }
uniform vec3 uCol0;
//: param custom { "default": 1 }
uniform vec3 uCol1;
//: param custom { "default": 1 }
uniform vec3 uCol2;
//: param custom { "default": 1 }
uniform vec3 uCol3;
//: param custom { "default": [0.0, 0.0, 1.0, 0.0] }
uniform vec4 uTexTransform; // packed values: [offsetX, offsetY, scale, rotation]
//: param custom { "default": 0.00 }
uniform float uPearlScale;
//: param custom { "default": true }
uniform bool uPearlMask;
//: param custom { "default": 0.6 }
uniform float uPaintRoughness;
//: param custom { "default": true }
uniform bool uCustomRoughness;
//: param custom { "default": true }
uniform bool uCustomNormal;
//: param custom { "default": true }
uniform bool uCustomMatMask;
//: param custom { "default": true }
uniform bool uCustomAOTex;

vec3 hueShift(vec3 col, float factor) {
    const vec3 w = vec3(0.5, 0.5, 0.5);
    float c = cos(factor);
    vec3 res = col;
    res *= c;
    res += cross(w, col) * sin(factor);
    res += w * dot(w, col) * (1.0 - c);
    return res;
}

float computeCutoffMask(float curvature, float factor, float alt, float grunge) {
    float m = grunge * pow(curvature, 2.4);
    m *= factor * 6.0 + 1.0;
    m *= smoothstep(0.0, 0.5, alt);
    m += smoothstep(0.5, 0.6, alt) * smoothstep(1.0, 0.9, alt);
    return smoothstep(0.58, 0.68, m);
}

vec3 valPBR(vec3 col, float l_min, float l_max) {
    float lum = dot(col * col, vec3(0.299, 0.587, 0.114));
    if (lum < pow(l_min / 255.0, 4.4))
        return vec3(0.0, 0.0, 1.0);
    else if (lum > pow(l_max / 255.0, 4.4))
        return vec3(1.0, 0.0, 0.0);
    else
        return vec3(0.0);
}

void shade(V2F inputs) {
    LocalVectors vectors = computeLocalFrame(inputs);

    vec3 resultORM = vec3(0.0);
    vec3 resultCol = vec3(0.0);
    vec3 uBaseMetal = vec3(1.0);
    vec3 uPatinaTint = vec3(1.0);
    vec3 uPatinaWear = vec3(1.0);
    vec3 uGrime = vec3(1.0);
    float cutoffMask = 1.0;

    if (uLivePreview) {
        // fetch default weapon model material maps
        vec3 defaultORM = texture(dORMTex, inputs.tex_coord).rgb;
        vec3 defaultCol = sRGB2linear(texture(dBaseTex, inputs.tex_coord).rgb);

        if (!uCustomNormal) {
            vec3 defaultNormal = sRGB2linear(texture(dNormalTex, inputs.tex_coord).rgb);
            vectors.normal = tangentSpaceToWorldSpace(defaultNormal, inputs);
        }

        // transform texture
        float s = sin(uTexTransform.w);
        float c = cos(uTexTransform.w);
        inputs.sparse_coord.tex_coord *= mat2(c, s, -s, c);
        inputs.sparse_coord.tex_coord += uTexTransform.xy;
        inputs.sparse_coord.tex_coord *= uTexTransform.z;

        // fetch material maps
        vec3 paintCol = getBaseColor(baseChannel, inputs.sparse_coord);
        vec3 paintORM = vec3(0.5);
        paintORM.r = uCustomAOTex ? getAO(inputs.sparse_coord, true) : defaultORM.r;
        paintORM.g = uCustomRoughness ? getRoughness(roughChannel, inputs.sparse_coord) : uPaintRoughness;
        paintORM.b = 0.0;

        if (uCustomMatMask) {
            if (uFinishStyle == AQ || uFinishStyle == AM)
                paintORM.b = 1.0;
            else if (uFinishStyle == GS)
                paintORM.b = getMetallic(metalChannel, inputs.sparse_coord);
        } else
            paintORM.b = defaultORM.b;

        // cutoff mask calculation
        vec3 gunGrunge = texture(dGrungeTex, inputs.tex_coord).rgb;
        float curvature = texture(dCurvTex, inputs.tex_coord).x;
        float alpha = textureSparse(alphaChannel, inputs.sparse_coord).x;
        cutoffMask = computeCutoffMask(curvature, uWearAmount, alpha, gunGrunge.b);

        // apply wear effect
        paintCol *= clamp(pow(gunGrunge.r, 2.0 * uWearAmount), 0.0, 1.0);
        paintORM.g += gunGrunge.g * clamp(2 * uWearAmount - 1.0, 0.0, 1.0);
        // TODO: make wear also affect specular color

        float pearlMask = uPearlMask ? textureSparse(pearlChannel, inputs.sparse_coord).x : 1.0;
        float hueShiftFactor = (1.0 - dot(vectors.normal, vectors.eye)) * uPearlScale * pearlMask;

        // apply pearlescent effect
        paintCol = hueShift(paintCol, hueShiftFactor);

        // cut out the paint material
        resultCol = mix(paintCol, defaultCol, cutoffMask);
        resultORM = mix(paintORM, defaultORM, cutoffMask);

        // compute extra colors
        uPatinaTint = clamp(uCol1, uWearAmount, 1.0);
    } else {
        resultCol = getBaseColor(baseChannel, inputs.sparse_coord);
        resultORM.r = getAO(inputs.sparse_coord, true);
        resultORM.g = getRoughness(roughChannel, inputs.sparse_coord);
        resultORM.b = getMetallic(metalChannel, inputs.sparse_coord);
    }

    if (uPBRValidation) {
        vec3 res = valPBR(resultCol, uPBRRange.x, uPBRRange.y);
        resultCol = mix((res.r > 0.0 || res.b > 0.0) ? vec3(0.0) : resultCol, resultCol, cutoffMask);
        emissiveColorOutput(mix(res, vec3(0.0), cutoffMask));
    }

    float specLevel = getSpecularLevel(specChannel, inputs.sparse_coord);
    vec3 diffColor = generateDiffuseColor(resultCol, resultORM.b);
    vec3 specColor = generateSpecularColor(specLevel, resultCol, resultORM.b);
    float shadowFactor = getShadowFactor();
    float specOcclusion = specularOcclusionCorrection(resultORM.r * shadowFactor, resultORM.b, resultORM.g);

    albedoOutput(diffColor);
    diffuseShadingOutput(resultORM.r * shadowFactor * envIrradiance(vectors.normal));
    specularShadingOutput(pbrComputeSpecular(vectors, specColor * uPatinaTint, resultORM.g));
}
