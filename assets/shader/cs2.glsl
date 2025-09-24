import lib-normal.glsl
import lib-vectors.glsl

#include "std/weaponfinish.glsl"
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
//: param custom { "default": [50, 245, 106, 255] }
uniform vec4 uPBRRanges; // packed values: [non-metallic min:max, metallic min:max]

void shade(V2F inputs) {
    ShaderOutputs outputs;

    if (uLivePreview) {
        applyFinish(inputs, outputs);
        // pbr validation
        if (uPBRValidation) {
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

        switch (uDebugChannel) {
            case 1:
                emissiveColorOutput(vec3(1.0 - outputs.wear));
                break;
            case 2:
                emissiveColorOutput(outputs.color);
                break;
            case 3:
                emissiveColorOutput(sRGB2linear(vec3(outputs.orm.g)));
                break;
            case 4:
                emissiveColorOutput(sRGB2linear(vec3(outputs.pearlFactor / TAU + 0.5)));
                break;
            default:
                shadePBR(outputs);
        }
    } else {
        outputs.vectors = computeLocalFrame(inputs);
        outputs.orm.r = getAO(inputs.tex_coord, true);
        #if EXTERN_MODE
            outputs.color = tex2D(uMatColor, inputs.tex_coord).rgb;
            outputs.orm.g = tex2D(uMatRough, inputs.tex_coord).r;
            outputs.orm.b = tex2D(uMatMasks, inputs.tex_coord).r;
        #else
            outputs.color = tex2D(uPatternColor, inputs.tex_coord).rgb;
            outputs.orm.g = tex2D(uPatternRough, inputs.tex_coord).r;
            outputs.orm.b = tex2D(uPatternMasks, inputs.tex_coord).r;
        #endif
        shadePBR(outputs);
    }
}
