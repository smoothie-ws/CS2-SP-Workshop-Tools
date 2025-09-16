import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import Painter 1.0
import AlgWidgets 2.0
import "./SPWidgets"
import "./random.mjs" as Random
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

    Component.onCompleted: {
        weaponFinish.connect();
        styleBox.currentKeyChanged.connect(() => {
            if (root.projectKind == 2) 
                Plugin.updateStyle(styleBox.currentKey, externMode.checked);
        });
        externMode.checkedChanged.connect(() => {
            if (root.projectKind == 2) 
                Plugin.updateStyle(styleBox.currentKey, externMode.checked);
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
            "externMode":             { control: externMode,             prop: "checked"      },
            "style":                  { control: styleBox,               prop: "currentKey"   },
            "weapon":                 { control: weaponBox,              prop: "currentKey"   },
            "econitem":               { control: econitem,               prop: "filePath"     },
            "texturesFolder":         { control: texturesFolder,         prop: "filePath"     },
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
            "uDebugChannel":          { control: debugChannel,           prop: "currentKey"   },
            "uPBRRanges":             { control: pbrRanges,              prop: "ranges"       },
            "uWearAmt":               { control: wearAmount,             prop: "value"        },
            "uBaseScale":             { control: weaponBox,              prop: "baseScale"    },
            "uTexTransform":          { control: texTransform,           prop: "transform"    },
            "uWearTransform":         { control: wearTransform,          prop: "transform"    },
            "uGrungeTransform":       { control: grungeTransform,        prop: "transform"    },
            "uIgnoreWeaponSizeScale": { control: ignoreWeaponSizeScale,  prop: "checked"      },
            "uUseRoughByColor":       { control: useRoughByCol,          prop: "checked"      },
            "uUseCustomRough":        { control: useRoughTex,            prop: "checked"      },
            "uUsePearlMask":          { control: usePearlMask,           prop: "checked"      },
            "uUseCustomNormal":       { control: useNormalMap,           prop: "checked"      },
            "uUseCustomMasks":        { control: useMatMasks,            prop: "checked"      },
            "uUseCustomAOTex":        { control: useAOTex,               prop: "checked"      },
            "uPatternColor":          { control: patternTex,             prop: "url"          },
            "uPatternRough":          { control: useRoughTex,            prop: "url"          },
            "uPatternPearl":          { control: usePearlMask,           prop: "url"          },
            "uPatternNormal":         { control: useNormalMap,           prop: "url"          },
            "uPatternMasks":          { control: useMatMasks,            prop: "url"          },
            "uPatternAO":             { control: useAOTex,               prop: "url"          },
            "uSprayBlend":            { control: sprayBlend,             prop: "array"        },
            "uPaintRough":            { control: paintRough,             prop: "value"        },
            "uPearlScale":            { control: pearlScale,             prop: "value"        },
            "uPaintRoughNum":         { control: paintRoughNum,          prop: "array"        },
            "uPaintMetalNum":         { control: paintMetalNum,          prop: "array"        },
            "uPaintDurabilityNum":    { control: paintDurabilityNum,     prop: "array"        },
            // dynamically generated components
            "uBaseColor":             { control: null,                   prop: "url"          },
            "uBaseRough":             { control: null,                   prop: "url"          },
            "uBaseNormal":            { control: null,                   prop: "url"          },
            "uBaseMasks":             { control: null,                   prop: "url"          },
            "uBaseCavity":            { control: null,                   prop: "url"          },
            "uWearTex":               { control: null,                   prop: "url"          },
            "uGrungeTex":             { control: null,                   prop: "url"          },
            "uCol0":                  { control: null,                   prop: "arrayColor"   },
            "uCol1":                  { control: null,                   prop: "arrayColor"   },
            "uCol2":                  { control: null,                   prop: "arrayColor"   },
            "uCol3":                  { control: null,                   prop: "arrayColor"   }
        }
    }

    component TextureFetcher: ColumnLayout {
        id: fetcher

        required property string text

        property alias checked: toggler.checked
        property alias url: picker.url

        SPButton {
            id: toggler
            checkable: true
            text: `Use ${fetcher.text}`
            tooltip.text: `Whether to ${text.toLowerCase()}`
            Layout.fillWidth: true
        }
        
        SPLabeled {
            text: fetcher.text
            visible: fetcher.checked && externMode.checked

            SPResourcePicker {
                id: picker
                Layout.fillWidth: true
                filters: AlgResourcePicker.TEXTURE
            }
        }
    }

    component MultiSlider: ColumnLayout {
        id: multi
        
        required property string paramId
        required property string paramName
        
        property alias model: rep.model
        property alias array: lock.array
        
        SPLock {
            id: lock
            property var array: []
        }

        Component.onCompleted: arrayChanged.connect(() => lock.update(() => {
            for (var i = 0; i < rep.model.length; i++)
                rep.itemAt(i).control.value = array[i];
        }))
        
        Repeater {
            id: rep
            model: []
            delegate: SPParameter {
                Layout.fillWidth: true

                property alias control: control

                SPSlider {
                    id: control
                    text: `${multi.paramName} ${modelData}`
                    from: 0.0
                    to: 1.0

                    onValueChanged: lock.update(() => {
                        var arr = lock.array;
                        arr[index] = value;
                        lock.array = arr;
                    })
                }

                onResetRequested: {
                    var param = JSON.parse(Plugin.getDefaultWeaponFinishParameter(multi.paramId));
                    if (param == null)
                        return;
                    var value = [index];
                    if (value == undefined)
                        return;
                    control.value = value;
                }
            }
            
            onItemAdded: (i, item) => array.splice(i, 0, 0.0)
            onItemRemoved: (i, item) => array.remove(i)
        }
    }
    
    SPLock {
        id: texTransform

        property var transform: [1.0, 0.0, 0.0, 0.0]

        onTransformChanged: update(() => {
            texScale.value = transform[0];
            texOffsetX.value = transform[1];
            texOffsetY.value = transform[2];
            texRotation.value = transform[3];
        })

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
                enabled: root.projectKind == 2 && baseTextures.ready
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
            spacing: 10

            SPGroup {
                text: "Preview"
                color: "#333333"
                toggled: false
                gradient: undefined
                radius: 15
                spacing: 10
                Layout.fillWidth: true
                header: Text {
                    text: "Missing textures!"
                    color: Qt.rgba(0.85, 0.15, 0.15)
                    visible: !baseTextures.ready
                    rightPadding: 5
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }

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
                            4: "Pearlescence"
                        }
                    }
                }

                SPButton {
                    id: externMode
                    checkable: true
                    text: "External Mode"
                    tooltip.text: "Use external pattern textures instead of project channels"
                    Layout.fillWidth: true
                }

                SPGroup {
                    id: pbrRanges
                    text: "PBR Ranges"
                    Layout.fillWidth: true

                    property bool updating: false
                    property var ranges: [50, 245, 106, 255]

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

                    SPParameter {
                        SPRangeSlider {
                            id: nmPBRRange
                            text: "Non-metallic:"
                            from: 0
                            to: 255
                            precision: 0
                            pickValue: false
                            onRangeChanged: pbrRanges.sync()
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
                            onRangeChanged: pbrRanges.sync()
                        }
                        onResetRequested: weaponFinish.resetParameter("mPBRRange")
                    }
                }

                SPGroup {
                    id: baseTextures
                    toggled: false
                    text: "Base Textures"
                    Layout.fillWidth: true

                    property real labelScopeWidth: 0.0
                    readonly property bool ready: {
                        for (let i = 0; i < textureRepeater.count; ++i) {
                            const item = textureRepeater.itemAt(i);
                            if (!item || item.url === "")
                                return false;
                        }
                        if (externMode.checked) {
                            if (patternTex.url === "" || patternTex.url === null)
                                return false;
                            for (const p of ["Rough", "Pearl", "Normal", "Masks", "AO"]) {
                                const c = weaponFinish.parameters[`uPattern${p}`].control;
                                if (c.checked && (c.url === "" || c.url === null))
                                    return false;
                            }
                        }
                        return true;
                    }

                    onReadyChanged: enableLivePreview.checked = ready

                    Repeater {
                        id: textureRepeater
                        model: [
                            { param: "uWearTex",          text: "Wear"              },
                            { param: "uGrungeTex",        text: "Grunge"            },
                            { param: "uBaseColor",        text: "Base Color"        },
                            { param: "uBaseRough",        text: "Roughness"         },
                            { param: "uBaseMasks",        text: "Masks"             },
                            { param: "uBaseNormal",       text: "Normal"            },
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
                            baseTextures.labelScopeWidth = Math.max(baseTextures.labelScopeWidth, control.scopeWidth);
                            control.scopeWidth = Qt.binding(() => baseTextures.labelScopeWidth);
                        }
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
                            let b = Math.sqrt(w.uv_scale);
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
                bottomPadding: 10
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    width: weaponFinishSettings.width - 20
                    spacing: 10

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Common"

                        SPLabeled {
                            id: patternTex
                            visible: ["hy", "sp", "am", "aa", "cu", "aq", "gs"].includes(styleBox.currentKey) && externMode.checked
                            text: ["hy", "sp", "am", "aa"].includes(styleBox.currentKey) ? "Pattern Mask" : "Albedo Texture"

                            property alias url: patternTexPicker.url

                            SPResourcePicker {
                                id: patternTexPicker
                                Layout.fillWidth: true
                                filters: AlgResourcePicker.TEXTURE
                            }
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
                        id: colorGroup
                        Layout.fillWidth: true
                        text: "Colors"
                        visible: styleBox.currentKey != "cu"

                        property real labelScopeWidth: 0.0

                        TextureFetcher {
                            id: useColMask
                            text: "Paint-By-Number Mask"
                            visible: ["so", "hy", "sp", "an", "am", "aa"].includes(styleBox.currentKey)
                            Layout.fillWidth: true

                            SPLock {
                                Component.onCompleted: {
                                    useColMask.checkedChanged.connect(() => update(() => useMatMasks.checked = useColMask.checked));
                                    useMatMasks.checkedChanged.connect(() => update(() => useColMask.checked = useColMask.checked));
                                }
                            }
                        }

                        Repeater {
                            model: [
                                [
                                    { text: "Base Metal", tooltip: "The metal before patina, revealed through scratches" }, 
                                    { text: "Base Coat", tooltip: "Color that covers all paintable areas of the weapon" }
                                ], 
                                [
                                    { text: "Patina Tint", tooltip: "Tint of the newly applied patina" }, 
                                    { text: "Red Mask", tooltip: "Color to store in the Red Channel of the texture" }
                                ], 
                                [
                                    { text: "Patina Wear", tooltip: "Tint of the aged patina" }, 
                                    { text: "Green Mask", tooltip: "Color to store in the Green Channel of the texture" }
                                ], 
                                [
                                    { text: "Grime", tooltip: "Color of the grime, oil accretion, or oxide that accumulates in cavities" }, 
                                    { text: "Blue Mask", tooltip: "Color to store in the Blue Channel of the texture" }
                                ]
                            ]
                            delegate: SPParameter {
                                visible: styleBox.currentKey != "an" || index == 0
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
                                weaponFinish.parameters[`uCol${i}`].control = control;
                                colorGroup.labelScopeWidth = Math.max(colorGroup.labelScopeWidth, control.scopeWidth);
                                control.scopeWidth = Qt.binding(() => colorGroup.labelScopeWidth);
                            }
                        }
                    }

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Texture Placement"

                        MultiSlider {
                            id: sprayBlend
                            visible: styleBox.currentKey == "sp"
                            model: ["X", "Y"]
                            paramId: "uSprayBlend"
                            paramName: "Spray Blend"
                            width: parent.width
                        }

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
                        Layout.fillWidth: true
                        text: "Materials"

                        TextureFetcher {
                            id: useRoughTex
                            text: "Roughness Texture"
                            visible: !useRoughByCol.visible || (useRoughByCol.visible && !useRoughByCol.checked)
                            Layout.fillWidth: true
                        }

                        SPButton {
                            id: useRoughByCol
                            visible: ["so", "hy", "sp"].includes(styleBox.currentKey) && !useRoughTex.checked
                            checkable: true
                            text: "Use Roughness By Color"
                            tooltip.text: `Whether to ${text.toLowerCase()}`
                            Layout.fillWidth: true
                        }

                        MultiSlider {
                            id: paintRoughNum
                            visible: useRoughByCol.visible && useRoughByCol.checked
                            model: ["X", "Y", "Z", "W"]
                            paramId: "uPaintRough"
                            paramName: "Paint Roughness"
                            width: parent.width
                        }
                        
                        SPParameter {
                            visible: useRoughTex.visible && !useRoughTex.checked
                            SPSlider {
                                id: paintRough
                                text: "Paint Roughness"
                                from: 0
                                to: 1
                            }
                            onResetRequested: weaponFinish.resetParameter("uPaintRough")
                        }

                        SPSeparator { Layout.fillWidth: true }

                        TextureFetcher {
                            id: useMatMasks
                            text: "Material Mask"
                            visible: !useColMask.visible
                            Layout.fillWidth: true
                        }

                        MultiSlider {
                            id: paintMetalNum
                            visible: ["so", "hy", "sp"].includes(styleBox.currentKey)
                            model: ["X", "Y", "Z", "W"]
                            paramId: "uPaintMetal"
                            paramName: "Paint Metalness"
                            width: parent.width
                        }
                    }

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Normals"

                        TextureFetcher {
                            id: useNormalMap
                            text: "Normal Map"
                            Layout.fillWidth: true
                        }

                        TextureFetcher {
                            id: useAOTex
                            text: "Ambient Occlusion"
                            Layout.fillWidth: true
                        }
                    }

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Effects"

                        TextureFetcher {
                            id: usePearlMask
                            text: "Pearlescence Mask"
                            Layout.fillWidth: true
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
                        text: "Wear and Grunge"

                        MultiSlider {
                            id: paintDurabilityNum
                            visible: ["so", "hy", "sp"].includes(styleBox.currentKey)
                            model: ["X", "Y", "Z", "W"]
                            paramId: "uPaintDurability"
                            paramName: "Paint Durability"
                            width: parent.width
                        }

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
                    }
                }
            }
        }
    }
}
