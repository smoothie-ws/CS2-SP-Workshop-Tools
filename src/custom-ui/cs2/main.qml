import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0
import "./SPWidgets"
import "utils.mjs" as Utils

Rectangle {
    id: root
    color: AlgStyle.background.color.mainWindow
    height: mainLayout.height
    onHeightChanged: {
        if (height != mainLayout.height)
            height = Qt.binding(() => mainLayout.height);
    }

    Component.onCompleted: {
        shader.connect();
        if (alg.project.settings.contains("CS2WT")) 
            shader.setValues(alg.project.settings.value("CS2WT"));
        else if (alg.settings.contains("CS2WT"))
            shader.setValues(alg.settings.value("CS2WT"));
    }

    PainterPlugin {
        onComputationStatusChanged: {
            const name = Utils.File.getFileName(alg.project.lastImportedMeshUrl());
            if (weaponBox.currentValue != name)
                weaponBox.currentIndex = weaponBox.model.findIndex(w => w.value === name);
        }

        onProjectAboutToSave: {
            alg.project.settings.setValue("CS2WT", shader.getValues());
        }
    }

    QtObject {
        id: shader

        property string shaderId: ""

        property var parameters: {
            "u_finish_style":             { item: finishStyleBox,         prop: "currentIndex" },
            "u_enable_live_preview":      { item: enableLivePreview,      prop: "checked"      },
            "u_enable_pbr_validation":    { item: enablePBRValidation,    prop: "checked"      },
            "u_pbr_limits":               { item: pbrLimits,              prop: "range"        },
            "u_wear_amount":              { item: wearAmount,             prop: "value"        },
            "u_tex_transform":            { item: texTransform,           prop: "transform"    },
            "u_ignore_weapon_size_scale": { item: ignoreTextureSizeScale, prop: "checked"      },
            "u_use_pearl_mask":           { item: usePearlescentMask,     prop: "checked"      },
            "u_pearl_scale":              { item: pearlescentScale,       prop: "value"        },
            "u_use_roughness_tex":        { item: useRoughnessTexture,    prop: "checked"      },
            "u_paint_roughness":          { item: paintRoughness,         prop: "value"        },
            // dynamically generated components:
            "u_d_gun_grunge_sampler":     { item: null,                   prop: "url"          },
            "u_d_basecolor_sampler":      { item: null,                   prop: "url"          },
            "u_d_normal_sampler":         { item: null,                   prop: "url"          },
            "u_d_orm_sampler":            { item: null,                   prop: "url"          },
            "u_d_curv_sampler":           { item: null,                   prop: "url"          },
            "u_col0":                     { item: null,                   prop: "arrayColor"   },
            "u_col1":                     { item: null,                   prop: "arrayColor"   },
            "u_col2":                     { item: null,                   prop: "arrayColor"   },
            "u_col3":                     { item: null,                   prop: "arrayColor"   },
            "u_use_normal_map":           { item: null,                   prop: "checked"      },
            "u_use_material_mask":        { item: null,                   prop: "checked"      },
            "u_use_ao_tex":               { item: null,                   prop: "checked"      }
        }

        function connect() {
            for (const [param, component] of Object.entries(parameters)) {
                const cl = alg.shaders.parameter(shaderId, param);
                component.item[component.prop] = Qt.binding(() => cl.value);
                cl.value = Qt.binding(() => component.item[component.prop]);
            }
        }

        function getValues() {
            var values = {}
            for (const [param, component] of Object.entries(parameters))
                values[param] = component.item[component.prop];
            return values;
        }

        function setValues(values) {
            for (const v in values) {
                const component = parameters[v.param];
                component.item[component.prop] = v.value;
            }
        }
    }

    function displayShaderParameters(shaderId) {
        shader.shaderId = shaderId;
    }

    function importTexture(url) {
        return alg.resources.importSessionResource(url, "texture");
    }

    function resetWeapon(weaponName) {
        const path = Qt.resolvedUrl('assets/materials/').slice(8);
        try {
            shader.parameters["u_d_basecolor_sampler"].item.url = importTexture(`${path}${weaponName}/color.jpg`);
            shader.parameters["u_d_normal_sampler"].item.url = importTexture(`${path}${weaponName}/normal.jpg`);
            shader.parameters["u_d_orm_sampler"].item.url = importTexture(`${path}${weaponName}/orm.jpg`);
            shader.parameters["u_d_curv_sampler"].item.url = importTexture(`${path}${weaponName}/curvature.jpg`);
        } catch(err) {
            alg.log.warning("Failed to fetch default weapon textures: " + err.message)
        }
    }

    QtObject {
        id: texTransform

        // packed values: [scale, rotation, offsetX, offsetY]
        property var transform: [
            texureScale.value, 
            textureRotation.value, 
            textureOffsetX.value, 
            textureOffsetY.value
        ]

        onTransformChanged: {
            texureScale.value = transform[0];
            textureRotation.value = transform[1];
            textureOffsetX.value = transform[2];
            textureOffsetY.value = transform[3];
        }
    }

    ColumnLayout {
        id: mainLayout
        width: root.width

        Item {
            Layout.fillWidth: true
            height: layout.height

            RowLayout {
                id: layout
                width: parent.width
                anchors.margins: 10
                spacing: 10

                SPButton {
                    id: exportButton
                    Layout.alignment: Qt.AlignHCenter
                    text: "Export to .econitem"
                    icon.source: "./assets/icons/export.png"
                    icon.width: 18
                    icon.height: 18

                    onClicked: {
                        fileDialog.mode = SPFileDialog.SaveFile
                        fileDialog.title = "Export to .econitem"
                        fileDialog.open()
                    }
                }

                SPButton {
                    id: importButton
                    Layout.alignment: Qt.AlignHCenter
                    text: "Import from .econitem"
                    icon.source: "./assets/icons/import.png"
                    icon.width: 18
                    icon.height: 18

                    onClicked: {
                        fileDialog.mode = SPFileDialog.OpenFile
                        fileDialog.title = "Import from .econitem"
                        fileDialog.open()
                    }
                }
            }

            SPFileDialog {
                id: fileDialog
                folder: Qt.resolvedUrl("file:///C:/Program Files (x86)/Steam/steamapps/common/Counter-Strike Global Offensive/content/csgo")
                nameFilters: ["EconItem files (*.econitem)"]

                onAccepted: {
                    if (mode === SPFileDialog.SaveFile)
                        Utils.EconItem.exportTo(fileUrl)
                    else
                        Utils.EconItem.importFrom(fileUrl)
                }
            }
        }

        SPSeparator { Layout.fillWidth: true }

        SPGroup {
            id: general
            Layout.fillWidth: true
            expandable: false
            padding: 10
            background: Rectangle {
                color: Qt.rgba(1, 1, 1, 0.05)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)
                radius: 10
            }

            RowLayout {
                width: parent.width

                SPButton {
                    id: enableLivePreview
                    Layout.fillWidth: true
                    checkable: true
                    text: "Live Preview"
                }

                SPButton {
                    id: enablePBRValidation
                    Layout.fillWidth: true
                    checkable: true
                    text: "PBR Validation"
                }
            }

            SPRangeSlider {
                id: pbrLimits
                text: "PBR Limits"
                enabled: enablePBRValidation.checked
                from: 0
                to: 255
                pickValue: false
            }
        }

        SPGroup {
            Layout.fillWidth: true
            toggled: false
            text: "Default Textures"
            
            Repeater {
                model: [
                    { param: "u_d_gun_grunge_sampler", text: "Gun Grunge"        },
                    { param: "u_d_basecolor_sampler",  text: "Base Color"        },
                    { param: "u_d_normal_sampler",     text: "Normal Map"        },
                    { param: "u_d_orm_sampler",        text: "ORM Texture"       },
                    { param: "u_d_curv_sampler",       text: "Curvature Texture" }
                ]
                delegate: SPResourcePicker {
                    label: modelData.text
                    filters: AlgResourcePicker.TEXTURE
                    Layout.fillWidth: true
                }

                onItemAdded: (i, item) => {
                    shader.parameters[model[i].param].item = item;
                }
            }
        }

        SPSeparator { Layout.fillWidth: true }

        ColumnLayout {
            Layout.bottomMargin: 10
            Layout.fillWidth: true
            spacing: 10
            enabled: enableLivePreview.checked

            SPGroup {
                Layout.fillWidth: true
                text: "Common"

                SPLabeled {
                    id: weapon
                    text: "Weapon"
                    Layout.fillWidth: true

                    SPComboBox {
                        id: weaponBox
                        textRole: "text"
                        valueRole: "value"
                        Layout.fillWidth: true
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
                            { text: "SG 553", value: "sg553" },
                            { text: "SSG 08", value: "ssg08" },
                            { text: "Tec-9", value: "tec9" },
                            { text: "UMP-45", value: "ump45" },
                            { text: "USP-S", value: "usp_silencer" },
                            { text: "XM1014", value: "xm1014" },
                            { text: "Zeus x27", value: "taser" }
                        ]

                        onCurrentValueChanged: resetWeapon(currentValue)
                    }

                    Component.onCompleted: scopeWidth = Math.max(scopeWidth, finishStyle.scopeWidth)
                }

                SPLabeled {
                    id: finishStyle
                    text: "Finish Style"
                    Layout.fillWidth: true

                    SPComboBox {
                        id: finishStyleBox
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: [
                            { text: "Solid Color", value: 0 },
                            { text: "Hydrographic", value: 1 },
                            { text: "Spray Paint", value: 2 },
                            { text: "Anodized", value: 3 },
                            { text: "Anodized Multicolored", value: 4 },
                            { text: "Anodized Airbrushed", value: 5 },
                            { text: "Custom Paint Job", value: 6 },
                            { text: "Patina", value: 7 },
                            { text: "Gunsmith", value: 8 }
                        ]
                        textRole: "text"
                        valueRole: "value"
                    }

                    Component.onCompleted: scopeWidth = Math.max(scopeWidth, weapon.scopeWidth)
                }

                SPSeparator { }

                SPSlider {
                    id: wearAmount
                    text: "Wear Amount"
                    from: wearLimits.minValue.toFixed(2)
                    to: wearLimits.maxValue.toFixed(2)
                    onValueChanged: wearLimits.value = value
                }

                SPSlider {
                    id: texureScale
                    text: "Texture Scale"
                    from: -10
                    to: 10

                    onValueChanged: texTransform.transform[0] = value
                }

                SPButton {
                    Layout.fillWidth: true
                    id: ignoreTextureSizeScale
                    checkable: true
                    text: "Ignore Weapon Size Scale"
                }
            }

            SPGroup {
                Layout.fillWidth: true
                text: "Texture Placement"

                SPRangeSlider {
                    id: textureRotation
                    text: "Texture Rotation"
                    from: -360
                    to: 360

                    onValueChanged: texTransform.transform[1] = value
                }

                SPRangeSlider {
                    id: textureOffsetX
                    text: "Texture Offset X"
                    from: -1
                    to: 1

                    onValueChanged: texTransform.transform[2] = value
                }

                SPRangeSlider {
                    id: textureOffsetY
                    text: "Texture Offset Y"
                    from: -1
                    to: 1

                    onValueChanged: texTransform.transform[3] = value
                }
            }

            SPGroup {
                id: colorGroup
                Layout.fillWidth: true
                text: "Color"
                visible: finishStyleBox.currentIndex != 6

                property real scopeWidth: 0.0

                Repeater {
                    model: finishStyleBox.currentIndex > 6 ? [
                        "Base Metal",
                        "Patina Tint", 
                        "Patina Wear", 
                        "Grime"
                    ] : [
                        "Base Coat", 
                        "Red Channel",
                        "Green Channel",
                        "Blue Channel"
                    ]
                    delegate: SPLabeled {
                        text: modelData
                        SPColorButton { }
                    }

                    onItemAdded: (i, item) => {
                        colorGroup.scopeWidth = Math.max(colorGroup.scopeWidth, item.scopeWidth);
                        item.scopeWidth = Qt.binding(() => colorGroup.scopeWidth);
                        shader.parameters[`u_col${i}`].item = item;
                    }
                }
            }

            SPGroup {
                Layout.fillWidth: true
                text: "Effects"

                SPRangeSlider {
                    id: wearLimits
                    text: "Wear Limits"
                    from: 0.0
                    to: 1.0
                    onValueChanged: wearAmount.value = value
                }

                SPSeparator { Layout.fillWidth: true }

                SPButton {
                    Layout.fillWidth: true
                    id: usePearlescentMask
                    checkable: true
                    text: "Custom Pearlescent Mask"
                }

                SPSlider {
                    id: pearlescentScale
                    text: "Pearlescent Scale"
                    from: -6
                    to: 6
                }

                SPSeparator { Layout.fillWidth: true }

                SPButton {
                    id: useRoughnessTexture
                    Layout.fillWidth: true
                    checkable: true
                    text: "Custom Roughness Texture"
                }
                
                SPSlider {
                    id: paintRoughness
                    text: "Paint Roughness"
                    visible: !useRoughnessTexture.checked
                    from: 0
                    to: 1
                }
            }

            SPGroup {
                id: advancedGroup
                text: "Advanced"
                toggled: false
                Layout.fillWidth: true

                Repeater {
                    model: [
                        { param: "u_use_normal_map",    text: "Custom Normal Map"        },
                        { param: "u_use_material_mask", text: "Custom Material Mask"     },
                        { param: "u_use_ao_tex",        text: "Custom Ambient Occlusion" }
                    ]
                    delegate: SPButton {
                        checkable: true
                        text: modelData.text
                        Layout.fillWidth: true
                    }

                    onItemAdded: (i, item) => {
                        shader.parameters[model[i].param].item = item;
                    }
                }
            }
        }

        SPSeparator { Layout.fillWidth: true }
        
        Text {
            id: footer
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.RichText
            font.pixelSize: 11
            color: Qt.rgba(0.8, 0.8, 0.8, 1.0)
            text: "Created by <a href=\"https://steamcommunity.com/id/smoothie-ws/\">smoothie</a>"

            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
