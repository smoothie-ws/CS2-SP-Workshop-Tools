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
#define HY 5 // Hydrographic
#define AQ 6 // Patina
#define SP 7 // Spray-Paint

//- Default Weapon Material parameters:
//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D default_basecolor_sampler;
//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D default_normal_sampler;
//: param custom { "default": "", "default_color": [1.0, 0.5, 0.0] }
uniform sampler2D default_orm_sampler;

//- PBR shader specific parameters:
//: param auto channel_basecolor
uniform SamplerSparse basecolor_tex;
//: param auto channel_roughness
uniform SamplerSparse roughness_tex;
//: param auto channel_metallic
uniform SamplerSparse metallic_tex;
//: param auto channel_specularlevel
uniform SamplerSparse specularlevel_tex;
//: param auto texture_curvature
uniform SamplerSparse curvature_tex;

//- CS2 Weapon Finish specific parameters:
//: param custom { "default": true }
uniform_specialization bool u_enable_live_preview;
//: param custom { "default": 4 }
uniform_specialization int u_finish_style;
//: param custom { "default": 0 }
uniform_specialization int u_weapon;
//: param custom { "default": true }
uniform_specialization bool u_enable_pbr_validation;
//: param custom { "default": 78.0 }
uniform float u_m_rgb_min;
//: param custom { "default": 250.0 }
uniform float u_m_rgb_max;
//: param custom { "default": 52.0 }
uniform float u_nm_rgb_min;
//: param custom { "default": 220.0 }
uniform float u_nm_rgb_max;
//: param auto channel_user0
uniform SamplerSparse pearlescent_tex;
//: param auto channel_user1
uniform SamplerSparse alpha_tex;
//: param custom { "default": 0.00 }
uniform float u_wear;
//: param custom { "default": 1 }
uniform vec3 u_base_metal;
//: param custom { "default": 1 }
uniform vec3 u_patina_tint;
//: param custom { "default": 1 }
uniform vec3 u_patina_wear;
//: param custom { "default": 1 }
uniform vec3 u_grime;
//: param custom { "default": 1.00 }
uniform float u_tex_scale;
//: param custom { "default": 0.00 }
uniform float u_pearl_scale;
//: param custom { "default": true }
uniform bool u_use_pearl_mask;
//: param custom { "default": 0.6 }
uniform float u_paint_roughness;
//: param custom { "default": true }
uniform bool u_use_roughness_tex;
//: param custom { "default": true }
uniform bool u_use_normal_map;
//: param custom { "default": true }
uniform bool u_use_material_mask;
//: param custom { "default": true }
uniform bool u_use_ao_tex;

//- Special functions:
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 * 0.33, 2.0 * 0.33, -1.0); // 0.33 is 1/3
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) * (1 / (6.0 * d + e))), d * (1 / (q.x + e)), q.x);
}

vec3 hsv2rgb(vec3 c)
{
  vec4 K = vec4(1.0, 2.0 * 0.33, 1.0 * 0.33, 3.0); // 0.33 is 1/3
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

vec3 PBRValidate(vec3 c, float v_min, float v_max)
{
    float luminance = dot(c, vec3(0.299, 0.587, 0.114));

    if (luminance < pow(v_min / 255.0, 2.2)) {
        return vec3(0.0, 0.0, 1.0); // Any too dark color will blink Blue
    }
    if (luminance > pow(v_max / 255.0, 2.2)) {
        return vec3(1.0, 0.0, 0.0); // Any too light color will blink Red
    }
    return vec3(0.0);
}

vec3 sampler2Texture(sampler2D u_sampler, SparseCoord sparse_coord) {
    vec3 tex = texture(u_sampler, sparse_coord.tex_coord).rgb;
    return sRGB2linear(tex);
}

void shade(V2F inputs) 
{
    LocalVectors vectors = computeLocalFrame(inputs);

    // TODO: set this values to the actual default values for weapon finishes
    float roughness = u_paint_roughness;
    vec3 baseColor = vec3(0.0, 0.0, 0.0);
    float metallic = 0.0;
    float specularLevel = 0.0;
    vec3 diffColor = vec3(0.0, 0.0, 0.0);
    vec3 specColor = vec3(0.0, 0.0, 0.0);
    float shadowFactor = 0.0;
    float occlusion = 1.0;
    float specOcclusion = 0.0;

    if (u_enable_live_preview) {
        inputs.sparse_coord.tex_coord *= u_tex_scale;

        vec3 curvature = textureSparse(curvature_tex, inputs.sparse_coord).xxx;
        vec3 wear_mask = step(0.0, 1.0 - curvature * (5.0 / (5.0 - u_wear * 2))); // 5.0 and 2 is 1 * 5 and 0.4 * 5

        if (u_use_roughness_tex) {
            roughness = getRoughness(roughness_tex, inputs.sparse_coord);
        }

        baseColor = getBaseColor(basecolor_tex, inputs.sparse_coord);

        if (u_finish_style != CU && 
            u_finish_style != SP && 
            u_finish_style != HY && 
            u_finish_style != AN && 
            u_finish_style != AA) 
        {
                if (u_finish_style != AQ &&
                    u_finish_style != AM && 
                    u_use_material_mask) 
                {   
                    metallic = getMetallic(metallic_tex, inputs.sparse_coord);
                } else {
                    metallic = 1.0;
                }
        }

        specularLevel = getSpecularLevel(specularlevel_tex, inputs.sparse_coord);
        diffColor = generateDiffuseColor(baseColor, metallic);

        vec3 patina_tint = clamp(u_patina_tint, u_wear, 1.0);
        specColor = generateSpecularColor(specularLevel, baseColor * patina_tint, metallic);
        shadowFactor = getShadowFactor();

        if (u_use_ao_tex) {
            occlusion = getAO(inputs.sparse_coord, true);
        }
        specOcclusion = specularOcclusionCorrection(occlusion * shadowFactor, metallic, roughness);

        float u_pearl_mask = 1.0;

        if (u_use_pearl_mask) {
            u_pearl_mask = textureSparse(pearlescent_tex, inputs.sparse_coord).x;
        }

        diffColor = shiftColor(diffColor, vectors, u_pearl_scale * 0.167, u_pearl_mask); // 0.167 is 1/6
        specColor = shiftColor(specColor, vectors, u_pearl_scale * 0.167, u_pearl_mask);

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

    if (u_enable_pbr_validation)
    {   
        vec3 color = mix(baseColor, specColor, metallic);

        if (metallic < 0.5) {
            emissiveColorOutput(PBRValidate(color, u_nm_rgb_min, u_nm_rgb_max));
        } else {
            emissiveColorOutput(PBRValidate(color, u_m_rgb_min, u_m_rgb_max));
        }
    }

    albedoOutput(diffColor);
    diffuseShadingOutput(occlusion * shadowFactor * envIrradiance(vectors.normal));
    specularShadingOutput(specOcclusion * pbrComputeSpecular(vectors, specColor, roughness, occlusion, 0.0));
}