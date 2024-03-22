import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "SPWidgets"

Rectangle {
    id: root
    width: parent.width
    height: parent.height

    function set_enabled(is_enabled) {
        shaderParams.enabled = is_enabled;
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillHeight: true
            implicitWidth: 34
            color: "#252525"

            ColumnLayout {
                property int padding: parent.width * 0.1
                x: padding
                y: padding
                width: parent.width - padding
                Layout.alignment: Qt.AlignTop

                SPTabButton {
                    Layout.fillWidth: true
                    checked: true
                    icon.source: "../../icons/icon_folder.png"
                    icon.width: 20
                    icon.height: 20
                    onSelected: loader.sourceComponent = redSquare
                }

                SPTabButton {
                    Layout.fillWidth: true
                    icon.source: "../../icons/icon_eye.png"
                    icon.width: 20
                    icon.height: 20
                    onSelected: loader.sourceComponent = shaderParams
                }
            }
        }

        Loader {
            id: loader
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: shaderParams
        }
    }

    Component {
        id: redSquare
        Rectangle {
            color: "red"
        }
    }

    Component {
        id: shaderParams
        Rectangle {
            color: "#818181"
            property int padding: 1
            ShaderParameters {
                x: parent.padding
                y: parent.padding
                width: loader.width - parent.padding * 2
                height: loader.height - parent.padding * 2
            }
        }
    }
}