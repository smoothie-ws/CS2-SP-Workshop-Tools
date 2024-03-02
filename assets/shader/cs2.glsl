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
//: param custom { "default": "gun_grunge", "default_color": [1.0, 1.0, 1.0] }
uniform sampler2D gun_grunge_sampler;
//: param custom { "default": "paint_wear", "default_color": [1.0, 1.0, 1.0] }
uniform sampler2D paint_wear_sampler;
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
//: param auto channel_user0
uniform SamplerSparse pearlescent_tex;
//: param auto channel_user1
uniform SamplerSparse alpha_tex;

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

vec3 hueShift(vec3 color, float factor) {
    const vec3 w = vec3(0.5, 0.5, 0.5);
    float cosAngle = cos(factor);
    return vec3(color * cosAngle + cross(w, color) * sin(factor) + w * dot(w, color) * (1.0 - cosAngle));
}

float calculateWearMask(float curvature, float factor, float alpha, float tex) {
    float mask = tex * sRGB2linear(curvature);
    mask *= factor * 6.0 + 1.0;
    mask *= smoothstep(0.0, 0.5, alpha);
    mask += smoothstep(0.5, 0.6, alpha) * smoothstep(1.0, 0.9, alpha);
    mask = smoothstep(0.58, 0.68, mask);
    return mask;
}

vec3 validateLuminance(vec3 c, float v_min, float v_max) {
    float lum = dot(c*c, vec3(0.299, 0.587, 0.114));
    float minLum = pow(v_min / 255.0, 4.4), maxLum = pow(v_max / 255.0, 4.4);
    return lum < minLum ? vec3(0.0, 0.0, 1.0) : (lum > maxLum ? vec3(1.0, 0.0, 0.0) : vec3(0.0));
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
        vec3 gun_grunge = texture(gun_grunge_sampler, inputs.tex_coord).rgb;
        float paint_wear = texture(paint_wear_sampler, inputs.tex_coord).x;

        inputs.sparse_coord.tex_coord *= u_tex_scale;

        float curvature = textureSparse(curvature_tex, inputs.sparse_coord).x;
        float alpha = textureSparse(alpha_tex, inputs.sparse_coord).x;
        float wear_mask = calculateWearMask(curvature, u_wear, alpha, paint_wear);

        if (u_use_roughness_tex) {
            roughness = getRoughness(roughness_tex, inputs.sparse_coord);
        }

        roughness *= step(0.1, clamp(gun_grunge.x, 1.0 - u_wear, 1.0));

        float u_pearl_mask = 1.0;

        if (u_use_pearl_mask) {
            u_pearl_mask = textureSparse(pearlescent_tex, inputs.sparse_coord).x;
        }

        float hue_shift_factor = (1.0 - dot(vectors.normal, vectors.eye)) * u_pearl_scale * u_pearl_mask;

        baseColor = getBaseColor(basecolor_tex, inputs.sparse_coord);
        baseColor = hueShift(baseColor, hue_shift_factor);

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
        diffColor = mix(generateDiffuseColor(baseColor, metallic), vec3(0.0, 0.0, 0.0), wear_mask);

        vec3 patina_tint = clamp(u_patina_tint, u_wear, 1.0);
        specColor = generateSpecularColor(specularLevel, baseColor * patina_tint, metallic);
        shadowFactor = getShadowFactor();

        if (u_use_ao_tex) {
            occlusion = getAO(inputs.sparse_coord, true);
        }

        specOcclusion = specularOcclusionCorrection(occlusion * shadowFactor, metallic, roughness);

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
            emissiveColorOutput(validateLuminance(color, u_nm_rgb_min, u_nm_rgb_max));
        } else {
            emissiveColorOutput(validateLuminance(color, u_m_rgb_min, u_m_rgb_max));
        }
    }

    albedoOutput(diffColor);
    diffuseShadingOutput(occlusion * shadowFactor * envIrradiance(vectors.normal));
    specularShadingOutput(pbrComputeSpecular(vectors, specColor, roughness, occlusion, 0.0));
}