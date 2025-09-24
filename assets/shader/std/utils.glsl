#include "constants.glsl"

float srgb2linear(float color) {
    float linseg = color / 12.92;
    float expseg = pow((color / 1.055) + 0.0521327, 2.4);

    const float cap = 0.04045;
    float select = color > cap ? expseg : linseg;

    return select;
}

vec2 srgb2linear(vec2 color) {
    const float cap = 0.04045;

    vec2 linseg = color / vec2(12.92);
    vec2 expseg = pow((color / vec2(1.055)) + vec2(0.0521327), vec2(2.4));

    return vec2(
        color.r > cap ? expseg.r : linseg.r, 
        color.g > cap ? expseg.g : linseg.g
    );
}

vec3 srgb2linear(vec3 color) {
    const float cap = 0.04045;

    vec3 linseg = color / vec3(12.92);
    vec3 expseg = pow((color / vec3(1.055)) + vec3(0.0521327), vec3(2.4));

    return vec3(
        color.r > cap ? expseg.r : linseg.r, 
        color.g > cap ? expseg.g : linseg.g, 
        color.b > cap ? expseg.b : linseg.b
    );
}

vec4 srgb2linear(vec4 color) {
    const float cap = 0.04045;

    vec4 linseg = color / vec4(12.92);
    vec4 expseg = pow((color / vec4(1.055)) + vec4(0.0521327), vec4(2.4));

    return vec4(
        color.r > cap ? expseg.r : linseg.r, 
        color.g > cap ? expseg.g : linseg.g, 
        color.b > cap ? expseg.b : linseg.b, 
        color.a > cap ? expseg.a : linseg.a
    );
}

vec3 linear2srgb( vec3 vLinearColor ) {
	vec3 linseg = vLinearColor.rgb * 12.92;
	vec3 expseg = ( 1.055 * pow( vLinearColor.rgb, vec3 ( 1.0 / 2.4) )) - 0.055;

	return vec3(
        vLinearColor.r <= 0.0031308 ? linseg.r : expseg.r,
        vLinearColor.g <= 0.0031308 ? linseg.g : expseg.g,
        vLinearColor.b <= 0.0031308 ? linseg.b : expseg.b 
    );
}

vec3 rgb2hsl(vec3 color) {
    float maxC = max(max(color.r, color.g), color.b);
    float minC = min(min(color.r, color.g), color.b);
    float l = (maxC + minC) * 0.5;

    float h = 0.0;
    float s = 0.0;

    if (maxC != minC) {
        float d = maxC - minC;
        s = l > 0.5 ? d / (2.0 - maxC - minC) : d / (maxC + minC);
        if (maxC == color.r)
            h = (color.g - color.b) / d + (color.g < color.b ? 6.0 : 0.0);
        else if (maxC == color.g)
            h = (color.b - color.r) / d + 2.0;
        else
            h = (color.r - color.g) / d + 4.0;
        h /= 6.0;
    }

    return vec3(h, s, l);
}

float hue2rgb(float p, float q, float t) {
    if (t < 0.0) t += 1.0;
    if (t > 1.0) t -= 1.0;
    if (t < 1.0 / 6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0 / 2.0) return q;
    if (t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
    return p;
}

vec3 hsl2rgb(vec3 hsl) {
    float r, g, b;

    if (hsl.y == 0.0) {
        r = g = b = hsl.z;
    } else {
        float q = hsl.z < 0.5 ? hsl.z * (1.0 + hsl.y) : hsl.z + hsl.y - hsl.z * hsl.y;
        float p = 2.0 * hsl.z - q;
        r = hue2rgb(p, q, hsl.x + 1.0 / 3.0);
        g = hue2rgb(p, q, hsl.x);
        b = hue2rgb(p, q, hsl.x - 1.0 / 3.0);
    }

    return vec3(r, g, b);
}

vec3 hueShift(vec3 col, float factor) {
    vec3 hsl = rgb2hsl(col);
    hsl.x = mod(hsl.x + factor / TAU, 1.0);
    return hsl2rgb(hsl);
}
