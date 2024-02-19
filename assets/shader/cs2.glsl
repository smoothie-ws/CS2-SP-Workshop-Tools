//- Substance 3D Painter CS2 shader
//- ============================================
//-
//- Import from libraries.
import lib-pbr.glsl
import lib-bent-normal.glsl
import lib-sss.glsl
import lib-utils.glsl
import lib-vectors.glsl

//- Attach a custom UI file.
//: metadata {
//:   "custom-ui": "cs2/custom-ui.qml"
//: }

//- PBR shader specific parameters:
//: param auto channel_basecolor
uniform SamplerSparse basecolor_tex;
//: param auto channel_roughness
uniform SamplerSparse roughness_tex;
//: param auto channel_metallic
uniform SamplerSparse metallic_tex;
//: param auto channel_specularlevel
uniform SamplerSparse specularlevel_tex;

//- CS2 Weapon Finish specific parameter:
//: param auto user_0
uniform float pearlescent_tex;

//- Finish styles:
#define AA 0 // Anodized Airbrushed
#define AM 1 // Anodized Multicolored
#define AN 2 // Anodized
#define CU 3 // Custom Paint Job
#define GS 4 // Gunsmith
#define HG 5 // Hydrographic
#define PT 6 // patina
#define SP 7 // Spray-Paint
//: param custom { "default": 4 }
uniform int u_finish_style;

//- Weapons:
#define ak47 0
#define aug 1
#define awp 2
#define cz75 3
#define deagle 4
#define duals 5
#define famas 6
#define fiveseven 7
#define g3sg1 8
#define galil 9
#define g18 10
#define mac10 11
#define mag7 12
#define m249 13
#define m4a1s 14
#define m4a4 15
#define mp5sd 16
#define mp7 17
#define mp9 18
#define negev 19
#define nova 20
#define p2000 21
#define p250 22
#define p90 23
#define bizon 24
#define r8 25
#define scar20 26
#define sg553 27
#define ssg08 28
#define sawedoff 29
#define tec9 30
#define ump45 31
#define usps 32
#define xm1014 33
#define zeus 34
//: param custom { "default": 0 }
uniform int u_weapon;

//- Other parameters:
//: param custom { "default": 0.00 }
uniform float u_wear;
//: param custom { "default": 1.00 }
uniform float u_tex_scale;

//- Special methods:
// All components are in the range [0…1], including hue.
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

//- Entry point of the shader.
void shade(V2F inputs)
{ 
  inputs.sparse_coord.tex_coord *= u_tex_scale;

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
  computeBentNormal(vectors, inputs);

  // convert a diffuse color to the HSV color space
  vec3 hsv = rgb2hsv(diffColor);
    
  // shift a color hue
  hsv.x = getEyeVec(inputs.position).x;
  
  // convert a diffuse color back to the RGB color space
  // vec3 shiftedColor = hsv2rgb(hsv);
  vec3 shiftedColor = vectors.eye;

  // Feed parameters for a physically based BRDF integration
  emissiveColorOutput(pbrComputeEmissive(emissive_tex, inputs.sparse_coord));
  albedoOutput(shiftedColor);
  diffuseShadingOutput(occlusion * shadowFactor * envIrradiance(getDiffuseBentNormal(vectors)));
  specularShadingOutput(specOcclusion * pbrComputeSpecular(vectors, specColor, roughness, occlusion, getBentNormalSpecularAmount()));
  sssCoefficientsOutput(getSSSCoefficients(inputs.sparse_coord));
  sssColorOutput(getSSSColor(inputs.sparse_coord));
}