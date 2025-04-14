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
uniform SamplerSparse basecolor_tex;
//: param auto channel_roughness
uniform SamplerSparse roughness_tex;
//: param auto channel_metallic
uniform SamplerSparse metallic_tex;
//: param auto channel_specularlevel
uniform SamplerSparse specularlevel_tex;
//: param auto channel_user0
uniform SamplerSparse pearlescent_tex;
//: param auto channel_user1
uniform SamplerSparse alpha_tex;

//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D u_d_gun_grunge_sampler;
//: param custom { "default": "", "default_color": [0.2, 0.2, 0.2] }
uniform sampler2D u_d_basecolor_sampler;
//: param custom { "default": "", "default_color": [0.5, 0.5, 1.0] }
uniform sampler2D u_d_normal_sampler;
//: param custom { "default": "", "default_color": [1.0, 0.3, 1.0] }
uniform sampler2D u_d_orm_sampler;
//: param custom { "default": "", "default_color": [0.5, 0.5, 0.5] }
uniform sampler2D u_d_curv_sampler;

//: param custom { "default": true }
uniform_specialization bool u_enable_live_preview;
//: param custom { "default": true }
uniform_specialization bool u_enable_pbr_validation;
//: param custom { "default": 4 }
uniform_specialization int u_finish_style;

//: param custom { "default": [90, 250] }
uniform vec2 u_pbr_range;
//: param custom { "default": 0.00 }
uniform float u_wear_amount;
//: param custom { "default": true }
uniform bool u_ignore_weapon_size_scale;
//: param custom { "default": 1 }
uniform vec3 u_col0;
//: param custom { "default": 1 }
uniform vec3 u_col1;
//: param custom { "default": 1 }
uniform vec3 u_col2;
//: param custom { "default": 1 }
uniform vec3 u_col3;
//: param custom { "default": [0.0, 0.0, 1.0, 0.0] }
uniform vec4 u_tex_transform; // packed values: [offsetX, offsetY, scale, rotation]
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
    const vec3 w = vec3(0.5, 0.5, 0.5);

    float cosa = cos(factor);
    vec3 res = col;
    res *= cosa;
    res += cross(w, col) * sin(factor);
    res += w * dot(w, col) * (1.0 - cosa);
    return res;
}

float computeCutoffMask(float curvature, float factor, float alt, float grunge) {
    float mask = grunge * pow(curvature, 2.4);
    mask *= factor * 6.0 + 1.0;
    mask *= smoothstep(0.0, 0.5, alt);
    mask += smoothstep(0.5, 0.6, alt) * smoothstep(1.0, 0.9, alt);
    return smoothstep(0.58, 0.68, mask);
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

    vec3 rORM = vec3(0.0);
    vec3 rColor = vec3(0.0);
    vec3 uBaseMetal = vec3(1.0);
    vec3 uPatinaTint = vec3(1.0);
    vec3 uPatinaWear = vec3(1.0);
    vec3 uGrime = vec3(1.0);
    float cutoffMask = 1.0;

    if (u_enable_live_preview) {
        // fetch default weapon model material maps
        vec3 dORM = texture(u_d_orm_sampler, inputs.tex_coord).rgb;
        vec3 dColor = sRGB2linear(texture(u_d_basecolor_sampler, inputs.tex_coord).rgb);

        if (!u_use_normal_map) {
            vec3 dNormal = sRGB2linear(texture(u_d_normal_sampler, inputs.tex_coord).rgb);

            // tweak a normal map to work correctly with the local vectors
            dNormal *= 1.8;
            dNormal -= 0.4;

            vectors.normal = tangentSpaceToWorldSpace(dNormal, inputs);
        }

        // transform texture
        float s = sin(u_tex_transform.w);
        float c = cos(u_tex_transform.w);
        inputs.sparse_coord.tex_coord *= mat2(c, s, -s, c);
        inputs.sparse_coord.tex_coord += u_tex_transform.xy;
        inputs.sparse_coord.tex_coord *= u_tex_transform.z;

        // fetch material maps
        vec3 pColor = getBaseColor(basecolor_tex, inputs.sparse_coord);
        vec3 pORM = vec3(0.5);
        pORM.r = u_use_ao_tex ? getAO(inputs.sparse_coord, true) : dORM.r;
        pORM.g = u_use_roughness_tex ? getRoughness(roughness_tex, inputs.sparse_coord) : u_paint_roughness;
        pORM.b = 0.0;

        if (u_use_material_mask) {
            if (u_finish_style == AQ || u_finish_style == AM)
                pORM.b = 1.0;
            else if (u_finish_style == GS)
                pORM.b = getMetallic(metallic_tex, inputs.sparse_coord);
        } else
            pORM.b = dORM.b;

        // cutoff mask calculation
        vec3 gunGrunge = texture(u_d_gun_grunge_sampler, inputs.tex_coord).rgb;
        float curvature = texture(u_d_curv_sampler, inputs.tex_coord).x;
        float alpha = textureSparse(alpha_tex, inputs.sparse_coord).x;
        cutoffMask = computeCutoffMask(curvature, u_wear_amount, alpha, gunGrunge.b);

        // apply wear effect
        pColor *= clamp(pow(gunGrunge.r, 2.0 * u_wear_amount), 0.0, 1.0);
        pORM.g += gunGrunge.g * clamp(2 * u_wear_amount - 1.0, 0.0, 1.0);
        // TODO: make wear also affect specular color

        float pearlMask = u_use_pearl_mask ? textureSparse(pearlescent_tex, inputs.sparse_coord).x : 1.0;
        float hueShiftFactor = (1.0 - dot(vectors.normal, vectors.eye)) * u_pearl_scale * pearlMask;

        // apply pearlescent effect
        pColor = hueShift(pColor, hueShiftFactor);

        // cut out the paint material
        rColor = mix(pColor, dColor, cutoffMask);
        rORM = mix(pORM, dORM, cutoffMask);

        // compute extra colors
        uPatinaTint = clamp(u_col1, u_wear_amount, 1.0);
    } else {
        rColor = getBaseColor(basecolor_tex, inputs.sparse_coord);
        rORM.r = getAO(inputs.sparse_coord, true);
        rORM.g = getRoughness(roughness_tex, inputs.sparse_coord);
        rORM.b = getMetallic(metallic_tex, inputs.sparse_coord);
    }

    if (u_enable_pbr_validation) {
        vec3 res = valPBR(rColor, u_pbr_range.x, u_pbr_range.y);
        rColor = mix((res.r > 0.0 || res.b > 0.0) ? vec3(0.0) : rColor, rColor, cutoffMask);
        emissiveColorOutput(mix(res, vec3(0.0), cutoffMask));
    }

    float specLevel = getSpecularLevel(specularlevel_tex, inputs.sparse_coord);
    vec3 diffColor = generateDiffuseColor(rColor, rORM.b);
    vec3 specColor = generateSpecularColor(specLevel, rColor, rORM.b);
    float shadowFactor = getShadowFactor();
    float specOcclusion = specularOcclusionCorrection(rORM.r * shadowFactor, rORM.b, rORM.g);

    albedoOutput(diffColor);
    diffuseShadingOutput(rORM.r * shadowFactor * envIrradiance(vectors.normal));
    specularShadingOutput(pbrComputeSpecular(vectors, specColor * uPatinaTint, rORM.g));
}
