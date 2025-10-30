import lib-sampler.glsl

struct BoxSample {
    vec4 tX;
    vec4 tY;
    vec4 tZ;
};

vec4 tex2D(sampler2D tex, vec2 uv) {
    return texture(tex, uv);
}

vec4 tex2D(SamplerSparse tex, vec2 uv) {
    return texture(tex.tex, uv);
}

BoxSample boxSample(sampler2D t, vec3 p, vec4 f0, vec4 f1) { 
    return BoxSample(
        tex2D(t, vec2(dot(p.yz, f0.xy) + f0.w, dot(p.yz, f1.xy) + f1.w)),
        tex2D(t, vec2(dot(p.xz, f0.xy) + f0.w, dot(p.xz, f1.xy) + f1.w)),
        tex2D(t, vec2(dot(p.yx, f0.xy) + f0.w, dot(p.yx, f1.xy) + f1.w))
    );
}

BoxSample boxSample(SamplerSparse t, vec3 p, vec4 f0, vec4 f1) { 
    return boxSample(t.tex, p, f0, f1);
}

