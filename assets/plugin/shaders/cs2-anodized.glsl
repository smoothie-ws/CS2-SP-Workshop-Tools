import lib-sparse.glsl

//: param auto channel_user0
uniform SamplerSparse albedo_tex;

void shade(V2F inputs)
{
  vec3 basecolor = textureSparse(albedo_tex, inputs.sparse_coord).rgb;
  diffuseShadingOutput(basecolor);
}