import lib-pbr.glsl

//: param custom { "default": [50, 245, 106, 255] }
uniform vec4 uPBRRanges; // packed values: [non-metallic min:max, metallic min:max]

void shadePBR(ShaderOutputs outputs) {
    float shadow = getShadowFactor();
    vec3 diffColor = generateDiffuseColor(outputs.color, outputs.orm.b);
    vec3 specColor = generateSpecularColor(0.04, outputs.color, outputs.orm.b);
    float specOcclusion = specularOcclusionCorrection(shadow, outputs.orm.b, outputs.orm.g);

    albedoOutput(diffColor);
    diffuseShadingOutput(outputs.orm.r * shadow * envIrradiance(outputs.vectors.normal));
    specularShadingOutput(specOcclusion * pbrComputeSpecular(outputs.vectors, specColor, outputs.orm.g));
}

void validatePBR(out ShaderOutputs outputs) {
    float g = dot(linear2sRGB(outputs.color), vec3(0.2126, 0.7152, 0.0722));

    vec3 valCol = mix(
        vec3(step(uPBRRanges[1] / 255, g), 0.0, step(g, uPBRRanges[0] / 255)), // non-metallic
        vec3(step(uPBRRanges[3] / 255, g), 0.0, step(g, uPBRRanges[2] / 255)), // metallic
        step(0.5, outputs.orm.b)
    );

    valCol = mix(valCol, vec3(0.0), outputs.wear);
    outputs.color = clamp(outputs.color - length(valCol), 0.0, 1.0) + valCol;

    emissiveColorOutput(valCol);
}
