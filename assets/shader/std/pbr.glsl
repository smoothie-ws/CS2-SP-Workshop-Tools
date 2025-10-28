import lib-pbr.glsl
import lib-sampler.glsl

#include "constants.glsl"

void shadePBR(CustomWeaponOutputs O) {
    float shadow = getShadowFactor();
    vec3 diffColor = generateDiffuseColor(O.color.rgb, O.metalness.y);
    vec3 specColor = generateSpecularColor(0.04, O.color.rgb, O.metalness.y);
    float specOcclusion = specularOcclusionCorrection(shadow, O.metalness.y, O.metalness.x);

    albedoOutput(diffColor);
    diffuseShadingOutput(O.metalness.w * shadow * envIrradiance(O.vectors.normal));
    specularShadingOutput(specOcclusion * pbrComputeSpecular(O.vectors, specColor, O.metalness.x));
}

void validatePBR(inout CustomWeaponOutputs O) {
    float L = dot(O.color.rgb, vec3(0.3, 0.59, 0.11));
    float b = step(0.90 + 0.08 * O.metalness.y, L);
    float d = step(L, 0.03 + 0.104 * O.metalness.y);

    vec3 valCol = mix(vec3(0.0), mix(vec3(1.0, 0.0, O.metalness.y), vec3(O.metalness.y, 0.0, 1.0), d), b + d);

    O.color.rgb = mix(O.color.rgb, vec3(0.0, 0.0, 0.0), b + d) + valCol;
    emissiveColorOutput(valCol);
}
