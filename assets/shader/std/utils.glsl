#include "constants.glsl"

float luma(vec3 c) { return dot(c, vec3(0.2125, 0.7154, 0.0721)); }

float saturate(float x) { return clamp(x, 0.0, 1.0); }
vec2 saturate(vec2 x) { return clamp(x, vec2(0.0), vec2(1.0)); }
vec3 saturate(vec3 x) { return clamp(x, vec3(0.0), vec3(1.0)); }
vec4 saturate(vec4 x) { return clamp(x, vec4(0.0), vec4(1.0)); }

void computePearlescence(inout CustomWeaponOutputs O) {
    // pearlescence
    const vec3 axis = vec3(0.5773500204);

    if (O.pearlFactor != 0.0) {
        O.pearlFactor *= (1.0 - dot(O.vectors.normal, O.vectors.eye)) * saturate(O.metalness.z);

        float cmax = max(O.color.rgb.r, max(O.color.rgb.g, O.color.rgb.b));
        float sat = cmax == 0.0 ? 0.0 : (cmax - min(O.color.rgb.r, min(O.color.rgb.g, O.color.rgb.b))) / cmax;
        float sat_w = pow(sat, 0.125);

        float ct = cos(O.pearlFactor), st = sin(O.pearlFactor);
        vec3 rotated =  O.color.rgb * ct + cross(axis, O.color.rgb) * st + axis * dot(axis, O.color.rgb) * (1.0 - ct);

        O.color.rgb = mix(vec3(luma(O.color.rgb)), rotated, sat_w);
    }

    // // glitter
    // float glitterIntensity = roughness * min(1.0, g_fGlitterIntensity);

    // vec3 glitterColor;
    // float metalness;
    // vec2 roughnessMap;
    // vec3 baseColor;
    // vec3 normalMap;

    // if (glitterIntensity != 0.0){
    //     // Calculate view direction
    //     vec3 viewDir = normalize(PerViewConstantBuffer_t._m0.xyz - worldPosition.xyz);
        
    //     // Setup glitter texture coordinates
    //     float glitterScale = notEqual(PerViewConstantBufferCsgo_t._m2, ivec4(0)).x ? 2.5 : 1.75;
    //     vec2 glitterUV = surfaceUV.xy * (glitterScale * g_fGlitterScale * g_flUvScale1);
        
    //     // Sample glitter normal map
    //     vec4 glitterNormal = texture(sampler2D(g_tGlitterNormal, AddressU_0_AddressV_0_Filter_0_AddressW_0), glitterUV);
        
    //     // Decode normal from texture
    //     vec3 decodedNormal = decodeNormal(glitterNormal.xy);
    //     vec3 glitterBump = decodedNormal * decodedNormal.z;
    //     vec3 blendedNormal = glitterBump.xyz + baseNormal.xyz;
        
    //     // Calculate glitter reflection
    //     vec3 reflectedDir = reflect(viewDir, normalize(transformToTangentSpace(blendedNormal)));
    //     vec3 rainbowEffect = sin(reflectedDir * mix(12.0, 5.6, g_fGlitterRainbowSpread));
        
    //     // Apply rainbow spectrum
    //     vec3 rainbowColor = calculateRainbowSpectrum(rainbowEffect);
        
    //     // Calculate glitter alpha
    //     float glitterAlpha = glitterNormal.w;
    //     float glitterMask = (glitterIntensity * glitterAlpha) * abs(1.0 - glitterBump.z);
        
    //     // Output values
    //     glitterColor = rainbowColor * glitterAlpha * dot(viewDir, tangentNormal) * g_fGlitterIntensity;
    //     roughnessMap = roughness * (1.0 - glitterMask * 0.25);
    //     baseColor = baseColorValue * mix(1.0 + glitterMask * 2.5, 1.0, luminance(baseColorValue));
    //     metalness = max(metallicValue, glitterMask * 0.5 * glitterIntensity);
    //     normalMap = baseNormal + (glitterBump * glitterIntensity * clamp(1.0 - mipLevel * 40.0, 0.0, 1.0));
    // }
}
