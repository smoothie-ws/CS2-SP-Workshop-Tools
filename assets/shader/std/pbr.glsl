import lib-pbr.glsl

void shadePBR(ShaderOutputs outputs) {
    float shadow = getShadowFactor();
    vec3 diffColor = generateDiffuseColor(outputs.color, outputs.orm.b);
    vec3 specColor = generateSpecularColor(0.04, outputs.color, outputs.orm.b);
    float specOcclusion = specularOcclusionCorrection(shadow, outputs.orm.b, outputs.orm.g);

    albedoOutput(diffColor);
    diffuseShadingOutput(outputs.orm.r * shadow * envIrradiance(outputs.vectors.normal));
    specularShadingOutput(specOcclusion * pbrComputeSpecular(outputs.vectors, specColor, outputs.orm.g));
}
