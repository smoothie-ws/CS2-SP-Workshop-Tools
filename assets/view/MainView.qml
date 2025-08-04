import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
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
            if (projectKind == 2) {
                weaponFinishSettings.weaponFinish.loadParams();
                const component = weaponFinishSettings.weaponFinish.parameters["econitem"];
                const p = component.control[component.prop];
                const f = p.substring(Math.max(p.lastIndexOf('/'), p.lastIndexOf('\\')) + 1);
                finishName.text = f.substring(0, f.lastIndexOf(".")).toUpperCase();
            }
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

            Text {
                id: finishName
                visible: root.projectKind == 2
                Layout.maximumWidth: 150
                elide: Text.ElideRight
                color: AlgStyle.text.color.normal
                font.bold: true
            }

            SPButton {
                text: "Set up as Weapon Finish"
                visible: root.projectKind == 1
                tooltip.text: "Set up opened project as Weapon Finish"
                icon.source: Plugin.asset("icons/settings.png")
                icon.width: 18
                icon.height: 18
                Layout.alignment: Qt.AlignCenter

                onClicked: Plugin.initWeaponFinish(false)
            }
            
            SPSeparator { Layout.fillWidth: true }

            SPButton {
                text: "New Weapon Finish"
                tooltip.text: "Create new project and set it up as a Weapon Finish"
                icon.source: Plugin.asset("icons/add.png")
                icon.width: 14
                icon.height: 14
                Layout.alignment: Qt.AlignCenter

                onClicked: Plugin.initWeaponFinish(true)
            }
        }

        // main
        WeaponFinishSettings {
            id: weaponFinishSettings
            Layout.minimumWidth: 350
            Layout.fillWidth: true
            Layout.fillHeight: true
            enabled: root.projectKind == 2
            opacity: enabled ? 1.0 : 0.5
        }
    }
}
