import lib-normal.glsl
import lib-vectors.glsl

#include "std/pbr.glsl"
#include "customweapon.glsl"

//: metadata {
//:  "custom-ui" : "cs2-ui.qml"
//: }

// General Parameters --------------------------------------------- //

//: param custom { "default": true }
uniform_specialization bool g_bLivePreview;
//: param custom { "default": 0 }
uniform_specialization int g_bDebugChannel;
//: param custom { "default": false }
uniform_specialization bool g_bPBRValidation;
#if EXTERN_MODE
//: param auto channel_basecolor
    uniform SamplerSparse g_tMatColor;
//: param auto channel_roughness
    uniform SamplerSparse g_tMatRough;
//: param auto channel_user0
    uniform SamplerSparse g_tMatMasks;
#endif

void shade(V2F inputs) {
    ShaderOutputs outputs;

    if (g_bLivePreview) {
        composeCustomWeapon(inputs, outputs);
        if (g_bPBRValidation)
            validatePBR(outputs);

        switch (g_bDebugChannel) {
            case 1:
                emissiveColorOutput(vec3(outputs.metalness.z));
                break;
            case 2:
                emissiveColorOutput(outputs.color.rgb);
                break;
            case 3:
                emissiveColorOutput(sRGB2linear(vec3(outputs.metalness.xy, 0.0)));
                break;
            case 4:
                emissiveColorOutput(sRGB2linear(vec3(outputs.metalness.w / TAU + 0.5)));
                break;
            default:
                shadePBR(outputs);
        }
    } else {
        outputs.vectors = computeLocalFrame(inputs);
        #if EXTERN_MODE
            outputs.color.rgb = tex2D(g_tMatColor, inputs.tex_coord).rgb;
            outputs.metalness.r = tex2D(g_tMatRough, inputs.tex_coord).r;
            outputs.metalness.g = tex2D(g_tMatMasks, inputs.tex_coord).r;
        #else
            outputs.color.rgb = tex2D(g_tPattern, inputs.tex_coord).rgb;
            outputs.metalness.r = tex2D(g_tPaintRoughness, inputs.tex_coord).r;
            outputs.metalness.g = tex2D(g_tPaintMasks, inputs.tex_coord).r;
        #endif
        outputs.color.w = getAO(inputs.tex_coord, true);
        outputs.metalness.ba = vec2(1.0, 0.0);
        shadePBR(outputs);
    }
}
