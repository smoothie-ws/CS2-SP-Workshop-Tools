import lib-normal.glsl
import lib-vectors.glsl

#include "customweapon.glsl"
#include "std/pbr.glsl"

//: metadata {
//:  "custom-ui" : "cs2-ui.qml"
//: }

// General Parameters --------------------------------------------- //

//: param custom { "default": true }
uniform_specialization bool uLivePreview;
//: param custom { "default": 0 }
uniform_specialization int uDebugChannel;
//: param custom { "default": false }
uniform_specialization bool uPBRValidation;
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

    if (uLivePreview) {
        composeCustomWeapon(inputs, outputs);
        if (uPBRValidation)
            validatePBR(outputs);

        // switch (uDebugChannel) {
        //     case 1:
        //         emissiveColorOutput(vec3(1.0 - outputs.wear));
        //         break;
        //     case 2:
        //         emissiveColorOutput(outputs.color);
        //         break;
        //     case 3:
                emissiveColorOutput(sRGB2linear(vec3(outputs.orm)));
        //         break;
        //     case 4:
        //         emissiveColorOutput(sRGB2linear(vec3(outputs.pearlFactor / TAU + 0.5)));
        //         break;
        //     default:
        //         shadePBR(outputs);
        // }
    } else {
        outputs.vectors = computeLocalFrame(inputs);
        outputs.orm.r = getAO(inputs.tex_coord, true);
        #if EXTERN_MODE
            outputs.color = tex2D(g_tMatColor, inputs.tex_coord).rgb;
            outputs.orm.g = tex2D(g_tMatRough, inputs.tex_coord).r;
            outputs.orm.b = tex2D(g_tMatMasks, inputs.tex_coord).r;
        #else
            outputs.color = tex2D(g_tPattern, inputs.tex_coord).rgb;
            outputs.orm.g = tex2D(g_tPaintRoughness, inputs.tex_coord).r;
            outputs.orm.b = tex2D(g_tPaintMasks, inputs.tex_coord).r;
        #endif
        shadePBR(outputs);
    }
}
