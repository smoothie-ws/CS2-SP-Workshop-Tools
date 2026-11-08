import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import Painter 1.0
import AlgWidgets 2.0
import "./SPWidgets"
import "./SPWidgets/math.js" as MathUtils

import "./modules/random.mjs" as Random

Rectangle {
    id: root
    color: "#262626"

    // 0 - closed
    // 1 - regular project
    // 2 - weapon finish
    property int projectKind: 0
    readonly property string selectedStyle: styleBox.currentKey || ""

    Connections {
        target: Plugin

        function onProjectKindChanged(kind) {
            root.projectKind = kind;
            if (kind == 2) {
                weaponFinish.loadParams();
                weaponFinish.updateWeapon(weaponBox.currentKey, true);
                weaponFinish.updateStyle();
                const c = weaponFinish.parameters["econitem"];
                if (c !== undefined) {
                    const p = c.control[c.prop];
                    if (typeof p === "string") {
                        const n = Plugin.fileName(p);
                        if (n !== "") {
                            finishName.text = `#${n.toUpperCase()}`;
                            return;
                        }
                    }
                }
                const project = JSON.parse(Plugin.getWeaponFinish()) || {};
                if (project.name) {
                    finishName.text = `#${project.name.toUpperCase()}`;
                    return;
                }
            }
            finishName.text = "#UNKNOWN";
        }

        function onProjectAboutToSave() {
            weaponFinish.syncEcon();
        }


        function onStyleReady() {
            weaponFinish.connect();

        }

        function onPluginAboutToClose() {
            weaponFinish.dump();
        }
    }

    Component.onCompleted: {
        styleBox.currentKeyChanged.connect(() => weaponFinish.updateStyle());

        weaponBox.currentKeyChanged.connect(() => { if (root.projectKind == 2 && !weaponFinish.loading) weaponFinish.updateWeapon(weaponBox.currentKey); });
        weaponFinish.parameters["g_tWear"].control.url = Plugin.importTexture(Plugin.localPath(Plugin.asset("textures/paint_wear.png")));
        weaponFinish.parameters["g_tGrunge"].control.url = Plugin.importTexture(Plugin.localPath(Plugin.asset("textures/gun_grunge.png")));
        weaponFinish.captureDefaults();
    }

    WeaponFinish {
        id: weaponFinish
        objectName: "weaponFinish"

        parameters: {
            "seed":                              { control: general,              prop: "seed",          slot: null,  expr: null },
            "style":                             { control: styleBox,             prop: "currentKey",    slot: null,  expr: null },
            "weapon":                            { control: weaponBox,            prop: "currentKey",    slot: null,  expr: null },
            "econitem":                          { control: econitem,             prop: "filePath",      slot: null,  expr: null },
            "texturesFolder":                    { control: texturesFolder,       prop: "filePath",      slot: null,  expr: null },
            "wearRange":                         { control: wearRange,            prop: "range",         slot: null,  expr: null },
            "g_flPatternTexCoordScale":          { control: patternTexCoordScale, prop: "value",         slot: null,  expr: null },
            "uTexTransform":                     { control: patternTransform,     prop: "components",    slot: null,  expr: null },
            "texRotationRange":                  { control: texRotation,          prop: "range",         slot: null,  expr: null },
            "texOffsetXRange":                   { control: texOffsetX,           prop: "range",         slot: null,  expr: null },
            "texOffsetYRange":                   { control: texOffsetY,           prop: "range",         slot: null,  expr: null },

            // shader parameters
            "g_bLivePreview":                    { control: enableLivePreview,    prop: "checked",       slot: null,  expr: null },
            "g_bPBRValidation":                  { control: pbrValidation,        prop: "validating",    slot: null,  expr: null },
            "g_bDebugChannel":                   { control: debugChannel,         prop: "currentKey",    slot: null,  expr: value => Number(value) },
            "g_vPatternTexCoordXform0":          { control: patternTransform,     prop: "matrixForm0",   slot: null,  expr: null },
            "g_vPatternTexCoordXform1":          { control: patternTransform,     prop: "matrixForm1",   slot: null,  expr: null },
            "g_vWearTexCoordXform0":             { control: wearTransform,        prop: "matrixForm0",   slot: null,  expr: null },
            "g_vWearTexCoordXform1":             { control: wearTransform,        prop: "matrixForm1",   slot: null,  expr: null },
            "g_vGrungeTexCoordXform0":           { control: grungeTransform,      prop: "matrixForm0",   slot: null,  expr: null },
            "g_vGrungeTexCoordXform1":           { control: grungeTransform,      prop: "matrixForm1",   slot: null,  expr: null },
            "g_fWearSoftness":                   { control: wearSoftness,          prop: "value",         slot: null,  expr: null },
            "g_flWearAmount":                    { control: wearAmount,           prop: "value",         slot: null,  expr: null },
            "g_bIgnoreWeaponSizeScale":          { control: ignoreWeaponSizeScale,prop: "checked",       slot: null,  expr: null },
            "g_bOverrideAmbientOcclusion":       { control: useAOTex,             prop: "checked",       slot: null,  expr: null },
            "g_bOverrideDefaultMasks":           { control: useMatMasks,          prop: "checked",       slot: null,  expr: null },
            "g_bUseNormalMap":                   { control: useNormalMap,         prop: "checked",       slot: null,  expr: null },
            "g_bUseRoughness":                   { control: useRoughTex,          prop: "checked",       slot: null,  expr: null },
            "g_bUsePearlescenceMask":            { control: usePearlMask,         prop: "checked",       slot: null,  expr: null },
            "g_vSprayBiasBlend":                 { control: sprayBlend,           prop: "array",         slot: null,  expr: value => [0, value[0], value[1]] },
            "g_flPaintRoughness":                { control: paintRough,           prop: "value",         slot: null,  expr: null },
            "g_flPearlescentScale":              { control: pearlScale,           prop: "value",         slot: null,  expr: null },
            "g_bRoughnessPerColor":              { control: useRoughByCol,        prop: "checked",       slot: null,  expr: null },
            "g_vPaintRoughness":                 { control: paintRoughNum,        prop: "array",         slot: null,  expr: null },
            "g_vPaintMetalness":                 { control: paintMetalNum,        prop: "array",         slot: null,  expr: null },
            "g_vPaintDurability":                { control: paintDurabilityNum,   prop: "array",         slot: null,  expr: x => [1.0 - x[0], 1.0 - x[1], 1.0 - x[2], 1.0 - x[3]] },

            // dynamically generated components
            "g_tColor":                          { control: null,                 prop: "url",           slot: null,  expr: null },
            "g_tMetalness":                      { control: null,                 prop: "url",           slot: null,  expr: null },
            "g_tSurface":                        { control: null,                 prop: "url",           slot: null,  expr: null },
            "g_tAmbientOcclusion":               { control: null,                 prop: "url",           slot: null,  expr: null },
            "g_tMasks":                          { control: null,                 prop: "url",           slot: null,  expr: null },
            "g_tWear":                           { control: wearTexture,                 prop: "url",           slot: null,  expr: null },
            "g_tGrunge":                         { control: grungeTexture,                 prop: "url",           slot: null,  expr: null },
            "g_vColor0":                         { control: null,                 prop: "arrayColor",    slot: null,  expr: x => [Math.pow(x[0], 2.4), Math.pow(x[1], 2.4), Math.pow(x[2], 2.4)] },
            "g_vColor1":                         { control: null,                 prop: "arrayColor",    slot: null,  expr: x => [Math.pow(x[0], 2.4), Math.pow(x[1], 2.4), Math.pow(x[2], 2.4)] },
            "g_vColor2":                         { control: null,                 prop: "arrayColor",    slot: null,  expr: x => [Math.pow(x[0], 2.4), Math.pow(x[1], 2.4), Math.pow(x[2], 2.4)] },
            "g_vColor3":                         { control: null,                 prop: "arrayColor",    slot: null,  expr: x => [Math.pow(x[0], 2.4), Math.pow(x[1], 2.4), Math.pow(x[2], 2.4)] }
        }

        function updateStyle() {
            if (root.projectKind == 2 && !weaponFinish.loading)
                Plugin.updateStyle(styleBox.currentKey);
        }
    }

    component TextureParameter: SPParameter {
        required property string paramId

        property alias text: label.text
        property alias url: resourcePicker.url

        SPLabeled {
            id: label
            SPResourcePicker {
                id: resourcePicker
                Layout.fillWidth: true
                filters: AlgResourcePicker.TEXTURE
            }
        }
        onResetRequested: weaponFinish.resetParameter(paramId)
    }

    TransformMatrix {
        id: patternTransform
        baseScale: ignoreWeaponSizeScale.checked ? 1.0 : weaponBox.uvScale
        onScaleChanged: patternTexCoordScale.value = scale
        onTranslationXChanged: texOffsetX.value = translationX
        onTranslationYChanged: texOffsetY.value = translationY
        onRotationChanged: texRotation.value = rotation
    }
    TransformMatrix { id: wearTransform; baseScale: patternTransform.baseScale }
    TransformMatrix { id: grungeTransform; baseScale: patternTransform.baseScale }
    
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
                objectName: "finishName"
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
                id: pbrValidation
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

                property bool validating: false

                onClicked: if (enabled) checked = !checked
                onValidatingChanged: if (!checked) validating = false

                Timer {
                    id: blinkTimer
                    interval: 750
                    running: pbrValidation.checked
                    repeat: true

                    onRunningChanged: pbrValidation.validating = running
                    onTriggered: pbrValidation.validating = !pbrValidation.validating
                }

                Shortcut {
                    sequence: "V"
                    onActivated: if (pbrValidation.enabled) pbrValidation.checked = !pbrValidation.checked
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

                SPLabeled {
                    text: "Environment Map"
                    Layout.fillWidth: true

                    SPComboBox {
                        Layout.fillWidth: true
                        map: JSON.parse(Plugin.getPreviewEnvs())
                        onCurrentKeyChanged: Plugin.setPreviewEnv(currentKey)
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
                        return true;
                    }

                    onReadyChanged: enableLivePreview.checked = ready

                    Repeater {
                        id: textureRepeater
                        model: [
                            { param: "g_tColor",            text: "Base Color"        },
                            { param: "g_tMetalness",        text: "Roughness"         },
                            { param: "g_tMasks",            text: "Masks"             },
                            { param: "g_tSurface",          text: "Normal"            },
                            { param: "g_tAmbientOcclusion", text: "Cavity"            }
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

                    texRotation.value = r.randomFloat(texRotation.minValue, texRotation.maxValue);
                    texOffsetX.value = r.randomFloat(texOffsetX.minValue, texOffsetX.maxValue);
                    texOffsetY.value = r.randomFloat(texOffsetY.minValue, texOffsetY.maxValue);

                    wearTransform.scale = r.randomFloat(1.6, 1.8);
                    wearTransform.rotation = r.randomFloat(0.0, 360.0);
                    wearTransform.translationX = r.randomFloat(0.0, 1.0);
                    wearTransform.translationY = r.randomFloat(0.0, 1.0);

                    grungeTransform.scale = r.randomFloat(1.6, 1.8);
                    grungeTransform.rotation = r.randomFloat(0.0, 360.0);
                    grungeTransform.translationX = r.randomFloat(0.0, 1.0);
                    grungeTransform.translationY = r.randomFloat(0.0, 1.0);
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

                        onClicked: weaponFinish.importEcon()
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
                            onAccepted: econitem.filePath = Plugin.localPath(fileUrl.toString());
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
                        tooltip.text: "Export Weapon Finish textures (Ctrl+E)"
                        background.color: hovered ? Qt.rgba(0, 0, 0, 0.75) : Qt.rgba(0, 0, 0, 0.25)

                        onClicked: Plugin.exportWeaponFinishTextures()

                        Shortcut {
                            sequence: "Ctrl+E"
                            onActivated: if (parent.enabled) Plugin.exportWeaponFinishTextures()
                        }
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
                            onAccepted: texturesFolder.filePath = Plugin.localPath(fileUrl.toString());
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
                        property real uvScale: 1.0

                        onCurrentKeyChanged: uvScale = weapons[currentKey] ? weapons[currentKey].uv_scale : 1.0
                    }

                    Component.onCompleted: scopeWidth = Math.max(scopeWidth, style.scopeWidth)
                }

                SPLabeled {
                    id: style
                    text: "Paint Style"
                    Layout.fillWidth: true

                    SPComboBox {
                        id: styleBox
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        map: JSON.parse(Plugin.getFinishStyles())
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
                    id: paramsColumn
                    width: weaponFinishSettings.width - 20
                    spacing: 10

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Common"

                        SPParameter {
                            SPSlider {
                                id: patternTexCoordScale
                                text: "Texture Scale"
                                from: -10
                                to: 10
                                onValueChanged: patternTransform.scale = value
                            }
                            onResetRequested: weaponFinish.resetParameter("g_flPatternTexCoordScale")
                        }

                        SPParameter {
                            SPButton {
                                id: ignoreWeaponSizeScale
                                text: "Ignore Weapon Size Scale"
                                Layout.fillWidth: true
                                checkable: true
                                tooltip.text: "For some finishes, the automatic scale adjustment per-weapon is not desired"
                            }
                            onResetRequested: weaponFinish.resetParameter("g_bIgnoreWeaponSizeScale")
                        }
                    }

                    SPGroup {
                        id: colorGroup
                        Layout.fillWidth: true
                        text: "Colors"
                        visible: styleBox.currentKey != "cu"

                        property real labelScopeWidth: 0.0

                        SPParameter {
                            width: parent.width
                            visible: ["so", "hy", "sp", "an", "am", "aa"].includes(styleBox.currentKey)

                            SPTextureFetcher {
                                id: useColMask
                                text: "Paint-By-Number Mask"
                                Layout.fillWidth: true

                                SPLock {
                                    Component.onCompleted: {
                                        useColMask.checkedChanged.connect(() => update(() => useMatMasks.checked = useColMask.checked));
                                        useMatMasks.checkedChanged.connect(() => update(() => useColMask.checked = useMatMasks.checked));
                                    }
                                }
                            }
                            onResetRequested: weaponFinish.resetParameter("g_bOverrideDefaultMasks")
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
                                
                                onResetRequested: weaponFinish.resetParameter(`g_vColor${index}`)
                            }

                            onItemAdded: (i, control) => {
                                weaponFinish.parameters[`g_vColor${i}`].control = control;
                                colorGroup.labelScopeWidth = Math.max(colorGroup.labelScopeWidth, control.scopeWidth);
                                control.scopeWidth = Qt.binding(() => colorGroup.labelScopeWidth);
                            }
                        }
                    }

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Texture Placement"

                        SPMultiSlider {
                            id: sprayBlend
                            visible: ["sp", "aa"].includes(styleBox.currentKey)
                            model: ["Back", "Top"]
                            paramId: "g_vSprayBiasBlend"
                            paramName: "Spray Blend"
                            width: parent.width
                        }

                        SPParameter {
                            SPRangeSlider {
                                id: texRotation
                                text: "Texture Rotation"
                                from: -360
                                to: 360
                                onValueChanged: patternTransform.rotation = value
                            }
                            onResetRequested: weaponFinish.resetParameter("texRotationRange")
                        }

                        SPParameter {
                            SPRangeSlider {
                                id: texOffsetX
                                text: "Texture Offset X"
                                from: -1
                                to: 1
                                onValueChanged: patternTransform.translationX = value
                            }
                            onResetRequested: weaponFinish.resetParameter("texOffsetXRange")
                        }

                        SPParameter {
                            SPRangeSlider {
                                id: texOffsetY
                                text: "Texture Offset Y"
                                from: -1
                                to: 1
                                onValueChanged: patternTransform.translationY = value
                            }
                            onResetRequested: weaponFinish.resetParameter("texOffsetYRange")
                        }
                    }

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Materials"

                        SPParameter {
                            width: parent.width
                            visible: !useRoughByCol.visible || (useRoughByCol.visible && !useRoughByCol.checked)
                            
                            SPTextureFetcher {
                                id: useRoughTex
                                text: "Roughness Texture"
                                Layout.fillWidth: true
                            }
                            onResetRequested: weaponFinish.resetParameter("g_bUseRoughness")
                        }

                        SPParameter {
                            width: parent.width
                            visible: styleBox.currentKey == "ce"
                            
                            SPTextureFetcher {
                                id: useMetalMask
                                text: "Paint Metalness Mask"
                                Layout.fillWidth: true
                            }
                            onResetRequested: weaponFinish.resetParameter("g_bUseMetalness")
                        }

                        SPParameter {
                            visible: ["so", "hy", "sp"].includes(styleBox.currentKey) && !useRoughTex.checked

                            SPButton {
                                id: useRoughByCol
                                checkable: true
                                text: "Use Roughness By Color"
                                tooltip.text: `Whether to ${text.toLowerCase()}`
                                Layout.fillWidth: true
                            }
                            onResetRequested: weaponFinish.resetParameter("g_bRoughnessPerColor")
                        }

                        SPMultiSlider {
                            id: paintRoughNum
                            visible: useRoughByCol.visible && useRoughByCol.checked
                            model: ["Base Coat", "Red Mask", "Green Mask", "Blue Mask"]
                            paramId: "g_vPaintRoughness"
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
                            onResetRequested: weaponFinish.resetParameter("g_flPaintRoughness")
                        }

                        SPSeparator { Layout.fillWidth: true }

                        SPParameter {
                            width: parent.width
                            visible: !useColMask.visible
                            
                            SPTextureFetcher {
                                id: useMatMasks
                                text: "Material Mask"
                                Layout.fillWidth: true
                            }
                            onResetRequested: weaponFinish.resetParameter("g_bOverrideDefaultMasks")
                        }

                        SPMultiSlider {
                            id: paintMetalNum
                            visible: ["so", "hy", "sp"].includes(styleBox.currentKey)
                            model: ["Base Coat", "Red Mask", "Green Mask", "Blue Mask"]
                            paramId: "g_vPaintMetalness"
                            paramName: "Paint Metalness"
                            width: parent.width
                        }
                    }

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Overlay"
                        visible: styleBox.currentKey == "ce"

                        SPParameter {
                            width: parent.width
                            
                            SPButton {
                                id: enableOverlay
                                checkable: true
                                text: "Enable Overlay"
                                Layout.fillWidth: true
                            }
                            onResetRequested: weaponFinish.resetParameter("g_bEnableOverlay")
                        }

                        Column {
                            visible: enableOverlay.checked
                            Layout.fillWidth: true
                            
                            TextureParameter {
                                visible: styleBox.currentKey == "ce"
                                paramId: "g_tOverlay"
                                text: "Overlay Texture"
                            }

                            SPParameter {
                                width: parent.width
                                
                                SPButton {
                                    id: randomizeOverlayUVs
                                    text: "Randomize Overlay UVs"
                                    checkable: true
                                    Layout.fillWidth: true
                                }
                                onResetRequested: weaponFinish.resetParameter("g_bRandomizeOverlayUVs")
                            }
                        }
                    }

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Normals"

                        SPParameter {
                            width: parent.width
                            
                            SPTextureFetcher {
                                id: useNormalMap
                                text: "Normal Map"
                                Layout.fillWidth: true
                            }

                            onResetRequested: weaponFinish.resetParameter("g_bUseNormalMap")
                        }

                        SPParameter {
                            width: parent.width
                            
                            SPTextureFetcher {
                                id: useAOTex
                                text: "Ambient Occlusion"
                                Layout.fillWidth: true
                            }

                            onResetRequested: weaponFinish.resetParameter("g_bOverrideAmbientOcclusion")
                        }
                    }

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Effects"

                        SPParameter {
                            width: parent.width
                            visible: styleBox.currentKey == "ce"
                            
                            SPTextureFetcher {
                                id: useSFXMask
                                text: "SFX Mask"
                                Layout.fillWidth: true
                            }
                            onResetRequested: weaponFinish.resetParameter("g_bUseSFXMask")
                        }

                        SPParameter {
                            width: parent.width
                            
                            SPTextureFetcher {
                                id: usePearlMask
                                text: "Pearlescence Mask"
                                Layout.fillWidth: true
                            }

                            onResetRequested: weaponFinish.resetParameter("g_bUsePearlescenceMask")
                        }

                        SPParameter {
                            SPSlider {
                                id: pearlScale
                                text: "Pearlescent Scale"
                                from: -6
                                to: 6
                            }
                            onResetRequested: weaponFinish.resetParameter("g_flPearlescentScale")
                        }

                        SPMultiSlider {
                            id: glitterNum
                            visible: styleBox.currentKey == "ce"
                            model: ["Intensity", "Scale", "Rainbow Balance", "Rainbow Spread"]
                            paramId: "g_vGlitter"
                            paramName: "Glitter"
                            width: parent.width
                        }

                        SPMultiSlider {
                            id: iridescentNum
                            visible: styleBox.currentKey == "ce"
                            model: ["Strength", "Scale", "Hue Shift"]
                            paramId: "g_vIridescent"
                            paramName: "Iridescent"
                            width: parent.width
                        }
                    }

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Wear and Grunge"

                        SPMultiSlider {
                            id: paintDurabilityNum
                            visible: ["so", "hy", "sp"].includes(styleBox.currentKey)
                            model: ["Base Coat", "Red Mask", "Green Mask", "Blue Mask"]
                            paramId: "g_vPaintDurability"
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
                                weaponFinish.resetParameter("g_flWearAmount");
                            }
                        }

                        TextureParameter {
                            id: wearTexture
                            visible: false
                            paramId: "g_tWear"
                            text: "Wear Texture"
                        }

                        SPParameter {
                            SPSlider {
                                id: wearSoftness
                                text: "Wear Softness"
                                from: -6
                                to: 6
                            }
                            onResetRequested: weaponFinish.resetParameter("g_fWearSoftness")
                        }

                        SPParameter {
                            SPRangeSlider {
                                id: wearRotation
                                text: "Wear Rotation"
                                from: -360
                                to: 360
                                onValueChanged: wearTransform.rotation = value
                            }
                        }

                        TextureParameter {
                            id: grungeTexture
                            visible: false
                            paramId: "g_tGrunge"
                            text: "Grunge Texture"
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                SPButton {
                    id: saveAsDefaults
                    text: "Save as defaults"
                    icon.source: Plugin.asset("icons/save.png")
                    tooltip.text: "Save current settings as default"

                    onClicked: weaponFinish.saveDefaults()
                }

                SPSeparator { Layout.fillWidth: true }

                SPButton {
                    id: restoreDefaults
                    text: "Restore defaults"
                    icon.source: "./icons/cycle.png"

                    onClicked: weaponFinish.restoreDefaults()
                }
            }
        }
    }
}
