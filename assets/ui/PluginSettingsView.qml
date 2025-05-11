import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

Rectangle {
    id: root
    color: AlgStyle.background.color.mainWindow

    property string cs2Path: ""

    property var weaponList: []

    property bool cs2PathIsValid: true
    property bool weaponIsValid: false

    onCs2PathChanged: cs2PathIsValid = cs2Path == "" ? true : CS2WT.valCs2Path(cs2Path)

    function open() {
        try {
            const settings = JSON.parse(CS2WT.getPluginSettings());

            CS2WT.info(weaponFinish.parameters["uCol0"].control == null);

            if ("cs2_path" in settings)
                cs2Path = settings["cs2_path"];
            if ("ignore_textures_are_missing" in settings)
                ignoreTexturesAreMissing.checked = settings["ignore_textures_are_missing"];
            if ("weapon_list" in settings) {
                const m = [];
                for (const [value, text] of Object.entries(settings["weapon_list"]))
                    m.push({value: value, text: text});
                weaponList = m;
            }
            if ("weapon_finish" in settings) {
                for (const [param, value] of Object.entries(settings["weapon_finish"])) {
                    const component = weaponFinish.parameters[param];
                    if (component !== undefined)
                        component.control[component.prop] = value;
                }
            }

            show();
        } catch (e) {
            CS2WT.error(`Failed to open Plugin Settings: ${e.toString()}`);
        }
    }

    function save() {
        const weapon_list = {};
        for (const weapon of weaponList)
            weapon_list[weapon.value] = weapon.text;

        const weapon_finish = {};
        for (const [param, component] of Object.entries(weaponFinish.parameters))
            weapon_finish[param] = component.control[component.prop];

        CS2WT.setPluginSettings(JSON.stringify({
            cs2_path: cs2Path,
            weapon_list: weapon_list,
            weapon_finish: weapon_finish,
            ignore_textures_are_missing: ignoreTexturesAreMissing.checked
        }));

        close();
    }

    function valWeapon() {
        const id = weaponIdInput.text.trim();
        const name = weaponNameInput.text.trim();
        let exists = false;
        for (const weapon of root.weaponList)
            if (weapon.value == id || weapon.text == name) {
                exists = true;
                break;
            }
        weaponIsValid = id != "" && name != "" && !exists;
    }

    function addWeapon() {
        root.weaponList = [{
            value: weaponIdInput.text.trim(),
            text: weaponNameInput.text.trim()
        }].concat(root.weaponList);
        weaponIdInput.text = "";
        weaponNameInput.text = "";
        weaponIsValid = false;
    }

    QtObject {
        id: weaponFinish

        property var parameters: {
            "finishStyle":            { control: finishStyleBox,         prop: "currentKey"   },
            "texScale":               { control: texScale,               prop: "value"        },
            "texRotationRange":       { control: texRotation,            prop: "range"        },
            "texOffsetXRange":        { control: texOffsetX,             prop: "range"        },
            "texOffsetYRange":        { control: texOffsetY,             prop: "range"        },
            "uIgnoreWeaponSizeScale": { control: ignoreWeaponSizeScale,  prop: "checked"      },
            "wearRange":              { control: wearRange,              prop: "range"        },
            "uUsePearlMask":          { control: usePearlescentMask,     prop: "checked"      },
            "uPearlScale":            { control: pearlescentScale,       prop: "value"        },
            "uUseCustomRough":        { control: useRoughnessTexture,    prop: "checked"      },
            "uPaintRoughness":        { control: paintRoughness,         prop: "value"        },
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
        spacing: 25
        anchors.fill: parent
        anchors.margins: 20
        
        RowLayout {
            spacing: 15
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ColumnLayout {
                spacing: 15
                Layout.minimumWidth: 325
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                ColumnLayout {
                    spacing: 15
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Label {
                        text: "CS2 Path"
                        font.bold: true
                        height: 20
                        Layout.fillWidth: true
                        color: AlgStyle.text.color.normal
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true

                        Rectangle {
                            color: "transparent"
                            radius: 13.5
                            height: 30
                            border.width: 2
                            border.color: root.cs2PathIsValid ? "transparent" : "red"
                            Layout.fillWidth: true
                            
                            SPTextInput {
                                id: cs2PathInput
                                anchors.fill: parent
                                anchors.margins: parent.border.width + 2
                                text: root.cs2Path

                                onTextEdited: root.cs2Path = text
                            }
                        }

                        SPButton {
                            id: cs2PathPicker
                            text: "Select"
                            
                            onClicked: fileDialog.open()

                            SPFileDialog {
                                id: fileDialog
                                title: "Select folder"
                                selectFolder: true
                                folder: Qt.resolvedUrl(root.cs2Path)

                                onAccepted: {
                                    cs2PathInput.text = fileUrl.toString().substring(8);
                                    cs2PathInput.textEdited();
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    spacing: 15
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Label {
                        text: "Weapons"
                        font.bold: true
                        height: 20
                        Layout.fillWidth: true
                        color: AlgStyle.text.color.normal
                    }

                    Rectangle {
                        radius: 10
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Qt.rgba(0.0, 0.0, 0.0, 0.1)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10

                            RowLayout {
                                spacing: 10
                                height: 50
                                Layout.fillWidth: true
                                
                                SPLabeled {
                                    text: "ID:"

                                    SPTextInput {
                                        id: weaponIdInput
                                        Layout.preferredWidth: 75
                                        text: modelData.value
                                        tooltip.text: "Weapon Identifier"

                                        onTextEdited: root.valWeapon()
                                    }
                                }
                                
                                SPLabeled {
                                    text: "Name:"

                                    SPTextInput {
                                        id: weaponNameInput
                                        Layout.preferredWidth: 100
                                        text: modelData.text
                                        tooltip.text: "Weapon Name"

                                        onTextEdited: root.valWeapon()
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                SPButton {
                                    text: "Add"
                                    tooltip.text: "Add new weapon"
                                    enabled: root.weaponIsValid

                                    onClicked: root.addWeapon()
                                }
                            }

                            SPSeparator { Layout.fillWidth: true }

                            ScrollView {
                                clip: true
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                ColumnLayout {
                                    id: weaponListLayout
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.rightMargin: 15

                                    Repeater {
                                        model: root.weaponList
                                        delegate: Item {
                                            Layout.fillWidth: true
                                            height: 25

                                            RowLayout {
                                                spacing: 10
                                                anchors.fill: parent

                                                SPLabeled {
                                                    text: "ID:"
                                                    label.opacity: 0.5

                                                    Label {
                                                        Layout.preferredWidth: 75
                                                        text: modelData.value
                                                        color: AlgStyle.text.color.normal
                                                    }
                                                }
                                                
                                                SPLabeled {
                                                    text: "Name:"
                                                    label.opacity: 0.5

                                                    Label {
                                                        Layout.preferredWidth: 100
                                                        text: modelData.text
                                                        color: AlgStyle.text.color.normal
                                                    }
                                                }

                                                Item { Layout.fillWidth: true }

                                                SPButton {
                                                    padding: 5
                                                    implicitWidth: 20
                                                    implicitHeight: implicitWidth
                                                    icon.source: "./SPWidgets/icons/close.png"
                                                    icon.width: implicitWidth * 0.5
                                                    icon.height: implicitHeight * 0.5
                                                    tooltip.text: "Remove"
                                                    backgroundRect.color: "black"
                                                    backgroundRect.opacity: hovered ? 0.5 : 0.25

                                                    onClicked: root.weaponList = root.weaponList.filter(w => w.value != modelData.value)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                SPButton {
                    id: ignoreTexturesAreMissing
                    text: "Ignore Textures Are Missing"
                    checkable: true
                    contentAlignment: Qt.ALignLeft | Qt.AlignVCenter
                    Layout.fillWidth: true
                }
            }

            SPSeparator {
                axis: SPSeparator.Vertical
                Layout.fillHeight: true
            }

            ColumnLayout {
                spacing: 15
                Layout.minimumWidth: 325
                Layout.fillWidth: true
                Layout.fillHeight: true

                Label {
                    text: "Default Weapon Finish Settings"
                    font.bold: true
                    height: 20
                    Layout.fillWidth: true
                    color: AlgStyle.text.color.normal
                }

                Rectangle {
                    id: weaponFinishBackground
                    radius: 10
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Qt.rgba(0.0, 0.0, 0.0, 0.1)

                    ScrollView {
                        clip: true
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 5
                        anchors.bottomMargin: 10

                        ColumnLayout {
                            width: weaponFinishBackground.width - 30

                            SPLabeled {
                                text: "Common"
                                label.font.bold: true
                                Layout.fillWidth: true
                                Layout.topMargin: 20
                                Layout.bottomMargin: 10
                                SPSeparator { Layout.fillWidth: true }
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
                            }

                            SPSlider {
                                id: texScale
                                text: "Texture Scale"
                                from: -10
                                to: 10
                                onValueChanged: texTransform.sync()
                            }

                            SPButton {
                                id: ignoreWeaponSizeScale
                                text: "Ignore Weapon Size Scale"
                                checkable: true
                                tooltip.text: "For some finishes, the automatic scale adjustment per-weapon is not desired"
                                contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                            }

                            SPLabeled {
                                text: "Texture Placement"
                                label.font.bold: true
                                Layout.fillWidth: true
                                Layout.topMargin: 20
                                Layout.bottomMargin: 10
                                SPSeparator { Layout.fillWidth: true }
                            }

                            SPRangeSlider {
                                id: texRotation
                                text: "Texture Rotation"
                                from: -360
                                to: 360
                                pickValue: false
                            }

                            SPRangeSlider {
                                id: texOffsetX
                                text: "Texture Offset X"
                                from: -1
                                to: 1
                                pickValue: false
                            }

                            SPRangeSlider {
                                id: texOffsetY
                                text: "Texture Offset Y"
                                from: -1
                                to: 1
                                pickValue: false
                            }

                            SPLabeled {
                                text: "Color"
                                label.font.bold: true
                                Layout.fillWidth: true
                                Layout.topMargin: 20
                                Layout.bottomMargin: 10
                                SPSeparator { Layout.fillWidth: true }
                            }

                            Repeater {
                                model: ["Color0", "Color1", "Color2", "Color3"]
                                delegate: SPLabeled {
                                    text: modelData

                                    property alias arrayColor: colorPicker.arrayColor

                                    SPColorButton { 
                                        id: colorPicker
                                    }
                                }

                                onItemAdded: (i, control) => {
                                    weaponFinish.parameters[`uCol${i}`].control = control;
                                    CS2WT.info(weaponFinish.parameters["uCol0"].control == null);
                                }
                            }

                            SPLabeled {
                                text: "Effects"
                                label.font.bold: true
                                Layout.fillWidth: true
                                Layout.topMargin: 20
                                Layout.bottomMargin: 10
                                SPSeparator { Layout.fillWidth: true }
                            }

                            SPRangeSlider {
                                id: wearRange
                                text: "Wear Range"
                                minValue: 0.0
                                maxValue: 1.0
                                pickValue: false
                            }

                            SPButton {
                                id: usePearlescentMask
                                text: "Custom Pearlescent Mask"
                                Layout.fillWidth: true
                                checkable: true
                                contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                            }

                            SPSlider {
                                id: pearlescentScale
                                text: "Pearlescent Scale"
                                from: -6
                                to: 6
                            }

                            SPButton {
                                id: useRoughnessTexture
                                text: "Custom Roughness Texture"
                                Layout.fillWidth: true
                                checkable: true
                                contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                            }
                                
                            SPSlider {
                                id: paintRoughness
                                text: "Paint Roughness"
                                from: 0
                                to: 1
                            }

                            SPLabeled {
                                text: "Advanced"
                                label.font.bold: true
                                Layout.fillWidth: true
                                Layout.topMargin: 20
                                Layout.bottomMargin: 10
                                SPSeparator { Layout.fillWidth: true }
                            }

                            Repeater {
                                model: [
                                    { param: "uUseCustomNormal",    text: "Custom Normal Map"        },
                                    { param: "uUseCustomMasks",     text: "Custom Material Mask"     },
                                    { param: "uUseCustomAOTex",     text: "Custom Ambient Occlusion" }
                                ]
                                delegate: SPButton {
                                    checkable: true
                                    text: modelData.text
                                    tooltip.text: `Whether to use ${text.toLowerCase()} or the weapon default one`
                                    Layout.fillWidth: true
                                    contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                                }

                                onItemAdded: (i, control) => {
                                    weaponFinish.parameters[model[i].param].control = control;
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            id: footer
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            SPButton {
                id: acceptButton
                text: "Save And Close"
                enabled: root.cs2PathIsValid
                backgroundRect.opacity: hovered ? 1.0 : 0.65
                backgroundRect.color: "white"
                label.color: "#262626"
                Layout.alignment: Qt.AlignHCenter

                onClicked: root.save()
            }

            SPButton {
                id: rejectButton
                text: "Close"
                backgroundRect.opacity: hovered ? 0.75 : 0.25
                backgroundRect.color: "black"
                label.color: AlgStyle.text.color.normal
                Layout.alignment: Qt.AlignHCenter

                onClicked: root.close()
            }
        }
    }
}
