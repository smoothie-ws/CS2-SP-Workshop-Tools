// TODO
// metadata {
//   "custom-ui": "cs-2/custom-ui.qml"
// }

//: param auto channel_basecolor
uniform SamplerSparse basecolor_tex;
//: param auto channel_roughness
uniform SamplerSparse roughness_tex;
//: param auto channel_metallic
uniform SamplerSparse metallic_tex;
//: param auto channel_specularlevel
uniform SamplerSparse specularlevel_tex;

//: param custom {
//:   "group": "Weapon Finish",
//:   "default": 4,
//:   "label": "Finish Style",
//:   "widget": "combobox",
//:   "values": {
//:     "Anodized Airbrushed": 0,
//:     "Anodized Multicolored": 1,
//:     "Anodized": 2,
//:     "Custom Paint Job": 3,
//:     "Gunsmith": 4,
//:     "Hydrographic": 5,
//:     "Patina": 6,
//:     "Spray Paint": 7
//:   }
//: }
uniform int u_finish_style;

// <-- Gunsmith -->
//: param custom { 
//:   "group": "Weapon Finish/Gunsmith",
//:   "default": "channel_basecolor",
//:   "visible": "input.u_finish_style == 4",
//:   "label": "Albedo Texture",
//:   "usage": "texture" 
//: }
uniform sampler2D u_gs_base_texture;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith",
//:   "default": "true", 
//:   "visible": "input.u_finish_style == 4",
//:   "label": "Ignore Weapon Size Scale" 
//: }
uniform bool u_gs_ignore_weapon_size_scale;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith",
//:   "default": 1.00, 
//:   "label": "Texture scale", 
//:   "visible": "input.u_finish_style == 4",
//:   "min": -10.0,
//:   "max": 10.0 
//: }
uniform float u_gs_texture_scale;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Color",
//:   "default": 0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "Base Metal", 
//:   "widget": "color" 
//: }
uniform vec3 u_gs_color_base_metal;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Color",
//:   "default": 0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "Patina Tint", 
//:   "widget": "color" 
//: }
uniform vec3 u_gs_color_patina_tint;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Color",
//:   "default": 0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "Patina Wear", 
//:   "widget": "color" 
//: }
uniform vec3 u_gs_color_patina_wear;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Color",
//:   "default": 0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "Grime", 
//:   "widget": "color" 
//: }
uniform vec3 u_gs_color_grime;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Texture Placement/Rotation",
//:   "default": 0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "from",
//:   "min": -360.0,
//:   "max": 360.0
//: }
uniform float u_gs_texture_rotation_min;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Texture Placement/Rotation",
//:   "default": 0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "to",
//:   "min": -360.0,
//:   "max": 360.0
//: }
uniform float u_gs_texture_rotation_max;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Texture Placement/Offset X",
//:   "default": 0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "from",
//:   "min": -360.0,
//:   "max": 360.0
//: }
uniform float u_gs_texture_offset_x_min;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Texture Placement/Offset X",
//:   "default": 0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "to",
//:   "min": -360.0,
//:   "max": 360.0
//: }
uniform float u_gs_texture_offset_x_max;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Texture Placement/Offset Y",
//:   "default": 0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "from",
//:   "min": -360.0,
//:   "max": 360.0
//: }
uniform float u_gs_texture_offset_y_min;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Texture Placement/Offset Y",
//:   "default": 0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "to",
//:   "min": -360.0,
//:   "max": 360.0
//: }
uniform float u_gs_texture_offset_y_max;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Effects/Wear",
//:   "default": 0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "min",
//:   "min": 0.0,
//:   "max": 1.0
//: }
uniform float u_gs_texture_wear_min;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Effects/Wear",
//:   "default": 1.0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "max",
//:   "min": 0.0,
//:   "max": 1.0
//: }
uniform float u_gs_texture_wear_max;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Effects",
//:   "default": 0,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "Pearlescent Scale",
//:   "min": 0.0,
//:   "max": 6.0
//: }
uniform float u_gs_pearlescent_scale;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Effects",
//:   "default": "true", 
//:   "visible": "input.u_finish_style == 4",
//:   "label": "Use Pearlescent Mask" 
//: }
uniform bool u_gs_use_pearlescent_mask;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Effects",
//:   "default": "channel_normal",
//:   "visible": "input.u_finish_style == 4 && input.u_gs_use_pearlescent_mask",
//:   "label": "Pearlescent Mask",
//:   "usage": "texture" 
//: }
uniform sampler2D u_gs_pearlescent_mask;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Effects",
//:   "default": 0.4,
//:   "visible": "input.u_finish_style == 4", 
//:   "label": "Paint Roughness",
//:   "min": 0.0,
//:   "max": 1.0
//: }
uniform float u_gs_paint_roughness;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Effects",
//:   "default": "true", 
//:   "visible": "input.u_finish_style == 4",
//:   "label": "Use Roughness Texture" 
//: }
uniform bool u_gs_use_roughness_texture;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Effects",
//:   "default": "channel_normal",
//:   "visible": "input.u_finish_style == 4 && input.u_gs_use_roughness_texture",
//:   "label": "Roughness Texture",
//:   "usage": "texture" 
//: }
uniform sampler2D u_gs_roughness_texture;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Advanced",
//:   "default": "true", 
//:   "visible": "input.u_finish_style == 4",
//:   "label": "Use Custom Normal Map" 
//: }
uniform bool u_gs_use_normal_map;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Advanced",
//:   "default": "channel_normal",
//:   "visible": "input.u_finish_style == 4 && input.u_gs_use_normal_map",
//:   "label": "Normal Map",
//:   "usage": "texture" 
//: }
uniform sampler2D u_gs_normal_map;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Advanced",
//:   "default": "true", 
//:   "visible": "input.u_finish_style == 4",
//:   "label": "Use Custom Material Mask" 
//: }
uniform bool u_gs_use_material_mask;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Advanced",
//:   "default": "channel_normal",
//:   "visible": "input.u_finish_style == 4 && input.u_gs_use_material_mask",
//:   "label": "Material Mask",
//:   "usage": "texture" 
//: }
uniform sampler2D u_gs_material_mask;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Advanced",
//:   "default": "true", 
//:   "visible": "input.u_finish_style == 4",
//:   "label": "Use Custom Ambient Occlusion" 
//: }
uniform bool u_gs_use_ambient_occlusion;

