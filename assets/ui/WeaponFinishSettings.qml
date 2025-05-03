import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import QtQuick.Window 2.15
import Qt.labs.platform 1.1
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0
import "./SPWidgets"
import "./SPWidgets/math.js" as MathUtils

Rectangle {
    id: root
    color: AlgStyle.background.color.mainWindow
    implicitHeight: mainLayout.height + 10

    function loadWeaponFinish() {
        weaponFinish.load();
        weaponFinish.connect();

        // load base textures
        const values = JSON.parse(internal.js("alg.project.settings.value(\"weapon_finish\")"));
        const w = weaponBox.currentKey;
        const texPath = `${internal.pluginPath()}/assets/textures`;
        for (const [param, file] of Object.entries({
                "uGrungeTex": "grunge.tga", 
                "uScratchesTex": "scratches.png", 
                "uBaseColor": `models/${w}/${w}_color.png`, 
                "uBaseRough": `models/${w}/${w}_rough.png`, 
                "uBaseSurface": `models/${w}/${w}_surface.png`, 
                "uBaseMasks": `models/${w}/${w}_masks.png`, 
                "uBaseCavity": `models/${w}/${w}_cavity.png`
            }))
            if (values[param] === undefined || values[param] === "")
                weaponFinish.parameters[param].control.url = importTexture(`${texPath}/${file}`);
    }

    // when user changes finish style, the corresponding shader instance has outdated parameter values
    function syncWeaponFinish() {
        weaponFinish.syncShader();
    }

    function importTexture(url) {
        return JSON.parse(internal.js(`alg.resources.importSessionResource("${url}", "texture")`));
    }

    PainterPlugin {
        onProjectAboutToSave: weaponFinish.save()
    }

    Component.onCompleted: {
        finishStyleBox.currentKeyChanged.connect(() => 
            internal.changeFinishStyle(finishStyleBox.currentKey)
        );
        weaponBox.currentKeyChanged.connect(() => {
            const w = weaponBox.currentKey;
            const path = `${internal.pluginPath()}/assets/textures/models/${w}`;
            try {
                weaponFinish.parameters["uBaseColor"].control.url = importTexture(`${path}/${w}_color.png`);
                weaponFinish.parameters["uBaseRough"].control.url = importTexture(`${path}/${w}_rough.png`);
                weaponFinish.parameters["uBaseSurface"].control.url = importTexture(`${path}/${w}_surface.png`);
                weaponFinish.parameters["uBaseMasks"].control.url = importTexture(`${path}/${w}_masks.png`);
                weaponFinish.parameters["uBaseCavity"].control.url = importTexture(`${path}/${w}_cavity.png`);
            } catch(err) { 
                internal.error(err.toString());
            }
        });
    }

    WeaponFinish {
        id: weaponFinish

        parameters: {
            "econitem":               { control: econitem,               prop: "filePath"     },
            "texturesFolder":         { control: texturesFolder,         prop: "filePath"     },
            "finishStyle":            { control: finishStyleBox,         prop: "currentKey"   },
            "weapon":                 { control: weaponBox,              prop: "currentKey"   },
            "wearRange":              { control: wearRange,              prop: "range"        },
            "texScale":               { control: texScale,               prop: "value"        },
            "texRotationRange":       { control: texRotation,            prop: "range"        },
            "texOffsetXRange":        { control: texOffsetX,             prop: "range"        },
            "texOffsetYRange":        { control: texOffsetY,             prop: "range"        },
            // Shader parameters
            "uLivePreview":           { control: enableLivePreview,      prop: "checked"      },
            "uPBRValidation":         { control: enablePBRValidation,    prop: "checked"      },
            "uWearAmt":               { control: wearAmount,             prop: "value"        },
            "uTexTransform":          { control: texTransform,           prop: "transform"    },
            "uIgnoreWeaponSizeScale": { control: ignoreWeaponSizeScale, prop: "checked"      },
            "uUsePearlMask":          { control: usePearlescentMask,     prop: "checked"      },
            "uPearlScale":            { control: pearlescentScale,       prop: "value"        },
            "uUseCustomRough":        { control: useRoughnessTexture,    prop: "checked"      },
            "uPaintRoughness":        { control: paintRoughness,         prop: "value"        },
            // dynamically generated components
            "uGrungeTex":             { control: null,                   prop: "url"          },
            "uScratchesTex":          { control: null,                   prop: "url"          },
            "uBaseColor":             { control: null,                   prop: "url"          },
            "uBaseRough":             { control: null,                   prop: "url"          },
            "uBaseSurface":           { control: null,                   prop: "url"          },
            "uBaseMasks":             { control: null,                   prop: "url"          },
            "uBaseCavity":            { control: null,                   prop: "url"          },
            "uCol0":                  { control: null,                   prop: "arrayColor"   },
            "uCol1":                  { control: null,                   prop: "arrayColor"   },
            "uCol2":                  { control: null,                   prop: "arrayColor"   },
            "uCol3":                  { control: null,                   prop: "arrayColor"   },
            "uUseCustomNormal":       { control: null,                   prop: "checked"      },
            "uUseCustomMasks":        { control: null,                   prop: "checked"      },
            "uUseCustomAOTex":        { control: null,                   prop: "checked"      }
        }
    }

    QtObject {
        id: texTransform

        property bool updating: false
        property var transform: [0.0, 0.0, 1.0, 0.0]

        onTransformChanged: update(() => {
            texOffsetX.value = transform[0];
            texOffsetY.value = transform[1];
            texScale.value = transform[2];
            texRotation.value = transform[3] * 180.0 / Math.PI;
        })

        function update(f) {
            if (!updating) {
                updating = true;
                f();
                updating = false;
            }
        }

        function sync() {
            update(() => {
                transform = [
                    texOffsetX.value, 
                    texOffsetY.value,
                    texScale.value, 
                    texRotation.value * Math.PI / 180.0
                ];
            });
        }
    }

    ColumnLayout {
        id: mainLayout
        width: root.width

        Rectangle {
            id: general
            color: Qt.rgba(1, 1, 1, 0.05)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.1)
            radius: 10
            Layout.fillWidth: true
            height: generalLayout.implicitHeight + generalLayout.anchors.margins * 2

            ColumnLayout {
                id: generalLayout
                spacing: 10
                anchors.fill: parent
                anchors.margins: 10
                
                Label {
                    font.bold: true
                    opacity: enabled ? 1.0 : 0.5
                    text: "Weapon Finish Settings"
                    color: AlgStyle.text.color.normal
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight + 10
                }

                RowLayout {
                    Layout.fillWidth: true
                        
                    SPButton {
                        text: "Import"
                        enabled: econitem.filePath != ""
                        icon.source: "./icons/import.png"
                        icon.width: 15
                        icon.height: 15
                        tooltip.text: "Import values from the .econitem file"
                        backgroundRect.color: "black"
                        backgroundRect.opacity: hovered ? 0.75 : 0.25

                        onClicked: internal.importWeaponFinishEconItem()
                    }

                    SPLabeled {
                        id: econitem
                        Layout.fillWidth: true
                        text: "Econitem File"

                        property string filePath: ""

                        onFilePathChanged: weaponFinish.updateEconItemPath(filePath)

                        Label {
                            clip: true
                            opacity: 0.5
                            elide: Text.ElideLeft
                            horizontalAlignment: Text.AlignLeft
                            text: econitem.filePath
                            color: AlgStyle.text.color.normal
                            Layout.fillWidth: true
                        }

                        SPButton {
                            text: "Select"
                            label.color: Qt.rgba(0.0, 0.0, 0.0, 0.75)
                            backgroundRect.color: "white"
                            backgroundRect.opacity: hovered ? 0.5 : 0.25

                            onClicked: econFileDialog.open()

                            SPFileDialog {
                                id: econFileDialog
                                title: "Select file"
                                folder: econitem.filePath.substring(econitem.filePath.lastIndexOf("/"))
                                nameFilters: [ "CS2 Econ Item (*.econitem)" ]
                                onAccepted: econitem.filePath = fileUrl.toString().substring(8);
                            }
                        }

                        SPButton {
                            text: "Show"
                            enabled: econitem.filePath != ""
                            tooltip.text: "Reveal in File Explorer"

                            onClicked: internal.showInExplorer(econitem.filePath)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                            
                    SPButton {
                        text: "Export"
                        enabled: texturesFolder.filePath !== ""
                        icon.source: "./icons/export.png"
                        icon.width: 15
                        icon.height: 15
                        tooltip.text: "Export Weapon Finish textures"
                        label.color: AlgStyle.text.color.normal
                        backgroundRect.color: "black"
                        backgroundRect.opacity: hovered ? 0.75 : 0.25

                        onClicked: internal.exportWeaponFinishTextures()
                    }
                    
                    SPLabeled { 
                        id: texturesFolder
                        Layout.fillWidth: true
                        text: "Textures Folder"

                        property string filePath: ""

                        onFilePathChanged: weaponFinish.updateTexturesFolderPath(filePath)

                        Label {
                            clip: true
                            opacity: 0.5
                            elide: Text.ElideLeft
                            horizontalAlignment: Text.AlignLeft
                            text: texturesFolder.filePath
                            color: AlgStyle.text.color.normal
                            Layout.fillWidth: true
                        }

                        SPButton {
                            text: "Select"
                            label.color: Qt.rgba(0.0, 0.0, 0.0, 0.75)
                            backgroundRect.color: "white"
                            backgroundRect.opacity: hovered ? 0.5 : 0.25
                            
                            onClicked: texturesFolderDialog.open()

                            SPFileDialog {
                                id: texturesFolderDialog
                                title: "Select folder"
                                selectFolder: true
                                folder: texturesFolder.filePath
                                onAccepted: texturesFolder.filePath = fileUrl.toString().substring(8);
                            }
                        }

                        SPButton {
                            text: "Show"
                            enabled: texturesFolder.filePath != ""
                            tooltip.text: "Reveal in File Explorer"

                            onClicked: internal.showInExplorer(texturesFolder.filePath)
                        }
                    }
                }

                SPSeparator { Layout.fillWidth: true }

                RowLayout {
                    Layout.fillWidth: true

                    SPButton {
                        id: enableLivePreview
                        text: "Live Preview"
                        checkable: true
                        Layout.fillWidth: true
                        contentAlignment: Qt.AlignCenter
                        backgroundRect.color: checked ? Qt.rgba(0.75, 0.75, 1.0) : Qt.rgba(0.5, 0.5, 0.5)
                        backgroundRect.opacity: hovered ? 0.25 : 0.15
                    }

                    SPButton {
                        id: enablePBRValidation
                        text: "PBR Validation"
                        checkable: true
                        Layout.fillWidth: true
                        contentAlignment: Qt.AlignCenter
                        backgroundRect.color: checked ? Qt.rgba(0.75, 0.75, 1.0) : Qt.rgba(0.5, 0.5, 0.5)
                        backgroundRect.opacity: hovered ? 0.25 : 0.15
                    }
                }

                SPLabeled {
                    id: weapon
                    text: "Weapon"
                    Layout.fillWidth: true

                    SPComboBox {
                        id: weaponBox
                        Layout.fillWidth: true
                        map: JSON.parse(internal.getWeaponList())
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
                        map: {
                            "so": "Solid Color",
                            "hy": "Hydrographic",
                            "sp": "Spray Paint",
                            "an": "Anodized",
                            "am": "Anodized Multicolored",
                            "aa": "Anodized Airbrushed",
                            "cu": "Custom Paint Job",
                            "aq": "Patina",
                            "gs": "Gunsmith"
                        }
                    }

                    Component.onCompleted: scopeWidth = Math.max(scopeWidth, weapon.scopeWidth)
                }
            }
        }

        SPGroup {
            id: baseTextures
            Layout.fillWidth: true
            toggled: false
            text: "Base Textures"

            Repeater {
                model: [
                    { param: "uGrungeTex",        text: "Grunge"            },
                    { param: "uScratchesTex",     text: "Wear"              },
                    { param: "uBaseColor",        text: "Base Color"        },
                    { param: "uBaseRough",        text: "Roughness"         },
                    { param: "uBaseMasks",        text: "Masks"             },
                    { param: "uBaseSurface",      text: "Surface"           },
                    { param: "uBaseCavity",       text: "Cavity"            }
                ]
                delegate: SPParameter {
                    property alias url: resourcePicker.url
                    property alias scopeWidth: resourceLabel.scopeWidth

                    SPLabeled {
                        id: resourceLabel
                        text: modelData.text

                        SPResourcePicker {
                            id: resourcePicker
                            Layout.fillWidth: true
                            filters: AlgResourcePicker.TEXTURE
                        }
                    }

                    onResetRequested: weaponFinish.resetParameter(modelData.param)
                }

                onItemAdded: (i, control) => {
                    weaponFinish.parameters[model[i].param].control = control;
                    baseTextures.scopeWidth = Math.max(baseTextures.scopeWidth, control.scopeWidth);
                    control.scopeWidth = Qt.binding(() => baseTextures.scopeWidth);
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
                id: common
                Layout.fillWidth: true
                text: "Common"

                property int seed: 0

                onSeedChanged: {
                    texOffsetX.value = MathUtils.mapNorm(MathUtils.random(seed + 2), texOffsetX.minValue, texOffsetX.maxValue);
                    texOffsetY.value = MathUtils.mapNorm(MathUtils.random(seed + 3), texOffsetY.minValue, texOffsetY.maxValue);
                    texRotation.value = MathUtils.mapNorm(MathUtils.random(seed + 4), texRotation.minValue, texRotation.maxValue);
                }

                SPLabeled {
                    text: "Seed"
                    enabled: enableLivePreview.checked
                    Layout.fillWidth: true

                    SPSeparator { Layout.fillWidth: true }

                    SPTextInput {
                        Layout.preferredWidth: 45
                        text: common.seed
                        validator: RegExpValidator { regExp: /^-?[0-9]*/ }
                        onEditingFinished: common.seed = MathUtils.clamp(parseInt(text), 0, 9999);
                    }

                    SPButton {
                        id: randomButton
                        text: "Random"
                        tooltip.text: "Generate random seed number"

                        onPressed: common.seed = Math.floor(Math.random() * 1000)
                    }
                }

                SPParameter {
                    SPSlider {
                        id: wearAmount
                        text: `Wear Amount (${
                            value < 0.07 ? "Factory New" : (
                            value < 0.15 ? "Minimal Wear" : (
                            value < 0.37 ? "Field Tested" : (
                            value < 0.44 ? "Well Worn" : 
                            "Battle Scarred")))
                        })`
                        from: wearRange.minValue.toFixed(2)
                        to: wearRange.maxValue.toFixed(2)
                        onValueChanged: wearRange.value = value
                    }
                    onResetRequested: weaponFinish.resetParameter("uWearAmt")
                }

                SPParameter {
                    SPSlider {
                        id: texScale
                        text: "Texture Scale"
                        from: -10
                        to: 10
                        onValueChanged: texTransform.sync()
                    }
                    onResetRequested: weaponFinish.resetParameter("texScale")
                }

                SPParameter {
                    SPButton {
                        id: ignoreWeaponSizeScale
                        text: "Ignore Weapon Size Scale"
                        Layout.fillWidth: true
                        checkable: true
                        tooltip.text: "For some finishes, the automatic scale adjustment per-weapon is not desired"
                        contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                    }
                    onResetRequested: weaponFinish.resetParameter("uIgnoreWeaponSizeScale")
                }
            }

            SPGroup {
                Layout.fillWidth: true
                text: "Texture Placement"

                SPParameter {
                    SPRangeSlider {
                        id: texRotation
                        text: "Texture Rotation"
                        from: -360
                        to: 360
                        onValueChanged: texTransform.sync()
                    }
                    onResetRequested: weaponFinish.resetParameter("texRotationRange")
                }

                SPParameter {
                    SPRangeSlider {
                        id: texOffsetX
                        text: "Texture Offset X"
                        from: -1
                        to: 1
                        onValueChanged: texTransform.sync()
                    }
                    onResetRequested: weaponFinish.resetParameter("texOffsetXRange")
                }

                SPParameter {
                    SPRangeSlider {
                        id: texOffsetY
                        text: "Texture Offset Y"
                        from: -1
                        to: 1
                        onValueChanged: texTransform.sync()
                    }
                    onResetRequested: weaponFinish.resetParameter("texOffsetYRange")
                }
            }

            SPGroup {
                id: colorGroup
                Layout.fillWidth: true
                text: "Color"
                visible: finishStyleBox.currentIndex != 6

                Repeater {
                    model: [
                        [
                            { text: "Base Metal", tooltip: "The metal before patina, revealed through scratches" }, 
                            { text: "Base Coat", tooltip: "Color that covers all paintable areas of the weapon" }
                        ], 
                        [
                            { text: "Patina Tint", tooltip: "Tint of the newly applied patina" }, 
                            { text: "Red Channel", tooltip: "Color to store in the Red Channel of the texture" }
                        ], 
                        [
                            { text: "Patina Wear", tooltip: "Tint of the aged patina" }, 
                            { text: "Green Channel", tooltip: "Color to store in the Green Channel of the texture" }
                        ], 
                        [
                            { text: "Grime", tooltip: "Color of the grime, oil accretion, or oxide that accumulates in cavities" }, 
                            { text: "Blue Channel", tooltip: "Color to store in the Blue Channel of the texture" }
                        ]
                    ]
                    delegate: SPParameter {
                        property alias scopeWidth: colorPickerWidget.scopeWidth
                        property alias arrayColor: colorPicker.arrayColor

                        SPLabeled {
                            id: colorPickerWidget
                            text: finishStyleBox.currentIndex > 6 ? modelData[0].text : modelData[1].text
                            SPColorButton { 
                                id: colorPicker
                                tooltip.text: finishStyleBox.currentIndex > 6 ? modelData[0].tooltip : modelData[1].tooltip
                            }
                        }
                        onResetRequested: weaponFinish.resetParameter(`uCol${index}`)
                    }

                    onItemAdded: (i, control) => {
                        colorGroup.scopeWidth = Math.max(colorGroup.scopeWidth, control.scopeWidth);
                        control.scopeWidth = Qt.binding(() => colorGroup.scopeWidth);
                        weaponFinish.parameters[`uCol${i}`].control = control;
                        weaponFinish.parameters[`uCol${i}`].control = control;
                    }
                }
            }

            SPGroup {
                Layout.fillWidth: true
                text: "Effects"

                SPParameter {
                    SPRangeSlider {
                        id: wearRange
                        text: "Wear Range"
                        minValue: 0.0
                        maxValue: 1.0
                        onValueChanged: wearAmount.value = value
                    }
                    onResetRequested: {
                        weaponFinish.resetParameter("wearRange"); 
                        weaponFinish.resetParameter("uWearAmt");
                    }
                }

                SPSeparator { Layout.fillWidth: true }

                SPParameter {
                    SPButton {
                        id: usePearlescentMask
                        text: "Custom Pearlescent Mask"
                        Layout.fillWidth: true
                        checkable: true
                        contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                    }
                    onResetRequested: weaponFinish.resetParameter("uUsePearlMask")
                }

                SPParameter {
                    SPSlider {
                        id: pearlescentScale
                        text: "Pearlescent Scale"
                        from: -6
                        to: 6
                    }
                    onResetRequested: weaponFinish.resetParameter("uPearlScale")
                }

                SPSeparator { Layout.fillWidth: true }

                SPParameter {
                    SPButton {
                        id: useRoughnessTexture
                        text: "Custom Roughness Texture"
                        Layout.fillWidth: true
                        checkable: true
                        contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                    }
                    onResetRequested: weaponFinish.resetParameter("uUseCustomRough")
                }
                    
                SPParameter {
                    visible: !useRoughnessTexture.checked
                    SPSlider {
                        id: paintRoughness
                        text: "Paint Roughness"
                        from: 0
                        to: 1
                    }
                    onResetRequested: weaponFinish.resetParameter("uPaintRoughness")
                }
            }

            SPGroup {
                id: advancedGroup
                text: "Advanced"
                toggled: false
                Layout.fillWidth: true

                Repeater {
                    model: [
                        { param: "uUseCustomNormal",    text: "Custom Normal Map"        },
                        { param: "uUseCustomMasks",     text: "Custom Material Mask"     },
                        { param: "uUseCustomAOTex",     text: "Custom Ambient Occlusion" }
                    ]
                    delegate: SPParameter {
                        property alias control: advancedControl

                        SPButton {
                            id: advancedControl
                            checkable: true
                            text: modelData.text
                            tooltip.text: `Whether to use ${text.toLowerCase()} or the weapon default one`
                            Layout.fillWidth: true
                            contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        onResetRequested: weaponFinish.resetParameter(modelData.param)
                    }

                    onItemAdded: (i, control) => {
                        weaponFinish.parameters[model[i].param].control = control.control;
                    }
                }
            }
        }
    }
}
