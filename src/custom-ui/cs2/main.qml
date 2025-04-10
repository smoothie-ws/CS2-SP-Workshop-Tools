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

    property var parameters: {
        "u_d_gun_grunge_sampler":     dGunGrunge,
        "u_d_basecolor_sampler":      dBaseColor,
        "u_d_normal_sampler":         dNormalMap,
        "u_d_orm_sampler":            dORMtex,
        "u_d_curv_sampler":           dCurvTex,
        "u_finish_style":             finishStyleBox,
        "u_enable_live_preview":      enableLivePreview,
        "u_enable_pbr_validation":    enablePBRValidation,
        "u_pbr_limits":               pbrLimits,
        "weapon":                     weaponBox,
        "u_finish_style":             finishStyleBox,
        "u_wear_amount":              wearAmount,
        "u_tex_scale":                texureScale,
        "u_ignore_weapon_size_scale": ignoreTextureSizeScale,
        "tex_rotation":               textureRotation,
        "tex_offset_x":               textureOffsetX,
        "tex_offset_y":               textureOffsetY,
        "u_col0":                     color0,
        "u_col1":                     color1,
        "u_col2":                     color2,
        "u_col3":                     color3,
        "wear_limits":                wearLimits,
        "u_use_pearl_mask":           usePearlescentMask,
        "u_pearl_scale":              pearlescentScale,
        "u_use_roughness_tex":        useRoughnessTexture,
        "u_paint_roughness":          paintRoughness,
        "u_use_normal_map":           useNormalMap,
        "u_use_material_mask":        useMaterialMask,
        "u_use_ao_tex":               useAmbientOcclusion
    }

    function displayShaderParameters(shaderId) {
        for (const [param, item] of Object.entries(root.parameters))
            if (param.startsWith('u_'))
                item.connect(shaderId);
    }

    function readDefaults() {
        if (alg.project.settings.contains("CS2WT")) 
            return alg.project.settings.value("CS2WT");
        else if (alg.settings.contains("CS2WT"))
            return alg.settings.value("CS2WT");
        else 
            return {};
    }

    function setDefaults(defaults) {
        alg.log.info(defaults);
        for (const [param, value] of Object.entries(defaults)) {
            root.parameters[param].defaultValue = value;
        }
    }

    function writeDefaults() {
        var defaults = [];
        for (const [param, item] of Object.entries(root.parameters))
            defaults.push({ 
                param: param, 
                value: item.value
            });
        alg.project.settings.setValue("CS2WT", defaults);
        setDefaults(readDefaults());
    }

    function resetWeapon(weaponName) {
        const assetsPath = Qt.resolvedUrl('assets/materials/').slice(8);

        try {
            const baseColorRes = alg.resources.importSessionResource(assetsPath + `${weaponName}/color.jpg`, "texture");
            const normalMapRes = alg.resources.importSessionResource(assetsPath + `${weaponName}/normal.jpg`, "texture");
            const ormTexRes = alg.resources.importSessionResource(assetsPath + `${weaponName}/orm.jpg`, "texture");
            const curvTexRes = alg.resources.importSessionResource(assetsPath + `${weaponName}/curvature.jpg`, "texture");

            dBaseColor.value = baseColorRes;
            dNormalMap.value = normalMapRes;
            dORMtex.value = ormTexRes;
            dCurvTex.value = curvTexRes;
        } catch(err) {
            alg.log.error("ERROR: " + err.message)
        }
    }

    Component.onCompleted: {
        setDefaults(readDefaults());
    }

    PainterPlugin {
        onComputationStatusChanged: {
            const name = Utils.File.getFileName(alg.project.lastImportedMeshUrl());
            const item = weaponBox.control;
            if (item.currentValue != name)
                item.currentIndex = item.model.findIndex(w => w.value === name);
        }

        onProjectAboutToSave: writeDefaults()
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
                    icon.source: "./assets/icons/icon_export.png"
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
                    icon.source: "./assets/icons/icon_import.png"
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

        SPSeparator {
            Layout.fillWidth: true
        }

        SPGroup {
            Layout.fillWidth: true
            expandable: false
            padding: 10
            background: Rectangle {
                color: Qt.rgba(1, 1, 1, 0.05)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)
                radius: 10
            }

            ShaderParameter {
                id: enableLivePreview
                Layout.fillWidth: true
                text: "Live Preview"
                prop: "checked"
                resettable: false

                SPButton {
                    checkable: true
                    text: checked ? "Enabled" : "Disabled"
                }
            }

            ShaderParameter {
                id: enablePBRValidation
                Layout.fillWidth: true
                text: "PBR Validation"
                prop: "checked"
                resettable: false

                SPButton {
                    checkable: true
                    text: checked ? "Enabled" : "Disabled"
                }
            }

            ShaderParameter {
                id: pbrLimits
                enabled: enablePBRValidation.control.checked
                
                SPRangeSlider {
                    text: "PBR Limits"
                    stepSize: 1
                    from: 0
                    to: 255
                }
            }
        }

        SPGroup {
            id: colorsParamsGroup
            Layout.fillWidth: true
            toggled: false
            text: "Default Textures"

            ShaderParameter {
                id: dGunGrunge
                prop: "url"

                SPResourcePicker {
                    label: "Gun Grunge"
                    filters: AlgResourcePicker.TEXTURE
                }
            }

            ShaderParameter {
                id: dBaseColor
                prop: "url"

                SPResourcePicker {
                    label: "Base Color"
                    filters: AlgResourcePicker.TEXTURE
                }
            }

            ShaderParameter {
                id: dNormalMap
                prop: "url"

                SPResourcePicker {
                    label: "Normal Map"
                    filters: AlgResourcePicker.TEXTURE
                }
            }

            ShaderParameter {
                id: dORMtex
                prop: "url"

                SPResourcePicker {
                    label: "ORM Texture"
                    filters: AlgResourcePicker.TEXTURE
                }
            }

            ShaderParameter {
                id: dCurvTex
                prop: "url"

                SPResourcePicker {
                    label: "Curvature Texture"
                    filters: AlgResourcePicker.TEXTURE
                }
            }
        }

        SPSeparator {
            Layout.fillWidth: true
        }

        ColumnLayout {
            Layout.bottomMargin: 10
            Layout.fillWidth: true
            spacing: 10
            enabled: enableLivePreview.control.checked

            SPGroup {
                Layout.fillWidth: true
                text: "Common"

                ShaderParameter {
                    id: weaponBox
                    text: "Weapon"
                    prop: "currentIndex"

                    SPComboBox {
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
                        textRole: "text"
                        valueRole: "value"

                        onCurrentValueChanged: {
                            resetWeapon(currentValue);
                        }
                    }
                }

                ShaderParameter {
                    id: finishStyleBox
                    text: "Finish Style"
                    prop: "currentIndex"

                    SPComboBox {
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
                }

                SPSeparator { }

                ShaderParameter {
                    id: wearAmount
                    prop: "value"

                    SPSlider {
                        text: "Wear Amount"
                        from: wearLimits.control.minValue.toFixed(precision)
                        to: wearLimits.control.maxValue.toFixed(precision)
                        stepSize: 0.01
                    }
                }

                ShaderParameter {
                    id: texureScale
                    prop: "value"

                    SPSlider {
                        text: "Texture Scale"
                        from: -10
                        to: 10
                    }
                }

                ShaderParameter {
                    id: ignoreTextureSizeScale
                    text: "Ignore Weapon Size Scale:"
                    prop: "checked"

                    SPButton {
                        checkable: true
                        text: checked ? "Yes" : "No"
                    }
                }
            }

            SPGroup {
                Layout.fillWidth: true
                text: "Texture Placement"

                ShaderParameter {
                    id: textureRotation

                    SPRangeSlider {
                        text: "Texture Rotation"
                        from: -360
                        to: 360
                        minValue: 0
                        maxValue: 0
                    }
                }

                ShaderParameter {
                    id: textureOffsetX

                    SPRangeSlider {
                        text: "Texture Offset X"
                        from: -1
                        to: 1
                        minValue: 0
                        maxValue: 0
                    }
                }

                ShaderParameter {
                    id: textureOffsetY

                    SPRangeSlider {
                        text: "Texture Offset Y"
                        from: -1
                        to: 1
                        minValue: 0
                        maxValue: 0
                    }
                }
            }

            SPGroup {
                Layout.fillWidth: true
                visible: finishStyleBox.control.currentIndex != 6
                text: "Color"

                ShaderParameter {
                    id: color0
                    text: finishStyleBox.control.currentIndex > 6 ? "Base Metal" : "Base Coat"

                    SPColorButton { 
                        Component.onCompleted: {
                            colorChanged.connect(() => color0.update(() => color0.value = [color.r, color.g, color.b]));
                            color0.valueChanged.connect(() => 
                                color0.update(() => {
                                    color.r = color0.value[0]
                                    color.g = color0.value[1]
                                    color.b = color0.value[2]
                                })
                            );
                        }
                    }
                }

                ShaderParameter {
                    id: color1
                    visible: finishStyleBox.control.currentIndex != 3
                    text: finishStyleBox.control.currentIndex > 6 ? "Patina Tint" : "Red Channel"

                    SPColorButton { 
                        Component.onCompleted: {
                            colorChanged.connect(() => color1.update(() => color1.value = [color.r, color.g, color.b]));
                            color1.valueChanged.connect(() => 
                                color1.update(() => {
                                    color.r = color1.value[0]
                                    color.g = color1.value[1]
                                    color.b = color1.value[2]
                                })
                            );
                        }
                    }
                }

                ShaderParameter {
                    id: color2
                    visible: finishStyleBox.control.currentIndex != 3
                    text: finishStyleBox.control.currentIndex > 6 ? "Patina Wear" : "Green Channel"
                    
                    SPColorButton { 
                        Component.onCompleted: {
                            colorChanged.connect(() => color2.update(() => color2.value = [color.r, color.g, color.b]));
                            color2.valueChanged.connect(() => 
                                color2.update(() => {
                                    color.r = color2.value[0]
                                    color.g = color2.value[1]
                                    color.b = color2.value[2]
                                })
                            );
                        }
                    }
                }

                ShaderParameter {
                    id: color3
                    visible: finishStyleBox.control.currentIndex != 3
                    text: finishStyleBox.control.currentIndex > 6 ? "Grime" : "Blue Channel"
                    
                    SPColorButton { 
                        Component.onCompleted: {
                            colorChanged.connect(() => color3.update(() => color3.value = [color.r, color.g, color.b]));
                            color3.valueChanged.connect(() => 
                                color3.update(() => {
                                    color.r = color3.value[0]
                                    color.g = color3.value[1]
                                    color.b = color3.value[2]
                                })
                            );
                        }
                    }
                }
            }

            SPGroup {
                Layout.fillWidth: true
                text: "Effects"

                ShaderParameter {
                    id: wearLimits

                    SPRangeSlider {
                        text: "Wear Limits"
                        from: 0
                        to: 1
                        minValue: 0
                        maxValue: 1
                        stepSize: 0.01
                    }
                }

                SPSeparator { }

                ShaderParameter {
                    id: usePearlescentMask
                    text: "Pearlescent Mask"
                    prop: "checked"

                    SPButton {
                        checkable: true
                        text: checked ? "Use" : "Do not use"
                    }
                }

                ShaderParameter {
                    id: pearlescentScale
                    prop: "value"

                    SPSlider {
                        text: "Pearlescent Scale"
                        from: -6
                        to: 6
                    }
                }

                SPSeparator { }

                ShaderParameter {
                    id: useRoughnessTexture
                    prop: "checked"
                    text: "Roughness Texture"

                    property bool checked: true

                    SPButton {
                        checkable: true
                        text: checked ? "Use" : "Do not use"

                        onCheckedChanged: {
                            useRoughnessTexture.checked = checked
                        }
                    }
                }
                
                ShaderParameter {
                    id: paintRoughness
                    prop: "checked"
                    visible: !useRoughnessTexture.checked

                    SPSlider {
                        text: "Paint Roughness"
                        from: 0
                        to: 1
                    }
                }
            }

            SPGroup {
                Layout.fillWidth: true
                
                text: "Advanced"
                toggled: false

                ShaderParameter {
                    id: useNormalMap
                    prop: "checked"
                    text: "Normal Map"
                    
                    SPButton {
                        checkable: true
                        text: checked ? "Use" : "Do not use"
                    }
                }

                ShaderParameter {
                    id: useMaterialMask
                    prop: "checked"
                    text: "Material Mask"

                    SPButton {
                        checkable: true
                        text: checked ? "Use" : "Do not use"
                    }
                }

                ShaderParameter {
                    id: useAmbientOcclusion
                    prop: "checked"
                    text: "Ambient Occlusion"
                    
                    SPButton {
                        checkable: true
                        text: checked ? "Use" : "Do not use"
                    }
                }
            }
        }
        
        SPSeparator {
            Layout.fillWidth: true
        }
        
        Text {
            id: footer
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.RichText

            color: Qt.rgba(0.8, 0.8, 0.8, 1.0)
            text: "Created by <a href=\"https://steamcommunity.com/id/smoothie-ws/\">smoothie</a>"

            font.pixelSize: 11

            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
