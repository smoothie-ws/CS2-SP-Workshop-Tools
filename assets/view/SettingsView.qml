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

        onCs2PathChanged: cs2PathIsValid = cs2Path == "" ? true : Plugin.valCs2Path(cs2Path)

        function valWeapon() {
            const id = weaponIdInput.text.trim();
            const name = weaponNameInput.text.trim();
            const uv_scale = weaponUVScaleInput.text.trim();
            for (const [wid, w] of Object.entries(weapons))
                if (wid == id || w.name == name) {
                    weaponIsValid = false;
                    return;
                }
            weaponIsValid = id != "" && name != "" && length != "" && uv_scale != "";
        }

        function addWeapon() {
            weapons[weaponIdInput.text.trim()] = {
                name: weaponNameInput.text.trim(),
                uv_scale: weaponUVScaleInput.value,
            }
            weaponIdInput.text = "";
            weaponNameInput.text = "";
            weaponUVScaleInput.text = "";
            weaponIsValid = false;
            syncWeapons();
        }

        function remWeapon(weapon) {
            delete weapons[weapon];
            syncWeapons();
        }

        function syncWeapons() {
            weaponsWidgets.widgets = [];

            const weaponModel = [];
            for (const [wid, w] of Object.entries(weapons))
                weaponModel.push({
                    id: wid,
                    name: w.name,
                    length: w.length,
                    uv_scale: w.uv_scale
                });
            weaponsRepater.model = weaponModel;
        }

        function startDecompilation() {
            Plugin.startDecompilation(cs2Path, Object.keys(weapons));
        }
    }
    
    function getData() {
        return {
            cs2_path: internal.cs2PathIsValid ? internal.cs2Path : "",
            weapons: internal.weapons
        }
    }

    onOpened: {
        const settings = JSON.parse(Plugin.getPluginSettings());
        if ("cs2_path" in settings)
            internal.cs2Path = settings["cs2_path"];
        if ("weapons" in settings) 
            internal.weapons = settings["weapons"];
        internal.syncWeapons();
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
                    tooltip.text: "Refresh"
                    implicitWidth: 25
                    implicitHeight: implicitWidth
                    contentAlignment: Qt.AlignCenter
                    #if QT_VERSION >= 6
                    icon.source: "./icons/cycle.png"
                    #else
                    icon.source: "./SPWidgets/icons/cycle.png"
                    #endif
                    icon.width: implicitWidth * 0.5
                    icon.height: implicitHeight * 0.5

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
                        opacity: 0.5
                        Layout.leftMargin: 5
                        Layout.fillWidth: true
                        
                        SPLabeled {
                            text: "ID"
                            Layout.preferredWidth: 75
                        }
                        
                        SPLabeled {
                            text: "Name"
                            Layout.preferredWidth: 100
                        }

                        SPLabeled {
                            text: "UV Scale"
                            Layout.preferredWidth: 50
                        }

                        Item { Layout.fillWidth: true }
                    }

                    SPSeparator { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 10
                        height: 50
                        Layout.fillWidth: true
                        
                        SPTextInput {
                            id: weaponIdInput
                            Layout.preferredWidth: 75
                            tooltip.text: "Weapon Identifier"

                            onTextEdited: internal.valWeapon()
                        }

                        SPTextInput {
                            id: weaponNameInput
                            Layout.preferredWidth: 100
                            tooltip.text: "Weapon Name"

                            onTextEdited: internal.valWeapon()
                        }

                        SPTextInput {
                            id: weaponUVScaleInput
                            Layout.preferredWidth: 50
                            tooltip.text: "Weapon UV Scale"
                            validator: SPRegExprValidator { expr: /^-?[0-9]*\.?[0-9]*$/ }

                            readonly property real value: parseFloat(text)
                            
                            onTextEdited: internal.valWeapon()
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
                        Layout.leftMargin: 5
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
                                    
                                    property bool missingTextures: true

                                    function refresh() {
                                        missingTextures = !Plugin.checkWeaponTextures(modelData.id);
                                    }

                                    RowLayout {
                                        spacing: 10
                                        anchors.fill: parent
                                        
                                        Text {
                                            Layout.preferredWidth: 75
                                            text: modelData.id
                                            color: AlgStyle.text.color.normal
                                        }

                                        Text {
                                            Layout.preferredWidth: 100
                                            text: modelData.name
                                            color: AlgStyle.text.color.normal
                                        }

                                        Text {
                                            Layout.preferredWidth: 50
                                            text: modelData.uv_scale.toFixed(3)
                                            color: AlgStyle.text.color.normal
                                        }

                                        Item { Layout.fillWidth: true }

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

                                            onClicked: internal.remWeapon(modelData.id)
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
}
