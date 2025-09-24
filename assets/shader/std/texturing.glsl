import lib-sampler.glsl

vec4 tex2D(sampler2D tex, vec2 uv) {
    return texture(tex, uv);
}

vec4 tex2D(SamplerSparse tex, vec2 uv) {
    return texture(tex.tex, uv);
}

vec2 transform(vec2 uv, float scale, vec4 T) {
    float t = radians(T.w);
    float s = sin(t), c = cos(t);
    mat2 R = mat2(c, s, -s, c);

    float E = t - PI;
    float k = 1.0 / E - 0.1 * E + 0.5;
    vec2 o = vec2(s, c) * (k * s * s);

    uv.y = 1.0 - uv.y;
    uv = R * uv * T.x * scale + T.yz;
    uv.y = 1.0 - uv.y;

    return uv + o;
}
