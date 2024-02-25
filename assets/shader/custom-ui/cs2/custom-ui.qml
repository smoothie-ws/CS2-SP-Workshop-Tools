import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0
import "shaderconnect.js" as Shader

Rectangle {
    id: root
    color: AlgStyle.background.color.mainWindow
    height: mainLayout.height
    onHeightChanged: {
        if (height != mainLayout.height)
        {
            height = Qt.binding(function() { return mainLayout.height});
        }
    }

    function displayShaderParameters(shaderId) {
        Shader.connect(enableLivePreview, "checked", alg.shaders.parameter(shaderId, "u_enable_live_preview"));
        Shader.connect(enablePBRValidation, "tick", alg.shaders.parameter(shaderId, "u_enable_pbr_validation"));
        Shader.connect(mRGBRange, "firstValue", alg.shaders.parameter(shaderId, "u_m_rgb_min"));
        Shader.connect(mRGBRange, "secondValue", alg.shaders.parameter(shaderId, "u_m_rgb_max"));
        Shader.connect(nmRGBRange, "firstValue", alg.shaders.parameter(shaderId, "u_nm_rgb_min"));
        Shader.connect(nmRGBRange, "secondValue", alg.shaders.parameter(shaderId, "u_nm_rgb_max"));
        Shader.connect(styleBox, "currentIndex", alg.shaders.parameter(shaderId, "u_finish_style"));
        Shader.connect(textureScale, "value", alg.shaders.parameter(shaderId, "u_tex_scale"));
        Shader.connect(colBaseMetal, "arrayColor", alg.shaders.parameter(shaderId, "u_base_metal"));
        Shader.connect(colPatinaTint, "arrayColor", alg.shaders.parameter(shaderId, "u_patina_tint"));
        Shader.connect(colPatinaWear, "arrayColor", alg.shaders.parameter(shaderId, "u_patina_wear"));
        Shader.connect(colGrime, "arrayColor", alg.shaders.parameter(shaderId, "u_grime"));
        Shader.connect(pearlScale, "value", alg.shaders.parameter(shaderId, "u_pearl_scale"));
        Shader.connect(usePearlMask, "checked", alg.shaders.parameter(shaderId, "u_use_pearl_mask"));
        Shader.connect(paintRoughness, "value", alg.shaders.parameter(shaderId, "u_paint_roughness"));
        Shader.connect(useRoughnessTex, "checked", alg.shaders.parameter(shaderId, "u_use_roughness_tex"));
        Shader.connect(useNormalMap, "checked", alg.shaders.parameter(shaderId, "u_use_normal_map"));
        Shader.connect(useMaterialMask, "checked", alg.shaders.parameter(shaderId, "u_use_material_mask"));
        Shader.connect(useAOTex, "checked", alg.shaders.parameter(shaderId, "u_use_ao_tex"));
    }

    ColumnLayout {
        id: mainLayout
        width: parent.width
        spacing: 15

        GridLayout {
            columns: 2
            columnSpacing: 15
            Layout.fillWidth: true

            AlgLabel {
                text: "Finish style"
            }

            AlgComboBox {
                id: styleBox
                Layout.fillWidth: true
                tooltip: "Select a finish style"
                model: [
                { text: "Anodized Airbrushed", value: 0 },
                { text: "Anodized Multicolored", value: 1 },
                { text: "Anodized", value: 2 },
                { text: "Custom Paint Job", value: 3 },
                { text: "Gunsmith", value: 4 },
                { text: "Hydrographic", value: 5 },
                { text: "Patina", value: 6 },
                { text: "Spray Paint", value: 7 }
                ]
                textRole: "text"
                spacing: 5
            }

            AlgLabel {
                text: "Weapon"
            }

            AlgComboBox {
                id: weaponBox
                Layout.fillWidth: true
                tooltip: "Select a weapon"
                model: [
                { text: "AK-47", value: "ak47" },
                { text: "AUG", value: "aug" },
                { text: "AWP", value: "awp" },
                { text: "CZ75-Auto", value: "cz75" },
                { text: "Desert Eagle", value: "deagle" },
                { text: "Dual Berettas", value: "duals" },
                { text: "FAMAS", value: "famas" },
                { text: "Five-SeveN", value: "fiveseven" },
                { text: "G3SG1", value: "g3sg1" },
                { text: "Galil AR", value: "galil" },
                { text: "Glock-18", value: "g18" },
                { text: "MAC-10", value: "mac10" },
                { text: "MAG-7", value: "mag7" },
                { text: "M249", value: "m249" },
                { text: "M4A1-S", value: "m4a1s" },
                { text: "M4A4", value: "m4a4" },
                { text: "MP5-SD", value: "mp5sd" },
                { text: "MP7", value: "mp7" },
                { text: "MP9", value: "mp9" },
                { text: "Negev", value: "negev" },
                { text: "Nova", value: "nova" },
                { text: "P2000", value: "p2000" },
                { text: "P250", value: "p250" },
                { text: "P90", value: "p90" },
                { text: "PP-Bizon", value: "bizon" },
                { text: "R8 Revolver", value: "r8" },
                { text: "SCAR-20", value: "scar20" },
                { text: "SG 553", value: "sg553" },
                { text: "SSG 08", value: "ssg08" },
                { text: "Sawed-Off", value: "sawedoff" },
                { text: "Tec-9", value: "tec9" },
                { text: "UMP-45", value: "ump45" },
                { text: "USP-S", value: "usps" },
                { text: "XM1014", value: "xm1014" },
                { text: "Zeus x27", value: "zeus" }
                ]
                textRole: "text"
                currentIndex: 0
                spacing: 15
                onActivated: {
                    // TODO
                }
            }
        }

        AlgSlider {
            id: uWear
            Layout.fillWidth: true
            Layout.fillHeight: true

            value: 0.0
            minValue: 0.0
            maxValue: 1.0
            stepSize: 0.01
            text: {
                    if (value < 0.07)
                        return "Wear: Factory New (FN)";
                    else if (value < 0.15)
                        return "Wear: Minimal Wear (MW)";
                    else if (value < 0.37)
                        return "Wear: Field Tested (FT)";
                    else if (value < 0.45)
                        return "Wear: Well-Worn (WW)";
                    else
                        return "Wear: Battle-Scarred (BS)";
                }
        }
        
        AlgCheckBox {
            id: enableLivePreview
            text: "Live Preview"
            Layout.fillWidth: true
            checked: true
        }

        AlgCheckBox {
            id: enablePBRValidation
            text: "PBR Validate"
            Layout.fillWidth: true
            checked: true

            property bool tick: true

            onCheckedChanged: {
                tick = checked;
            }

            Timer {
                id: timer
                interval: blinkInterval.value * 1000
                running: enableBlinking.checked & enablePBRValidation.checked
                repeat: true
                onTriggered: {
                    parent.tick = !parent.tick;
                }
            }
        }

        AlgGroupWidget {
            activeScopeBorder : true
            text: "PBR Validation Parameters"
            visible: enablePBRValidation.checked
            toggled: true

            ColumnLayout {
                spacing: 15

                AlgCheckBox {
                    id: enableBlinking
                    text: "Blink"
                    checked: true

                    onCheckedChanged: {
                        enablePBRValidation.tick = checked ? enablePBRValidation.tick : true;
                    }
                }

                AlgSlider {
                    id: blinkInterval
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    visible: enableBlinking.checked
                    value: 0.5
                    minValue: 0.0
                    maxValue: 1.0
                    stepSize: 0.01
                    text: "Blink Interval"
                }

                SPRangeSlider {
                    id: mRGBRange
                    Layout.fillWidth: true
                    
                    label: "RGB range for metallic finishes"
                    minValue: 1
                    maxValue: 255
                    firstValue: 90
                    secondValue: 250
                    step: 1
                    precision: 0
                }

                SPRangeSlider {
                    id: nmRGBRange
                    Layout.fillWidth: true

                    label: "RGB range for non-metallic finishes"
                    minValue: 1
                    maxValue: 255
                    firstValue: 55
                    secondValue: 220
                    step: 1
                    precision: 0
                }
            }
        }

        AlgSlider {
            id: textureScale
            value: 1.0
            minValue: -10.0
            maxValue: 10.0
            text: "Texture Scale"
            Layout.fillWidth: true
            Layout.topMargin: 10
        }

        AlgCheckBox {
            text: "Ignore Weapon Size Scale"
            Layout.fillWidth: true
            Layout.topMargin: 10

            onCheckedChanged: {
                alg.log.warn("checked: " + checked)
            }
        }
        
        AlgGroupWidget {
            activeScopeBorder : true
            text: "Color"
            toggled: true

            GridLayout {
                columns: 2
                columnSpacing: 15
                rowSpacing: 10
                Layout.fillWidth: true

                AlgLabel {
                    Layout.fillHeight: true
                    text: "Base Metal"
                }
                AlgColorButton {
                    id: colBaseMetal
                    Layout.fillWidth: true

                    arrayColor: [0.5, 0.5, 0.5]
                }

                AlgLabel {
                    Layout.fillHeight: true
                    text: "Patina Tint"
                }
                AlgColorButton {
                    id: colPatinaTint
                    Layout.fillWidth: true

                    arrayColor: [0.5, 0.5, 0.5]
                }

                AlgLabel {
                    Layout.fillHeight: true
                    text: "Patina Wear"
                }
                AlgColorButton {
                    id: colPatinaWear
                    Layout.fillWidth: true

                    arrayColor: [0.5, 0.5, 0.5]
                }

                AlgLabel {
                    Layout.fillHeight: true
                    text: "Grime"
                }
                AlgColorButton {
                    id: colGrime
                    Layout.fillWidth: true

                    arrayColor: [0.5, 0.5, 0.5]
                }
            }
        }

        AlgGroupWidget {
            activeScopeBorder : true
            text: "Texture Placement"
            toggled: true

            ColumnLayout {
                spacing: 10
                Layout.fillWidth: true

                SPRangeSlider {
                    id: texRotation
                    Layout.fillWidth: true
                    label: "Texture Rotation"

                    minValue: -360.0
                    maxValue: 360.0
                    firstValue: 0.0
                    secondValue: 0.0
                    step: 1.0
                }

                SPRangeSlider {
                    id: texOffsetX
                    Layout.fillWidth: true
                    label: "Texture Offset X"

                    minValue: -1.0
                    maxValue: 1.0
                    firstValue: 0.0
                    secondValue: 0.0
                    step: 0.1
                }

                SPRangeSlider {
                    id: texOffsetY
                    Layout.fillWidth: true
                    label: "Texture Offset Y"

                    minValue: -1.0
                    maxValue: 1.0
                    firstValue: 0.0
                    secondValue: 0.0
                    step: 0.1
                }
            }
        }

        AlgGroupWidget {
            activeScopeBorder : true
            text: "Effects"
            toggled: true

            ColumnLayout {
                spacing: 10
                Layout.fillWidth: true

                SPRangeSlider {
                    id: wearLimits
                    Layout.fillWidth: true
                    label: "Wear Limits"

                    minValue: 0.0
                    maxValue: 1.0
                    firstValue: 0.0
                    secondValue: 1.0
                    step: 0.05
                }

                AlgSlider {
                    id: pearlScale
                    Layout.fillWidth: true

                    value: 0.0
                    minValue: -6.0
                    maxValue: 6.0
                    text: "Pearlescent Scale"
                }

                AlgCheckBox {
                    id: usePearlMask
                    text: "Use Pearlescent Mask"
                }
       
                AlgCheckBox {
                    id: useRoughnessTex
                    text: "Use Roughness Texture"
                }

                AlgSlider {
                    id: paintRoughness
                    Layout.fillWidth: true
                    visible: !useRoughnessTex.checked
                    value: 0.6
                    minValue: 0.0
                    maxValue: 1.0
                    text: "Paint Roughness"
                }
            }
        }

        AlgGroupWidget {
            activeScopeBorder : true
            text: "Advanced"
            toggled: true

            ColumnLayout {
                spacing: 10
                Layout.fillWidth: true

                AlgCheckBox {
                    id: useNormalMap
                    text: "Use Custom Normal Map"
                }

                AlgCheckBox {
                    id: useMaterialMask
                    text: "Use Custom Material Mask"
                }

                AlgCheckBox {
                    id: useAOTex
                    text: "Use Custom Ambient Occlusion"
                }
            }
        }
    }
}

