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
    CustomWeaponOutputs O;

    if (g_bLivePreview) {
        composeCustomWeapon(inputs, O);
        pearl(O);
        if (g_bPBRValidation)
            validatePBR(O);

        switch (g_bDebugChannel) {
            case 1:
                emissiveColorOutput(vec3(O.color.a));
                break;
            case 2:
                emissiveColorOutput(O.color.rgb);
                break;
            case 3:
                emissiveColorOutput(sRGB2linear(O.metalness.xyz));
                break;
            case 4:
                emissiveColorOutput(vec3(O.pearlFactor + 0.5));
                break;
            default:
                shadePBR(O);
        }
    } else {
        O.vectors = computeLocalFrame(inputs);
        #if EXTERN_MODE
            O.color.rgb = tex2D(g_tMatColor, inputs.tex_coord).rgb;
            O.metalness.x = tex2D(g_tMatRough, inputs.tex_coord).x;
            O.metalness.y = tex2D(g_tMatMasks, inputs.tex_coord).x;
        #else
            O.color.rgb = tex2D(g_tPattern, inputs.tex_coord).rgb;
            O.metalness.x = tex2D(g_tPaintRoughness, inputs.tex_coord).x;
            O.metalness.y = tex2D(g_tPaintMasks, inputs.tex_coord).x;
        #endif
        O.color.a = 1.0;
        O.metalness.zw = vec2(0.0, getAO(inputs.tex_coord, true));
        shadePBR(O);
    }
}
