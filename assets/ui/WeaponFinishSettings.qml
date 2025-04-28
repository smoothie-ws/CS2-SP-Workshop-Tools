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

    function connectWeaponFinish() {
        // connect shader
        for (const [param, component] of Object.entries(weaponFinish.parameters)) 
            if (param.startsWith("u")) {
                component.item[component.prop] = JSON.parse(internal.js(`alg.shaders.parameter(0, "${param}").value`));
                if (["filePath", "url"].includes(component.prop))
                    component.item[component.prop + "Changed"].connect(() => 
                        internal.js(`alg.shaders.parameter(0, "${param}").value = "${component.item[component.prop]}"`)
                    );
                else
                    component.item[component.prop + "Changed"].connect(() =>
                        internal.js(`alg.shaders.parameter(0, "${param}").value = ${component.item[component.prop]}`)
                    );
            }
        // load textures
        weaponFinish.parameters["uGrungeTex"].item.url = importTexture(`${internal.pluginPath()}/assets/textures/grunge.tga`);
        weaponFinish.parameters["uScratchesTex"].item.url = importTexture(`${internal.pluginPath()}/assets/textures/scratches.png`);
        // load defaults
        weaponFinish.setValues(alg.project.settings.value("weapon_finish"));
    }

    PainterPlugin {
        onProjectAboutToSave: {
            internal.js(`alg.project.settings.setValue("weapon_finish", ${JSON.stringify(weaponFinish.getValues())})`)
            internal.info(internal.js("alg.project.settings.value(\"weapon_finish\")"));
        }
    }

    QtObject {
        id: weaponFinish

        property var parameters: {
            "econfile":               { item: econFile,               prop: "filePath"     },
            "weapon":                 { item: weaponBox,              prop: "currentIndex" },
            "wearRange":              { item: wearRange,              prop: "range"        },
            "texScale":               { item: texScale,               prop: "value"        },
            "texRotationRange":       { item: texRotation,            prop: "range"        },
            "texOffsetXRange":        { item: texOffsetX,             prop: "range"        },
            "texOffsetYRange":        { item: texOffsetY,             prop: "range"        },
            // shader parameters
            "uFinishStyle":           { item: finishStyleBox,         prop: "currentIndex" },
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

        function getValues() {
            var values = {}
            for (const [param, component] of Object.entries(parameters))
                values[param] = component.item[component.prop];
            return values;
        }

        function setValues(values) {
            for (const v of values) {
                const component = parameters[v.param];
                component.item[component.prop] = v.value;
            }
        }
        
        function reset(param) {
            const settings = JSON.parse(internal.js("alg.project.settings.value(\"weapon_finish\")"));
            if (settings !== null)
                for (const d of settings)
                    if (param == d.param) {
                        const component = weaponFinish.parameters[d.param];
                        component.item[component.prop] = d.value;
                        break;
                    }
        }
    }

    function importTexture(url) {
        return JSON.parse(internal.js(`alg.resources.importSessionResource("${url}", "texture")`));
    }

    function resetWeapon(name) {
        const path = `${internal.pluginPath()}/assets/textures/models/${name}`;
        try {
            weaponFinish.parameters["uBaseColor"].item.url = importTexture(`${path}/${name}_color.png`);
            weaponFinish.parameters["uBaseRough"].item.url = importTexture(`${path}/${name}_rough.png`);
            weaponFinish.parameters["uBaseSurface"].item.url = importTexture(`${path}/${name}_surface.png`);
            weaponFinish.parameters["uBaseMasks"].item.url = importTexture(`${path}/${name}_masks.png`);
            weaponFinish.parameters["uBaseCavity"].item.url = importTexture(`${path}/${name}_cavity.png`);
        } catch(err) {
            
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
                visible: root.isNew
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
                    onResetRequested: weaponFinish.reset("uWearAmt")
                }

                SPParameter {
                    SPSlider {
                        id: texScale
                        text: "Texture Scale"
                        from: -10
                        to: 10
                        onValueChanged: texTransform.sync()
                    }
                    onResetRequested: weaponFinish.reset("texScale")
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
                    onResetRequested: weaponFinish.reset("uIgnoreWeaponSizeScale")
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
                    onResetRequested: weaponFinish.reset("texRotationRange")
                }

                SPParameter {
                    SPRangeSlider {
                        id: texOffsetX
                        text: "Texture Offset X"
                        from: -1
                        to: 1
                        onValueChanged: texTransform.sync()
                    }
                    onResetRequested: weaponFinish.reset("texOffsetXRange")
                }

                SPParameter {
                    SPRangeSlider {
                        id: texOffsetY
                        text: "Texture Offset Y"
                        from: -1
                        to: 1
                        onValueChanged: texTransform.sync()
                    }
                    onResetRequested: weaponFinish.reset("texOffsetYRange")
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
                        onResetRequested: weaponFinish.reset(`uCol${index}`)
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
                        weaponFinish.reset("wearRange"); 
                        weaponFinish.reset("uWearAmt");
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
                    onResetRequested: weaponFinish.reset("uUsePearlMask")
                }

                SPParameter {
                    SPSlider {
                        id: pearlescentScale
                        text: "Pearlescent Scale"
                        from: -6
                        to: 6
                    }
                    onResetRequested: weaponFinish.reset("uPearlScale")
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
                    onResetRequested: weaponFinish.reset("uUseCustomRough")
                }
                    
                SPParameter {
                    visible: !useRoughnessTexture.checked
                    SPSlider {
                        id: paintRoughness
                        text: "Paint Roughness"
                        from: 0
                        to: 1
                    }
                    onResetRequested: weaponFinish.reset("uPaintRoughness")
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

                        onResetRequested: weaponFinish.reset(modelData.param)
                    }

                    onItemAdded: (i, item) => {
                        weaponFinish.parameters[model[i].param].item = item.control;
                    }
                }
            }
        }
    }
}
