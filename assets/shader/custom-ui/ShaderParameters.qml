import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0
import "SPWidgets"
import "shaderparameters.js" as Shader

ScrollView {
    id: root
    clip: true
    visible: true
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

    Component.onCompleted: {
        var parameters = [
            { element: enableLivePreview, property: "checked", uniform: "u_enable_live_preview" },
            { element: enablePBRValidation, property: "checked", uniform: "u_enable_pbr_validation" },
            { element: mRGBRange, property: "firstValue", uniform: "u_m_rgb_min" },
            { element: mRGBRange, property: "secondValue", uniform: "u_m_rgb_max" },
            { element: nmRGBRange, property: "firstValue", uniform: "u_nm_rgb_min" },
            { element: nmRGBRange, property: "secondValue", uniform: "u_nm_rgb_max" }
        ];

        parameters.forEach(function(parameter) {
            Shader.connect(parameter.element, parameter.property, parameter.uniform);
        });
    }

    ColumnLayout {
        id: settingsLayout
        anchors.margins: 10
        width: root.availableWidth
        spacing: 15
        opacity: root.enabled ? 1.0 : 0.5

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
                }

                Item {
                    Layout.fillWidth: true
                }
                
                SPButton {
                    id: enablePBRValidation
                    text: "PBR Validate"
                    checkable: true
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
        
        AlgGroupWidget {
            activeScopeBorder: true
            text: "Default Material Textures"
            visible: true

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
        
        Repeater {
            property var weaponModel: [
                { text: "AK-47", value: 0 },
                { text: "AUG", value: 1 },
                { text: "AWP", value: 2 },
                { text: "PP-Bizon", value: 3 },
                { text: "CZ75-Auto", value: 4 },
                { text: "Desert Eagle", value: 5 },
                { text: "Dual Berettas", value: 6 },
                { text: "FAMAS", value: 7 },
                { text: "Five-SeveN", value: 8 },
                { text: "Glock-18", value: 9 },
                { text: "G3SG1", value: 10 },
                { text: "Galil AR", value: 11 },
                { text: "MAC-10", value: 12 },
                { text: "M249", value: 13 },
                { text: "M4A1-S", value: 14 },
                { text: "M4A4", value: 15 },
                { text: "MAG-7", value: 16 },
                { text: "MP5-SD", value: 17 },
                { text: "MP7", value: 18 },
                { text: "MP9", value: 19 },
                { text: "Negev", value: 20 },
                { text: "Nova", value: 21 },
                { text: "P2000", value: 22 },
                { text: "P250", value: 23 },
                { text: "P90", value: 24 },
                { text: "R8 Revolver", value: 25 },
                { text: "Sawed-Off", value: 26 },
                { text: "SCAR-20", value: 27 },
                { text: "SG 553", value: 28 },
                { text: "SSG 08", value: 29 },
                { text: "Tec-9", value: 30 },
                { text: "UMP-45", value: 31 },
                { text: "USP-S", value: 32 },
                { text: "XM1014", value: 33 },
                { text: "Zeus x27", value: 34 }
            ]

            property var finishStyleModel: [
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

            model: [
                { label: "Common",
                    parameters: [
                        { label: "Finish Style", widget: "comboBox", defaults: 9, model: finishStyleModel, uniform: "u_finish_style" },
                        { label: "Weapon", widget: "comboBox", defaults: 0, model: weaponModel },
                        { label: "Wear Amount", widget: "slider", range: [0.0, 1.0], defaults: 0.0, uniform: "u_wear" },
                        { label: "Texture Scale", widget: "slider", range: [-10.0, 10.0], defaults: 1.0, uniform: "u_tex_scale" },
                        { label: "Ignore Weapon Size Scale", widget: "checkBox", defaults: true }
                    ]
                },
                { label: "Color",
                    parameters: [
                        { label: "Base Metal", widget: "colorButton", defaults: Qt.hsva(1, 0, 1), uniform: "u_base_metal" },
                        { label: "Patina Tint", widget: "colorButton", defaults: Qt.hsva(1, 0, 1), uniform: "u_patina_tint" },
                        { label: "Patina Wear", widget: "colorButton", defaults: Qt.hsva(1, 0, 1), uniform: "u_patina_wear" },
                        { label: "Grime", widget: "colorButton", defaults: Qt.hsva(1, 0, 1), uniform: "u_grime" }
                    ]
                },
                { label: "Texture Placement",
                    parameters: [
                        { label: "Texture Rotation", widget: "rangeSlider", range: [-360.0, 360.0], defaults: [0.0, 0.0] },
                        { label: "Texture Offset X", widget: "rangeSlider", range: [-1.0, 1.0], defaults: [0.0, 0.0] },
                        { label: "Texture Offset Y", widget: "rangeSlider", range: [-1.0, 1.0], defaults: [0.0, 0.0] }
                    ]
                },
                { label: "Effects",
                    parameters: [
                        { label: "Wear Limits", widget: "rangeSlider", range: [0.0, 1.0], defaults: [0.0, 1.0] },
                        { label: "Pearlescent Scale", widget: "slider", range: [-6.0, 6.0], defaults: 0.0, uniform: "u_pearl_scale" },
                        { label: "Paint Roughness", widget: "slider", range: [0.0, 1.0], defaults: 0.3, uniform: "u_paint_roughness" }
                    ]
                },
                { label: "Advanced",
                    parameters: [
                        { label: "Use Pearlescent Mask", widget: "checkBox", defaults: true, uniform: "u_use_normal_map" },
                        { label: "Use Roughness Texture", widget: "checkBox", defaults: true, uniform: "u_use_material_mask" },
                        { label: "Use Normal Map", widget: "checkBox", defaults: true, uniform: "u_use_normal_map" },
                        { label: "Use Material Mask", widget: "checkBox", defaults: true, uniform: "u_use_material_mask" },
                        { label: "Use Ambient Occlusion", widget: "checkBox", defaults: true, uniform: "u_use_ao_tex" }
                    ]
                }
            ]

            ParameterGroup {
                text: modelData.label
                columnAmount: 2
                activeScopeBorder: true
                toggled: true
                Layout.fillWidth: true

                parameters: modelData.parameters
            }
        }
    }
    
}
