import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

Rectangle {
    id: root
    color: "#262626"

    // 0 - closed
    // 1 - regular project
    // 2 - weapon finish
    property alias projectKind: weaponFinishSettings.projectKind

    Connections {
        target: Plugin

        function onProjectKindChanged(projectKind) {
            root.projectKind = projectKind;
            if (projectKind == 2)
                weaponFinishSettings.weaponFinish.loadParams();
        }

        function onProjectAboutToSave() {
            weaponFinishSettings.weaponFinish.syncEcon();
        }

        function onStyleReady() {
            weaponFinishSettings.weaponFinish.syncShader();
        }

        function onPluginAboutToClose() {
            weaponFinishSettings.weaponFinish.dump();
        }
    }

    ColumnLayout {
        anchors.fill: root
        anchors.margins: 10
        spacing: 10

        // header
        RowLayout {
            id: header
            Layout.fillWidth: true

            SPButton {
                text: "New Weapon Finish"
                tooltip.text: "Create new project and set it up as a Weapon Finish"
                icon.source: Plugin.asset("icons/add.png")
                icon.width: 14
                icon.height: 14
                Layout.alignment: Qt.AlignCenter

                onClicked: Plugin.initWeaponFinish(true)
            }

            SPSeparator { Layout.fillWidth: true }
        }

        // main
        Rectangle {
            id: main
            color: "#2b2b2b"
            radius: 10
            clip: true
            Layout.minimumWidth: 350
            Layout.fillWidth: true
            Layout.fillHeight: true

            WeaponFinishSettings {
                id: weaponFinishSettings
                anchors.fill: parent
                anchors.margins: 10
                enabled: root.projectKind == 2
                layer.enabled: root.projectKind !== 2
                layer.effect: GaussianBlur {
                    anchors.fill: parent
                    anchors.margins: 10
                    transparentBorder: true
                    source: weaponFinishSettings
                    radius: 4
                    samples: 8
                    deviation: 2
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "black"
                radius: parent.radius
                opacity: root.projectKind == 2 ? 0.0 : 0.2
            }

            ColumnLayout {
                id: placeholder
                anchors.fill: parent
                spacing: 20
                visible: root.projectKind != 2

                Label {
                    text: root.projectKind == 0 ? "No project is opened" : "Opened project is not Weapon Finish"
                    color: AlgStyle.text.color.normal
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter | (root.projectKind == 0 ? Qt.AlignVCenter : Qt.AlignBottom)
                }
                
                SPButton {
                    text: "Set up as Weapon Finish"
                    visible: root.projectKind == 1
                    tooltip.text: "Set up opened project as Weapon Finish"
                    icon.source: Plugin.asset("icons/settings.png")
                    icon.width: 18
                    icon.height: 18
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                    onClicked: Plugin.initWeaponFinish(false)
                }
            }
        }

        // footer
        RowLayout {
            Layout.fillWidth: true

            SPSeparator { Layout.fillWidth: true }

            Repeater {
                function fromCharCodes(arr) {
                    return arr.map(c => String.fromCharCode(c)).join("");
                }

                model: [
                    fromCharCodes([
                        60,98,62,60,97,32,104,114,101,102,61,34,104,116,116,112,115,58,47,47,103,105,116,
                        104,117,98,46,99,111,109,47,115,109,111,111,116,104,105,101,45,119,115,47,67,83,
                        50,45,83,80,45,87,111,114,107,115,104,111,112,45,84,111,111,108,115,34,62,67,83,
                        50,32,87,111,114,107,115,104,111,112,32,84,111,111,108,115,60,47,97,62,32,118
                    ]) + Plugin.getPluginVersion() + "</b>",

                    fromCharCodes([
                        124,32,67,114,101,97,116,101,100,32,98,121,32,60,97,32,104,114,101,102,61,34,104,
                        116,116,112,115,58,47,47,115,116,101,97,109,99,111,109,109,117,110,105,116,121,
                        46,99,111,109,47,105,100,47,115,109,111,111,116,104,105,101,45,119,115,47,34,62,
                        60,98,62,115,109,111,111,116,104,105,101,60,47,98,62,60,47,97,62
                    ])
                ]

                delegate: Text {
                    color: AlgStyle.text.color.normal
                    opacity: 0.75
                    textFormat: Text.RichText

                    text: qsTr(`<style>a:link{color:%1;text-decoration:none;}</style>${modelData}`).arg(hoveredLink ? "#e08ee0" : "#6dabf0")

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (parent.hoveredLink)
                                Qt.openUrlExternally(parent.linkAt(mouseX, mouseY));
                        }
                    }
                }
            }
            
            SPSeparator { Layout.fillWidth: true }
        }
    }
}
