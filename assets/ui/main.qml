import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import AlgWidgets.Style 2.0
import "SPWidgets"

Rectangle {
    id: root
    width: parent.width
    height: parent.height

    function set_enabled(is_enabled) {
        loader.enabled = is_enabled;
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillHeight: true
            implicitWidth: 38
            color: "#212121"

            ColumnLayout {
                property int padding: parent.width * 0.1
                x: padding
                y: padding
                width: parent.width - padding
                Layout.alignment: Qt.AlignTop

                SPTabButton {
                    backgroundColor: AlgStyle.background.color.mainWindow
                    Layout.fillWidth: true
                    checked: true
                    icon.source: "../icons/icon_folder.png"
                    icon.width: 22
                    icon.height: 22
                    onSelected: loader.sourceComponent = projectManager
                }

                SPTabButton {
                    backgroundColor: AlgStyle.background.color.mainWindow
                    Layout.fillWidth: true
                    icon.source: "../icons/icon_eye.png"
                    icon.width: 22
                    icon.height: 22
                    onSelected: loader.sourceComponent = shaderParams
                }
            }
        }

        Loader {
            id: loader
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: projectManager
        }
    }

    Component {
        id: projectManager
        ProjectManager {

        }
    }

    Component {
        id: shaderParams
        ShaderParameters {
            
        }
    }
}