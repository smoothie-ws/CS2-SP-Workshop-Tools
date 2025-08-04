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
            } else
                finishName.text = "No Weapon Finish opened";
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
                text: "No Weapon Finish opened"
                Layout.maximumWidth: 150
                elide: Text.ElideRight
                color: AlgStyle.text.color.normal
                font.bold: true
            }

            SPSeparator { Layout.fillWidth: true }

            SPButton {
                text: root.projectKind == 1 ? "Set up as Weapon Finish" : "New Weapon Finish"
                tooltip.text: root.projectKind == 1 ? "Set up opened project as Weapon Finish" : "Create new project and set it up as a Weapon Finish"
                icon.source: root.projectKind == 1 ? Plugin.asset("icons/settings.png") : Plugin.asset("icons/add.png")
                icon.width: 18
                icon.height: 18
                Layout.alignment: Qt.AlignCenter

                onClicked: Plugin.initWeaponFinish(root.projectKind != 1)
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
