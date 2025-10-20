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
            weaponFinish.connect();
        }

        function onPluginAboutToClose() {
            weaponFinish.dump();
        }
    }

    Component.onCompleted: {
        styleBox.currentKeyChanged.connect(() => if (root.projectKind == 2) Plugin.updateStyle(styleBox.currentKey, externMode.checked));
        externMode.checkedChanged.connect(() => if (root.projectKind == 2) Plugin.updateStyle(styleBox.currentKey, externMode.checked););
        weaponBox.currentKeyChanged.connect(() => if (root.projectKind == 2) weaponFinish.updateWeapon(weaponBox.currentKey));
        weaponFinish.parameters["g_tWear"].control.url = Plugin.importTexture(Plugin.asset("textures/wear.png").slice(5));
        weaponFinish.parameters["g_tGrunge"].control.url = Plugin.importTexture(Plugin.asset("textures/grunge.png").slice(5));
    }

    WeaponFinish {
        id: weaponFinish

        parameters: {
            "externMode":                        { control: externMode,           prop: "checked",       slot: null },
            "style":                             { control: styleBox,             prop: "currentKey",    slot: null },
            "weapon":                            { control: weaponBox,            prop: "currentKey",    slot: null },
            "econitem":                          { control: econitem,             prop: "filePath",      slot: null },
            "texturesFolder":                    { control: texturesFolder,       prop: "filePath",      slot: null },
            "wearRange":                         { control: wearRange,            prop: "range",         slot: null },
            "g_flPatternTexCoordScale":          { control: patternTexCoordScale, prop: "value",         slot: null },
            "texRotationRange":                  { control: texRotation,          prop: "range",         slot: null },
            "texOffsetXRange":                   { control: texOffsetX,           prop: "range",         slot: null },
            "texOffsetYRange":                   { control: texOffsetY,           prop: "range",         slot: null },
            "nmPBRRange":                        { control: nmPBRRange,           prop: "range",         slot: null },
            "mPBRRange":                         { control: mPBRRange,            prop: "range",         slot: null },

            // shader parameters
            "g_bLivePreview":                    { control: enableLivePreview,    prop: "checked",       slot: null },
            "g_bPBRValidation":                  { control: enablePBRValidation,  prop: "checked",       slot: null },
            "g_bDebugChannel":                   { control: debugChannel,         prop: "currentKey",    slot: null },
            "uPBRRanges":                        { control: pbrRanges,            prop: "ranges",        slot: null },
            "g_vPatternTexCoordXform0":          { control: patternTransform,     prop: "matrixForm0",   slot: null },
            "g_vPatternTexCoordXform1":          { control: patternTransform,     prop: "matrixForm1",   slot: null },
            "g_vWearTexCoordXform0":             { control: wearTransform,        prop: "matrixForm0",   slot: null },
            "g_vWearTexCoordXform1":             { control: wearTransform,        prop: "matrixForm1",   slot: null },
            "g_vGrungeTexCoordXform0":           { control: grungeTransform,      prop: "matrixForm0",   slot: null },
            "g_vGrungeTexCoordXform1":           { control: grungeTransform,      prop: "matrixForm1",   slot: null },
            "g_flWearAmount":                    { control: wearAmount,           prop: "value",         slot: null },
            "g_flWeaponLength":                  { control: weaponBox,            prop: "weaponLength",  slot: null },
            "g_flUvScale":                       { control: weaponBox,            prop: "uvScale",       slot: null },
            "g_bIgnoreWeaponSizeScale":          { control: ignoreWeaponSizeScale,prop: "checked",       slot: null },
            "g_bRoughnessPerColor":              { control: useRoughByCol,        prop: "checked",       slot: null },
            "g_bUseRoughness":                   { control: useRoughTex,          prop: "checked",       slot: null },
            "g_bUsePearlescenceMask":            { control: usePearlMask,         prop: "checked",       slot: null },
            "g_bUseNormalMap":                   { control: useNormalMap,         prop: "checked",       slot: null },
            "g_bOverrideDefaultMasks":           { control: useMatMasks,          prop: "checked",       slot: null },
            "g_bOverrideAmbientOcclusion":       { control: useAOTex,             prop: "checked",       slot: null },
            "g_tPattern":                        { control: patternTex,           prop: "url",           slot: null },
            "g_tPaintRoughness":                 { control: useRoughTex,          prop: "url",           slot: null },
            "g_tPearlescenceMask":               { control: usePearlMask,         prop: "url",           slot: null },
            "g_tPaintNormal":                    { control: useNormalMap,         prop: "url",           slot: null },
            "g_tPaintMasks":                     { control: useMatMasks,          prop: "url",           slot: null },
            "g_tPaintAO":                        { control: useAOTex,             prop: "url",           slot: null },
            "g_vSprayBiasBlend":                 { control: sprayBlend,           prop: "array",         slot: null },
            "g_flPaintRoughness":                { control: paintRough,           prop: "value",         slot: null },
            "g_flPearlescentScale":              { control: pearlScale,           prop: "value",         slot: null },
            "g_vPaintRoughness":                 { control: paintRoughNum,        prop: "array",         slot: null },
            "g_vPaintMetalness":                 { control: paintMetalNum,        prop: "array",         slot: null },
            "g_vPaintDurability":                { control: paintDurabilityNum,   prop: "array",         slot: null },

            // dynamically generated components
            "g_tColor":                          { control: null,                 prop: "url",           slot: null },
            "g_tMetalness":                      { control: null,                 prop: "url",           slot: null },
            "g_tSurface":                        { control: null,                 prop: "url",           slot: null },
            "g_tMasks":                          { control: null,                 prop: "url",           slot: null },
            "g_tAmbientOcclusion":               { control: null,                 prop: "url",           slot: null },
            "g_tWear":                           { control: null,                 prop: "url",           slot: null },
            "g_tGrunge":                         { control: null,                 prop: "url",           slot: null },
            "g_vColor0":                         { control: null,                 prop: "arrayColor",    slot: null },
            "g_vColor1":                         { control: null,                 prop: "arrayColor",    slot: null },
            "g_vColor2":                         { control: null,                 prop: "arrayColor",    slot: null },
            "g_vColor3":                         { control: null,                 prop: "arrayColor",    slot: null }
        }
    }

    TransformMatrix { id: patternTransform }
    TransformMatrix { id: wearTransform }
    TransformMatrix { id: grungeTransform }

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
                    text: `${multi.paramName} - ${modelData}`
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

                SPButton {
                    id: externMode
                    checkable: true
                    text: "External Mode"
                    tooltip.text: "Use external pattern textures instead of project channels"
                    Layout.fillWidth: true
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
                    text: "Preview Environment"
                    Layout.fillWidth: true

                    SPComboBox {
                        Layout.fillWidth: true
                        map: JSON.parse(Plugin.getPreviewEnvs())
                        onCurrentKeyChanged: Plugin.setEnv(currentKey)
                    }
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
                                const c = weaponFinish.parameters[`g_tPaint${p}`].control;
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
                            { param: "g_tWear",          text: "Wear"              },
                            { param: "g_tGrunge",        text: "Grunge"            },
                            { param: "g_tColor",        text: "Base Color"        },
                            { param: "g_tMetalness",        text: "Roughness"         },
                            { param: "g_tMasks",        text: "Masks"             },
                            { param: "g_tSurface",       text: "Normal"            },
                            { param: "g_tAmbientOcclusion",       text: "Cavity"            }
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

                    patternTransform.rotation = r.randomFloat(texRotation.minValue, texRotation.maxValue);
                    patternTransform.translationX = r.randomFloat(texOffsetX.minValue, texOffsetX.maxValue);
                    patternTransform.translationY = r.randomFloat(texOffsetY.minValue, texOffsetY.maxValue);

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
                        property real weaponLength: 1.0
                        property real uvScale: 1.0

                        onCurrentKeyChanged: {
                            const w = weapons[currentKey]; 
                            weaponLength = w.length;
                            uvScale = w.uv_scale;
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

                        MultiSlider {
                            id: sprayBlend
                            visible: styleBox.currentKey == "sp"
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
                            model: ["Base Coat", "Red Mask", "Green Mask", "Blue Mask"]
                            paramId: "g_flPaintRoughness"
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

                        TextureFetcher {
                            id: useMatMasks
                            text: "Material Mask"
                            visible: !useColMask.visible
                            Layout.fillWidth: true
                        }

                        MultiSlider {
                            id: paintMetalNum
                            visible: ["so", "hy", "sp"].includes(styleBox.currentKey)
                            model: ["Base Coat", "Red Mask", "Green Mask", "Blue Mask"]
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
                            onResetRequested: weaponFinish.resetParameter("g_flPearlescentScale")
                        }
                    }

                    SPGroup {
                        Layout.fillWidth: true
                        text: "Wear and Grunge"

                        MultiSlider {
                            id: paintDurabilityNum
                            visible: ["so", "hy", "sp"].includes(styleBox.currentKey)
                            model: ["Base Coat", "Red Mask", "Green Mask", "Blue Mask"]
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
                                weaponFinish.resetParameter("g_flWearAmount");
                            }
                        }
                    }
                }
            }
        }
    }
}
