import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import QtQuick.Window 2.15
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0
import "./SPWidgets"
import "./SPWidgets/math.js" as MathUtils

Rectangle {
    id: root
    color: AlgStyle.background.color.mainWindow
    implicitHeight: mainLayout.height

    function loadWeaponFinish() {
        weaponFinish.load();
    }

    function importTexture(url) {
        return JSON.parse(internal.js(`alg.resources.importSessionResource("${url}", "texture")`));
    }

    PainterPlugin {
        onProjectAboutToSave: weaponFinish.save()
    }

    Component.onCompleted: {
        // connect widgets to shader
        for (const [param, component] of Object.entries(weaponFinish.parameters)) 
            if (param.startsWith("u")) {
                if (["filePath", "url"].includes(component.prop))
                    component.item[component.prop + "Changed"].connect(() => 
                        internal.js(`alg.shaders.parameter(0, "${param}").value = "${component.item[component.prop]}"`)
                    );
                else if (["range", "arrayColor", "transform"].includes(component.prop))
                    component.item[component.prop + "Changed"].connect(() => 
                        internal.js(`alg.shaders.parameter(0, "${param}").value = [${component.item[component.prop]}]`)
                    );
                else
                    component.item[component.prop + "Changed"].connect(() => 
                        internal.js(`alg.shaders.parameter(0, "${param}").value = ${component.item[component.prop]}`)
                    );
            }
        finishStyleBox.currentKeyChanged.connect(() => internal.changeFinishStyle(finishStyleBox.currentKey));
    }

    QtObject {
        id: weaponFinish
        objectName: weaponFinish

        property var parameters: {
            "econFile":               { item: econFile,               prop: "filePath"     },
            "texturesFolder":         { item: texturesFolder,         prop: "filePath"     },
            "finishStyle":            { item: finishStyleBox,         prop: "currentKey" },
            "weapon":                 { item: weaponBox,              prop: "currentKey" },
            "wearRange":              { item: wearRange,              prop: "range"        },
            "texScale":               { item: texScale,               prop: "value"        },
            "texRotationRange":       { item: texRotation,            prop: "range"        },
            "texOffsetXRange":        { item: texOffsetX,             prop: "range"        },
            "texOffsetYRange":        { item: texOffsetY,             prop: "range"        },
            // Shader parameters
            "uLivePreview":           { item: enableLivePreview,      prop: "checked"      },
            "uPBRValidation":         { item: enablePBRValidation,    prop: "checked"      },
            "uWearAmt":               { item: wearAmount,             prop: "value"        },
            "uTexTransform":          { item: texTransform,           prop: "transform"    },
            "uIgnoreWeaponSizeScale": { item: ignoreTextureSizeScale, prop: "checked"      },
            "uUsePearlMask":          { item: usePearlescentMask,     prop: "checked"      },
            "uPearlScale":            { item: pearlescentScale,       prop: "value"        },
            "uUseCustomRough":        { item: useRoughnessTexture,    prop: "checked"      },
            "uPaintRoughness":        { item: paintRoughness,         prop: "value"        },
            // dynamically generated components
            "uGrungeTex":             { item: null,                   prop: "url"          },
            "uScratchesTex":          { item: null,                   prop: "url"          },
            "uBaseColor":             { item: null,                   prop: "url"          },
            "uBaseRough":             { item: null,                   prop: "url"          },
            "uBaseSurface":           { item: null,                   prop: "url"          },
            "uBaseMasks":             { item: null,                   prop: "url"          },
            "uBaseCavity":            { item: null,                   prop: "url"          },
            "uCol0":                  { item: null,                   prop: "arrayColor"   },
            "uCol1":                  { item: null,                   prop: "arrayColor"   },
            "uCol2":                  { item: null,                   prop: "arrayColor"   },
            "uCol3":                  { item: null,                   prop: "arrayColor"   },
            "uUseCustomNormal":       { item: null,                   prop: "checked"      },
            "uUseCustomMasks":        { item: null,                   prop: "checked"      },
            "uUseCustomAOTex":        { item: null,                   prop: "checked"      },
        }

        // save weapon finish parameters
        function save() {
            var values = {}
            for (const [param, component] of Object.entries(parameters))
                values[param] = component.item[component.prop];
            internal.saveWeaponFinish(JSON.stringify(values));
        }

        // load weapon finish parameters
        function load() {
            const values = JSON.parse(internal.js("alg.project.settings.value(\"weapon_finish\")"));

            for (const [param, component] of Object.entries(parameters)) {
                // set shader's value
                if (param.startsWith("u"))
                    component.item[component.prop] = JSON.parse(internal.js(`alg.shaders.parameter(0, "${param}").value`));
                // else set saved value
                else {
                    const value = values[param];
                    if (value !== undefined)
                        component.item[component.prop] = value;
                }
            }

            // load textures
            const w = weaponBox.currentKey;
            const texPath = `${internal.pluginPath()}/assets/textures`;

            for (const [param, file] of Object.entries({
                    "uGrungeTex": "grunge.tga", 
                    "uScratchesTex": "scratches.png",
                    "uBaseColor": `models/${w}/${w}_color.png`, 
                    "uBaseRough": `models/${w}/${w}_rough.png`, 
                    "uBaseSurface": `models/${w}/${w}_surface.png`, 
                    "uBaseMasks": `models/${w}/${w}_masks.png`, 
                    "uBaseCavity": `models/${w}/${w}_cavity.png`, 
                }))
                if (values[param] === undefined || values[param] === "")
                    parameters[param].item.url = importTexture(`${texPath}/${file}`);
        }
        
        function resetParameter(parameter) {
            const component = parameters[parameter];
            const values = JSON.parse(internal.js("alg.project.settings.value(\"weapon_finish\")"));
            // first try to find saved value
            for (const [param, value] of Object.entries(values))
                if (parameter == param) {
                    component.item[component.prop] = value;
                    return;
                }
            // else set shader's default
            if (parameter.startsWith("u"))
                component.item[component.prop] = JSON.parse(internal.js(`alg.shaders.parameter(0, "${parameter}").value`));
        }

        function setWeapon(weapon) {
            const path = `${internal.pluginPath()}/assets/textures/models/${weapon}`;
            try {
                parameters["uBaseColor"].item.url = importTexture(`${path}/${weapon}_color.png`);
                parameters["uBaseRough"].item.url = importTexture(`${path}/${weapon}_rough.png`);
                parameters["uBaseSurface"].item.url = importTexture(`${path}/${weapon}_surface.png`);
                parameters["uBaseMasks"].item.url = importTexture(`${path}/${weapon}_masks.png`);
                parameters["uBaseCavity"].item.url = importTexture(`${path}/${weapon}_cavity.png`);
            } catch(err) {
                
            }
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

        SPGroup {
            id: settings
            Layout.fillWidth: true
            expandable: false
            text: "Project Settings"

            SPLabeled {
                id: econFile
                text: "Econitem File"
                Layout.fillWidth: true

                property string filePath: ""

                RowLayout {
                    Layout.fillWidth: true
                    
                    Label {
                        clip: true
                        opacity: 0.5
                        elide: Text.ElideLeft
                        horizontalAlignment: Text.AlignLeft
                        text: econFileDialog.fileUrl
                        color: AlgStyle.text.color.normal
                        Layout.fillWidth: true
                    }

                    SPButton {
                        text: "Select"
                        
                        onClicked: econFileDialog.open()

                        SPFileDialog {
                            id: econFileDialog
                            title: "Select file"
                            folder: Qt.resolvedUrl(internal.getCs2Path())
                            nameFilters: [ "CS2 Econ Item (*.econitem)" ]
                            onAccepted: econFile.filePath = fileUrl.toString().substring(8);
                        }
                    }
                }
            }

            SPLabeled {
                id: texturesFolder
                text: "Textures Folder"
                Layout.fillWidth: true

                property string filePath: ""

                RowLayout {
                    Layout.fillWidth: true
                    
                    Label {
                        clip: true
                        opacity: 0.5
                        elide: Text.ElideLeft
                        horizontalAlignment: Text.AlignLeft
                        text: texturesFolderDialog.fileUrl
                        color: AlgStyle.text.color.normal
                        Layout.fillWidth: true
                    }

                    SPButton {
                        text: "Select"
                        
                        onClicked: texturesFolderDialog.open()

                        SPFileDialog {
                            id: texturesFolderDialog
                            title: "Select folder"
                            selectFolder: true
                            folder: Qt.resolvedUrl(internal.getCs2Path())
                            onAccepted: texturesFolder.filePath = fileUrl.toString().substring(8);
                        }
                    }
                }
            }
        }

        SPSeparator { Layout.fillWidth: true }

        Rectangle {
            id: general
            color: Qt.rgba(1, 1, 1, 0.05)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.1)
            radius: 10
            Layout.fillWidth: true
            height: 100

            property int seed: 0

            onSeedChanged: {
                texOffsetX.value = MathUtils.mapNorm(MathUtils.random(seed + 2), texOffsetX.minValue, texOffsetX.maxValue);
                texOffsetY.value = MathUtils.mapNorm(MathUtils.random(seed + 3), texOffsetY.minValue, texOffsetY.maxValue);
                texRotation.value = MathUtils.mapNorm(MathUtils.random(seed + 4), texRotation.minValue, texRotation.maxValue);
            }

            ColumnLayout {
                id: generalLayout
                anchors.fill: parent
                anchors.margins: 10

                RowLayout {
                    SPButton {
                        id: enableLivePreview
                        text: "Live Preview"
                        checkable: true
                        implicitWidth: 150
                        contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                    }

                    SPLabeled {
                        text: "Seed"
                        enabled: enableLivePreview.checked
                        Layout.fillWidth: true

                        SPSeparator { Layout.fillWidth: true }

                        SPTextInput {
                            Layout.preferredWidth: 45
                            text: general.seed
                            validator: RegExpValidator { regExp: /^-?[0-9]*/ }
                            onEditingFinished: general.seed = MathUtils.clamp(parseInt(text), 0, 9999);
                        }

                        SPButton {
                            id: randomButton
                            text: "Random"
                            tooltip.text: "Generate random seed number"

                            onPressed: general.seed = Math.floor(Math.random() * 1000)
                        }
                    }
                }

                SPButton {
                    id: enablePBRValidation
                    text: "PBR Validation"
                    checkable: true
                    implicitWidth: 150
                    contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
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
                }

                onItemAdded: (i, item) => {
                    weaponFinish.parameters[model[i].param].item = item;
                    settings.scopeWidth = Math.max(settings.scopeWidth, item.scopeWidth);
                    item.scopeWidth = Qt.binding(() => settings.scopeWidth);
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
                        Layout.fillWidth: true
                        map: JSON.parse(internal.getWeaponList())
                        onCurrentKeyChanged: weaponFinish.setWeapon(currentKey)
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
                        id: ignoreTextureSizeScale
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

                    onItemAdded: (i, item) => {
                        colorGroup.scopeWidth = Math.max(colorGroup.scopeWidth, item.scopeWidth);
                        item.scopeWidth = Qt.binding(() => colorGroup.scopeWidth);
                        weaponFinish.parameters[`uCol${i}`].item = item;
                        weaponFinish.parameters[`uCol${i}`].item = item;
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
                        from: 0.0
                        to: 1.0
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

                    onItemAdded: (i, item) => {
                        weaponFinish.parameters[model[i].param].item = item.control;
                    }
                }
            }
        }
    }
}