//: param custom { 
//:   "group": "Weapon Finish/Gunsmith/Advanced",
//:   "default": "channel_normal",
//:   "visible": "input.u_finish_style == 4 && input.u_gs_use_ambient_occlusion",
//:   "label": "Ambient Occlusion Map",
//:   "usage": "texture" 
//: }
uniform sampler2D u_gs_ambient_occlusion;

// <-- Patina -->
//: param custom { 
//:   "group": "Weapon Finish/Patina",
//:   "default": "channel_basecolor",
//:   "visible": "input.u_finish_style == 6",
//:   "label": "Albedo Texture",
//:   "usage": "texture" 
//: }
uniform sampler2D u_pt_base_texture;

//: param custom { 
//:   "group": "Weapon Finish/Patina",
//:   "default": "true", 
//:   "visible": "input.u_finish_style == 6",
//:   "label": "Ignore Weapon Size Scale" 
//: }
uniform bool u_pt_ignore_weapon_size_scale;

//: param custom { 
//:   "group": "Weapon Finish/Patina",
//:   "default": 1.00, 
//:   "label": "Texture scale", 
//:   "visible": "input.u_finish_style == 6",
//:   "min": -10.0,
//:   "max": 10.0 
//: }
uniform float u_pt_texture_scale;

import lib-pbr.glsl
import lib-bent-normal.glsl
import lib-sss.glsl
import lib-utils.glsl

void shade(V2F inputs)
{

  // Fetch material parameters, and conversion to the specular/roughness model
  float roughness = getRoughness(roughness_tex, inputs.sparse_coord);
  vec3 baseColor = getBaseColor(basecolor_tex, inputs.sparse_coord);
  float metallic = getMetallic(metallic_tex, inputs.sparse_coord);
  float specularLevel = getSpecularLevel(specularlevel_tex, inputs.sparse_coord);
  vec3 diffColor = generateDiffuseColor(baseColor, metallic);
  vec3 specColor = generateSpecularColor(specularLevel, baseColor, metallic);

  // Get detail (ambient occlusion) and global (shadow) occlusion factors
  // separately in order to blend the bent normals properly
  float shadowFactor = getShadowFactor();
  float occlusion = getAO(inputs.sparse_coord, true, use_bent_normal);
  float specOcclusion = specularOcclusionCorrection(
    use_bent_normal ? shadowFactor : occlusion * shadowFactor,
    metallic,
    roughness);

  LocalVectors vectors = computeLocalFrame(inputs);
  computeBentNormal(vectors,inputs);

  // Feed parameters for a physically based BRDF integration
  emissiveColorOutput(pbrComputeEmissive(emissive_tex, inputs.sparse_coord));
  albedoOutput(diffColor);
  diffuseShadingOutput(occlusion * shadowFactor * envIrradiance(getDiffuseBentNormal(vectors)));
  specularShadingOutput(specOcclusion * pbrComputeSpecular(vectors, specColor, roughness, occlusion, getBentNormalSpecularAmount()));
  sssCoefficientsOutput(getSSSCoefficients(inputs.sparse_coord));
  sssColorOutput(getSSSColor(inputs.sparse_coord));
}