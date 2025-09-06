import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import Painter 1.0
import AlgWidgets 2.0
import "./SPWidgets"
import "./SPWidgets/math.js" as MathUtils
import "./random.mjs" as Random

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
        weaponFinish.parameters["uWearTex"].control.url = Plugin.importTexture(Plugin.asset("textures/wear.png").slice(5));
        weaponFinish.parameters["uGrungeTex"].control.url = Plugin.importTexture(Plugin.asset("textures/grunge.png").slice(5));
    }

    WeaponFinish {
        id: weaponFinish

        parameters: {
            "econitem":               { control: econitem,               prop: "filePath"     },
            "texturesFolder":         { control: texturesFolder,         prop: "filePath"     },
            "style":                  { control: styleBox,               prop: "currentKey"   },
            "uDebugChannel":          { control: debugChannel,           prop: "currentKey"   },
            "weapon":                 { control: weaponBox,              prop: "currentKey"   },
            "wearRange":              { control: wearRange,              prop: "range"        },
            "texScale":               { control: texScale,               prop: "value"        },
            "texRotationRange":       { control: texRotation,            prop: "range"        },
            "texOffsetXRange":        { control: texOffsetX,             prop: "range"        },
            "texOffsetYRange":        { control: texOffsetY,             prop: "range"        },
            "nmPBRRange":             { control: nmPBRRange,             prop: "range"        },
            "mPBRRange":              { control: mPBRRange,              prop: "range"        },
            // shader parameters
            "uLivePreview":           { control: enableLivePreview,      prop: "checked"      },
            "uPBRValidation":         { control: enablePBRValidation,    prop: "checked"      },
            "uPBRRanges":             { control: preview,              prop: "ranges"       },
            "uWearAmt":               { control: wearAmount,             prop: "value"        },
            "uBaseScale":             { control: weaponBox,              prop: "baseScale"    },
            "uTexTransform":          { control: texTransform,           prop: "transform"    },
            "uWearTransform":         { control: wearTransform,          prop: "transform"    },
            "uGrungeTransform":       { control: grungeTransform,        prop: "transform"    },
            "uIgnoreWeaponSizeScale": { control: ignoreWeaponSizeScale,  prop: "checked"      },
            "uPaintRough":            { control: paintRough,             prop: "value"        },
            "uPearlScale":            { control: pearlScale,             prop: "value"        },
            // dynamically generated components
            "uWearTex":               { control: null,                   prop: "url"          },
            "uGrungeTex":             { control: null,                   prop: "url"          },
            "uBaseColor":             { control: null,                   prop: "url"          },
            "uBaseRough":             { control: null,                   prop: "url"          },
            "uBaseSurface":           { control: null,                   prop: "url"          },
            "uBaseMasks":             { control: null,                   prop: "url"          },
            "uBaseCavity":            { control: null,                   prop: "url"          },
            "uCol0":                  { control: null,                   prop: "arrayColor"   },
            "uCol1":                  { control: null,                   prop: "arrayColor"   },
            "uCol2":                  { control: null,                   prop: "arrayColor"   },
            "uCol3":                  { control: null,                   prop: "arrayColor"   },
            "uUseCustomRough":        { control: null,                   prop: "checked"      },
            "uUsePearlMask":          { control: null,                   prop: "checked"      },
            "uUseCustomNormal":       { control: null,                   prop: "checked"      },
            "uUseCustomMasks":        { control: null,                   prop: "checked"      },
            "uUseCustomAOTex":        { control: null,                   prop: "checked"      }
        }
    }

    QtObject {
        id: texTransform

        property bool updating: false
        property var transform: [1.0, 0.0, 0.0, 0.0]

        onTransformChanged: update(() => {
            texScale.value = transform[0];
            texOffsetX.value = transform[1];
            texOffsetY.value = transform[2];
            texRotation.value = transform[3];
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
                    texScale.value, 
                    texOffsetX.value, 
                    texOffsetY.value,
                    texRotation.value
                ];
            });
        }
    }

    QtObject {
        id: wearTransform
        property var transform: [1.0, 0.0, 0.0, 0.0]
    }

    QtObject {
        id: grungeTransform
        property var transform: [1.0, 0.0, 0.0, 0.0]
    }

    ColumnLayout {
        anchors.fill: root
        anchors.margins: 10
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            SPButton {
                tooltip.text: "Create new project and set it up as Weapon Finish"
                contentAlignment: Qt.AlignCenter
                implicitWidth: 25
                implicitHeight: implicitWidth
                icon.source: Plugin.asset("icons/add.png")
                icon.width: implicitWidth * 0.75
                icon.height: implicitHeight * 0.75
                Layout.alignment: Qt.AlignCenter

                onClicked: Plugin.initWeaponFinish(true)
            }

            SPButton {
                enabled: root.projectKind > 0
                tooltip.text: "Set up opened project as Weapon Finish"
                contentAlignment: Qt.AlignCenter
                implicitWidth: 25
                implicitHeight: implicitWidth
                icon.source: Plugin.asset("icons/settings.png")
                icon.width: implicitWidth * 0.75
                icon.height: implicitHeight * 0.75
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
                enabled: root.projectKind == 2 && preview.ready
                contentAlignment: Qt.AlignCenter
                implicitWidth: 25
                implicitHeight: implicitWidth
                icon.source: Plugin.asset("icons/eye.png")
                icon.width: implicitWidth * 0.75
                icon.height: implicitHeight * 0.75
                tooltip.text: `${checked ? "Disable" : "Enable"} Livew Previewing of the Weapon Finish (G)`
                background.color: checked ? "#095aba" : "transparent"
                background.opacity: hovered ? 1.0 : 0.75
                
                onClicked: if (enabled) checked = !checked

                onCheckedChanged: {
                    if (!preview.ready)
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
            spacing: 10

            SPGroup {
                id: preview
                text: "Preview"
                color: "#333333"
                gradient: undefined
                radius: 15
                spacing: 10
                Layout.fillWidth: true
                header: Text {
                    text: "Missing textures!"
                    color: Qt.rgba(0.85, 0.15, 0.15)
                    visible: !preview.ready
                    rightPadding: 5
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }

                property bool updating: false
                property var ranges: [50, 245, 106, 255]

                property real labelScopeWidth: 0.0
                readonly property bool ready: {
                    for (let i = 0; i < textureRepeater.count; ++i) {
                        const item = textureRepeater.itemAt(i);
                        if (!item || item.url === "")
                            return false;
                    }
                    return true;
                }

                function update(f) {
                    if (!updating) {
                        updating = true;
                        f();
                        updating = false;
                    }
                }

                function sync() {
                    update(() => {
                        ranges = [
                            nmPBRRange.minValue, 
                            nmPBRRange.maxValue,
                            mPBRRange.minValue, 
                            mPBRRange.maxValue
                        ];
                    });
                }

                onRangesChanged: update(() => {
                    nmPBRRange.minValue = ranges[0];
                    nmPBRRange.maxValue = ranges[1];
                    mPBRRange.minValue = ranges[2];
                    mPBRRange.maxValue = ranges[3];
                })

                onReadyChanged: enableLivePreview.checked = ready

                SPLabeled {
                    enabled: enableLivePreview.checked
                    opacity: enabled ? 1.0 : 0.5
                    text: "Debug Channel"
                    Layout.fillWidth: true

                    SPComboBox {
                        id: debugChannel
                        Layout.fillWidth: true
                        map: {
                            0: "Combined", 
                            1: "Wear",
                            2: "Albedo", 
                            3: "Roughness",
                            4: "Pearl factor"
                        }
                    }
                }
                
                SPLabeled {
                    text: "PBR Ranges"
                    label.font.bold: true
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    SPSeparator { Layout.fillWidth: true }
                }

                SPParameter {
                    SPRangeSlider {
                        id: nmPBRRange
                        text: "Non-metallic:"
                        from: 0
                        to: 255
                        precision: 0
                        pickValue: false
                        onRangeChanged: preview.sync()
                    }
                    onResetRequested: weaponFinish.resetParameter("nmPBRRange")
                }

                SPParameter {
                    SPRangeSlider {
                        id: mPBRRange
                        text: "Metallic:"
                        from: 0
                        to: 255
                        precision: 0
                        pickValue: false
                        onRangeChanged: preview.sync()
                    }
                    onResetRequested: weaponFinish.resetParameter("mPBRRange")
                }

                SPLabeled {
                    text: "Base Textures"
                    label.font.bold: true
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    SPSeparator { Layout.fillWidth: true }
                }

                Repeater {
                    id: textureRepeater
                    model: [
                        { param: "uWearTex",          text: "Wear"              },
                        { param: "uGrungeTex",        text: "Grunge"            },
                        { param: "uBaseColor",        text: "Base Color"        },
                        { param: "uBaseRough",        text: "Roughness"         },
                        { param: "uBaseMasks",        text: "Masks"             },
                        { param: "uBaseSurface",      text: "Surface"           },
                        { param: "uBaseCavity",       text: "Cavity"            }
                    ]

                    delegate: SPLabeled {
                        text: modelData.text

                        property alias url: resourcePicker.url

                        SPResourcePicker {
                            id: resourcePicker
                            Layout.fillWidth: true
                            filters: AlgResourcePicker.TEXTURE
                        }
                    }

                    onItemAdded: (i, control) => {
                        weaponFinish.parameters[model[i].param].control = control;
                        preview.labelScopeWidth = Math.max(preview.labelScopeWidth, control.scopeWidth);
                        control.scopeWidth = Qt.binding(() => preview.labelScopeWidth);
                    }
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

                property int seed: 0

                onSeedChanged: {
                    const r = new Random.Stream(seed);
                    texTransform.transform = [
                        texScale.value, 
                        r.randomFloat(texOffsetX.minValue, texOffsetX.maxValue),
                        1.0 - r.randomFloat(texOffsetY.minValue, texOffsetY.maxValue),
                        r.randomFloat(texRotation.minValue, texRotation.maxValue)
                    ];
                    wearTransform.transform = [
                        r.randomFloat(1.6, 1.8),
                        r.randomFloat(0.0, 1.0),
                        1.0 - r.randomFloat(0.0, 1.0),
                        r.randomFloat(0.0, 360.0)
                    ];
                    grungeTransform.transform = [
                        r.randomFloat(1.6, 1.8),
                        r.randomFloat(0.0, 1.0),
                        1.0 - r.randomFloat(0.0, 1.0),
                        r.randomFloat(0.0, 360.0)
                    ];
                }

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
                        map: {
                            const weaponMap = {};
                            for (const w of Object.keys(weapons))
                                weaponMap[w] = weapons[w].name;
                            weaponMap;
                        }

                        property var weapons: JSON.parse(Plugin.getWeapons())
                        property real baseScale: 1.0

                        onCurrentKeyChanged: {
                            const w = weapons[currentKey];
                            let b = w.length / 36 * Math.sqrt(w.uv_scale);
                            baseScale = b;
                        }
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
                            "cu": "Custom Paint Job",
                            "aq": "Patina",
                            "gs": "Gunsmith"
                        }
                    }

                    Component.onCompleted: scopeWidth = Math.max(scopeWidth, weapon.scopeWidth)
                }

                SPLabeled {
                    text: "Seed"
                    enabled: enableLivePreview.checked
                    Layout.fillWidth: true

                    SPSeparator { Layout.fillWidth: true }

                    SPTextInput {
                        Layout.preferredWidth: 45
                        text: general.seed
                        validator: SPRegExprValidator { expr: /^-?[0-9]*/ }
                        onEditingFinished: general.seed = MathUtils.clamp(parseInt(text), 0, 1000);
                    }

                    SPButton {
                        id: randomButton
                        text: "Random"
                        tooltip.text: "Generate random seed number"

                        onPressed: general.seed = Math.floor(Math.random() * 1000)
                    }
                }

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
            }

            ScrollView {
                clip: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                leftPadding: 10
                topPadding: 10
                bottomPadding: 10
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    enabled: enableLivePreview.checked
                    opacity: enabled ? 1.0 : 0.5
                    width: weaponFinishSettings.width - 20
                    spacing: 10

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

                        SPParameter {
                            // visible: !useRoughnessTexture.checked
                            SPSlider {
                                id: paintRough
                                text: "Paint Roughness"
                                from: 0
                                to: 1
                            }
                            onResetRequested: weaponFinish.resetParameter("uPaintRough")
                        }

                        SPParameter {
                            SPSlider {
                                id: pearlScale
                                text: "Pearlescent Scale"
                                from: -6
                                to: 6
                            }
                            onResetRequested: weaponFinish.resetParameter("uPearlScale")
                        }
                    }

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Transformation"

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

                        SPParameter {
                            SPSlider {
                                id: texScale
                                text: "Scale"
                                from: -10
                                to: 10
                                onValueChanged: texTransform.sync()
                            }
                            onResetRequested: weaponFinish.resetParameter("texScale")
                        }

                        SPParameter {
                            SPRangeSlider {
                                id: texRotation
                                text: "Rotation"
                                from: -360
                                to: 360
                                onValueChanged: texTransform.sync()
                            }
                            onResetRequested: weaponFinish.resetParameter("texRotationRange")
                        }

                        SPParameter {
                            SPRangeSlider {
                                id: texOffsetX
                                text: "Offset X"
                                from: -1
                                to: 1
                                onValueChanged: texTransform.sync()
                            }
                            onResetRequested: weaponFinish.resetParameter("texOffsetXRange")
                        }

                        SPParameter {
                            SPRangeSlider {
                                id: texOffsetY
                                text: "Offset Y"
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
                        text: "Colors"
                        visible: styleBox.currentIndex != 0 // !CU

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
                        text: "Texture Usage"

                        Repeater {
                            model: [
                                { param: "uUseCustomRough",    text: "Custom Roughness Texture" },
                                { param: "uUsePearlMask",      text: "Custom Pearlescent Mask"  },
                                { param: "uUseCustomNormal",   text: "Custom Normal Map"        },
                                { param: "uUseCustomMasks",    text: "Custom Material Mask"     },
                                { param: "uUseCustomAOTex",    text: "Custom Ambient Occlusion" }
                            ]
                            delegate: SPParameter {
                                property alias control: usageControl

                                SPButton {
                                    id: usageControl
                                    checkable: true
                                    text: modelData.text
                                    tooltip.text: `Whether to use ${text.toLowerCase()}`
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
