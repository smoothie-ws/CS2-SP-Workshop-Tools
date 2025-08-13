import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

SPDialog {
    id: root
    confirm.text: "Save"
    option: Row {
        spacing: 10

        Text {
            text: `<style>a:link{color:${hoveredLink ? "#e08ee0" : "#6dabf0"};text-decoration:none;}</style><a href="https://github.com/smoothie-ws/CS2-SP-Workshop-Tools">CS2 Workshop Tools</a> ${Plugin.getPluginVersion()}`
            textFormat: Text.RichText
            color: AlgStyle.text.color.normal
            opacity: 0.75
            anchors.verticalCenter: parent.verticalCenter

            onLinkActivated: Qt.openUrlExternally(link)
        }
        
        SPButton {
            text: "Check for updates"
            anchors.verticalCenter: parent.verticalCenter

            onClicked: Plugin.checkForUpdates()
        }
    }

    QtObject {
        id: internal
        
        property string cs2Path: ""
        property bool cs2PathIsValid: false
        property var weapons: []
        property bool weaponIsValid: false

        property var weaponFinish: {
            "nmPBRRange":             { control: nmPBRRange,             prop: "range"        },
            "mPBRRange":              { control: mPBRRange,              prop: "range"        },
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
            for (const weapon of weapons)
                if (weapon.value == id || weapon.text == name) {
                    exists = true;
                    break;
                }
            weaponIsValid = id != "" && name != "" && !exists;
        }

        function addWeapon() {
            weapons.push({
                value: weaponIdInput.text.trim(),
                text: weaponNameInput.text.trim()
            });
            weaponIdInput.text = "";
            weaponNameInput.text = "";
            weaponIsValid = false;
            syncWeapons();
        }

        function remWeapon(weapon) {
            for (let i = 0; i < weapons.length; ++i) {
                const w = weapons[i];
                if (w.value == weapon) {
                    weapons.splice(i, 1);
                    syncWeapons();
                    return;
                }
            }
        }

        function syncWeapons() {
            weaponsWidgets.widgets = [];
            weaponsRepater.model = weapons;
        }

        function startDecompilation() {
            const m = [];
            for (const weapon of weapons)
                m.push(weapon.value);
            Plugin.startDecompilation(cs2Path, m);
        }
    }
    
    function getData() {
        const weapons = {};
        for (const weapon of internal.weapons)
            weapons[weapon.value] = weapon.text;
        const weapon_finish = {};
        for (const [param, component] of Object.entries(internal.weaponFinish))
            weapon_finish[param] = component.control[component.prop];
        return {
            cs2_path: internal.cs2PathIsValid ? internal.cs2Path : "",
            weapons: weapons,
            weapon_finish: weapon_finish
        }
    }

    onOpened: {
        try {
            const settings = JSON.parse(Plugin.getPluginSettings());
            if ("cs2_path" in settings)
                internal.cs2Path = settings["cs2_path"];
            if ("weapons" in settings) {
                const m = [];
                for (const [value, text] of Object.entries(settings["weapons"]))
                    m.push({value: value, text: text});
                internal.weapons = m;
            }
            if ("weapon_finish" in settings)
                for (const [param, value] of Object.entries(settings["weapon_finish"])) {
                    const component = internal.weaponFinish[param];
                    if (component !== undefined)
                        component.control[component.prop] = value;
                }
            internal.syncWeapons();
        } catch (e) {
            Plugin.error(`Failed to open Plugin Settings: ${e.toString()}`);
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

        onOpened: {
            progress = 0.0;
            log = "";
            currentState = "Decompiling";
        }

        Connections {
            target: Plugin

            function onDecompilationStarted() {
                decompilationPopup.open();
                onDecompilationUpdated(0.0, "Decompilation started")
            }

            function onDecompilationStateChanged(state) {
                decompilationPopup.currentState = state;
            }

            function onDecompilationUpdated(progress, msg) {
                decompilationPopup.progress = progress;
                decompilationPopup.log += `[${Plugin.time()}]: ${msg}\n`;
            }

            function onDecompilationFinished() {
                decompilationPopup.close();
                weaponsWidgets.refresh();
            }
        }

        content: ColumnLayout {
            width: 400
            spacing: 15

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: `${decompilationPopup.currentState}...`
                    color: AlgStyle.text.color.normal
                    Layout.fillWidth: true
                }

                Text {
                    color: AlgStyle.text.color.normal
                    text: `${parseInt(decompilationPopup.progress * 100)}%`
                }
            }

            Rectangle {
                height: 10
                radius: 15
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
                height: 100
                radius: 15
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

                    Text {
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
                            border.color: internal.cs2PathIsValid ? "transparent" : Qt.rgba(0.85, 0.15, 0.15)
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
                            
                            onClicked: fileDialog.show(internal.cs2Path)

                            SPFileDialog {
                                id: fileDialog
                                title: "Select folder"
                                selectFolder: true

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

                        Text {
                            text: "Weapons"
                            font.bold: true
                            height: 20
                            Layout.fillWidth: true
                            color: AlgStyle.text.color.normal
                        }

                        SPButton {
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
                            text: "Refresh"
                            #if QT_VERSION >= 6
                            icon.source: "./icons/cycle.png"
                            #else
                            icon.source: "./SPWidgets/icons/cycle.png"
                            #endif
                            icon.width: 15
                            icon.height: 15
                            tooltip.text: "Refresh"

                            onClicked: weaponsWidgets.refresh()
                        }
                    }

                    Rectangle {
                        radius: 15
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
                                    id: weaponsWidgets
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.rightMargin: 15

                                    property var widgets: []
                                    
                                    function refresh() {
                                        for (const widget of widgets)
                                            widget.refresh();
                                    }
                                    
                                    Repeater {
                                        id: weaponsRepater

                                        delegate: Item {
                                            id: weapon
                                            Layout.fillWidth: true
                                            height: 25

                                            readonly property string weaponId: modelData.value
                                            readonly property string weaponName: modelData.text
                                            
                                            property bool missingTextures: true

                                            function refresh() {
                                                missingTextures = !Plugin.checkWeaponTextures(weaponId);
                                            }

                                            RowLayout {
                                                spacing: 10
                                                anchors.fill: parent
                                                
                                                SPLabeled {
                                                    text: "ID:"
                                                    label.opacity: 0.5

                                                    Text {
                                                        Layout.preferredWidth: 75
                                                        text: modelData.value
                                                        color: AlgStyle.text.color.normal
                                                    }
                                                }
                                                
                                                SPLabeled {
                                                    text: "Name:"
                                                    label.opacity: 0.5

                                                    Text {
                                                        Layout.preferredWidth: 100
                                                        text: modelData.text
                                                        color: AlgStyle.text.color.normal
                                                    }
                                                }

                                                Text {
                                                    text: "!"
                                                    visible: weapon.missingTextures
                                                    font.bold: true
                                                    font.pixelSize: 16
                                                    color: Qt.rgba(0.85, 0.15, 0.15)
                                                    horizontalAlignment: Text.AlignRight
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                
                                                SPButton {
                                                    padding: 5
                                                    contentAlignment: Qt.AlignCenter
                                                    implicitWidth: 20
                                                    implicitHeight: implicitWidth
                                                    #if QT_VERSION >= 6
                                                    icon.source: "./icons/close.png"
                                                    #else
                                                    icon.source: "./SPWidgets/icons/close.png"
                                                    #endif
                                                    icon.width: implicitWidth * 0.5
                                                    icon.height: implicitHeight * 0.5
                                                    tooltip.text: "Remove"
                                                    background.color: "black"
                                                    background.opacity: hovered ? 0.5 : 0.25

                                                    onClicked: internal.remWeapon(modelData.value)
                                                }
                                            }
                                        }

                                        onItemAdded: (i, item) => {
                                            weaponsWidgets.widgets.push(item);
                                            item.refresh();
                                        }
                                    }
                                }
                            }
                        }
                    }
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

                Text {
                    text: "Default Weapon Finish Settings"
                    font.bold: true
                    height: 20
                    Layout.fillWidth: true
                    color: AlgStyle.text.color.normal
                }

                Rectangle {
                    id: weaponFinishBackground
                    radius: 15
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
                                text: "PBR Ranges"
                                label.font.bold: true
                                Layout.fillWidth: true
                                Layout.topMargin: 20
                                Layout.bottomMargin: 10
                                SPSeparator { Layout.fillWidth: true }
                            }

                            SPRangeSlider {
                                id: nmPBRRange
                                text: "Non-metallic:"
                                from: 0
                                to: 255
                                precision: 0
                                pickValue: false
                            }

                            SPRangeSlider {
                                id: mPBRRange
                                text: "Metallic:"
                                from: 0
                                to: 255
                                precision: 0
                                pickValue: false
                            }

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
                                }
                                onItemAdded: (i, item) => internal.weaponFinish[model[i].id].control = item
                            }
                        }
                    }
                }
            }
        }
    }
}
