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
    // 1 - regular substance painter project
    // 2 - weapon finish project
    property int projectKind: 0

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
                model: [
                    `<b><a href="https://github.com/smoothie-ws/CS2-SP-Workshop-Tools">CS2 Workshop Tools</a> v${Plugin.getPluginVersion()}</b>`,
                    "| Created by <a href=\"https://steamcommunity.com/id/smoothie-ws/\"><b>smoothie</b></a>"
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
