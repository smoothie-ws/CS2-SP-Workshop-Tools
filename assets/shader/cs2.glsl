import lib-pbr.glsl
import lib-vectors.glsl
import lib-utils.glsl
import lib-sampler.glsl

//: metadata {
//:   "custom-ui": "cs2/custom-ui.qml"
//: }

//- Finish styles:
#define AA 0 // Anodized Airbrushed
#define AM 1 // Anodized Multicolored
#define AN 2 // Anodized
#define CU 3 // Custom Paint Job
#define GS 4 // Gunsmith
#define HG 5 // Hydrographic
#define PT 6 // patina
#define SP 7 // Spray-Paint

//- PBR shader specific parameters:
//: param auto channel_basecolor
uniform SamplerSparse basecolor_tex;
//: param auto channel_roughness
uniform SamplerSparse roughness_tex;
//: param auto channel_metallic
uniform SamplerSparse metallic_tex;
//: param auto channel_specularlevel
uniform SamplerSparse specularlevel_tex;

//- CS2 Weapon Finish specific parameters:
//: param custom { "default": true }
uniform_specialization bool u_enable_live_preview;
//: param custom { "default": false }
uniform bool u_enable_range_verification;
//: param auto channel_user0
uniform SamplerSparse pearlescent_tex;
//: param auto channel_user1
uniform SamplerSparse alpha_tex;
//: param custom { "default": 4 }
uniform int u_finish_style;
//: param custom { "default": 0 }
uniform int u_weapon;
//: param custom { "default": 0.00 }
uniform float u_wear;
//: param custom { "default": 1.00 }
uniform float u_tex_scale;
//: param custom { "default": 0.00 }
uniform float u_pearl_scale;

//- Special functions:
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 shiftColor(vec3 c, LocalVectors v, float p_scale, float p_mask) 
{
    vec3 hsv = rgb2hsv(c);
    float p_factor = 1 - max(0.0, dot(v.normal, v.eye));
    hsv.x += p_factor * p_scale * p_mask;
    return hsv2rgb(hsv);
}

float getLuminance(vec3 c) {
    return float(dot(c, vec3(0.299, 0.587, 0.114)));
}

vec3 clampBrightness(vec3 c, float brightness_limit) 
{
    vec3 hsv = rgb2hsv(c);
    hsv.z = clamp(pow(hsv.z, hsv.z / brightness_limit), 0.0, 1.0);
    return hsv2rgb(hsv);
}

vec3 unclampBrightness(vec3 c, float brightness_limit) 
{
    vec3 hsv = rgb2hsv(c);
    hsv.z = (1.0 - hsv.z) * (brightness_limit / 255.0);
    return hsv2rgb(hsv);
}

// vec3 correct_range(vec3 c, vec2 limit_values) {
//     vec3 linear_rgb = sRGB2linear(c);
//     vec3 luminance = getLuminance(linear_rgb);
//     vec3 luminance_corrected = clamp(luminance, limit_values.x, limit_values.y);
//     vec3 luminance_lightening_factor = clamp(luminance_corrected - luminance, 0.0, 255.0);
//     vec3 luminance_darkening_factor = clamp(luminance - luminance_corrected, 0.0, 255.0);
//     vec3 color_ratios = linear_rgb / max(luminance, 1e-12);
//     vec3 linear_rgb_lightened = linear_rgb + luminance_lightening_factor * color_ratios;
//     vec3 linear_rgb_corrected = clamp(linear_rgb_lightened - luminance_darkening_factor, 0.0, 255.0);
//     return linear2sRGB(linear_rgb_corrected);
// }

vec3 verifyRange(vec3 c, vec2 limit_values) 
{
    vec3 linear_rgb = sRGB2linear(c);
    float luminance = getLuminance(linear_rgb);
    if (luminance < limit_values.x) {
        return vec3(0.0, 0.0, 1.0); // blue color indicating below the limit
    }
    if (luminance > limit_values.y) {
        return vec3(1.0, 0.0, 0.0); // red color indicating above the limit
    }
    return vec3(0.0);
}

void shade(V2F inputs) 
{
    LocalVectors vectors = computeLocalFrame(inputs);
    float roughness = 0.0;
    vec3 baseColor = vec3(0.0, 0.0, 0.0);
    float metallic = 0.0;
    float specularLevel = 0.0;
    vec3 diffColor = vec3(0.0, 0.0, 0.0);
    vec3 specColor = vec3(0.0, 0.0, 0.0);
    float shadowFactor = 0.0;
    float occlusion = 0.0;
    float specOcclusion = 0.0;

    if (u_enable_live_preview) {
        inputs.sparse_coord.tex_coord *= u_tex_scale;

        roughness = getRoughness(roughness_tex, inputs.sparse_coord);
        baseColor = getBaseColor(basecolor_tex, inputs.sparse_coord);

        if (u_finish_style != CU && 
            u_finish_style != SP && 
            u_finish_style != HG && 
            u_finish_style != AN && 
            u_finish_style != AA) 
        {
                if (u_finish_style != PT &&
                    u_finish_style != AM) 
                {
                metallic = getMetallic(metallic_tex, inputs.sparse_coord);
                } else {
                metallic = 1.0;
                }
        }

        specularLevel = getSpecularLevel(specularlevel_tex, inputs.sparse_coord);
        diffColor = generateDiffuseColor(baseColor, metallic);
        specColor = generateSpecularColor(specularLevel, baseColor, metallic);
        shadowFactor = getShadowFactor();
        occlusion = getAO(inputs.sparse_coord, true);
        specOcclusion = specularOcclusionCorrection(occlusion * shadowFactor, metallic, roughness);

        float u_pearl_mask = textureSparse(pearlescent_tex, inputs.sparse_coord).x;

        diffColor = shiftColor(diffColor, vectors, u_pearl_scale / 6, u_pearl_mask);
        specColor = shiftColor(specColor, vectors, u_pearl_scale / 6, u_pearl_mask);

    } else {
        roughness = getRoughness(roughness_tex, inputs.sparse_coord);
        baseColor = getBaseColor(basecolor_tex, inputs.sparse_coord);
        metallic = getMetallic(metallic_tex, inputs.sparse_coord);
        specularLevel = getSpecularLevel(specularlevel_tex, inputs.sparse_coord);
        diffColor = generateDiffuseColor(baseColor, metallic);
        specColor = generateSpecularColor(specularLevel, baseColor, metallic);
        shadowFactor = getShadowFactor();
        occlusion = getAO(inputs.sparse_coord, true);
        specOcclusion = specularOcclusionCorrection(occlusion * shadowFactor, metallic, roughness);
    }

    if (u_enable_range_verification) 
    {
        emissiveColorOutput(verifyRange(baseColor, vec2(0.03, 0.92)));
    }
    
    albedoOutput(diffColor);
    diffuseShadingOutput(occlusion * shadowFactor * envIrradiance(vectors.normal));
    specularShadingOutput(specOcclusion * pbrComputeSpecular(vectors, specColor, roughness, occlusion, 0.0));
}