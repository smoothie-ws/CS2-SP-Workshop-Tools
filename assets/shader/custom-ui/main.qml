import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0


ScrollView {
    id: root
    clip: true
    visible: true
    enabled: true
    width: parent.width
    height: parent.height
    padding: 10
    ScrollBar.vertical.policy: root.contentHeight > root.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    ScrollBar.horizontal.policy: root.contentWidth > root.width ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

    background: Rectangle {
            width: parent.width
            height: parent.height
            color: AlgStyle.background.color.mainWindow
        }

    // Block signals while applying a function on a QML component
    function protectSignalRetroAction(qmlComponent, fn) {
        return function() {
        var state = qmlComponent.state;
        if (state == "blockSignals") return;
        qmlComponent.state = "blockSignals";
        fn();
        qmlComponent.state = state;
        };
    }

    function updateComponentValue(qmlComponent, propertyKey, shaderParameter) {
        const getProperty = (propertyKey, shaderParameter) => {
        const propertyType = typeof qmlComponent[propertyKey];
            switch (propertyType) {
            case "number":
                return shader_bridge.get_number(shaderParameter);
            case "boolean":
                return shader_bridge.get_bool(shaderParameter);
            default:
                return shader_bridge.get_list(shaderParameter);
            }
        };

        // Set QML property to the current parameter value
        qmlComponent[propertyKey] = getProperty(propertyKey, shaderParameter);
    }

    // Connect a shader parameter to the property of a QML component
    function shaderParameterConnect(qmlComponent, propertyKey, shaderParameter) {
        // When the QML property has changed, update shader parameter data
        qmlComponent[propertyKey + "Changed"].connect(protectSignalRetroAction(qmlComponent, function() {
            shader_bridge.set_parameter_value(shaderParameter, qmlComponent[propertyKey]);
        }));
    }

    property var parameters: []

    Component.onCompleted: {
        parameters = [
            { element: enableLivePreview, property: "checked", uniform: "u_enable_live_preview" },
            { element: enablePBRValidation, property: "checked", uniform: "u_enable_pbr_validation" },
            { element: mRGBRange, property: "firstValue", uniform: "u_m_rgb_min" },
            { element: mRGBRange, property: "secondValue", uniform: "u_m_rgb_max" },
            { element: nmRGBRange, property: "firstValue", uniform: "u_nm_rgb_min" },
            { element: nmRGBRange, property: "secondValue", uniform: "u_nm_rgb_max" },
            { element: styleBox, property: "currentIndex", uniform: "u_finish_style" },
            { element: uWear, property: "controlValue", uniform: "u_wear" },
            { element: textureScale, property: "controlValue", uniform: "u_tex_scale" },
            { element: colBaseMetal, property: "arrayColor", uniform: "u_base_metal" },
            { element: colPatinaTint, property: "arrayColor", uniform: "u_patina_tint" },
            { element: colPatinaWear, property: "arrayColor", uniform: "u_patina_wear" },
            { element: colGrime, property: "arrayColor", uniform: "u_grime" },
            { element: pearlScale, property: "controlValue", uniform: "u_pearl_scale" },
            { element: usePearlMask, property: "checked", uniform: "u_use_pearl_mask" },
            { element: paintRoughness, property: "controlValue", uniform: "u_paint_roughness" },
            { element: useRoughnessTex, property: "checked", uniform: "u_use_roughness_tex" },
            { element: useNormalMap, property: "checked", uniform: "u_use_normal_map" },
            { element: useMaterialMask, property: "checked", uniform: "u_use_material_mask" },
            { element: useAOTex, property: "checked", uniform: "u_use_ao_tex" }
        ];

        parameters.forEach(function(parameter) {
            shaderParameterConnect(parameter.element, parameter.property, parameter.uniform);
        });
    }
    
    Timer {
        id: timer
        running: true
        repeat: true
        interval: 1000

        onTriggered: {
            parameters.forEach(function(parameter) {
                updateComponentValue(parameter.element, parameter.property, parameter.uniform);
            });
        }
    }

    ColumnLayout {
        id: settingsLayout
        width: root.availableWidth
        spacing: 15

        Rectangle {
            Layout.fillWidth: true
            height: previewButtons.height + 20
            color: "#2d2d2d"
            radius: 5

            RowLayout {
                id: previewButtons
                y: 10
                width: parent.width

                Item {
                    Layout.fillWidth: true
                }

                SPButton {
                    id: enableLivePreview
                    text: "Live Preview"
                    checkable: true
                    checked: true

                    onCheckedChanged: {
                        shader_bridge.test_slot("u_patina_wear")
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
                
                SPButton {
                    id: enablePBRValidation
                    text: "PBR Validate"
                    checkable: true
                    checked: true
                }
                
                Item {
                    Layout.fillWidth: true
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
                    { text: "Solid Color", value: 1 },
                    { text: "Hydrographic", value: 2 },
                    { text: "Spray Paint", value: 3 },
                    { text: "Anodized", value: 4 },
                    { text: "Anodized Multicolored", value: 5 },
                    { text: "Anodized Airbrushed", value: 6 },
                    { text: "Custom Paint Job", value: 7 },
                    { text: "Patina", value: 8 },
                    { text: "Gunsmith", value: 9 }
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
                { text: "PP-Bizon", value: "bizon" },
                { text: "CZ75-Auto", value: "cz75a" },
                { text: "Desert Eagle", value: "deagle" },
                { text: "Dual Berettas", value: "elite" },
                { text: "FAMAS", value: "famas" },
                { text: "Five-SeveN", value: "fiveseven" },
                { text: "Glock-18", value: "glock18" },
                { text: "G3SG1", value: "g3sg1" },
                { text: "Galil AR", value: "galilar" },
                { text: "MAC-10", value: "mac10" },
                { text: "M249", value: "m249" },
                { text: "M4A1-S", value: "m4a1_silencer" },
                { text: "M4A4", value: "m4a4" },
                { text: "MAG-7", value: "mag7" },
                { text: "MP5-SD", value: "mp5sd" },
                { text: "MP7", value: "mp7" },
                { text: "MP9", value: "mp9" },
                { text: "Negev", value: "negev" },
                { text: "Nova", value: "nova" },
                { text: "P2000", value: "hkp2000" },
                { text: "P250", value: "p250" },
                { text: "P90", value: "p90" },
                { text: "R8 Revolver", value: "revolver" },
                { text: "Sawed-Off", value: "sawedoff" },
                { text: "SCAR-20", value: "scar20" },
                { text: "SG 553", value: "sg556" },
                { text: "SSG 08", value: "ssg08" },
                { text: "Tec-9", value: "tec9" },
                { text: "UMP-45", value: "ump45" },
                { text: "USP-S", value: "usp_silencer" },
                { text: "XM1014", value: "xm1014" },
                { text: "Zeus x27", value: "taser" }
            ]
                textRole: "text"
                currentIndex: 0
                spacing: 15
                onActivated: {
                    configureWeaponMesh(plugin.pluginPath, model[index].value);
                }
            }
        }
        
        AlgGroupWidget {
            activeScopeBorder: true
            text: "Default Material Textures"
            visible: true
            toggled: true

            GridLayout {
                columns: 2
                columnSpacing: 15
                rowSpacing: 10
                Layout.fillWidth: true

                AlgLabel {
                    text: "Gun Grunge Texture"
                }
                AlgResourceWidget {
                    id: gunGrungeResource
                    Layout.fillWidth: true

                    filters: AlgResourcePicker.TEXTURE
                }

                AlgLabel {
                    text: "Albedo Texture"
                }
                AlgResourceWidget {
                    id: albedoResource
                    Layout.fillWidth: true
                    
                    filters: AlgResourcePicker.TEXTURE
                }

                AlgLabel {
                    text: "Normal Map"
                }
                AlgResourceWidget {
                    id: normalMapResource
                    Layout.fillWidth: true
                    
                    filters: AlgResourcePicker.TEXTURE
                }

                AlgLabel {
                    text: "ORM Texture"
                }
                AlgResourceWidget {
                    id: ormResource
                    Layout.fillWidth: true
                    
                    filters: AlgResourcePicker.TEXTURE
                }
            }
        }

        SPSlider {
            id: uWear
            Layout.fillWidth: true
            Layout.fillHeight: true

            controlValue: 0.0
            minValue: 0.0
            maxValue: 1.0
            step: 0.01
            label: {
                    if (controlValue < 0.07)
                        return "Wear: Factory New (FN)";
                    else if (controlValue < 0.15)
                        return "Wear: Minimal Wear (MW)";
                    else if (controlValue < 0.37)
                        return "Wear: Field Tested (FT)";
                    else if (controlValue < 0.45)
                        return "Wear: Well-Worn (WW)";
                    else
                        return "Wear: Battle-Scarred (BS)";
                }
        }

        SPSlider {
            id: textureScale
            controlValue: 1.0
            minValue: -10.0
            maxValue: 10.0
            label: "Texture Scale"
            Layout.fillWidth: true
        }

        AlgCheckBox {
            text: "Ignore Weapon Size Scale"
            Layout.fillWidth: true

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

                SPSlider {
                    id: pearlScale
                    Layout.fillWidth: true

                    controlValue: 0.0
                    minValue: -6.0
                    maxValue: 6.0
                    label: "Pearlescent Scale"
                }

                AlgCheckBox {
                    id: usePearlMask
                    text: "Use Pearlescent Mask"
                }
    
                AlgCheckBox {
                    id: useRoughnessTex
                    text: "Use Roughness Texture"
                }

                SPSlider {
                    id: paintRoughness
                    Layout.fillWidth: true
                    visible: !useRoughnessTex.checked
                    controlValue: 0.6
                    minValue: 0.0
                    maxValue: 1.0
                    label: "Paint Roughness"
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
