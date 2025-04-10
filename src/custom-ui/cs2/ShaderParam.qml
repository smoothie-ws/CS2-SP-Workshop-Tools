import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import Painter 1.0
import AlgWidgets 2.0
import "../cs2wt.mjs" as CS2WT

Item {
    id: root
    implicitHeight: loader.height

    default property alias children: loader.sourceComponent
    property alias control: loader.item
    property alias text: label.text
    property string parameter: ""
    property string key: ""
    property var defaultValue: null
    property real spacing: 10
    property real __separatorX: label.text !== "" ? label.width + spacing : 0
    property real availableWidth: width - (__separatorX + (resettable ? resetButton.width : 0))
    property alias resettable: resetButton.visible

    function connectShaderParameter(shaderId) {
        if (loader.status == Loader.Ready && root.key !== "" && root.parameter !== "") {
            CS2WT.Shader.connect(root.control, root.key, alg.shaders.parameter(shaderId, root.parameter));
        }
    }

    function update(defaultValue) {
        root.defaultValue = defaultValue;
        if (loader.status == Loader.Ready && root.key !== "") {
            loader.item[root.key] = defaultValue;
        }
    }

    AlgLabel { 
        id: label
        y: loader.height / 2 - height / 2 
    }

    Loader {
        id: loader
        x: root.__separatorX
        width: root.availableWidth - spacing
    }

    SPButton {
        id: resetButton
        Layout.alignment: Qt.AlignRight
        x: root.width - width
        y: loader.height / 2 - height / 2
        enabled: root.defaultValue != loader.item[key]
        icon.source: "./icons/icon_cycle.png"
        icon.width: 14
        icon.height: 14
        background: null
        onClicked: { if (root.defaultValue !== null) loader.item[root.key] = root.defaultValue }
    }
}
