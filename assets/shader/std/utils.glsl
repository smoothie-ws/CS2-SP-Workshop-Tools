#include "constants.glsl"

float luma(vec3 c) { return dot(c, vec3(0.2125, 0.7154, 0.0721)); }

float saturate(float x) { return clamp(x, 0.0, 1.0); }
vec2 saturate(vec2 x) { return clamp(x, vec2(0.0), vec2(1.0)); }
vec3 saturate(vec3 x) { return clamp(x, vec3(0.0), vec3(1.0)); }
vec4 saturate(vec4 x) { return clamp(x, vec4(0.0), vec4(1.0)); }

void computePearlescence(inout CustomWeaponOutputs O) {
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
}
