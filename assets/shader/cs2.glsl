import lib-pbr.glsl
import lib-vectors.glsl
import lib-utils.glsl
import lib-sampler.glsl
import lib-normal.glsl

//: metadata {
//:   "custom-ui": "cs2/custom-ui.qml"
//: }

//- Finish styles:
#define SO 1 // Solid Color
#define HY 2 // Hydrographic
#define SP 3 // Spray-Paint
#define AN 4 // Anodized
#define AM 5 // Anodized Multicolored
#define AA 6 // Anodized Airbrushed
#define CU 7 // Custom Paint Job
#define AQ 8 // Patina
#define GS 9 // Gunsmith

//- Default Weapon Material parameters:
//: param custom { "default": "gun_grunge", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D gun_grunge_sampler;
//: param custom { "default": "roughness_grunge", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D roughness_grunge_sampler;
//: param custom { "default": "paint_wear", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D paint_wear_sampler;
//: param custom { "default": "", "default_color": [0.1, 0.1, 0.1] }
uniform sampler2D default_basecolor_sampler;
//: param custom { "default": "", "default_color": [0.5, 0.5, 1.0] }
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

vec3 hueShift(vec3 col, float factor) {
    const vec3 weights = vec3(0.5, 0.5, 0.5);
    vec3 colShifted = col;
    float cosAngle = cos(factor);

    colShifted *= cosAngle;
    colShifted += cross(weights, col) * sin(factor);
    colShifted += weights * dot(weights, col) * (1.0 - cosAngle);

    return colShifted;
}

float computeCutoffMask(float curvature, float factor, float alt, float grunge) {
    float cutoffMask = grunge * pow(curvature, 2.4);

    cutoffMask *= factor * 6.0 + 1.0;
    cutoffMask *= smoothstep(0.0, 0.5, alt);
    cutoffMask += smoothstep(0.5, 0.6, alt) * smoothstep(1.0, 0.9, alt);
    cutoffMask = smoothstep(0.58, 0.68, cutoffMask);

    return cutoffMask;
}

vec3 validateLuminance(vec3 col, float v_min, float v_max) {
    float lum = dot(col * col, vec3(0.299, 0.587, 0.114));
    float minLum = pow(v_min / 255.0, 4.4), maxLum = pow(v_max / 255.0, 4.4);

    if (lum < minLum) {
        return vec3(0.0, 0.0, 1.0);
    } else if (lum > maxLum) {
        return vec3(1.0, 0.0, 0.0);
    } else {
        return vec3(0.0);
    }
}

void shade(V2F inputs) {
    LocalVectors vectors = computeLocalFrame(inputs);

    vec3 rORM = vec3(0.0);
    vec3 rColor = vec3(0.0);
    float cutoffMask = 1.0;
    vec3 uBaseMetal = vec3(1.0);
    vec3 uPatinaTint = vec3(1.0);
    vec3 uPatinaWear = vec3(1.0);
    vec3 uGrime = vec3(1.0);

    if (u_enable_live_preview) {
        // fetch default weapon model material maps
        vec3 dORM = texture(default_orm_sampler, inputs.tex_coord).rgb;
        vec3 dColor = sRGB2linear(texture(default_basecolor_sampler, inputs.tex_coord).rgb);

        if (!u_use_normal_map) {
            vec3 dNormal = sRGB2linear(texture(default_normal_sampler, inputs.tex_coord).rgb);

            // tweak a normal map to work correctly with the local vectors
            dNormal *= 1.8;
            dNormal -= 0.4;

            vectors.normal = tangentSpaceToWorldSpace(dNormal, inputs);
        }

        // apply texture scale parameter
        inputs.sparse_coord.tex_coord *= u_tex_scale;

        // fetch material maps
        vec3 pColor = getBaseColor(basecolor_tex, inputs.sparse_coord);
        vec3 pORM = vec3(0.5);
        pORM.r = u_use_ao_tex ? getAO(inputs.sparse_coord, true) : dORM.r;
        pORM.g = u_use_roughness_tex ? getRoughness(roughness_tex, inputs.sparse_coord) : u_paint_roughness;
        pORM.b = 0.0;
        
        // if (u_use_material_mask) {
        if (u_finish_style == AQ || u_finish_style == AM) {   
            pORM.b = 1.0;
        } else if (u_finish_style == GS) {
            pORM.b = getMetallic(metallic_tex, inputs.sparse_coord);
        } 
        // }

        // cutoff mask calculation
        vec3 gunGrunge = texture(gun_grunge_sampler, inputs.tex_coord * 1.8).rgb;
        float roughGrunge = texture(roughness_grunge_sampler, inputs.tex_coord * 1.8).x;
        float paintWear = texture(paint_wear_sampler, inputs.tex_coord * 1.8).x;
        float curvature = textureSparse(curvature_tex, inputs.sparse_coord).x;
        float alpha = textureSparse(alpha_tex, inputs.sparse_coord).x;
        cutoffMask = computeCutoffMask(curvature, u_wear, alpha, paintWear);

        // apply wear effect
        pColor *= clamp(pow(gunGrunge, vec3(2.0) * u_wear), 0.0, 1.0);
        pORM.g += roughGrunge * clamp(2 * u_wear - 1.0, 0.0, 1.0);
        // TODO: make wear also affect specular color

        float pearlMask = u_use_pearl_mask ? textureSparse(pearlescent_tex, inputs.sparse_coord).x : 1.0;
        float hueShiftFactor = (1.0 - dot(vectors.normal, vectors.eye)) * u_pearl_scale * pearlMask;

        // apply pearlescent effect
        pColor = hueShift(pColor, hueShiftFactor);

        // cut out the paint material
        rColor = mix(pColor, dColor, cutoffMask);
        rORM = mix(pORM, dORM, cutoffMask);

        // compute extra colors
        uPatinaTint = clamp(u_patina_tint, u_wear, 1.0);

    } else {
        rColor = getBaseColor(basecolor_tex, inputs.sparse_coord);
        rORM.r = getAO(inputs.sparse_coord, true);
        rORM.g = getRoughness(roughness_tex, inputs.sparse_coord);
        rORM.b = getMetallic(metallic_tex, inputs.sparse_coord);
    }

    if (u_enable_pbr_validation)
    {   
        vec3 res = vec3(0.0);
        if (rORM.b < 0.5) {
            res = validateLuminance(rColor, u_nm_rgb_min, u_nm_rgb_max);
        } else {
            res = validateLuminance(rColor, u_m_rgb_min, u_m_rgb_max);
        }
        emissiveColorOutput(mix(res, vec3(0.0), cutoffMask));
    }
    
    float specLevel = getSpecularLevel(specularlevel_tex, inputs.sparse_coord);
    vec3 diffColor = generateDiffuseColor(rColor, rORM.b);
    vec3 specColor = generateSpecularColor(specLevel, rColor, rORM.b);
    float shadowFactor = getShadowFactor();
    float specOcclusion = specularOcclusionCorrection(rORM.r * shadowFactor, rORM.b, rORM.g);

    albedoOutput(diffColor);
    diffuseShadingOutput(rORM.r * shadowFactor * envIrradiance(vectors.normal));
    specularShadingOutput(pbrComputeSpecular(vectors, specColor * uPatinaTint, rORM.g, rORM.r, 0.0));
}