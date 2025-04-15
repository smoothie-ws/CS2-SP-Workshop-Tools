import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0
import "./SPWidgets"
import "./SPWidgets/math.js" as MathUtils

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
        else
            writeDefaults();
        const name = alg.project.lastImportedMeshUrl();
        if (weaponBox.currentValue != name) {
            const index = weaponBox.model.findIndex(w => w.value === name);
            if (index != -1)
                weaponBox.currentIndex = index;
        }
    }

    PainterPlugin {
        onProjectAboutToSave: writeDefaults()
    }

    QtObject {
        id: shader

        property string shaderId: ""

        property var parameters: {
            "uFinishStyle":           { item: finishStyleBox,         prop: "currentIndex" },
            "uLivePreview":           { item: enableLivePreview,      prop: "checked"      },
            "uPBRValidation":         { item: enablePBRValidation,    prop: "checked"      },
            "uPBRRange":              { item: pbrRange,               prop: "range"        },
            "uWearAmount":            { item: wearAmount,             prop: "value"        },
            "uTexTransform":          { item: texTransform,           prop: "transform"    },
            "uIgnoreWeaponSizeScale": { item: ignoreTextureSizeScale, prop: "checked"      },
            "uPearlMask":             { item: usePearlescentMask,     prop: "checked"      },
            "uPearlScale":            { item: pearlescentScale,       prop: "value"        },
            "uCustomRoughness":       { item: useRoughnessTexture,    prop: "checked"      },
            "uPaintRoughness":        { item: paintRoughness,         prop: "value"        },
            // dynamically generated components
            "dGrungeTex":             { item: null,                   prop: "url"          },
            "dBaseTex":               { item: null,                   prop: "url"          },
            "dNormalTex":             { item: null,                   prop: "url"          },
            "dORMTex":                { item: null,                   prop: "url"          },
            "dCurvTex":               { item: null,                   prop: "url"          },
            "uCol0":                  { item: null,                   prop: "arrayColor"   },
            "uCol1":                  { item: null,                   prop: "arrayColor"   },
            "uCol2":                  { item: null,                   prop: "arrayColor"   },
            "uCol3":                  { item: null,                   prop: "arrayColor"   },
            "uCustomNormal":          { item: null,                   prop: "checked"      },
            "uCustomMatMask":         { item: null,                   prop: "checked"      },
            "uCustomAOTex":           { item: null,                   prop: "checked"      },
            // not shader related
            "wearRange":              { item: wearRange,              prop: "range"        },
            "texScale":               { item: texScale,               prop: "value"        },
            "texRotationRange":       { item: texRotation,            prop: "range"        },
            "texOffsetXRange":        { item: texOffsetX,             prop: "range"        },
            "texOffsetYRange":        { item: texOffsetY,             prop: "range"        }
        }

        function connect() {
            for (const [param, component] of Object.entries(parameters)) 
                if (param.startsWith("u_")) {
                    const cl = alg.shaders.parameter(shaderId, param);
                    cl.valueChanged.connect(() => 
                        component.item[component.prop] = cl.value
                    );
                    component.item[component.prop + "Changed"].connect(() => 
                        cl.value = component.item[component.prop]
                    );
                }
        }

        function getValues() {
            var values = []
            for (const [param, component] of Object.entries(parameters))
                values.push({
                    param: param, 
                    value: component.item[component.prop]
                });
            return values;
        }

        function setValues(values) {
            for (const v of values) {
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

    function writeDefaults() {
        alg.project.settings.setValue("CS2WT", shader.getValues());
    }

    function reset(param) {
        if (alg.project.settings.contains("CS2WT"))
            for (const d of alg.project.settings.value("CS2WT"))
                if (param == d.param) {
                    const component = shader.parameters[d.param];
                    component.item[component.prop] = d.value;
                    break;
                }
    }

    function resetWeapon(weaponName) {
        const path = Qt.resolvedUrl('assets/materials/').slice(8);
        try {
            shader.parameters["dBaseTex"].item.url = importTexture(`${path}${weaponName}/color.jpg`);
            shader.parameters["dNormalTex"].item.url = importTexture(`${path}${weaponName}/normal.jpg`);
            shader.parameters["dORMTex"].item.url = importTexture(`${path}${weaponName}/orm.jpg`);
            shader.parameters["dCurvTex"].item.url = importTexture(`${path}${weaponName}/curvature.jpg`);
        } catch(err) { }
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
                    Layout.fillWidth: true
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
                    Layout.fillWidth: true
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
                    const file = alg.fileIO.open(fileUrl);
                    // if (mode === SPFileDialog.SaveFile)
                    //     econExport(file.readAll());
                    // else
                    //     econImport(file.readAll())
                    file.close();
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
                            tooltipText: "Generate random seed number"

                            onPressed: general.seed = Math.floor(Math.random() * 1000)
                        }
                    }
                }

                RowLayout {
                    SPButton {
                        id: enablePBRValidation
                        text: "PBR Validation"
                        checkable: true
                        implicitWidth: 150
                        contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                    }

                    SPParameter {
                        SPRangeSlider {
                            id: pbrRange
                            text: "PBR Range"
                            enabled: enablePBRValidation.checked
                            from: 0
                            to: 255
                            pickValue: false
                        }
                        onResetRequested: root.reset("uPBRRange")
                    }
                }
            }
        }

        SPGroup {
            Layout.fillWidth: true
            toggled: false
            text: "Default Textures"
            
            Repeater {
                model: [
                    { param: "dGrungeTex", text: "Gun Grunge"        },
                    { param: "dBaseTex",  text: "Base Color"        },
                    { param: "dNormalTex",     text: "Normal Map"        },
                    { param: "dORMTex",        text: "ORM Texture"       },
                    { param: "dCurvTex",       text: "Curvature Texture" }
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

                SPParameter {
                    SPSlider {
                        id: wearAmount
                        text: "Wear Amount"
                        from: wearRange.minValue.toFixed(2)
                        to: wearRange.maxValue.toFixed(2)
                        onValueChanged: wearRange.value = value
                    }
                    onResetRequested: root.reset("uWearAmount")
                }

                SPParameter {
                    SPSlider {
                        id: texScale
                        text: "Texture Scale"
                        from: -10
                        to: 10
                        onValueChanged: texTransform.sync()
                    }
                    onResetRequested: root.reset("texScale")
                }

                SPParameter {
                    SPButton {
                        id: ignoreTextureSizeScale
                        text: "Ignore Weapon Size Scale"
                        Layout.fillWidth: true
                        checkable: true
                        contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                    }
                    onResetRequested: root.reset("uIgnoreWeaponSizeScale")
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
                    onResetRequested: root.reset("texRotationRange")
                }

                SPParameter {
                    SPRangeSlider {
                        id: texOffsetX
                        text: "Texture Offset X"
                        from: -1
                        to: 1
                        onValueChanged: texTransform.sync()
                    }
                    onResetRequested: root.reset("texOffsetXRange")
                }

                SPParameter {
                    SPRangeSlider {
                        id: texOffsetY
                        text: "Texture Offset Y"
                        from: -1
                        to: 1
                        onValueChanged: texTransform.sync()
                    }
                    onResetRequested: root.reset("texOffsetYRange")
                }
            }

            SPGroup {
                id: colorGroup
                Layout.fillWidth: true
                text: "Color"
                visible: finishStyleBox.currentIndex != 6

                property real scopeWidth: 0.0

                Repeater {
                    model: [
                        ["Base Metal", "Base Coat"], 
                        ["Patina Tint", "Red Channel"],
                        ["Patina Wear", "Green Channel"],
                        ["Grime", "Blue Channel"]
                    ]
                    delegate: SPParameter {
                        property alias scopeWidth: colorPickerWidget.scopeWidth
                        property alias arrayColor: colorPicker.arrayColor

                        SPLabeled {
                            id: colorPickerWidget
                            text: finishStyleBox.currentIndex > 6 ? modelData[0] : modelData[1]
                            SPColorButton { 
                                id: colorPicker
                                tooltipText: parent.text + " color"
                            }
                        }
                        onResetRequested: root.reset(`uCol${index}`)
                    }

                    onItemAdded: (i, item) => {
                        colorGroup.scopeWidth = Math.max(colorGroup.scopeWidth, item.scopeWidth);
                        item.scopeWidth = Qt.binding(() => colorGroup.scopeWidth);
                        shader.parameters[`uCol${i}`].item = item;
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
                        root.reset("wearRange"); 
                        root.reset("uWearAmount");
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
                    onResetRequested: root.reset("uPearlMask")
                }

                SPParameter {
                    SPSlider {
                        id: pearlescentScale
                        text: "Pearlescent Scale"
                        from: -6
                        to: 6
                    }
                    onResetRequested: root.reset("uPearlScale")
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
                    onResetRequested: root.reset("uCustomRoughness")
                }
                    
                SPParameter {
                    visible: !useRoughnessTexture.checked
                    SPSlider {
                        id: paintRoughness
                        text: "Paint Roughness"
                        from: 0
                        to: 1
                    }
                    onResetRequested: root.reset("uPaintRoughness")
                }
            }

            SPGroup {
                id: advancedGroup
                text: "Advanced"
                toggled: false
                Layout.fillWidth: true

                Repeater {
                    model: [
                        { param: "uCustomNormal",    text: "Custom Normal Map"        },
                        { param: "uCustomMatMask", text: "Custom Material Mask"     },
                        { param: "uCustomAOTex",        text: "Custom Ambient Occlusion" }
                    ]
                    delegate: SPParameter {
                        property alias control: advancedControl

                        SPButton {
                            id: advancedControl
                            checkable: true
                            text: modelData.text
                            tooltipText: `Whether to use ${text.toLowerCase()}. Otherwise, the default weapon ${text.substring(7).toLowerCase()} is used`
                            Layout.fillWidth: true
                            contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        onResetRequested: root.reset(modelData.param)
                    }

                    onItemAdded: (i, item) => {
                        shader.parameters[model[i].param].item = item.control;
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
