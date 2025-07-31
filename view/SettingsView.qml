import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

SPDialog {
    id: root
    color: AlgStyle.background.color.mainWindow
    confirm.text: "Save"

    Connections {
        target: Plugin

        function onDecompilationStarted() {
            decompilationPopup.open();
            onDecompilationUpdated(0.0, "Decompilation started")
        }

        function onDecompilationStateChanged(state) {
            decompilationPopup.currentState = state;
        }

        function onDecompilationUpdated(p, msg) {
            decompilationPopup.progress = p;
            decompilationPopup.log += `\n[${Plugin.time()}]: ${msg}`;
        }

        function onDecompilationFinished() {
            decompilationPopup.close();
            weaponListWidgets.refresh();
        }
    }

    QtObject {
        id: internal
        
        property string cs2Path: ""
        property bool cs2PathIsValid: false
        property var weaponList: []
        property bool weaponIsValid: false

        property var weaponFinish: {
            "style":                  { control: styleBox,               prop: "currentKey"   },
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

        onCs2PathChanged: cs2PathIsValid = cs2Path == "" ? true : Plugin.valCs2Path(cs2Path)

        function valWeapon() {
            const id = weaponIdInput.text.trim();
            const name = weaponNameInput.text.trim();
            let exists = false;
            for (const weapon of internal.weaponList)
                if (weapon.value == id || weapon.text == name) {
                    exists = true;
                    break;
                }
            weaponIsValid = id != "" && name != "" && !exists;
        }

        function addWeapon() {
            internal.weaponList = [{
                value: weaponIdInput.text.trim(),
                text: weaponNameInput.text.trim()
            }].concat(internal.weaponList);
            weaponIdInput.text = "";
            weaponNameInput.text = "";
            weaponIsValid = false;
        }

        function startDecompilation() {
            const m = [];
            for (const weapon of internal.weaponList)
                m.push(weapon.value);
            Plugin.startDecompilation(m);
        }
    }
    
    function getData() {
        const weapon_list = {};
        for (const weapon of internal.weaponList)
            weapon_list[weapon.value] = weapon.text;
        const weapon_finish = {};
        for (const [param, component] of Object.entries(internal.weaponFinish))
            weapon_finish[param] = component.control[component.prop];
        return {
            cs2_path: internal.cs2Path,
            weapon_list: weapon_list,
            weapon_finish: weapon_finish
        }
    }

    onOpened: {
        try {
            const settings = JSON.parse(Plugin.getPluginSettings());
            if ("cs2_path" in settings)
                internal.cs2Path = settings["cs2_path"];
            if ("weapon_list" in settings) {
                const m = [];
                for (const [value, text] of Object.entries(settings["weapon_list"]))
                    m.push({value: value, text: text});
                internal.weaponList = m;
            }
            if ("weapon_finish" in settings)
                for (const [param, value] of Object.entries(settings["weapon_finish"])) {
                    const component = internal.weaponFinish[param];
                    if (component !== undefined)
                        component.control[component.prop] = value;
                }
            weaponListWidgets.refresh();
        } catch (e) {
            Plugin.error(`Failed to open Plugin Settings: ${e.toString()}`);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            spacing: 15
            
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
                            border.color: internal.cs2PathIsValid ? "transparent" : "red"
                            Layout.fillWidth: true
                            
                            SPTextInput {
                                id: cs2PathInput
                                anchors.fill: parent
                                anchors.margins: parent.border.width + 2
                                text: internal.cs2Path
                                tooltip.text: "CS2 path is used to sync .econitem files and fast texture exporting"

                                onTextEdited: internal.cs2Path = text
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
                                folder: Qt.resolvedUrl(internal.cs2Path)

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

                    RowLayout {
                        height: 20
                        Layout.fillWidth: true

                        Label {
                            text: "Weapons"
                            font.bold: true
                            height: 20
                            Layout.fillWidth: true
                            color: AlgStyle.text.color.normal
                        }

                        SPButton {
                            id: decompileButton
                            text: "Decompile"
                            enabled: internal.cs2PathIsValid
                            icon.source: Plugin.asset("icons/export.png")
                            icon.width: 15
                            icon.height: 15
                            tooltip.text: "Decompile all the missing weapon textures from the list below"
                            background.color: hovered ? Qt.rgba(0, 0, 0, 0.75) : Qt.rgba(0, 0, 0, 0.25)

                            onClicked: internal.startDecompilation()
                        }

                        SPButton {
                            id: refreshButton
                            icon.source: "./SPWidgets/icons/cycle.png"
                            icon.width: 15
                            icon.height: 15
                            tooltip.text: "Refresh"

                            onClicked: weaponListWidgets.refresh()
                        }
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
                                        tooltip.text: "Weapon Identifier"

                                        onTextEdited: internal.valWeapon()
                                    }
                                }
                                
                                SPLabeled {
                                    text: "Name:"

                                    SPTextInput {
                                        id: weaponNameInput
                                        Layout.preferredWidth: 100
                                        tooltip.text: "Weapon Name"

                                        onTextEdited: internal.valWeapon()
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                SPButton {
                                    text: "Add"
                                    tooltip.text: "Add new weapon"
                                    enabled: internal.weaponIsValid

                                    onClicked: internal.addWeapon()
                                }
                            }

                            SPSeparator { Layout.fillWidth: true }

                            ScrollView {
                                clip: true
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                ColumnLayout {
                                    id: weaponListWidgets
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.rightMargin: 15

                                    property var widgets: []
                                    
                                    function refresh() {
                                        for (const widget of widgets)
                                            widget.missingTextures = !Plugin.checkWeaponTextures(widget.weaponId);
                                    }
                                    
                                    Component.onCompleted: refresh()
                                    
                                    Repeater {
                                        model: internal.weaponList

                                        delegate: Item {
                                            id: weapon
                                            Layout.fillWidth: true
                                            height: 25

                                            readonly property string weaponId: modelData.value
                                            readonly property string weaponName: modelData.text
                                            
                                            property bool missingTextures: true

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

                                                SPIcon {
                                                    Layout.fillWidth: true
                                                    height: parent.height - 10
                                                    icon.source: "./SPWidgets/icons/warning.png"
                                                    icon.opacity: 0.0
                                                    overlay.color: Qt.rgba(0.85, 0.15, 0.15)
                                                    overlay.opacity: weapon.missingTextures ? 0.85 : 0.0
                                                    tooltip.text: weapon.missingTextures ? "Missing base textures for this weapon!" : ""
                                                }
                                                
                                                SPButton {
                                                    padding: 5
                                                    implicitWidth: 20
                                                    implicitHeight: implicitWidth
                                                    icon.source: "./SPWidgets/icons/close.png"
                                                    icon.width: implicitWidth * 0.5
                                                    icon.height: implicitHeight * 0.5
                                                    tooltip.text: "Remove"
                                                    background.color: "black"
                                                    background.opacity: hovered ? 0.5 : 0.25

                                                    onClicked: internal.weaponList = internal.weaponList.filter(w => w.value != modelData.value)
                                                }
                                            }
                                        }

                                        onItemAdded: (i, item) => {
                                            weaponListWidgets.widgets.push(item);
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
                            }

                            SPSlider {
                                id: texScale
                                text: "Texture Scale"
                                from: -10
                                to: 10
                            }

                            SPButton {
                                id: ignoreWeaponSizeScale
                                text: "Ignore Weapon Size Scale"
                                checkable: true
                                tooltip.text: "For some finishes, the automatic scale adjustment per-weapon is not desired"
                                Layout.fillWidth: true
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
                                model: 4
                                delegate: SPLabeled {
                                    text: `Color${index}`
                                    Layout.fillWidth: true

                                    property alias arrayColor: colorPicker.arrayColor

                                    SPColorButton { 
                                        id: colorPicker
                                        Layout.fillWidth: true
                                    }
                                }
                                onItemAdded: (i, item) => internal.weaponFinish[`uCol${i}`].control = item
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
                                    { id: "uUseCustomNormal", text: "Custom Normal Map" },
                                    { id: "uUseCustomMasks", text: "Custom Material Mask" },
                                    { id: "uUseCustomAOTex", text: "Custom Ambient Occlusion" }
                                ]
                                delegate: SPButton {
                                    checkable: true
                                    text: modelData.text
                                    tooltip.text: `Whether to use ${modelData.text.toLowerCase()} or the weapon default one`
                                    Layout.fillWidth: true
                                    contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                                }
                                onItemAdded: (i, item) => internal.weaponFinish[model[i].id].control = item
                            }
                        }
                    }
                }
            }
        }
    }
    
    SPPopup {
        id: decompilationPopup
        anchors.centerIn: parent
        title: "Decompiling"
        ignorable: false
        closable: false
        acceptable: false
        cancelable: false

        property real progress: 0.0
        property string log: ""
        property string currentState: "Decompiling"

        content: ColumnLayout {
            width: 400
            spacing: 15

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: `${decompilationPopup.currentState}...`
                    color: AlgStyle.text.color.normal
                    Layout.fillWidth: true
                }

                Label {
                    color: AlgStyle.text.color.normal
                    text: `${parseInt(decompilationPopup.progress * 100)}%`
                }
            }

            Rectangle {
                height: 10
                radius: 5
                Layout.fillWidth: true
                color: Qt.rgba(0.0, 0.0, 0.0, 0.25)

                Rectangle {
                    height: parent.height
                    radius: parent.radius
                    width: Math.max(height, decompilationPopup.progress * parent.width)
                    color: AlgStyle.text.color.normal
                }
            }
            
            Rectangle {
                height: 50
                radius: 5
                Layout.fillWidth: true
                color: Qt.rgba(0.0, 0.0, 0.0, 0.25)

                ScrollView {
                    anchors.fill: parent
                    clip: true

                    Text {
                        text: decompilationPopup.log
                        color: AlgStyle.text.color.normal
                        anchors.fill: parent
                        anchors.margins: 10
                    }
                }
            }
        }
    }
}
