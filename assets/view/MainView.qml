import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import Painter 1.0
import AlgWidgets 2.0
import "./SPWidgets"
import "./SPWidgets/math.js" as MathUtils

Rectangle {
    id: root
    color: "#262626"

    // 0 - closed
    // 1 - regular project
    // 2 - weapon finish
    property int projectKind: 0

    Connections {
        target: Plugin

        function onProjectKindChanged(projectKind) {
            root.projectKind = projectKind;
            if (projectKind == 2) {
                weaponFinish.loadParams();
                const c = weaponFinish.parameters["econitem"];
                if (c !== undefined) {
                    const p = c.control[c.prop];
                    if (p !== undefined) {
                        const f = p.substring(p.replace("\\", "/").lastIndexOf("/"));
                        const n = f.substring(1, f.lastIndexOf("."));
                        if (n !== "") {
                            finishName.text = `#${n.toUpperCase()}`;
                            return;
                        }
                    }
                }
            }
            finishName.text = "#UNKNOWN";
        }

        function onProjectAboutToSave() {
            weaponFinish.syncEcon();
        }

        function onStyleReady() {
            weaponFinish.syncShader();
        }

        function onPluginAboutToClose() {
            weaponFinish.dump();
        }
    }

    WeaponFinish {
        id: weaponFinish

        parameters: {
            "econitem":               { control: econitem,               prop: "filePath"     },
            "texturesFolder":         { control: texturesFolder,         prop: "filePath"     },
            "style":                  { control: styleBox,               prop: "currentKey"   },
            "weapon":                 { control: weaponBox,              prop: "currentKey"   },
            "wearRange":              { control: wearRange,              prop: "range"        },
            "texScale":               { control: texScale,               prop: "value"        },
            "texRotationRange":       { control: texRotation,            prop: "range"        },
            "texOffsetXRange":        { control: texOffsetX,             prop: "range"        },
            "texOffsetYRange":        { control: texOffsetY,             prop: "range"        },
            // shader parameters
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

    ColumnLayout {
        anchors.fill: root
        anchors.margins: 10
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            SPButton {
                tooltip.text: "Create new project and set it up as Weapon Finish"
                icon.source: Plugin.asset("icons/add.png")
                icon.width: 18
                icon.height: 18
                Layout.alignment: Qt.AlignCenter

                onClicked: Plugin.initWeaponFinish(true)
            }

            SPButton {
                enabled: root.projectKind > 0
                tooltip.text: "Set up opened project as Weapon Finish"
                icon.source: Plugin.asset("icons/settings.png")
                icon.width: 18
                icon.height: 18
                Layout.alignment: Qt.AlignCenter

                onClicked: Plugin.initWeaponFinish(false)
            }

            SPSeparator { Layout.fillWidth: true }

            Text {
                id: finishName
                text: "#UNKNOWN"
                Layout.maximumWidth: 150
                elide: Text.ElideRight
                color: AlgStyle.text.color.normal
                font.bold: true
            }

            SPSeparator { Layout.fillWidth: true }

            SPButton {
                id: enableLivePreview
                enabled: root.projectKind == 2 && baseTextures.ready
                contentAlignment: Qt.AlignCenter
                implicitWidth: 25
                implicitHeight: implicitWidth
                icon.source: Plugin.asset("icons/eye.png")
                icon.width: implicitWidth * 0.75
                icon.height: implicitHeight * 0.75
                tooltip.text: `${checked ? "Disable" : "Enable"} Livew Previewing of the Weapon Finish (V)`
                background.color: checked ? "#095aba" : "transparent"
                background.opacity: hovered ? 1.0 : 0.75
                
                onClicked: if (enabled) checked = !checked

                onCheckedChanged: {
                    if (!baseTextures.ready)
                        checked = false;
                }

                Shortcut {
                    sequence: "G"
                    onActivated: if (enableLivePreview.enabled) enableLivePreview.checked = !enableLivePreview.checked
                }
            }

            SPButton {
                id: enablePBRValidation
                enabled: root.projectKind == 2 && enableLivePreview.checked
                contentAlignment: Qt.AlignCenter
                implicitWidth: 25
                implicitHeight: implicitWidth
                icon.source: Plugin.asset("icons/validation.png")
                icon.width: implicitWidth * 0.75
                icon.height: implicitHeight * 0.75
                tooltip.text: `${checked ? "Disable" : "Enable"} PBR validation of the Weapon Finish (V)`
                background.color: checked ? "#095aba" : "transparent"
                background.opacity: hovered ? 1.0 : 0.75
                
                onClicked: if (enabled) checked = !checked
                
                Shortcut {
                    sequence: "V"
                    onActivated: if (enablePBRValidation.enabled) enablePBRValidation.checked = !enablePBRValidation.checked
                }
            }
        }

        ColumnLayout {
            id: weaponFinishSettings
            Layout.minimumWidth: 350
            Layout.fillWidth: true
            Layout.fillHeight: true
            enabled: root.projectKind == 2
            opacity: enabled ? 1.0 : 0.5
            spacing: 0
            
            Component.onCompleted: {
                weaponFinish.connect();
                styleBox.currentKeyChanged.connect(() => {
                    if (root.projectKind == 2) 
                        Plugin.updateStyle(styleBox.currentKey);
                });
                weaponBox.currentKeyChanged.connect(() => {
                    if (root.projectKind == 2) 
                        weaponFinish.updateWeapon(weaponBox.currentKey);
                });
                weaponFinish.parameters["uGrungeTex"].control.url = Plugin.importTexture(Plugin.asset("textures/grunge.tga").slice(5));
                weaponFinish.parameters["uScratchesTex"].control.url = Plugin.importTexture(Plugin.asset("textures/scratches.png").slice(5));
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

            SPGroup {
                id: general
                text: "General"
                color: "#333333"
                gradient: undefined
                radius: 15
                spacing: 10
                Layout.fillWidth: true

                SPLabeled {
                    id: econitem
                    text: "Econitem file"
                    Layout.fillWidth: true
                    
                    property string filePath: ""

                    onFilePathChanged: Plugin.updateEconPath(filePath)

                    Component.onCompleted: scopeWidth = Math.max(scopeWidth, texturesFolder.scopeWidth)

                    SPButton {
                        text: "Import"
                        enabled: econitem.filePath != ""
                        tooltip.text: "Import values from the .econitem file"
                        icon.source: Plugin.asset("icons/import.png")
                        icon.width: 15
                        icon.height: 15
                        background.color: hovered ? Qt.rgba(0, 0, 0, 0.75) : Qt.rgba(0, 0, 0, 0.25)

                        onClicked: {
                            Plugin.importWeaponFinishEcon();
                            weaponFinish.loadParams();
                        }
                    }

                    Text {
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

                        onClicked: econFileDialog.show(econitem.filePath)

                        SPFileDialog {
                            id: econFileDialog
                            title: "Select file"
                            nameFilters: [ "CS2 Econ Item (*.econitem)" ]
                            onAccepted: econitem.filePath = fileUrl.toString().substring(8);
                        }
                    }

                    SPButton {
                        text: "Show"
                        enabled: econitem.filePath != ""
                        tooltip.text: "Show in Explorer"

                        onClicked: Plugin.showInExplorer(econitem.filePath)
                    }
                }

                SPLabeled {
                    id: texturesFolder
                    text: "Textures Folder"
                    Layout.fillWidth: true
                            
                    property string filePath: ""

                    onFilePathChanged: Plugin.updateTexturesFolderPath(filePath)

                    Component.onCompleted: scopeWidth = Math.max(scopeWidth, econitem.scopeWidth)

                    SPButton {
                        text: "Export"
                        enabled: texturesFolder.filePath !== ""
                        icon.source: Plugin.asset("icons/export.png")
                        icon.width: 15
                        icon.height: 15
                        tooltip.text: "Export Weapon Finish textures"
                        background.color: hovered ? Qt.rgba(0, 0, 0, 0.75) : Qt.rgba(0, 0, 0, 0.25)

                        onClicked: Plugin.exportWeaponFinishTextures()
                    }
                    
                    Text {
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
                        
                        onClicked: texturesFolderDialog.show(texturesFolder.filePath)

                        SPFileDialog {
                            id: texturesFolderDialog
                            title: "Select folder"
                            selectFolder: true
                            onAccepted: texturesFolder.filePath = fileUrl.toString().substring(8);
                        }
                    }

                    SPButton {
                        text: "Show"
                        enabled: texturesFolder.filePath != ""
                        tooltip.text: "Show in Explorer"

                        onClicked: Plugin.showInExplorer(texturesFolder.filePath)
                    }
                }

                SPSeparator { Layout.fillWidth: true }

                SPLabeled {
                    id: weapon
                    text: "Weapon"
                    Layout.fillWidth: true

                    SPComboBox {
                        id: weaponBox
                        Layout.fillWidth: true
                        map: JSON.parse(Plugin.getWeaponList())
                    }

                    Component.onCompleted: scopeWidth = Math.max(scopeWidth, style.scopeWidth)
                }

                SPLabeled {
                    id: style
                    text: "Finish Style"
                    Layout.fillWidth: true

                    SPComboBox {
                        id: styleBox
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

                SPGroup {
                    id: baseTextures
                    Layout.fillWidth: true
                    toggled: false
                    text: "Base Textures"
                    header: Text {
                        text: "Missing textures!"
                        color: Qt.rgba(0.85, 0.15, 0.15)
                        visible: !baseTextures.ready
                        rightPadding: 5
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    readonly property bool ready: {
                        for (let i = 0; i < textureRepeater.count; ++i) {
                            const item = textureRepeater.itemAt(i);
                            if (!item || item.url === "")
                                return false;
                        }
                        return true;
                    }

                    property real labelScopeWidth: 0.0

                    onReadyChanged: enableLivePreview.checked = ready

                    Repeater {
                        id: textureRepeater
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

                            onResetRequested: weaponFinish.resetParameter(modelData.param)

                            SPLabeled {
                                id: resourceLabel
                                text: modelData.text

                                SPResourcePicker {
                                    id: resourcePicker
                                    Layout.fillWidth: true
                                    filters: AlgResourcePicker.TEXTURE
                                }
                            }
                        }

                        onItemAdded: (i, control) => {
                            weaponFinish.parameters[model[i].param].control = control;
                            baseTextures.labelScopeWidth = Math.max(baseTextures.labelScopeWidth, control.scopeWidth);
                            control.scopeWidth = Qt.binding(() => baseTextures.labelScopeWidth);
                        }
                    }
                }
            }

            ScrollView {
                clip: true
                enabled: enableLivePreview.checked
                layer.enabled: true
                opacity: enabled ? 1.0 : 0.5
                Layout.fillWidth: true
                Layout.fillHeight: true
                leftPadding: 10
                topPadding: 10
                bottomPadding: 10
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    width: weaponFinishSettings.width - 20
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
                                validator: SPRegExprValidator { expr: /^-?[0-9]*/ }
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
                        visible: styleBox.currentIndex != 6

                        property real labelScopeWidth: 0.0

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
                                Layout.fillWidth: true

                                property alias scopeWidth: colorPickerWidget.scopeWidth
                                property alias arrayColor: colorPicker.arrayColor

                                SPLabeled {
                                    id: colorPickerWidget
                                    Layout.fillWidth: true
                                    text: styleBox.currentIndex > 6 ? modelData[0].text : modelData[1].text
                                    SPColorButton { 
                                        id: colorPicker
                                        Layout.fillWidth: true
                                        tooltip.text: styleBox.currentIndex > 6 ? modelData[0].tooltip : modelData[1].tooltip
                                    }
                                }
                                onResetRequested: weaponFinish.resetParameter(`uCol${index}`)
                            }

                            onItemAdded: (i, control) => {
                                colorGroup.labelScopeWidth = Math.max(colorGroup.labelScopeWidth, control.scopeWidth);
                                control.scopeWidth = Qt.binding(() => colorGroup.labelScopeWidth);
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
    }
}
