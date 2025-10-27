import lib-pbr.glsl
import lib-sampler.glsl

#include "constants.glsl"

//: param custom { "default": [50, 245, 106, 255] }
uniform vec4 g_vPBRRanges; // packed values: [non-metallic min:max, metallic min:max]

void shadePBR(ShaderOutputs outputs) {
    float shadow = getShadowFactor();
    vec3 diffColor = generateDiffuseColor(outputs.color.rgb, outputs.metalness.g);
    vec3 specColor = generateSpecularColor(0.04, outputs.color.rgb, outputs.metalness.g);
    float specOcclusion = specularOcclusionCorrection(shadow, outputs.metalness.g, outputs.metalness.r);

    albedoOutput(diffColor);
    diffuseShadingOutput(outputs.color.a * shadow * envIrradiance(outputs.vectors.normal));
    specularShadingOutput(specOcclusion * pbrComputeSpecular(outputs.vectors, specColor, outputs.metalness.r));
}

void validatePBR(out ShaderOutputs outputs) {
    float g = dot(linear2sRGB(outputs.color.rgb), vec3(0.2126, 0.7152, 0.0722));

    vec3 valCol = mix(
        vec3(step(g_vPBRRanges[1], g), 0.0, step(g, g_vPBRRanges[0])), // non-metallic
        vec3(step(g_vPBRRanges[3], g), 0.0, step(g, g_vPBRRanges[2])), // metallic
        step(0.5, outputs.metalness.g)
    );

    valCol = mix(valCol, vec3(0.0), outputs.metalness.z);
    outputs.color.rgb = clamp(outputs.color.rgb - length(valCol), 0.0, 1.0) + valCol;

    emissiveColorOutput(valCol);
}
